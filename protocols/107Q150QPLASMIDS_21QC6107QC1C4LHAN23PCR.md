# AC2021_NANOPORE_PCR10 107Q150QPLASMIDS_21QC6107QC1C4LHAN23PCR

```bash
cd /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q150QPLASMIDS_21QC6107QC1C4LHAN23PCR/20230929_1305_MN38445_FAW13878_30928e85
mkdir -p analysis/basecalling
mkdir -p analysis/alignment
mkdir -p analysis/fastq2fasta
```

## Basecalling

```bash
mkdir /lustrehome/gianluca/strique/jobs/AC2021_NANOPORE_PCR10/107Q150QPLASMIDS_21QC6107QC1C4LHAN23PCR
cd /lustrehome/gianluca/strique/jobs/AC2021_NANOPORE_PCR10/107Q150QPLASMIDS_21QC6107QC1C4LHAN23PCR

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
cd /lustrehome/gianluca/strique/jobs/AC2021_NANOPORE_PCR10/107Q150QPLASMIDS_21QC6107QC1C4LHAN23PCR

for n in 01 02 03 04 05 06 07 08 09 ; do cp guppy-gianluca-job-WG-align01.json guppy-gianluca-job-WG-align${n}.json ; done

for n in 01 02 03 04 05 06 07 08 09 ; do sed -i -e "s/barcode01/barcode${n}/g" guppy-gianluca-job-WG-align${n}.json ; done

for n in 01 02 03 04 05 06 07 08 09 ; do ./submit_chronos_gianluca guppy-gianluca-job-WG-align${n}.json ; done
```

> looking for reads aligned with chr4

```bash
for n in 01 02 03 04 05 06 07 08 09; do cat  /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q150QPLASMIDS_21QC6107QC1C4LHAN23PCR/20230929_1305_MN38445_FAW13878_30928e85/analysis/alignment/barcode${n}_WG/alignment_summary.txt | awk '{ if($2 == "chr4" && $6 < 40 &&  $7 > 1000 ) print }' | wc -l ; done 

6336
140992
166711
172486
460202
578235
265950
1340027
1637
```

### FASTQ2FASTA

```bash
mkdir /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q150QPLASMIDS_21QC6107QC1C4LHAN23PCR/20230929_1305_MN38445_FAW13878_30928e85/analysis/fastq2fasta

for n in 01 02 03 04 05 06 07 08 09; do zcat /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q150QPLASMIDS_21QC6107QC1C4LHAN23PCR/20230929_1305_MN38445_FAW13878_30928e85/analysis/basecalling/pass/barcode${n}/*.fastq.gz | awk '{if(NR%4==1) {printf(">%s\n",substr($0,2));} else if(NR%4==2) print;}' > /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q150QPLASMIDS_21QC6107QC1C4LHAN23PCR/20230929_1305_MN38445_FAW13878_30928e85/analysis/fastq2fasta/barcode${n}_allreads.fasta ; done
```

> number all reads from specific barcode

```bash
for n in 01 02 03 04 05 06 07 08 09; do cat  /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q150QPLASMIDS_21QC6107QC1C4LHAN23PCR/20230929_1305_MN38445_FAW13878_30928e85/analysis/fastq2fasta/barcode${n}_allreads.fasta | grep start_time | wc -l ; done

294562
171678
186121
947586
524649
647827
298435
2102643
130817
```

### BLASTN 107Qbarcode

```bash
source ~/.bashrc

mkdir /lustrehome/gianluca/straglr/blastn/AC2021_NANOPORE_PCR10/107Q150QPLASMIDS_21QC6107QC1C4LHAN23PCR

for n in 01 02 05 06 07 08 ; do blastn -task blastn-short -query /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q150QPLASMIDS_21QC6107QC1C4LHAN23PCR/20230929_1305_MN38445_FAW13878_30928e85/analysis/fastq2fasta/barcode${n}_allreads.fasta -subject /lustrehome/gianluca/straglr/barcode_fasta/barcode107Q.fa -outfmt 6 > /lustrehome/gianluca/straglr/blastn/AC2021_NANOPORE_PCR10/107Q150QPLASMIDS_21QC6107QC1C4LHAN23PCR/barcode${n}_blastn_107Q.txt ; done

for n in  03 04 ; do blastn -task blastn-short -query /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q150QPLASMIDS_21QC6107QC1C4LHAN23PCR/20230929_1305_MN38445_FAW13878_30928e85/analysis/fastq2fasta/barcode${n}_allreads.fasta -subject /lustrehome/gianluca/straglr/barcode_fasta/barcode21Q.fa -outfmt 6 > /lustrehome/gianluca/straglr/blastn/AC2021_NANOPORE_PCR10/107Q150QPLASMIDS_21QC6107QC1C4LHAN23PCR/barcode${n}_blastn_21Q.txt ; done

for n in 09 ; do blastn -task blastn-short -query /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q150QPLASMIDS_21QC6107QC1C4LHAN23PCR/20230929_1305_MN38445_FAW13878_30928e85/analysis/fastq2fasta/barcode${n}_allreads.fasta -subject /lustrehome/gianluca/straglr/barcode_fasta/barcode150Q.fa -outfmt 6 > /lustrehome/gianluca/straglr/blastn/AC2021_NANOPORE_PCR10/107Q150QPLASMIDS_21QC6107QC1C4LHAN23PCR/barcode${n}_blastn_150Q.txt ; done
```

### *straglr*, for CAG count

CL Merge 100 bam:

```bash
for n in 01 02 03 04 05 06 07 08 09 ; do bash ~/straglr/jobs/bash-merge_100_BAM.sh /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q150QPLASMIDS_21QC6107QC1C4LHAN23PCR/20230929_1305_MN38445_FAW13878_30928e85/analysis/alignment/barcode${n}_WG ; done
```

CL Job submission:

```bash
mkdir /lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/107Q150QPLASMIDS_21QC6107QC1C4LHAN23PCR

cd /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q150QPLASMIDS_21QC6107QC1C4LHAN23PCR/20230929_1305_MN38445_FAW13878_30928e85/analysis/alignment/

for n in 01 02 03 04 05 06 07 08 09; do ls barcode${n}_WG/*.multi.bam | while IFS="$(printf '/')" read -r f1 f2 ; do echo condor_submit -name ettore \
-a "out_dir=/lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/107Q150QPLASMIDS_21QC6107QC1C4LHAN23PCR" \
-a "bam=/lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q150QPLASMIDS_21QC6107QC1C4LHAN23PCR/20230929_1305_MN38445_FAW13878_30928e85/analysis/alignment/barcode${n}_WG/${f2}" \
-a "ref=/lustre/home/enza/cattaneo/data/Methylation-RUES2-FLG/RUES2-20CAG/reference/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna" \
-a "out_prefix=barcode${n}_v4_${f2}" \
-a "bed=/lustrehome/gianluca/test_straglr/CAG_v4.bed" \
-a "file=${f2}" \
-a "barcode=barcode${n}" \
/lustrehome/gianluca/straglr/jobs/condor-straglr_exp.job ; done ; done | less -S
```

### Merge multiple *straglr* output - version CAG_v4.bed

```bash
cd /lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/107Q150QPLASMIDS_21QC6107QC1C4LHAN23PCR

for n in 01 02 03 04 05 06 07 08 09; do ls barcode${n}_v4_split*.tsv | grep aa | while read file ; do cat ${file} > barcode${n}_v4.tsv; done ; done

for n in 01 02 03 04 05 06 07 08 09; do ls barcode${n}_v4_split*.tsv | grep -v aa | while read file ; do cat ${file} | grep -v "#" >> barcode${n}_v4.tsv; done ; done

#cancel all .ok files created for job-control
rm *.ok
```

### Create folder to save on local computer with blastn+straglr+alignment_summary - version CAG_v4.bed

```bash
cd /lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/107Q150QPLASMIDS_21QC6107QC1C4LHAN23PCR

for n in 01 02 03 04 05 06 07 08 09; do mkdir barcode${n}_v4 ; done

ALIGNMENT=/lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q150QPLASMIDS_21QC6107QC1C4LHAN23PCR/20230929_1305_MN38445_FAW13878_30928e85/analysis/alignment

BLASTN=/lustrehome/gianluca/straglr/blastn/AC2021_NANOPORE_PCR10/107Q150QPLASMIDS_21QC6107QC1C4LHAN23PCR

STRAGLR=/lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/107Q150QPLASMIDS_21QC6107QC1C4LHAN23PCR

for n in 01 02 03 04 05 06 07 08 09; do cp ${ALIGNMENT}/barcode${n}_WG/alignment_summary.txt ${STRAGLR}/barcode${n}_v4/ &&  cp ${BLASTN}/barcode${n}* ${STRAGLR}/barcode${n}_v4/ &&  cp ${STRAGLR}/barcode${n}_v4.tsv ${STRAGLR}/barcode${n}_v4/ ; done 
```

### Rsync to local computer - version CAG_v4.bed

```bash
mkdir /Users/gianlucadamaggio/projects/cattaneo/straglr/AC2021_NANOPORE_PCR10/107Q150QPLASMIDS_21QC6107QC1C4LHAN23PCR/

for n in 01 02 03 04 05 06 07 08 09; do rsync -avh --progress gianluca@ui02.recas.ba.infn.it:/lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/107Q150QPLASMIDS_21QC6107QC1C4LHAN23PCR/barcode${n}_v4 /Users/gianlucadamaggio/projects/cattaneo/straglr/AC2021_NANOPORE_PCR10/107Q150QPLASMIDS_21QC6107QC1C4LHAN23PCR/ ; done
```
-->