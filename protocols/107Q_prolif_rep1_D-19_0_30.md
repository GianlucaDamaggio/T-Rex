# AC2021_NANOPORE_PCR10 107Q_prolif_div-19_div0_div30


#### Basecalling
```
cd /lustrehome/gianluca/strique/jobs/AC2021_NANOPORE_PCR10/107Q_prolif_div-19_div0_div30/
./submit_chronos_gianluca guppy-gianluca-job-prolif-basecalling.json
```

#### STRIQUE INDEX
```
cd /lustrehome/gianluca/strique/jobs/AC2021_NANOPORE_PCR10/107Q_prolif_div-19_div0_div30/
condor_submit -name ettore condor-striqueIndex.job
```

#### alignment reads "both_ends" with PCR fragment
```
cd /lustrehome/gianluca/strique/jobs/AC2021_NANOPORE_PCR10/107Q_prolif_div-19_div0_div30/
for n in $(seq 13 24); do ./submit_chronos_gianluca guppy-gianluca-job-prolif-align${n}.json ; done
```

#### numero di reads allineate con fasta 107Q flippato (senza NEO)
```
for n in $(seq 13 24) ; do cat barcode$n/alignment_summary.txt | grep 107Q | wc -l ; done
```
|barcode |reads number|
|------|--------------|
| barcode13 | 390867  |
| barcode14 | 413112  |
| barcode15 | 339500  |
| barcode16 | 349115  |
| barcode17 | 355277  |
| barcode18 | 295978  |
| barcode19 | 382411  |
| barcode20 | 178698  |
| barcode21 | 45023   |
| barcode22 | 32107   |
| barcode23 | 39602   |
| barcode24 | 31913   |

#### 3.2 - STRique count Analysis
##### 3.2.1 concat all SAM file after alignment
```
for n in $(seq 13 24); do bash /lustre/home/enza/cattaneo/src/concatSAM_split4STRique_PCR10.sh /lustre/home/enza/cattaneo/data/AC2021_NANOPORE_PCR10/107Q_prolif_div-19_div0_div30/20210910_1823_MN29119_FAQ65926_067e1781/analysis/alignment/barcode${n} 107Q ; done
```

```
for c in $(seq 13 24); do ls barcode${c}/split_fq_* | while IFS="$(printf '/')" read -r f1 f2 ; do for n in 10 ; do echo condor_submit -name ettore -a "sam=/lustre/home/enza/cattaneo/data/AC2021_NANOPORE_PCR10/107Q_prolif_div-19_div0_div30/20210910_1823_MN29119_FAQ65926_067e1781/analysis/alignment/barcode${c}/${f2}" -a "fofn=/lustre/home/enza/cattaneo/data/AC2021_NANOPORE_PCR10/107Q_prolif_div-19_div0_div30/20210910_1823_MN29119_FAQ65926_067e1781/fast5/reads.fofn" -a "config=/lustre/home/enza/cattaneo/config_file/AC2021_NANOPORE_PCR10/HTT_config_AC2021_NANOPORE_PCR10_150_770bp_CAG.tsv" -a "output=/lustrehome/gianluca/strique/striqueOutput/AC2021_NANOPORE_PCR10/107Q_prolif_div-19_div0_div30/barcode${c}/AC_barcode${c}_prolif.${f2}.qs10.150_770bp_CAG.tsv" -a "file=${f2}" -a "barcode=${c}" /lustrehome/gianluca/strique/jobs/AC2021_NANOPORE_PCR10/107Q_prolif_div-19_div0_div30/condor-striqueCount_exp.job ; done ; done; done | wc -l
```

#### 4.2 Merge splitted STRique output
```
for n in $(seq 13 24) ;  do cp barcode${n}/AC_barcode${n}_prolif.split_fq_aa.qs10.150_770bp_CAG.tsv barcode${n}/AC_barcode${n}_prolif.qs10.150_770bp_CAG.tsv ; done

for n in $(seq 13 24) ; do ls barcode${n}/AC_barcode${n}_prolif.split_fq_* | grep -v aa | while read line ; do cat $line | tail -n+2 >> barcode${n}/AC_barcode${n}_prolif.qs10.150_770bp_CAG.tsv ; done ; done
```


# AC2021_NANOPORE_PCR10 Plurip_c4_DIV35 Plurip_c21_DIV35 Plurip_c1_DIV34 Plurip_c25_DIV34

#### Basecalling
```
cd /lustrehome/gianluca/strique/jobs/AC2021_NANOPORE_PCR10/Plurip_c4_DIV35/
./submit_chronos_gianluca guppy-gianluca-job-prolif-basecalling.json

cd /lustrehome/gianluca/strique/jobs/AC2021_NANOPORE_PCR10/Plurip_c21_DIV35/
./submit_chronos_gianluca guppy-gianluca-job-prolif-basecalling.json

cd /lustrehome/gianluca/strique/jobs/AC2021_NANOPORE_PCR10/Plurip_c1_DIV34/
./submit_chronos_gianluca guppy-gianluca-job-prolif-basecalling.json

cd /lustrehome/gianluca/strique/jobs/AC2021_NANOPORE_PCR10/Plurip_c25_DIV34/
./submit_chronos_gianluca guppy-gianluca-job-prolif-basecalling.json
```

#### STRIQUE INDEX
```
cd /lustrehome/gianluca/strique/jobs/AC2021_NANOPORE_PCR10/Plurip_c4_DIV35/
condor_submit -name ettore condor-striqueIndex.job

cd /lustrehome/gianluca/strique/jobs/AC2021_NANOPORE_PCR10/Plurip_c21_DIV35/
condor_submit -name ettore condor-striqueIndex.job

cd /lustrehome/gianluca/strique/jobs/AC2021_NANOPORE_PCR10/Plurip_c1_DIV34/
condor_submit -name ettore condor-striqueIndex.job

cd /lustrehome/gianluca/strique/jobs/AC2021_NANOPORE_PCR10/Plurip_c25_DIV34/
condor_submit -name ettore condor-striqueIndex.job
```

#### alignment reads "both_ends" with PCR fragment
```
cd /lustrehome/gianluca/strique/jobs/AC2021_NANOPORE_PCR10/Plurip_c4_DIV35/
./submit_chronos_gianluca guppy-gianluca-job-prolif-align.json

cd /lustrehome/gianluca/strique/jobs/AC2021_NANOPORE_PCR10/Plurip_c21_DIV35/
./submit_chronos_gianluca guppy-gianluca-job-prolif-align.json

cd /lustrehome/gianluca/strique/jobs/AC2021_NANOPORE_PCR10/Plurip_c1_DIV34/
./submit_chronos_gianluca guppy-gianluca-job-prolif-align.json

cd /lustrehome/gianluca/strique/jobs/AC2021_NANOPORE_PCR10/Plurip_c25_DIV34/
./submit_chronos_gianluca guppy-gianluca-job-prolif-align.json
```

#### numero di reads allineate con fasta 107Q flippato (senza NEO)
```
cat /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c21_DIV35/20210915_1534_MN37986_AHJ235_abab1e6b/analysis/alignment/alignment_summary.txt | grep 107Q | wc -l

cat /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c4_DIV35/20210914_1550_MN37986_AHJ024_4805f915/analysis/alignment/alignment_summary.txt | grep 107Q | wc -l

cat /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c25_DIV34/20210915_1748_MN29119_AHI878_6fd99a18/analysis/alignment/alignment_summary.txt | grep 107Q | wc -l

cat /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c1_DIV34/20210914_1733_MN29119_AHJ047_2dd526c8/analysis/alignment/alignment_summary.txt | grep 107Q | wc -l

```
|barcode |reads number|
|------|--------------|
| c1 | 182964  |
| c4 | 205300  |
| c21 | 81565  |
| c25 | 102983  |


#### 3.2 - STRique count Analysis
##### 3.2.1 concat all SAM file after alignment
```
bash /lustre/home/enza/cattaneo/src/concatSAM_split4STRique_PCR10.sh /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c21_DIV35/20210915_1534_MN37986_AHJ235_abab1e6b/analysis/alignment/ 107Q

bash /lustre/home/enza/cattaneo/src/concatSAM_split4STRique_PCR10.sh /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c4_DIV35/20210914_1550_MN37986_AHJ024_4805f915/analysis/alignment/ 107Q

bash /lustre/home/enza/cattaneo/src/concatSAM_split4STRique_PCR10.sh /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c25_DIV34/20210915_1748_MN29119_AHI878_6fd99a18/analysis/alignment/ 107Q

bash /lustre/home/enza/cattaneo/src/concatSAM_split4STRique_PCR10.sh /lustrehome/gianluca/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c1_DIV34/20210914_1733_MN29119_AHJ047_2dd526c8/analysis/alignment/ 107Q

```

```

cd /lustre/home/enza/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c21_DIV35/20210915_1534_MN37986_AHJ235_abab1e6b/analysis/

for c in c21 ; do ls alignment/split_fq_* | while IFS="$(printf '/')" read -r f1 f2 ; do for n in 10 ; do echo condor_submit -name ettore -a "sam=/lustre/home/enza/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c21_DIV35/20210915_1534_MN37986_AHJ235_abab1e6b/analysis/alignment/${f2}" -a "fofn=/lustre/home/enza/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c21_DIV35/20210915_1534_MN37986_AHJ235_abab1e6b/fast5/reads.fofn" -a "config=/lustre/home/enza/cattaneo/config_file/AC2021_NANOPORE_PCR10/HTT_config_AC2021_NANOPORE_PCR10_150_770bp_CAG.tsv" -a "output=/lustrehome/gianluca/strique/striqueOutput/AC2021_NANOPORE_PCR10/Plurip_c21_DIV35/AC_barcode${c}_prolif_c21_DIV35.${f2}.qs10.150_770bp_CAG.tsv" -a "file=${f2}" -a "barcode=${c}" /lustrehome/gianluca/strique/jobs/AC2021_NANOPORE_PCR10/Plurip_c21_DIV35/condor-striqueCount_exp.job ; done ; done; done | wc -l


cd /lustre/home/enza/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c4_DIV35/20210914_1550_MN37986_AHJ024_4805f915/analysis/

for c in c4 ; do ls alignment/split_fq_* | while IFS="$(printf '/')" read -r f1 f2 ; do for n in 10 ; do echo condor_submit -name ettore -a "sam=/lustre/home/enza/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c4_DIV35/20210914_1550_MN37986_AHJ024_4805f915/analysis/alignment/${f2}" -a "fofn=/lustre/home/enza/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c4_DIV35/20210914_1550_MN37986_AHJ024_4805f915/fast5/reads.fofn" -a "config=/lustre/home/enza/cattaneo/config_file/AC2021_NANOPORE_PCR10/HTT_config_AC2021_NANOPORE_PCR10_150_770bp_CAG.tsv" -a "output=/lustrehome/gianluca/strique/striqueOutput/AC2021_NANOPORE_PCR10/Plurip_c4_DIV35/AC_barcode${c}_prolif_c4_DIV35.${f2}.qs10.150_770bp_CAG.tsv" -a "file=${f2}" -a "barcode=${c}" /lustrehome/gianluca/strique/jobs/AC2021_NANOPORE_PCR10/Plurip_c4_DIV35/condor-striqueCount_exp.job ; done ; done; done | wc -l


cd /lustre/home/enza/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c25_DIV34/20210915_1748_MN29119_AHI878_6fd99a18/analysis/

for c in c25 ; do ls alignment/split_fq_* | while IFS="$(printf '/')" read -r f1 f2 ; do for n in 10 ; do echo condor_submit -name ettore -a "sam=/lustre/home/enza/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c25_DIV34/20210915_1748_MN29119_AHI878_6fd99a18/analysis/alignment/${f2}" -a "fofn=/lustre/home/enza/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c25_DIV34/20210915_1748_MN29119_AHI878_6fd99a18/fast5/reads.fofn" -a "config=/lustre/home/enza/cattaneo/config_file/AC2021_NANOPORE_PCR10/HTT_config_AC2021_NANOPORE_PCR10_150_770bp_CAG.tsv" -a "output=/lustrehome/gianluca/strique/striqueOutput/AC2021_NANOPORE_PCR10/Plurip_c25_DIV34/AC_barcode${c}_prolif_c25_DIV34.${f2}.qs10.150_770bp_CAG.tsv" -a "file=${f2}" -a "barcode=${c}" /lustrehome/gianluca/strique/jobs/AC2021_NANOPORE_PCR10/Plurip_c25_DIV34/condor-striqueCount_exp.job ; done ; done; done | wc -l


cd /lustre/home/enza/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c1_DIV34/20210914_1733_MN29119_AHJ047_2dd526c8/analysis/

for c in c1 ; do ls alignment/split_fq_* | while IFS="$(printf '/')" read -r f1 f2 ; do for n in 10 ; do echo condor_submit -name ettore -a "sam=/lustre/home/enza/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c1_DIV34/20210914_1733_MN29119_AHJ047_2dd526c8/analysis/alignment/${f2}" -a "fofn=/lustre/home/enza/cattaneo/data/AC2021_NANOPORE_PCR10/Plurip_c1_DIV34/20210914_1733_MN29119_AHJ047_2dd526c8/fast5/reads.fofn" -a "config=/lustre/home/enza/cattaneo/config_file/AC2021_NANOPORE_PCR10/HTT_config_AC2021_NANOPORE_PCR10_150_770bp_CAG.tsv" -a "output=/lustrehome/gianluca/strique/striqueOutput/AC2021_NANOPORE_PCR10/Plurip_c1_DIV34/AC_barcode${c}_prolif_c1_DIV34.${f2}.qs10.150_770bp_CAG.tsv" -a "file=${f2}" -a "barcode=${c}" /lustrehome/gianluca/strique/jobs/AC2021_NANOPORE_PCR10/Plurip_c1_DIV34/condor-striqueCount_exp.job ; done ; done; done | wc -l
```

```
for n in c1_DIV34 c4_DIV35 c21_DIV35 c25_DIV34 ;  do echo cp Plurip_${n}/*_prolif_${n}.split_fq_aa.qs10.150_770bp_CAG.tsv Plurip_${n}/AC_${n}_prolif.qs10.150_770bp_CAG.tsv ; done | less -S

for n in c1_DIV34 c4_DIV35 c21_DIV35 c25_DIV34 ; do ls Plurip_${n}/*_prolif_${n}.split_fq_* | grep -v aa | while read line ; do cat $line | tail -n+2 >> Plurip_${n}/AC_${n}_prolif.qs10.150_770bp_CAG.tsv ; done ; done
```
##### Merge prolif -19,0 and 30 days

```
for n in c1_DIV34 ; do cat Plurip_${n}/AC_${n}_prolif.qs10.150_770bp_CAG.tsv | tail -n +2 >> 107Q_prolif_div-19_div0_div30/barcode21/AC_barcode21_prolif.qs10.150_770bp_CAG.tsv ; done

for n in c4_DIV35 ; do cat Plurip_${n}/AC_${n}_prolif.qs10.150_770bp_CAG.tsv | tail -n +2 >> 107Q_prolif_div-19_div0_div30/barcode22/AC_barcode22_prolif.qs10.150_770bp_CAG.tsv ; done

for n in c21_DIV35 ; do cat Plurip_${n}/AC_${n}_prolif.qs10.150_770bp_CAG.tsv | tail -n +2 >> 107Q_prolif_div-19_div0_div30/barcode23/AC_barcode23_prolif.qs10.150_770bp_CAG.tsv ; done

for n in c25_DIV34 ; do cat Plurip_${n}/AC_${n}_prolif.qs10.150_770bp_CAG.tsv | tail -n +2 >> 107Q_prolif_div-19_div0_div30/barcode24/AC_barcode24_prolif.qs10.150_770bp_CAG.tsv ; done
```
##### Merge prolif -19,0 and 30 days alignment_summary.txt

```
cd /Users/gianlucadamaggio/projects/cattaneo/docs/AC2021_NANOPORE_PCR10/alignment

cat Plurip_c1_DIV34/alignment_summary.txt | tail -n +2 >> 107Q_prolif_div-19_div0_div30/barcode21/alignment_summary.txt

cat Plurip_c4_DIV35/alignment_summary.txt | tail -n +2 >> 107Q_prolif_div-19_div0_div30/barcode22/alignment_summary.txt

cat Plurip_c21_DIV35/alignment_summary.txt | tail -n +2 >> 107Q_prolif_div-19_div0_div30/barcode23/alignment_summary.txt

cat Plurip_c25_DIV34/alignment_summary.txt | tail -n +2 >> 107Q_prolif_div-19_div0_div30/barcode24/alignment_summary.txt

```

# Multiple Peaks Detection (MPD)
~ re-run old experiment for improve the peaks detection

#### using multiple peaks detection for spike-in 45q_105q (PASTECS : -log2(pvalue) > 5 ; MFT : window_len = 20,25,30 ; Z-SCORE : lag = 15,20,25,30, treshold = 4.5, influence = 0.1)
## QSCORE 10 alignment vanilla & m13_barcode

## qscore10
```
for p in $(seq 13 20) ; do for c in long; do Rscript /Users/gianlucadamaggio/projects/cattaneo/docs/AC2021_NANOPORE_PCR10/peaksDetectComp_2021_PCR10.R -p AC2021_NANOPORE_barcode${p} -e '105' -l $c -m '10,15,16,17,18,19,20' -z '15,20,25,30' -s /Users/gianlucadamaggio/projects/cattaneo/striqueOutput/AC2021_NANOPORE_PCR10/107Q_prolif_div-19_div0_div30/barcode${p}/AC_barcode${p}_prolif.qs10.150_770bp_CAG.tsv -a /Users/gianlucadamaggio/projects/cattaneo/docs/AC2021_NANOPORE_PCR10/alignment/107Q_prolif_div-19_div0_div30/barcode${p}/alignment_summary.txt  -f /Users/gianlucadamaggio/Desktop/multiplePeaksDetector/multiplePeaksDetector_AC2021_NANOPORE_PCR10/107Q_prolif_div-19_div0_div30/barcode${p}/ ; done ;done

for p in $(seq 21 24) ; do for c in long; do Rscript /Users/gianlucadamaggio/projects/cattaneo/docs/AC2021_NANOPORE_PCR10/peaksDetectComp_2021_PCR10.R -p AC2021_NANOPORE_barcode${p} -e '105' -l $c -m '10,15,20' -z '20,25,30' -s /Users/gianlucadamaggio/projects/cattaneo/striqueOutput/AC2021_NANOPORE_PCR10/107Q_prolif_div-19_div0_div30/barcode${p}/AC_barcode${p}_prolif.qs10.150_770bp_CAG.tsv -a /Users/gianlucadamaggio/projects/cattaneo/docs/AC2021_NANOPORE_PCR10/alignment/107Q_prolif_div-19_div0_div30/barcode${p}/alignment_summary.txt  -f /Users/gianlucadamaggio/Desktop/multiplePeaksDetector/multiplePeaksDetector_AC2021_NANOPORE_PCR10/107Q_prolif_div-19_div0_div30/barcode${p}/ ; done ;done
```
