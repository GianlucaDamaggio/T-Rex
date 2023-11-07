# HD_dittograph

**HD_dittograph** is a [Nextflow](https://www.nextflow.io) pipeline for evaluating somatic instability of CAG repeat in HTT gene, exploiting Nanopore amplicon sequencing of time course (self-renewal or differentiation) experiments. The pipeline performs alignment of reads with [Minimap2](https://github.com/lh3/minimap2) and checks for the presence of a cell line-specific barcode with [Blastn](https://blast.ncbi.nlm.nih.gov/Blast.cgi?PROGRAM=blastn&PAGE_TYPE=BlastSearch&LINK_LOC=blasthome). Reads aligning to the target region and carrying the desired barcode are then subjected to CAG sizing with [Straglr](https://github.com/bcgsc/straglr). The adjusted Instability Index is then evaluated with a custom script for each combination of genotype, clone, replicate and time point.

## Getting started

**Prerequisites**

* [Nextflow](https://nf-co.re/usage/installation)
* [Docker](https://docs.docker.com/engine/install/) or [Singularity](https://sylabs.io/guides/3.0/user-guide/installation.html)                                                                                  
                                                                                   
**Installation**

```
git clone https://github.com/GianlucaDamaggio/HD_dittograph.git
cd HD_dittograph
chmod 755 *
```

## Overview

<p align="center">
  <img src="Figures/Rainbowdash_pipeline_flowchart.png" alt="drawing" width="900" title="Rainbowdash_pipeline_flowchart">
</p>

## Usage

The Rainbowdash pipeline requires you to open rainbowdash.conf configuration file and set the desired options. Then, you can run the pipeline using either docker or singularity environments just specifying a value for the -profile variable.

```
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
