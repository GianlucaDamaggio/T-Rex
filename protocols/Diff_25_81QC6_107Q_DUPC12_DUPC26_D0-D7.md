# AC2021_NANOPORE_PCR10 Diff_25_81QC6_107Q_DUPC12_DUPC26_D0-D7

## Basecalling

```bash
cd /lustrehome/gianluca/strique/jobs/AC2021_NANOPORE_PCR10/Diff_25_81QC6_107Q_DUPC12_DUPC26_D0-D7

./submit_chronos_gianluca guppy-gianluca-job-basecalling.json
```

## STRAGLR

### WHOLE GENOME alignment

Add to json file for alignment vs the whole-genome.

```json
"constraints": [["hostname", "LIKE", "hpc-gpu-1-[2,4]-[1-2].recas.ba.infn.it"]],
```

> Barcode 01-07

```bash
cd /lustrehome/gianluca/strique/jobs/AC2021_NANOPORE_PCR10/Diff_25_81QC6_107Q_DUPC12_DUPC26_D0-D7

for n in $(seq 13 24) ; do cp guppy-gianluca-job-WG-align13.json guppy-gianluca-job-WG-align${n}.json ; done

for n in $(seq 13 24) ; do sed -i -e "s/barcode13/barcode${n}/g" guppy-gianluca-job-WG-align${n}.json ; done

for n in $(seq 13 24) ; do ./submit_chronos_gianluca guppy-gianluca-job-WG-align${n}.json ; done
```

> looking for reads aligned with chr4

```bash
for n in $(seq 13 24) ; do cat  /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Diff_25_81QC6_107Q_DUPC12_DUPC26_D0-D7/20221024_1418_MN37986_FAT23661_2017f258/analysis/alignment/barcode${n}_WG/alignment_summary.txt | awk '{ if($2 == "chr4" && $6 < 40 &&  $7 > 1000 ) print }' | wc -l ; done 

169091
124184
107914
122923
117563
94166
127185
78104
148245
176147
74900
125163
```

### FASTQ2FASTA

```bash
mkdir /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Diff_25_81QC6_107Q_DUPC12_DUPC26_D0-D7/20221024_1418_MN37986_FAT23661_2017f258/analysis/fastq2fasta

for n in $(seq 13 24) ; do zcat /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Diff_25_81QC6_107Q_DUPC12_DUPC26_D0-D7/20221024_1418_MN37986_FAT23661_2017f258/analysis/basecalling/pass/barcode${n}/*.fastq.gz | awk '{if(NR%4==1) {printf(">%s\n",substr($0,2));} else if(NR%4==2) print;}' > /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Diff_25_81QC6_107Q_DUPC12_DUPC26_D0-D7/20221024_1418_MN37986_FAT23661_2017f258/analysis/fastq2fasta/barcode${n}_allreads.fasta ; done
```

> number all reads from specific barcode

```bash
for n in $(seq 13 24) ; do cat  /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Diff_25_81QC6_107Q_DUPC12_DUPC26_D0-D7/20221024_1418_MN37986_FAT23661_2017f258/analysis/fastq2fasta/barcode${n}_allreads.fasta | grep start_time | wc -l ; done

502166
506003
258304
238011
842894
562954
470762
883070
399796
637117
1046728
473144
```

### BLASTN 107Qbarcode

```bash
source ~/.bashrc

mkdir /lustrehome/gianluca/straglr/blastn/AC2021_NANOPORE_PCR10/Diff_25_81QC6_107Q_DUPC12_DUPC26_D0-D7

for n in $(seq 13 14) ; do blastn -task blastn-short -query /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Diff_25_81QC6_107Q_DUPC12_DUPC26_D0-D7/20221024_1418_MN37986_FAT23661_2017f258/analysis/fastq2fasta/barcode${n}_allreads.fasta -subject /lustrehome/gianluca/straglr/barcode_fasta/barcode81Q.fa -outfmt 6 > /lustrehome/gianluca/straglr/blastn/AC2021_NANOPORE_PCR10/Diff_25_81QC6_107Q_DUPC12_DUPC26_D0-D7/barcode${n}_blastn_81Q.txt ; done

for n in $(seq 15 24) ; do blastn -task blastn-short -query /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Diff_25_81QC6_107Q_DUPC12_DUPC26_D0-D7/20221024_1418_MN37986_FAT23661_2017f258/analysis/fastq2fasta/barcode${n}_allreads.fasta -subject /lustrehome/gianluca/straglr/barcode_fasta/barcode107Q_DUP.fa -outfmt 6 > /lustrehome/gianluca/straglr/blastn/AC2021_NANOPORE_PCR10/Diff_25_81QC6_107Q_DUPC12_DUPC26_D0-D7/barcode${n}_blastn_107Q_DUP.txt ; done
```

### *straglr*, for CAG count

CL Merge 100 bam:

```bash
for n in $(seq 13 24) ; do bash ~/straglr/jobs/bash-merge_100_BAM.sh /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Diff_25_81QC6_107Q_DUPC12_DUPC26_D0-D7/20221024_1418_MN37986_FAT23661_2017f258/analysis/alignment/barcode${n}_WG ; done
```

CL Job submission:

```bash
mkdir /lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/Diff_25_81QC6_107Q_DUPC12_DUPC26_D0-D7

cd /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Diff_25_81QC6_107Q_DUPC12_DUPC26_D0-D7/20221024_1418_MN37986_FAT23661_2017f258/analysis/alignment/

for n in $(seq 13 24) ; do ls barcode${n}_WG/*.multi.bam | while IFS="$(printf '/')" read -r f1 f2 ; do echo condor_submit -name ettore \
-a "out_dir=/lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/Diff_25_81QC6_107Q_DUPC12_DUPC26_D0-D7/" \
-a "bam=/lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Diff_25_81QC6_107Q_DUPC12_DUPC26_D0-D7/20221024_1418_MN37986_FAT23661_2017f258/analysis/alignment/barcode${n}_WG/${f2}" \
-a "ref=/lustre/home/enza/cattaneo/data/Methylation-RUES2-FLG/RUES2-20CAG/reference/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna" \
-a "out_prefix=barcode${n}_v4_${f2}" \
-a "bed=/lustrehome/gianluca/test_straglr/CAG_v4.bed" \
-a "file=${f2}" \
-a "barcode=barcode${n}" \
/lustrehome/gianluca/straglr/jobs/condor-straglr_exp.job ; done ; done | less -S
```

### Merge multiple *straglr* output - version CAG_v4.bed

```bash
cd /lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/Diff_25_81QC6_107Q_DUPC12_DUPC26_D0-D7

for n in $(seq 13 24) ; do ls barcode${n}_v4_split*.tsv | grep aa | while read file ; do cat ${file} > barcode${n}_v4.tsv; done ; done

for n in $(seq 13 24) ; do ls barcode${n}_v4_split*.tsv | grep -v aa | while read file ; do cat ${file} | grep -v "#" >> barcode${n}_v4.tsv; done ; done

#cancel all .ok files created for job-control
rm *.ok
```

### Create folder to save on local computer with blastn+straglr+alignment_summary - version CAG_v4.bed

```bash
cd /lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/Diff_25_81QC6_107Q_DUPC12_DUPC26_D0-D7

for n in $(seq 13 24) ; do mkdir barcode${n}_v4 ; done

ALIGNMENT=/lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Diff_25_81QC6_107Q_DUPC12_DUPC26_D0-D7/20221024_1418_MN37986_FAT23661_2017f258/analysis/alignment

BLASTN=/lustrehome/gianluca/straglr/blastn/AC2021_NANOPORE_PCR10/Diff_25_81QC6_107Q_DUPC12_DUPC26_D0-D7

STRAGLR=/lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/Diff_25_81QC6_107Q_DUPC12_DUPC26_D0-D7

for n in $(seq 13 24) ; do cp ${ALIGNMENT}/barcode${n}_WG/alignment_summary.txt ${STRAGLR}/barcode${n}_v4/ &&  cp ${BLASTN}/barcode${n}* ${STRAGLR}/barcode${n}_v4/ &&  cp ${STRAGLR}/barcode${n}_v4.tsv ${STRAGLR}/barcode${n}_v4/ ; done 
```

### Rsync to local computer - version CAG_v4.bed

```bash
mkdir /Users/gianlucadamaggio/projects/cattaneo/straglr/AC2021_NANOPORE_PCR10/Diff_25_81QC6_107Q_DUPC12_DUPC26_D0-D7/

for n in $(seq 13 24) ; do rsync -avh --progress gianluca@ui02.recas.ba.infn.it:/lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/Diff_25_81QC6_107Q_DUPC12_DUPC26_D0-D7/barcode${n}_v4 /Users/gianlucadamaggio/projects/cattaneo/straglr/AC2021_NANOPORE_PCR10/Diff_25_81QC6_107Q_DUPC12_DUPC26_D0-D7/ ; done
```
-->