# ADAPT 107Q rep1 Prolif for STRAGLR software and comparisons with STRique

## FASTQ2FASTA

107Q_prolif_div-19_div0_div30

```bash
for n in $(seq 17 24); do zcat /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q_prolif_div-19_div0_div30/20210910_1823_MN29119_FAQ65926_067e1781/analysis/basecalling/pass/barcode${n}/*.fastq.gz | awk '{if(NR%4==1) {printf(">%s\n",substr($0,2));} else if(NR%4==2) print;}' > /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q_prolif_div-19_div0_div30/20210910_1823_MN29119_FAQ65926_067e1781/analysis/fastq2fasta/barcode${n}_allreads.fasta ; done
```

107Q_prolif_div60_div90_div120

```bash
for n in $(seq 13 24); do zcat /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q_prolif_div60_div90_div120/20211021_1832_MN29119_FAQ69417_7ccbd2e4/analysis/basecalling/pass/barcode${n}/*.fastq.gz | awk '{if(NR%4==1) {printf(">%s\n",substr($0,2));} else if(NR%4==2) print;}' > /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q_prolif_div60_div90_div120/20211021_1832_MN29119_FAQ69417_7ccbd2e4/analysis/fastq2fasta/barcode${n}_allreads.fasta ; done
```

c1

```bash
zcat /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c1_DIV34/20210914_1733_MN29119_AHJ047_2dd526c8/analysis/basecalling/pass/*.fastq.gz | awk '{if(NR%4==1) {printf(">%s\n",substr($0,2));} else if(NR%4==2) print;}' > /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c1_DIV34/20210914_1733_MN29119_AHJ047_2dd526c8/analysis/fastq2fasta/c1_div34_allreads.fasta
```

c21

```bash
zcat /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c21_DIV35/20210915_1534_MN37986_AHJ235_abab1e6b/analysis/basecalling/pass/*.fastq.gz | awk '{if(NR%4==1) {printf(">%s\n",substr($0,2));} else if(NR%4==2) print;}' > /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c21_DIV35/20210915_1534_MN37986_AHJ235_abab1e6b/analysis/fastq2fasta/c21_div35_allreads.fasta
```

c25

```bash
zcat /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c25_DIV34/20210915_1748_MN29119_AHI878_6fd99a18/analysis/basecalling/pass/*.fastq.gz | awk '{if(NR%4==1) {printf(">%s\n",substr($0,2));} else if(NR%4==2) print;}' > /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c25_DIV34/20210915_1748_MN29119_AHI878_6fd99a18/analysis/fastq2fasta/c25_div34_allreads.fasta
```

c4

```bash
zcat /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c4_DIV35/20210914_1550_MN37986_AHJ024_4805f915/analysis/basecalling/pass/*.fastq.gz | awk '{if(NR%4==1) {printf(">%s\n",substr($0,2));} else if(NR%4==2) print;}' > /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c4_DIV35/20210914_1550_MN37986_AHJ024_4805f915/analysis/fastq2fasta/c4_div35_allreads.fasta
```

## BLASTN 107Qbarcode

107Q_prolif_div-19_div0_div30

```bash
source ~/.bashrc

for n in $(seq 17 24); do blastn -task blastn-short -query /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q_prolif_div-19_div0_div30/20210910_1823_MN29119_FAQ65926_067e1781/analysis/fastq2fasta/barcode${n}_allreads.fasta -subject /lustrehome/gianluca/straglr/barcode_fasta/barcode107Q.fa -outfmt 6 > /lustrehome/gianluca/straglr/blastn/AC2021_NANOPORE_PCR10/107Q_prolif_div-19_div0_div30/barcode${n}_blastn_107Q.txt ; done
```

107Q_prolif_div60_div90_div120

```bash
source ~/.bashrc

for n in $(seq 13 24); do blastn -task blastn-short -query /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q_prolif_div60_div90_div120/20211021_1832_MN29119_FAQ69417_7ccbd2e4/analysis/fastq2fasta/barcode${n}_allreads.fasta -subject /lustrehome/gianluca/straglr/barcode_fasta/barcode107Q.fa -outfmt 6 > /lustrehome/gianluca/straglr/blastn/AC2021_NANOPORE_PCR10/107Q_prolif_div60_div90_div120/barcode${n}_blastn_107Q.txt ; done
```

107Q_prolif_div60_div90_div120_II

```bash
source ~/.bashrc

mkdir /lustrehome/gianluca/straglr/blastn/AC2021_NANOPORE_PCR10/107Q_prolif_div60_div90_div120_II

for n in 01 02 03 04 05 06 07 08 09 10 11 12; do blastn -task blastn-short -query /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q_Prolif_div60_div90_div120_II/20211109_1755_MN37986_FAQ75854_4cfd8afc/analysis/fastq2fasta/barcode${n}_allreads.fasta -subject /lustrehome/gianluca/straglr/barcode_fasta/barcode107Q.fa -outfmt 6 > /lustrehome/gianluca/straglr/blastn/AC2021_NANOPORE_PCR10/107Q_prolif_div60_div90_div120_II/barcode${n}_blastn_107Q.txt ; done
```

c1

```bash
source ~/.bashrc

blastn -task blastn-short -query /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c1_DIV34/20210914_1733_MN29119_AHJ047_2dd526c8/analysis/fastq2fasta/c1_div34_allreads.fasta -subject /lustrehome/gianluca/straglr/barcode_fasta/barcode107Q.fa -outfmt 6 > /lustrehome/gianluca/straglr/blastn/AC2021_NANOPORE_PCR10/Plurip_c1_DIV34/c1_div34_blastn_107Q.txt
```

c21

```bash
source ~/.bashrc

blastn -task blastn-short -query /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c21_DIV35/20210915_1534_MN37986_AHJ235_abab1e6b/analysis/fastq2fasta/c21_div35_allreads.fasta -subject /lustrehome/gianluca/straglr/barcode_fasta/barcode107Q.fa -outfmt 6 > /lustrehome/gianluca/straglr/blastn/AC2021_NANOPORE_PCR10/Plurip_c21_DIV35/c21_div35_blastn_107Q.txt
```

c25

```bash
source ~/.bashrc

blastn -task blastn-short -query /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c25_DIV34/20210915_1748_MN29119_AHI878_6fd99a18/analysis/fastq2fasta/c25_div34_allreads.fasta -subject /lustrehome/gianluca/straglr/barcode_fasta/barcode107Q.fa -outfmt 6 > /lustrehome/gianluca/straglr/blastn/AC2021_NANOPORE_PCR10/Plurip_c25_DIV34/c25_div34_blastn_107Q.txt
```

c4

```bash
source ~/.bashrc

blastn -task blastn-short -query /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c4_DIV35/20210914_1550_MN37986_AHJ024_4805f915/analysis/fastq2fasta/c4_div35_allreads.fasta -subject /lustrehome/gianluca/straglr/barcode_fasta/barcode107Q.fa -outfmt 6 > /lustrehome/gianluca/straglr/blastn/AC2021_NANOPORE_PCR10/Plurip_c4_DIV35/c4_div35_blastn_107Q.txt

```

## Merge multiple BAM into one

Script location

```bash
/lustrehome/gianluca/strique/jobs/AC2021_NANOPORE_PCR10/21Q_45Q_C6_12_51_PLURIP_D0_30_60_90_120/bash-merge_multiBAM.sh
```

107Q_prolif_div-19_div0_div30

```bash
for n in $(seq 17 24) ; do bash bash-merge_multiBAM.sh /lustre/home/enza/cattaneo/data/AC2021_NANOPORE_PCR10/107Q_prolif_div-19_div0_div30/20210910_1823_MN29119_FAQ65926_067e1781/analysis/alignment/bam/barcode${n} ; done
```

107Q_prolif_div60_div90_div120

```bash
for n in $(seq 13 24) ; do bash bash-merge_multiBAM.sh /lustre/home/enza/cattaneo/data/AC2021_NANOPORE_PCR10/107Q_prolif_div60_div90_div120/20211021_1832_MN29119_FAQ69417_7ccbd2e4/analysis/alignment/bam/barcode${n} ; done
```

c1

```bash
bash bash-merge_multiBAM.sh /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c1_DIV34/20210914_1733_MN29119_AHJ047_2dd526c8/analysis/alignment_WG
```

c21

```bash
bash bash-merge_multiBAM.sh /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c21_DIV35/20210915_1534_MN37986_AHJ235_abab1e6b/analysis/alignment_WG
```

c25

```bash
bash bash-merge_multiBAM.sh /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c25_DIV34/20210915_1748_MN29119_AHI878_6fd99a18/analysis/alignment_WG
```

c4

```bash
bash bash-merge_multiBAM.sh /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c4_DIV35/20210914_1550_MN37986_AHJ024_4805f915/analysis/alignment_WG
```

## straglr, for CAG count

107Q_prolif_div-19_div0_div30

```bash
for n in $(seq 17 24) ; do echo qsub -q testqueue -l nodes=1:ppn=40 \
    -o /lustrehome/gianluca/junk/cattaneo/straglr_107Q_prolif_div-19_div0_div30_barcode${n}.out \
    -e /lustrehome/gianluca/junk/cattaneo/straglr_107Q_prolif_div-19_div0_div30_barcode${n}.err \
    -v out_dir="/lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/107Q_prolif_div-19_div0_div30",bam="/lustre/home/enza/cattaneo/data/AC2021_NANOPORE_PCR10/107Q_prolif_div-19_div0_div30/20210910_1823_MN29119_FAQ65926_067e1781/analysis/alignment/bam/barcode${n}/all_reads.sorted.bam",ref="/lustre/home/enza/cattaneo/data/Methylation-RUES2-FLG/RUES2-20CAG/reference/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna",out_prefix="barcode${n}",bed="/lustrehome/gianluca/test_straglr/CAG.bed" \
  -N straglr_107Q_prolif_div-19_div0_div30_count_barcode${n} \
    /lustrehome/gianluca/strique/jobs/AC2021_NANOPORE_PCR10/21Q_45Q_C6_12_51_PLURIP_D0_30_60_90_120/pbs-straglr.job ; done | less -S
```

107Q_prolif_div60_div90_div120

```bash
for n in $(seq 13 24) ; do echo qsub -q testqueue -l nodes=1:ppn=40 \
    -o /lustrehome/gianluca/junk/cattaneo/straglr_107Q_prolif_div60_div90_div120_barcode${n}.out \
    -e /lustrehome/gianluca/junk/cattaneo/straglr_107Q_prolif_div60_div90_div120_barcode${n}.err \
    -v out_dir="/lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/107Q_prolif_div60_div90_div120",bam="/lustre/home/enza/cattaneo/data/AC2021_NANOPORE_PCR10/107Q_prolif_div60_div90_div120/20211021_1832_MN29119_FAQ69417_7ccbd2e4/analysis/alignment/bam/barcode${n}/all_reads.sorted.bam",ref="/lustre/home/enza/cattaneo/data/Methylation-RUES2-FLG/RUES2-20CAG/reference/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna",out_prefix="barcode${n}",bed="/lustrehome/gianluca/test_straglr/CAG.bed" \
    -N straglr_107Q_prolif_div60_div90_div120_count_barcode${n} \
    /lustrehome/gianluca/strique/jobs/AC2021_NANOPORE_PCR10/21Q_45Q_C6_12_51_PLURIP_D0_30_60_90_120/pbs-straglr.job ; done | less -S
```

c1

```bash
echo qsub -q testqueue -l nodes=1:ppn=40 \
    -o /lustrehome/gianluca/junk/cattaneo/straglr_Plurip_c1_DIV34.out \
    -e /lustrehome/gianluca/junk/cattaneo/straglr_Plurip_c1_DIV34.err \
    -v out_dir="/lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/Plurip_c1_DIV34",bam="/lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c1_DIV34/20210914_1733_MN29119_AHJ047_2dd526c8/analysis/alignment_WG/all_reads.sorted.bam",ref="/lustre/home/enza/cattaneo/data/Methylation-RUES2-FLG/RUES2-20CAG/reference/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna",out_prefix="Plurip_c1_DIV34",bed="/lustrehome/gianluca/test_straglr/CAG.bed" \
    -N straglr_Plurip_c1_DIV34 \
    /lustrehome/gianluca/strique/jobs/AC2021_NANOPORE_PCR10/21Q_45Q_C6_12_51_PLURIP_D0_30_60_90_120/pbs-straglr.job | less -S
```

c21

```bash
echo qsub -q testqueue -l nodes=1:ppn=40 \
    -o /lustrehome/gianluca/junk/cattaneo/straglr_Plurip_c21_DIV35.out \
    -e /lustrehome/gianluca/junk/cattaneo/straglr_Plurip_c21_DIV35.err \
    -v out_dir="/lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/Plurip_c21_DIV35",bam="/lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c21_DIV35/20210915_1534_MN37986_AHJ235_abab1e6b/analysis/alignment_WG/all_reads.sorted.bam",ref="/lustre/home/enza/cattaneo/data/Methylation-RUES2-FLG/RUES2-20CAG/reference/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna",out_prefix="Plurip_c21_DIV35",bed="/lustrehome/gianluca/test_straglr/CAG.bed" \
    -N straglr_Plurip_c21_DIV35 \
    /lustrehome/gianluca/strique/jobs/AC2021_NANOPORE_PCR10/21Q_45Q_C6_12_51_PLURIP_D0_30_60_90_120/pbs-straglr.job | less -S
```

c25

```bash
echo qsub -q testqueue -l nodes=1:ppn=40 \
    -o /lustrehome/gianluca/junk/cattaneo/straglr_Plurip_c25_DIV34.out \
    -e /lustrehome/gianluca/junk/cattaneo/straglr_Plurip_c25_DIV34.err \
    -v out_dir="/lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/Plurip_c25_DIV34",bam="/lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c25_DIV34/20210915_1748_MN29119_AHI878_6fd99a18/analysis/alignment_WG/all_reads.sorted.bam",ref="/lustre/home/enza/cattaneo/data/Methylation-RUES2-FLG/RUES2-20CAG/reference/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna",out_prefix="Plurip_c25_DIV34",bed="/lustrehome/gianluca/test_straglr/CAG.bed" \
    -N straglr_Plurip_c25_DIV34 \
    /lustrehome/gianluca/strique/jobs/AC2021_NANOPORE_PCR10/21Q_45Q_C6_12_51_PLURIP_D0_30_60_90_120/pbs-straglr.job | less -S
```

c4

```bash
echo qsub -q testqueue -l nodes=1:ppn=40 \
    -o /lustrehome/gianluca/junk/cattaneo/straglr_Plurip_c4_DIV35.out \
    -e /lustrehome/gianluca/junk/cattaneo/straglr_Plurip_c4_DIV35.err \
    -v out_dir="/lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/Plurip_c4_DIV35",bam="/lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c4_DIV35/20210914_1550_MN37986_AHJ024_4805f915/analysis/alignment_WG/all_reads.sorted.bam",ref="/lustre/home/enza/cattaneo/data/Methylation-RUES2-FLG/RUES2-20CAG/reference/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna",out_prefix="Plurip_c4_DIV35",bed="/lustrehome/gianluca/test_straglr/CAG.bed" \
    -N straglr_Plurip_c4_DIV35 \
    /lustrehome/gianluca/strique/jobs/AC2021_NANOPORE_PCR10/21Q_45Q_C6_12_51_PLURIP_D0_30_60_90_120/pbs-straglr.job | less -S
```

## Re-do Straglr - version CAG_v4.bed

### *straglr*, for CAG count

CL Merge 100 bam:

```bash
for n in $(seq 17 24) ; do bash bash-merge_100_BAM.sh /lustre/home/enza/cattaneo/data/AC2021_NANOPORE_PCR10/107Q_prolif_div-19_div0_div30/20210910_1823_MN29119_FAQ65926_067e1781/analysis/alignment/bam/barcode${n}/ ; done
```

```bash
mkdir /lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/107Q_prolif_div-19_div0_div30

cd /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q_prolif_div-19_div0_div30/20210910_1823_MN29119_FAQ65926_067e1781/analysis/alignment/bam

for n in $(seq 17 24) ; do ls barcode${n}/*.multi.bam | while IFS="$(printf '/')" read -r f1 f2 ; do echo condor_submit -name ettore \
-a "out_dir=/lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/107Q_prolif_div-19_div0_div30/" \
-a "bam=/lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q_prolif_div-19_div0_div30/20210910_1823_MN29119_FAQ65926_067e1781/analysis/alignment/bam/barcode${n}/${f2}" \
-a "ref=/lustre/home/enza/cattaneo/data/Methylation-RUES2-FLG/RUES2-20CAG/reference/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna" \
-a "out_prefix=barcode${n}_v4_${f2}" \
-a "bed=/lustrehome/gianluca/test_straglr/CAG_v4.bed" \
-a "file=${f2}" \
-a "barcode=barcode${n}" \
/lustrehome/gianluca/straglr/jobs/condor-straglr_exp.job ; done ; done | less -S
```

C1

```bash
bash ~/straglr/jobs/bash-merge_100_BAM.sh /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c1_DIV34/20210914_1733_MN29119_AHJ047_2dd526c8/analysis/alignment_WG/
```

```bash
mkdir /lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/Plurip_c1_DIV34/

cd /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c1_DIV34/20210914_1733_MN29119_AHJ047_2dd526c8/analysis/

for n in Plurip_c1_DIV34 ; do ls alignment_WG/*.multi.bam | while IFS="$(printf '/')" read -r f1 f2 ; do echo condor_submit -name ettore \
-a "out_dir=/lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/Plurip_c1_DIV34/" \
-a "bam=/lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c1_DIV34/20210914_1733_MN29119_AHJ047_2dd526c8/analysis/alignment_WG/${f2}" \
-a "ref=/lustre/home/enza/cattaneo/data/Methylation-RUES2-FLG/RUES2-20CAG/reference/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna" \
-a "out_prefix=${n}_v4_${f2}" \
-a "bed=/lustrehome/gianluca/test_straglr/CAG_v4.bed" \
-a "file=${f2}" \
-a "barcode=${n}" \
/lustrehome/gianluca/straglr/jobs/condor-straglr_exp.job ; done ; done | less -S
```

C4

```bash
bash ~/straglr/jobs/bash-merge_100_BAM.sh /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c4_DIV35/20210914_1550_MN37986_AHJ024_4805f915/analysis/alignment_WG/
```

```bash
mkdir /lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/Plurip_c4_DIV35/

cd /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c4_DIV35/20210914_1550_MN37986_AHJ024_4805f915/analysis/

for n in Plurip_c4_DIV35 ; do ls alignment_WG/*.multi.bam | while IFS="$(printf '/')" read -r f1 f2 ; do echo condor_submit -name ettore \
-a "out_dir=/lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/Plurip_c4_DIV35/" \
-a "bam=/lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c4_DIV35/20210914_1550_MN37986_AHJ024_4805f915/analysis/alignment_WG/${f2}" \
-a "ref=/lustre/home/enza/cattaneo/data/Methylation-RUES2-FLG/RUES2-20CAG/reference/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna" \
-a "out_prefix=${n}_v4_${f2}" \
-a "bed=/lustrehome/gianluca/test_straglr/CAG_v4.bed" \
-a "file=${f2}" \
-a "barcode=${n}" \
/lustrehome/gianluca/straglr/jobs/condor-straglr_exp.job ; done ; done | less -S
```

C21

```bash
bash ~/straglr/jobs/bash-merge_100_BAM.sh /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c21_DIV35/20210915_1534_MN37986_AHJ235_abab1e6b/analysis/alignment_WG/
```

```bash
mkdir /lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/Plurip_c21_DIV35/

cd /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c21_DIV35/20210915_1534_MN37986_AHJ235_abab1e6b/analysis/

for n in Plurip_c21_DIV35 ; do ls alignment_WG/*.multi.bam | while IFS="$(printf '/')" read -r f1 f2 ; do echo condor_submit -name ettore \
-a "out_dir=/lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/Plurip_c21_DIV35/" \
-a "bam=/lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c21_DIV35/20210915_1534_MN37986_AHJ235_abab1e6b/analysis/alignment_WG/${f2}" \
-a "ref=/lustre/home/enza/cattaneo/data/Methylation-RUES2-FLG/RUES2-20CAG/reference/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna" \
-a "out_prefix=${n}_v4_${f2}" \
-a "bed=/lustrehome/gianluca/test_straglr/CAG_v4.bed" \
-a "file=${f2}" \
-a "barcode=${n}" \
/lustrehome/gianluca/straglr/jobs/condor-straglr_exp.job ; done ; done | less -S
```

C25

```bash
bash ~/straglr/jobs/bash-merge_100_BAM.sh /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c25_DIV34/20210915_1748_MN29119_AHI878_6fd99a18/analysis/alignment_WG/
```

```bash
mkdir /lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/Plurip_c25_DIV34/

cd /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c25_DIV34/20210915_1748_MN29119_AHI878_6fd99a18/analysis/

for n in Plurip_c25_DIV34 ; do ls alignment_WG/*.multi.bam | while IFS="$(printf '/')" read -r f1 f2 ; do echo condor_submit -name ettore \
-a "out_dir=/lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/Plurip_c25_DIV34/" \
-a "bam=/lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c25_DIV34/20210915_1748_MN29119_AHI878_6fd99a18/analysis/alignment_WG/${f2}" \
-a "ref=/lustre/home/enza/cattaneo/data/Methylation-RUES2-FLG/RUES2-20CAG/reference/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna" \
-a "out_prefix=${n}_v4_${f2}" \
-a "bed=/lustrehome/gianluca/test_straglr/CAG_v4.bed" \
-a "file=${f2}" \
-a "barcode=${n}" \
/lustrehome/gianluca/straglr/jobs/condor-straglr_exp.job ; done ; done | less -S
```

### Merge multiple *straglr* output - version CAG_v4.bed

```bash
cd /lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/107Q_prolif_div-19_div0_div30

for n in $(seq 17 24); do ls barcode${n}_v4_split*.tsv | grep aa | while read file ; do cat ${file} > barcode${n}_v4.tsv; done ; done

for n in $(seq 17 24); do ls barcode${n}_v4_split*.tsv | grep -v aa | while read file ; do cat ${file} | grep -v "#" >> barcode${n}_v4.tsv; done ; done

#cancel all .ok files created for job-control
rm *.ok
```

```bash
cd /lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/

for n in Plurip_c1_DIV34 Plurip_c4_DIV35 Plurip_c21_DIV35 Plurip_c25_DIV34 ; do ls ${n}/${n}_v4_split*.tsv | grep aa | while read file ; do cat ${file} > ${n}/${n}_v4.tsv; done ; done

for n in Plurip_c1_DIV34 Plurip_c4_DIV35 Plurip_c21_DIV35 Plurip_c25_DIV34 ; do ls ${n}/${n}_v4_split*.tsv | grep -v aa | while read file ; do cat ${file} | grep -v "#" >> ${n}/${n}_v4.tsv; done ; done

#cancel all .ok files created for job-control
for n in Plurip_c1_DIV34 Plurip_c4_DIV35 Plurip_c21_DIV35 Plurip_c25_DIV34 ; do rm ${n}/*.ok ; done 
```

### Create folder to save on local computer with blastn+straglr+alignment_summary - version CAG_v4.bed

```bash
cd /lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/107Q_prolif_div-19_div0_div30

for n in $(seq 17 24); do mkdir barcode${n}_v4 ; done

STRAGLR=/lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/107Q_prolif_div-19_div0_div30

for n in $(seq 17 24); do cp ${STRAGLR}/barcode${n}_v4.tsv ${STRAGLR}/barcode${n}_v4/ ; done 
```

### Rsync to local computer - version CAG_v4.bed

```bash
mkdir /Users/gianlucadamaggio/projects/cattaneo/straglr/AC2021_NANOPORE_PCR10/107Q_prolif_div-19_div0_div30/

for n in $(seq 17 24); do rsync -avh --progress gianluca@ui02.recas.ba.infn.it:/lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/107Q_prolif_div-19_div0_div30/barcode${n}_v4 /Users/gianlucadamaggio/projects/cattaneo/straglr/AC2021_NANOPORE_PCR10/107Q_prolif_div-19_div0_div30/ ; done
```

```bash
for n in Plurip_c1_DIV34 Plurip_c4_DIV35 Plurip_c21_DIV35 Plurip_c25_DIV34; do rsync -avh --progress gianluca@ui02.recas.ba.infn.it:/lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/${n}/${n}_v4.tsv /Users/gianlucadamaggio/projects/cattaneo/straglr/AC2021_NANOPORE_PCR10/${n}/ ; done
```

-->