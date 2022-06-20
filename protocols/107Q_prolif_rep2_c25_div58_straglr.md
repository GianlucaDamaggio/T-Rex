# 107Q_prolif_rep2_c25_div58

## STRAGLR

### WHOLE GENOME alignment

Add to json file for alignment vs the whole-genome.

```json
"constraints": [["hostname", "LIKE", "hpc-gpu-1-[2,4]-[1-2].recas.ba.infn.it"]],
```

C25_div58

```bash
./submit_chronos_gianluca guppy-gianluca-job-align-WG_c25_div58.json
```

### FASTQ2FASTA

```bash
mkdir /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q_prolif_rep2_c25_div58/20211124_1325_MN29119_AHI905_191b6139/analysis/fastq2fasta

for n in c25_div58 ; do zcat /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q_prolif_rep2_c25_div58/20211124_1325_MN29119_AHI905_191b6139/analysis/basecalling/pass/*.fastq.gz | awk '{if(NR%4==1) {printf(">%s\n",substr($0,2));} else if(NR%4==2) print;}' > /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q_prolif_rep2_c25_div58/20211124_1325_MN29119_AHI905_191b6139/analysis/fastq2fasta/${n}_allreads.fasta ; done
```

### BLASTN 107Qbarcode

```bash
source ~/.bashrc

mkdir /lustrehome/gianluca/straglr/blastn/AC2021_NANOPORE_PCR10/107Q_prolif_rep2_c25_div58

for n in c25_div58 ; do blastn -task blastn-short -query /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q_prolif_rep2_c25_div58/20211124_1325_MN29119_AHI905_191b6139/analysis/fastq2fasta/${n}_allreads.fasta -subject /lustrehome/gianluca/straglr/barcode_fasta/barcode107Q.fa -outfmt 6 > /lustrehome/gianluca/straglr/blastn/AC2021_NANOPORE_PCR10/107Q_prolif_rep2_c25_div58/${n}_blastn_107Q.txt ; done
```

### *straglr*, for CAG count

CL Merge 100 bam:

```bash
for n in c25_div58 ; do bash bash-merge_100_BAM.sh /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q_prolif_rep2_c25_div58/20211124_1325_MN29119_AHI905_191b6139/analysis/alignment/${n}_WG ; done
```

CL Job submission:

```bash
mkdir /lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/107Q_prolif_rep2_c25_div58

cd /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q_prolif_rep2_c25_div58/20211124_1325_MN29119_AHI905_191b6139/analysis/alignment/c25_div58_WG

for n in c25_div58 ; do ls ${n}_WG/*.multi.bam | while IFS="$(printf '/')" read -r f1 f2 ; do echo condor_submit -name ettore \
-a "out_dir=/lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/107Q_prolif_rep2_c25_div58/" \
-a "bam=/lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q_prolif_rep2_c25_div58/20211124_1325_MN29119_AHI905_191b6139/analysis/alignment/${n}_WG/${f2}" \
-a "ref=/lustre/home/enza/cattaneo/data/Methylation-RUES2-FLG/RUES2-20CAG/reference/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna" \
-a "out_prefix=${n}_${f2}" \
-a "bed=/lustrehome/gianluca/test_straglr/CAG.bed" \
-a "file=${f2}" \
-a "barcode=${n}" \
/lustrehome/gianluca/straglr/jobs/condor-straglr_exp.job ; done ; done | less -S
```

## Merge multiple *straglr* output

```bash
cd /lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/107Q_prolif_rep2_c25_div58

for n in c25_div58 ; do ls ${n}_split*.tsv | grep aa | while read file ; do cat ${file} > ${n}.tsv; done ; done

for n in c25_div58 ; do ls ${n}_split*.tsv | grep -v aa | while read file ; do cat ${file} | grep -v "#" >> ${n}.tsv; done ; done

#cancel all .ok files created for job-control
rm *.ok
```

## Create folder to save on local computer with blastn+straglr+alignment_summary

```bash
cd /lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/107Q_prolif_rep2_c25_div58

for n in c25_div58 ; do mkdir ${n} ; done

ALIGNMENT=/lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q_prolif_rep2_c25_div58/20211124_1325_MN29119_AHI905_191b6139/analysis/alignment

BLASTN=/lustrehome/gianluca/straglr/blastn/AC2021_NANOPORE_PCR10/107Q_prolif_rep2_c25_div58

STRAGLR=/lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/107Q_prolif_rep2_c25_div58

for n in c25_div58 ; do cp ${ALIGNMENT}/${n}_WG/alignment_summary.txt ${STRAGLR}/${n}/ &&  cp ${BLASTN}/${n}* ${STRAGLR}/${n}/ &&  cp ${STRAGLR}/${n}.tsv ${STRAGLR}/${n}/ ; done 
```

## Rsync to local computer

```bash
mkdir /Users/gianlucadamaggio/projects/cattaneo/straglr/AC2021_NANOPORE_PCR10/107Q_prolif_rep2_c25_div58/

for n in c25_div58 ; do rsync -avh --progress gianluca@ui02.recas.ba.infn.it:/lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/107Q_prolif_rep2_c25_div58/${n} /Users/gianlucadamaggio/projects/cattaneo/straglr/AC2021_NANOPORE_PCR10/107Q_prolif_rep2_c25_div58/ ; done
```

## Re-do Straglr - version CAG_v4.bed

```bash
mkdir /lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/107Q_prolif_rep2_c25_div58

cd /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q_prolif_rep2_c25_div58/20211124_1325_MN29119_AHI905_191b6139/analysis/alignment/

for n in c25_div58 ; do ls ${n}_WG/*.multi.bam | while IFS="$(printf '/')" read -r f1 f2 ; do echo condor_submit -name ettore \
-a "out_dir=/lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/107Q_prolif_rep2_c25_div58/" \
-a "bam=/lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q_prolif_rep2_c25_div58/20211124_1325_MN29119_AHI905_191b6139/analysis/alignment/${n}_WG/${f2}" \
-a "ref=/lustre/home/enza/cattaneo/data/Methylation-RUES2-FLG/RUES2-20CAG/reference/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna" \
-a "out_prefix=${n}_v4_${f2}" \
-a "bed=/lustrehome/gianluca/test_straglr/CAG_v4.bed" \
-a "file=${f2}" \
-a "barcode=${n}" \
/lustrehome/gianluca/straglr/jobs/condor-straglr_exp.job ; done ; done | less -S
```

### Merge multiple *straglr* output - version CAG_v4.bed

```bash
cd /lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/107Q_prolif_rep2_c25_div58

for n in c25_div58; do ls ${n}_v4_split*.tsv | grep aa | while read file ; do cat ${file} > ${n}_v4.tsv; done ; done

for n in c25_div58; do ls ${n}_v4_split*.tsv | grep -v aa | while read file ; do cat ${file} | grep -v "#" >> ${n}_v4.tsv; done ; done

#cancel all .ok files created for job-control
rm *.ok
```

### Create folder to save on local computer with blastn+straglr+alignment_summary - version CAG_v4.bed

```bash
cd /lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/107Q_prolif_rep2_c25_div58

for n in c25_div58; do mkdir ${n}_v4 ; done

STRAGLR=/lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/107Q_prolif_rep2_c25_div58

for n in c25_div58; do cp ${STRAGLR}/${n}_v4.tsv ${STRAGLR}/${n}_v4/ ; done 
```

### Rsync to local computer - version CAG_v4.bed

```bash
mkdir /Users/gianlucadamaggio/projects/cattaneo/straglr/AC2021_NANOPORE_PCR10/107Q_prolif_rep2_c25_div58/

for n in c25_div58; do rsync -avh --progress gianluca@ui02.recas.ba.infn.it:/lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/107Q_prolif_rep2_c25_div58/${n}_v4 /Users/gianlucadamaggio/projects/cattaneo/straglr/AC2021_NANOPORE_PCR10/107Q_prolif_rep2_c25_div58/ ; done
```
-->