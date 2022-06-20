# AC2021_NANOPORE_PCR10 107Q_NT_CTR_DIV34_DIV59_DIV90

## Basecalling

```bash
cd /lustrehome/gianluca/strique/jobs/AC2021_NANOPORE_PCR10/107Q_NT_CTR_DIV34_DIV59_DIV90

./submit_chronos_gianluca guppy-gianluca-job-basecalling.json
```

## STRAGLR

### WHOLE GENOME alignment

Add to json file for alignment vs the whole-genome.

```json
"constraints": [["hostname", "LIKE", "hpc-gpu-1-[2,4]-[1-2].recas.ba.infn.it"]],
```

> Barcode 01 - 12

```bash
cd /lustrehome/gianluca/strique/jobs/AC2021_NANOPORE_PCR10/107Q_NT_CTR_DIV34_DIV59_DIV90

for n in 01 02 03 04 05 06 07 08 09 10 11 12; do cp guppy-gianluca-job-WG-align01.json guppy-gianluca-job-WG-align${n}.json ; done

for n in 01 02 03 04 05 06 07 08 09 10 11 12; do sed -i -e "s/barcode01/barcode${n}/g" guppy-gianluca-job-WG-align${n}.json ; done

for n in 01 02 03 04 05 06 07 08 09 10 11 12; do ./submit_chronos_gianluca guppy-gianluca-job-WG-align${n}.json ; done
```

241140
258165
215736
290024
223770
314925
233787
254495
225818
204613
286912
162377

> pcr fragment

```bash
cd /lustrehome/gianluca/strique/jobs/AC2021_NANOPORE_PCR10/107Q_NT_CTR_DIV34_DIV59_DIV90

for n in 01 02 03 04 05 06 07 08 09 10 11 12; do cp guppy-gianluca-job-PCRfragment-align01.json guppy-gianluca-job-PCRfragment-align${n}.json ; done

for n in 01 02 03 04 05 06 07 08 09 10 11 12; do sed -i -e "s/barcode01/barcode${n}/g" guppy-gianluca-job-PCRfragment-align${n}.json ; done

for n in 01 02 03 04 05 06 07 08 09 10 11 12; do ./submit_chronos_gianluca guppy-gianluca-job-PCRfragment-align${n}.json ; done
```

### FASTQ2FASTA

```bash
mkdir /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q_NT_CTR_DIV34_DIV59_DIV90/20220317_1624_MN37986_FAR88343_0f70353f/analysis/fastq2fasta

for n in 01 02 03 04 05 06 07 08 09 10 11 12; do zcat /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q_NT_CTR_DIV34_DIV59_DIV90/20220317_1624_MN37986_FAR88343_0f70353f/analysis/basecalling/pass/barcode${n}/*.fastq.gz | awk '{if(NR%4==1) {printf(">%s\n",substr($0,2));} else if(NR%4==2) print;}' > /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q_NT_CTR_DIV34_DIV59_DIV90/20220317_1624_MN37986_FAR88343_0f70353f/analysis/fastq2fasta/barcode${n}_allreads.fasta ; done
```

### BLASTN 107Qbarcode

```bash
source ~/.bashrc

mkdir /lustrehome/gianluca/straglr/blastn/AC2021_NANOPORE_PCR10/107Q_NT_CTR_DIV34_DIV59_DIV90

for n in 01 02 03 04 05 06 07 08 09 10 11 12; do blastn -task blastn-short -query /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q_NT_CTR_DIV34_DIV59_DIV90/20220317_1624_MN37986_FAR88343_0f70353f/analysis/fastq2fasta/barcode${n}_allreads.fasta -subject /lustrehome/gianluca/straglr/barcode_fasta/barcode107Q.fa -outfmt 6 > /lustrehome/gianluca/straglr/blastn/AC2021_NANOPORE_PCR10/107Q_NT_CTR_DIV34_DIV59_DIV90/barcode${n}_blastn_107Q.txt ; done
```

### *straglr*, for CAG count

CL Merge 100 bam:

```bash
for n in 01 02 03 04 05 06 07 08 09 10 11 12 ; do bash ~/straglr/jobs/bash-merge_100_BAM.sh /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q_NT_CTR_DIV34_DIV59_DIV90/20220317_1624_MN37986_FAR88343_0f70353f/analysis/alignment/barcode${n}_WG ; done
```

> merge pcr alignment

```bash
for n in 01 02 03 04 05 06 07 08 09 10 11 12 ; do bash ~/straglr/jobs/bash-merge_100_BAM.sh /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q_NT_CTR_DIV34_DIV59_DIV90/20220317_1624_MN37986_FAR88343_0f70353f/analysis/alignment/barcode${n}_pcr ; done
```

CL Job submission:

```bash
mkdir /lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/107Q_NT_CTR_DIV34_DIV59_DIV90

cd /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q_NT_CTR_DIV34_DIV59_DIV90/20220317_1624_MN37986_FAR88343_0f70353f/analysis/alignment/

for n in 01 02 03 04 05 06 07 08 09 10 11 12 ; do ls barcode${n}_WG/*.multi.bam | while IFS="$(printf '/')" read -r f1 f2 ; do echo condor_submit -name ettore \
-a "out_dir=/lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/107Q_NT_CTR_DIV34_DIV59_DIV90/" \
-a "bam=/lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q_NT_CTR_DIV34_DIV59_DIV90/20220317_1624_MN37986_FAR88343_0f70353f/analysis/alignment/barcode${n}_WG/${f2}" \
-a "ref=/lustre/home/enza/cattaneo/data/Methylation-RUES2-FLG/RUES2-20CAG/reference/GCA_000001405.15_GRCh38_no_alt_analysis_set.fna" \
-a "out_prefix=barcode${n}_v4_${f2}" \
-a "bed=/lustrehome/gianluca/test_straglr/CAG_v4.bed" \
-a "file=${f2}" \
-a "barcode=barcode${n}" \
/lustrehome/gianluca/straglr/jobs/condor-straglr_exp.job ; done ; done | less -S

for align in pcr; do for n in 01 02 03 04 05 06 07 08 09 10 11 12 ; do ls barcode${n}_${align}/*.multi.bam | while IFS="$(printf '/')" read -r f1 f2 ; do echo condor_submit -name ettore \
-a "out_dir=/lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/107Q_NT_CTR_DIV34_DIV59_DIV90/" \
-a "bam=/lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q_NT_CTR_DIV34_DIV59_DIV90/20220317_1624_MN37986_FAR88343_0f70353f/analysis/alignment/barcode${n}_${align}/${f2}" \
-a "ref=/lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/AC2021_NANOPORE_PCR10_107Q_FLP.fa" \
-a "out_prefix=barcode${n}_${align}_v4_${f2}" \
-a "bed=/lustrehome/gianluca/test_straglr/CAG_v4_${align}.bed" \
-a "file=${f2}" \
-a "barcode=barcode${n}" \
/lustrehome/gianluca/straglr/jobs/condor-straglr_exp.job ; done ; done ; done | less -S
```

### Merge multiple *straglr* output - version CAG_v4.bed

```bash
cd /lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/107Q_NT_CTR_DIV34_DIV59_DIV90

for n in 01 02 03 04 05 06 07 08 09 10 11 12; do ls barcode${n}_v4_split*.tsv | grep aa | while read file ; do cat ${file} > barcode${n}_v4.tsv; done ; done

for n in 01 02 03 04 05 06 07 08 09 10 11 12; do ls barcode${n}_v4_split*.tsv | grep -v aa | while read file ; do cat ${file} | grep -v "#" >> barcode${n}_v4.tsv; done ; done

#cancel all .ok files created for job-control
rm *.ok
```

### Create folder to save on local computer with blastn+straglr+alignment_summary - version CAG_v4.bed

```bash
cd /lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/107Q_NT_CTR_DIV34_DIV59_DIV90

for n in 01 02 03 04 05 06 07 08 09 10 11 12; do mkdir barcode${n}_v4 ; done

ALIGNMENT=/lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/107Q_NT_CTR_DIV34_DIV59_DIV90/20220317_1624_MN37986_FAR88343_0f70353f/analysis/alignment

BLASTN=/lustrehome/gianluca/straglr/blastn/AC2021_NANOPORE_PCR10/107Q_NT_CTR_DIV34_DIV59_DIV90

STRAGLR=/lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/107Q_NT_CTR_DIV34_DIV59_DIV90

for n in 01 02 03 04 05 06 07 08 09 10 11 12; do cp ${ALIGNMENT}/barcode${n}_WG/alignment_summary.txt ${STRAGLR}/barcode${n}_v4/ &&  cp ${BLASTN}/barcode${n}* ${STRAGLR}/barcode${n}_v4/ &&  cp ${STRAGLR}/barcode${n}_v4.tsv ${STRAGLR}/barcode${n}_v4/ ; done 
```

### Rsync to local computer - version CAG_v4.bed

```bash
mkdir /Users/gianlucadamaggio/projects/cattaneo/straglr/AC2021_NANOPORE_PCR10/107Q_NT_CTR_DIV34_DIV59_DIV90/

for n in 01 02 03 04 05 06 07 08 09 10 11 12; do rsync -avh --progress gianluca@ui02.recas.ba.infn.it:/lustrehome/gianluca/straglr/output/AC2021_NANOPORE_PCR10/107Q_NT_CTR_DIV34_DIV59_DIV90/barcode${n}_v4 /Users/gianlucadamaggio/projects/cattaneo/straglr/AC2021_NANOPORE_PCR10/107Q_NT_CTR_DIV34_DIV59_DIV90/ ; done
```
-->