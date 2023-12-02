#!/usr/bin/env nextflow
/*
========================================================================================
                        GianlucaDamaggio/Rainbowdash
========================================================================================
 GianlucaDamaggio/Rainbowdash analysis pipeline.
 #### Homepage / Documentation
 https://github.com/GianlucaDamaggio/Rainbowdash
----------------------------------------------------------------------------------------
*/
def helpMessage() {
        log.info"""
    Usage:
    nextflow -c rainbowdash.conf run rainbowdash.nf --sampleSheet = "/path/to/sampleSheet.tsv" --scriptsDir = "/path/to/scripts_dir" --resultsDir = "/path/to/resultsDir" -profile docker

    Mandatory argument:
    -profile                                                              Configuration profile to use. Available: docker, singularity
    Other mandatory arguments which may be specified in the rainbowdash.conf file
    sampleSheet                                                           Sample sheet in tsv format containing Clone, PCR, Day, Replicate, fastqDir and barcodeFile
    scriptsDir                                                            Directory containing scripts for Instability computation
    resultsDir                                                            Path to a folder where results are stored
    referenceFile                                                         Path to fasta reference file
    bedFile                                                               Path to bed file for Straglr STR sizing
    dayNorm                                                               Day in sample sheet used for adjusting the Instability Index
    minAlLength                                                           Minimum barcode alignment length
    queryCovThr                                                           Minimum query coverage for aligned reads
    barcodeFilter                                                         Flag for filtering reads based on barcode identification
    countFormat                                                           Format for reporting STR length, choose between 'nCAG' or 'length'
    threshold                                                             threshold for noise filtering in Instability Index
    numBamsChunk                                                          Number of bam files to be merged into a single bam file
    maxF                                                                  Maximum number of jobs for the same process that can be submitted in parallel
    """.stripIndent()
}

//Show help message
if (params.help) {
    helpMessage()
    exit 0
}

//Read sample sheet, containing sample name, path to fastq file and barcode
Channel
    .fromPath( params.sampleSheet )
    .splitCsv(header: true, sep:'\t')
    .map{ row-> tuple(row.Clone, row.PCR, row.Day, row.Replicate, row.fastqDir, row.barcodeFile) }
    .set{sampleSheet_analysis}

//Barcode filtering
process barcodeFiltering {
    maxForks params.maxF
    input:
    tuple val(Clone), val(PCR), val(Day), val(Replicate), val(fastqDir), val(barcodeFile)

    output:
    tuple val(Clone), val(PCR), val(Day), val(Replicate), val(fastqDir), val(barcodeFile)

    script:
    if(params.barcodeFiltering)
    """
    full_sample_name=${Clone}\"_\"${PCR}\"_\"${Day}\"_\"${Replicate}
    mkdir -p ${params.resultsDir}/\$full_sample_name/
    mkdir -p ${params.resultsDir}/\$full_sample_name/barcodeFiltering

    #convert fastq to fasta
    zless ${fastqDir}/*.fastq* | awk \'{if(NR%4==1) {printf(\">%s\\n",substr(\$0,2));} else if(NR%4==2) print;}\' > ${params.resultsDir}/\$full_sample_name/barcodeFiltering/\$full_sample_name.fasta

    #blast read VS barcode
    /opt/conda/envs/straglr/bin/blastn -task blastn-short -query ${params.resultsDir}/\$full_sample_name/barcodeFiltering/\$full_sample_name.fasta -subject ${barcodeFile} -outfmt 6 > ${params.resultsDir}/\$full_sample_name/barcodeFiltering/\$full_sample_name\"_blastn.txt\"
    """
    else
    """
    echo "Skipped"
    """
}

//Alignment
process alignment {
    maxForks params.maxF
    input:
    tuple val(Clone), val(PCR), val(Day), val(Replicate), val(fastqDir), val(barcodeFile)
        
    output:
    tuple val(Clone), val(PCR), val(Day), val(Replicate), val(fastqDir), val(barcodeFile)

    script:
    if(params.alignment)
    """
    full_sample_name=${Clone}\"_\"${PCR}\"_\"${Day}\"_\"${Replicate}
    mkdir -p ${params.resultsDir}/\$full_sample_name/alignment
    
    #align reads to fasta reference
    /workdir/ont-guppy-cpu/bin/guppy_aligner -i ${fastqDir} -s ${params.resultsDir}/\$full_sample_name/alignment/ --bam_out --align_ref ${params.referenceFile} -t ${task.cpus}

    #create file with path to bam files
    find ${params.resultsDir}/\$full_sample_name/alignment/ -name \"*.bam\" > ${params.resultsDir}/\$full_sample_name/alignment/bam_list.txt

    #merge bam files in groups
    split -l ${params.numBamsChunk} ${params.resultsDir}/\$full_sample_name/alignment/bam_list.txt ${params.resultsDir}/\$full_sample_name/alignment/split_

    ls ${params.resultsDir}/\$full_sample_name/alignment/split_* | while read line ; do samtools merge -f -@ ${task.cpus} \${line}.multi.bam -b \$line ; samtools index \${line}.multi.bam; done

    tmpBams=\$(find ${params.resultsDir}/\$full_sample_name/alignment/ | grep \"\\.bam\" | grep -v \"split\")
    rm \$tmpBams
    """
    else
    """
    echo "Skipped"
    """
}

//STR Sizing

process STRSizing {
    maxForks params.maxF
    input:
    tuple val(Clone), val(PCR), val(Day), val(Replicate), val(fastqDir), val(barcodeFile)
        
    output:
    val Clone

    script:
    if(params.STRSizing)
    """
    export PATH=/opt/conda/envs/straglr/bin/:\$PATH
    full_sample_name=${Clone}\"_\"${PCR}\"_\"${Day}\"_\"${Replicate}
    mkdir -p ${params.resultsDir}/\$full_sample_name/STRSizing

    #Run Straglr for STR sizing on each bam
    cd ${params.resultsDir}/\$full_sample_name/STRSizing
    bamDir=${params.resultsDir}\"/\"${Clone}\"_\"${PCR}\"_\"${Day}\"_\"${Replicate}\"/alignment\"

    for bamFile in \$( find \$bamDir -name \"*multi.bam\"); do
      bamFileName=\$(echo \$(basename \$bamFile) | sed \'s/\\.bam//\');
      /opt/conda/envs/straglr/bin/python /workdir/straglr-1.2.0/straglr.py \
      \$bamFile \
      ${params.referenceFile} \
      \$bamFileName \
      --loci ${params.bedFile} \
      --nprocs ${task.cpus}
    done

    cp ${params.resultsDir}/\$full_sample_name/STRSizing/split_aa.multi.tsv \
    ${params.resultsDir}/\$full_sample_name/STRSizing/\$full_sample_name.tsv

    ls ${params.resultsDir}/\$full_sample_name/STRSizing/ | grep \"split\" | grep \"tsv\" | grep -v \"_aa.\" | \
    while read tsv; do
      cat \$tsv | grep -v \"#\" >> ${params.resultsDir}/\$full_sample_name/STRSizing/\$full_sample_name.tsv
    done

    """
    else
    """
    echo "Skipped"
    """
}


// Instability Computation
process instabilityComputation {
  input:
    val flagSTRSizing
    val flagBarcodeFiltering 
        
    output:

    script:
    if(params.instabilityComputation)
    """
    mkdir -p ${params.resultsDir}/instabilityComputation
    /opt/conda/bin/Rscript ${params.scriptsDir}/Calculate_II.R type=${params.countFormat} filter=${params.barcodeFilter} queryCovThr=${params.queryCovThr} targetChr=${params.targetChr} dayNorm=${params.dayNorm} resultsDir=${params.resultsDir} sampleSheet_file=${params.sampleSheet} threshold=\"${params.threshold}\" minAlLength=${params.minAlLength}
    """
    else
    """
    echo "Skipped"
    """
}

workflow {
    barcodeFiltering(sampleSheet_analysis)
    alignment(sampleSheet_analysis)
    STRSizing(alignment.out)
    instabilityComputation(STRSizing.out.collect(), barcodeFiltering.out.collect())
}
