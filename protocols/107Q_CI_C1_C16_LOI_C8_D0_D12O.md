# AC2021_NANOPORE_PCR10 107Q_CI_C1_C16_LOI_C8_D0_D12O

## Basecalling

```bash
cd /lustrehome/gianluca/strique/jobs/AC2021_NANOPORE_PCR10/107Q_CI_C1_C16_LOI_C8_D0_D12O

./submit_chronos_gianluca guppy-gianluca-job-basecalling.json
```

## STRAGLR

### WHOLE GENOME alignment

Add to json file for alignment vs the whole-genome.

```json
"constraints": [["hostname", "LIKE", "hpc-gpu-1-[2,4]-[1-2].recas.ba.infn.it"]],
```

> Barcode 13-24

```bash
cd /lustrehome/gianluca/strique/jobs/AC2021_NANOPORE_PCR10/107Q_CI_C1_C16_LOI_C8_D0_D12O

for n in $(seq 13 24) ; do cp guppy-gianluca-job-WG-align13.json guppy-gianluca-job-WG-align${n}.json ; done

for n in $(seq 13 24) ; do sed -i -e "s/barcode13/barcode${n}/g" guppy-gianluca-job-WG-align${n}.json ; done

for n in $(seq 13 24) ; do ./submit_chronos_gianluca guppy-gianluca-job-WG-align${n}.json ; done
```

### FASTQ2FASTA

```bash
mkdir /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q_CI_C1_C16_LOI_C8_D0_D12O/20220404_1647_MN37986_FAR96707_ade04679/analysis/fastq2fasta

for n in $(seq 13 24) ; do zcat /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q_CI_C1_C16_LOI_C8_D0_D12O/20220404_1647_MN37986_FAR96707_ade04679/analysis/basecalling/pass/barcode${n}/*.fastq.gz | awk '{if(NR%4==1) {printf(">%s\n",substr($0,2));} else if(NR%4==2) print;}' > /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q_CI_C1_C16_LOI_C8_D0_D12O/20220404_1647_MN37986_FAR96707_ade04679/analysis/fastq2fasta/barcode${n}_allreads.fasta ; done
```

### BLASTN 107Qbarcode

```bash
source ~/.bashrc

mkdir /lustrehome/gianluca/straglr/blastn/AC2021_NANOPORE_PCR10/107Q_CI_C1_C16_LOI_C8_D0_D12O

for n in $(seq 13 22) ; do blastn -task blastn-short -query /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q_CI_C1_C16_LOI_C8_D0_D12O/20220404_1647_MN37986_FAR96707_ade04679/analysis/fastq2fasta/barcode${n}_allreads.fasta -subject /lustrehome/gianluca/straglr/barcode_fasta/barcode107Q_CI.fa -outfmt 6 > /lustrehome/gianluca/straglr/blastn/AC2021_NANOPORE_PCR10/107Q_CI_C1_C16_LOI_C8_D0_D12O/barcode${n}_blastn_107Q_CI.txt ; done

for n in $(seq 23 24) ; do blastn -task blastn-short -query /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q_CI_C1_C16_LOI_C8_D0_D12O/20220404_1647_MN37986_FAR96707_ade04679/analysis/fastq2fasta/barcode${n}_allreads.fasta -subject /lustrehome/gianluca/straglr/barcode_fasta/barcode107Q_LOI.fa -outfmt 6 > /lustrehome/gianluca/straglr/blastn/AC2021_NANOPORE_PCR10/107Q_CI_C1_C16_LOI_C8_D0_D12O/barcode${n}_blastn_107Q_LOI.txt ; done

```

### *straglr*, for CAG count

CL Merge 100 bam:

```bash
for n in $(seq 13 24)  ; do bash ~/straglr/jobs/bash-merge_100_BAM.sh /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q_CI_C1_C16_LOI_C8_D0_D12O/20220404_1647_MN37986_FAR96707_ade04679/analysis/alignment/barcode${n}_WG ; done
```

CL Job submission:

```bash
mkdir /lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/107Q_CI_C1_C16_LOI_C8_D0_D12O

cd /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q_CI_C1_C16_LOI_C8_D0_D12O/20220404_1647_MN37986_FAR96707_ade04679/analysis/alignment/

for n in $(seq 13 24)  ; do ls barcode${n}_WG/*.multi.bam | while IFS="$(printf '/')" read -r f1 f2 ; do echo condor_submit -name ettore \
-a "out_dir=/lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/107Q_CI_C1_C16_LOI_C8_D0_D12O/" \
-a "bam=/lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q_CI_C1_C16_LOI_C8_D0_D12O/20220404_1647_MN37986_FAR96707_ade04679/analysis/alignment/barcode${n}_WG/${f2}" \
-a "ref=/lustre/home/enza/cattaneo/data/Methylation-RUES2-FLG/RUES2-20CAG/reference/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna" \
-a "out_prefix=barcode${n}_v4_${f2}" \
-a "bed=/lustrehome/gianluca/test_straglr/CAG_v4.bed" \
-a "file=${f2}" \
-a "barcode=barcode${n}" \
/lustrehome/gianluca/straglr/jobs/condor-straglr_exp.job ; done ; done | less -S
```

### Merge multiple *straglr* output - version CAG_v4.bed

```bash
cd /lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/107Q_CI_C1_C16_LOI_C8_D0_D12O

for n in $(seq 13 24) ; do ls barcode${n}_v4_split*.tsv | grep aa | while read file ; do cat ${file} > barcode${n}_v4.tsv; done ; done

for n in $(seq 13 24) ; do ls barcode${n}_v4_split*.tsv | grep -v aa | while read file ; do cat ${file} | grep -v "#" >> barcode${n}_v4.tsv; done ; done

#cancel all .ok files created for job-control
rm *.ok
```

### Create folder to save on local computer with blastn+straglr+alignment_summary - version CAG_v4.bed

```bash
cd /lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/107Q_CI_C1_C16_LOI_C8_D0_D12O

for n in $(seq 13 24) ; do mkdir barcode${n}_v4 ; done

ALIGNMENT=/lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q_CI_C1_C16_LOI_C8_D0_D12O/20220404_1647_MN37986_FAR96707_ade04679/analysis/alignment

BLASTN=/lustrehome/gianluca/straglr/blastn/AC2021_NANOPORE_PCR10/107Q_CI_C1_C16_LOI_C8_D0_D12O

STRAGLR=/lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/107Q_CI_C1_C16_LOI_C8_D0_D12O

for n in $(seq 13 24) ; do cp ${ALIGNMENT}/barcode${n}_WG/alignment_summary.txt ${STRAGLR}/barcode${n}_v4/ &&  cp ${BLASTN}/barcode${n}* ${STRAGLR}/barcode${n}_v4/ &&  cp ${STRAGLR}/barcode${n}_v4.tsv ${STRAGLR}/barcode${n}_v4/ ; done 
```

### Rsync to local computer - version CAG_v4.bed

```bash
mkdir /Users/gianlucadamaggio/projects/cattaneo/straglr/AC2021_NANOPORE_PCR10/107Q_CI_C1_C16_LOI_C8_D0_D12O/

for n in $(seq 13 24) ; do rsync -avh --progress gianluca@ui02.recas.ba.infn.it:/lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/107Q_CI_C1_C16_LOI_C8_D0_D12O/barcode${n}_v4 /Users/gianlucadamaggio/projects/cattaneo/straglr/AC2021_NANOPORE_PCR10/107Q_CI_C1_C16_LOI_C8_D0_D12O/ ; done
```
-->