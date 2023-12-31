#
# Copyright 2023. All rights reserved.
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

### load input variables ###
args = commandArgs(trailingOnly=TRUE)

for(v in args)
{
  vTmp <- strsplit(v,"=")[[1]]
  assign(vTmp[[1]],vTmp[[2]])
}

library("tidyverse")
library("scales")
library("optparse")

#set balanced_ds <- 0 if you do not want to perform strand balancing
balanced_ds <- 0
#set skip downsampling_flag <- 1 if you want to skip downsampling
skip_downsampling_flag <- 1

#convert variables in numeric format
threshold <- as.numeric(strsplit(threshold, split = ",")[[1]])
minAlLength <- as.numeric(minAlLength)
queryCovThr <- as.numeric(queryCovThr)

#read sample sheet
sampleSheet <- read.table(normalizePath(sampleSheet_file), header = TRUE, sep = "\t", quote = "")
sampleNamesFull <- paste0(sampleSheet$Clone, "_", sampleSheet$PCR, "_", sampleSheet$Day, "_", sampleSheet$Replicate)
rownames(sampleSheet) <- sampleNamesFull

df_to_build <- data.frame(matrix(ncol = 10, nrow = 0))
df_final <- data.frame(matrix(ncol = 10, nrow = 0))

## set seed at beginning
set.seed(22)

## generate 100 numbers that will be used as seeds in the downsampling process
n_seed <- sample(10:1000, 100, replace = F)

## set the percentage of reads retained in the downsampling process
percentage <- 100

#find blast files
blast_files <- list.files(path = resultsDir, pattern = "_blastn\\.txt", recursive = TRUE, full.names = TRUE)
names(blast_files) <- basename(dirname(dirname(blast_files)))
#find alignment files
alignment_files <- list.files(path = resultsDir, pattern = "alignment_summary\\.txt", recursive = TRUE, full.names = TRUE)
names(alignment_files) <- basename(dirname(dirname(alignment_files)))
#find straglr tsv files
straglr_files <- grep(x = list.files(path = resultsDir, pattern = "\\.tsv", full.names = TRUE, recursive = TRUE), value = TRUE, pattern = "split|downsampling|sampleSheet", invert = TRUE)
names(straglr_files) <- basename(dirname(dirname(straglr_files)))

#extract days from sampleSheet
days <- sort(as.numeric(unique(sampleSheet$Day)))

#cycle across days
for (div in days) {
  #read rows of sample sheet corresponding to the current day
  names_split <- sampleSheet[which(sampleSheet$Day == div), c("Clone", "PCR", "Day", "Replicate")]
  ## READ ALL FILES IN THE DIRECTORY
  #read alignment files
  alignment_files_curr <- alignment_files[rownames(sampleSheet)[which(sampleSheet$Day == div)]]
  align_df <- lapply(alignment_files_curr, read.table, header = TRUE)
  #read blast files
  blast_files_curr <- blast_files[rownames(sampleSheet)[which(sampleSheet$Day == div)]]
  blast_df <- lapply(blast_files_curr, function(x) {
    blast <- try(read.table(file = x, sep = "\t", quote = "", header = FALSE))
    colnames(blast) <- c("read_id", "barcode", "pident", "length", "mismatch", "gapopen", "qstart", "qend", "sstart", "send", "evalue", "bitscore")
    return(blast)
  })
  ## SAVE BLAST INFORMATION
  genotype <- gsub(x = gsub(x = unique(basename(sampleSheet[which(sampleSheet$Day == div), "barcodeFile"])), pattern = "\\..*", replacement = ""), pattern = "barcode", replacement = "")
  #read straglr tsv files
  straglr_files_curr <- straglr_files[rownames(sampleSheet)[which(sampleSheet$Day == div)]]
  tsv_df <- lapply(straglr_files_curr, function(x) {
    header <-  gsub(x = read.table(file = x, sep = "\t", comment.char = "", quote = "", header = FALSE, nrows = 1, skip = 1), pattern = "#", replacement = "")
    header[6] <- "read_id"
    tsv <- try(read.table(file = x, sep = "\t", quote = "", header = FALSE))
    colnames(tsv) <- header
    return(tsv)
  })
  cat(sprintf("Loaded data day %s\n", as.character(div)))
  
  ## FILTER READS USING ALIGNMENT COVERAGE, GENOMIC COORDINATE AND BLAST SCORE
  for (clone in names(tsv_df)) {
    #filter aligned reads
    goodReads_aligned <- as.data.frame(align_df[[clone]]) %>% filter(alignment_genome %in% targetChr, alignment_coverage > queryCovThr) %>% select(read_id, alignment_direction)
    #filter reads with blast barcode
    reads_blast <- as.data.frame(blast_df[[clone]]) %>% filter(length >= minAlLength)
    #merge blast results for filtered reads with straglr results
    temp_filtered_reads <- merge(reads_blast, as.data.frame((tsv_df[[clone]])), by = "read_id", all.x = TRUE)
    #merge filtered reads for alignment to filtered reads for blast and straglr 
    filtered_reads <- merge(goodReads_aligned, temp_filtered_reads, by = "read_id", all.x = TRUE)
    #retain only reads which survive the 3 filters
    reads <- na.omit(filtered_reads)
    ## use the variable in the for loop as object one
    assign(paste0("good_reads_", clone), reads, envir = globalenv() )
  }
  cat(sprintf("Filtered reads day %s\n", as.character(div)))
  day <- as.character(div)
  for (m in ls()[str_detect(ls(), '^good_reads_')]) {
    df <- get(m)
    name <- gsub(x = m, pattern = "good_reads_", replacement = "")
    if(type == "len") {
      names(df)[names(df) == "copy_number"] <- "count"
      temp_count <- df %>% group_by(count) %>% tally()
    }
    if (type == "nCAG"){
      if (filter == "N"){
        names(df)[names(df) == "size"] <- "count"
        df$n_CAG <- round((df$count)/3)
        temp_count <- df %>% group_by(n_CAG) %>% tally()
        names(temp_count)[names(temp_count)=="n_CAG"] <- "count"
      } else {
        names(df)[names(df) == "size"] <- "count"
        df$n_CAG <- ((df$count)/3)
        # Filter out reads with x.7 or x.0 copies of the STR
        ind_filt <- which(df$n_CAG - floor(df$n_CAG) > 0.1 & df$n_CAG - floor(df$n_CAG) < 0.4)
        al_dir <- df$alignment_direction
        if (length(ind_filt) > 0) {
          temp_count <- data.frame(count = round(df$n_CAG[ind_filt]), strand = al_dir[ind_filt], day, genotype)  
        } else {
          temp_count <- c()
        }
      }
    }
    if (length(ind_filt) > 0)  {
      temp_count$clone <- strsplit(m, split = "_")[[1]][3]
      assign(paste0("filt_good_reads_", name), temp_count, envir = globalenv() ) 
    } else {
      names_split <- names_split[setdiff(rownames(names_split), name), ]
    }
  }
  ## DETECT THE LIMITING RUN (LESS ABUNDANT)
  names_good_file <- ls()[str_detect(ls(), 'filt_good_reads_')]
  df_get <- map(names_good_file, get)
  names(df_get) <- names_good_file
  
  #evaluate the number of reads by strand
  num_reads <- unlist(lapply(df_get, function(x) {
    plus <- length(which(x$strand == "+"))
    minus <- length(which(x$strand == "-"))
    all <- plus + minus
    both <- c(plus, minus, all)
    names(both) <- c("+", "-", "all")
    return(both)
  }))
  
  #evaluate the number of reads by strand for balanced or unbalanced downsampled
  num_reads_all <- num_reads[grep(x = names(num_reads), pattern = "\\.all")]
  num_reads_all_limiting <- min(num_reads[grep(x = names(num_reads), pattern = "\\.all")])
  num_reads_plus <- num_reads[grep(x = names(num_reads), pattern = "\\.\\+")]
  num_reads_minus <- num_reads[grep(x = names(num_reads), pattern = "\\.\\-")]
  num_reads_balanced_limiting <- min(c(num_reads_plus, num_reads_minus))
  #evaluate limiting sample
  limiting_all <- gsub(x = gsub(x = names(num_reads_all[which(num_reads_all == min(num_reads_all))]), pattern = "\\.all", replacement = ""), pattern = "filt_good_reads_", replacement = "")
  limiting_plus <- gsub(x = gsub(x = names(num_reads_plus[which(num_reads_plus == min(num_reads_plus))]), pattern = "\\.\\+", replacement = ""), pattern = "filt_good_reads_", replacement = "")
  limiting_minus <- gsub(x = gsub(x = names(num_reads_minus[which(num_reads_minus == min(num_reads_minus))]), pattern = "\\.\\-", replacement = ""), pattern = "filt_good_reads_", replacement = "")
  limiting_balanced <- gsub(x = gsub(x = names(num_reads[which(num_reads == min(num_reads))]), pattern = "\\.\\+|\\.\\-", replacement = ""), pattern = "filt_good_reads_", replacement = "")  
  
  if (balanced_ds == 1) {
    cat(sprintf("Limiting run for '+' strand: %s (%d reads)\n", limiting_plus, min(num_reads_plus)))
    cat(sprintf("Limiting run for '-' strand: %s (%d reads)\n", limiting_minus, min(num_reads_minus)))
    cat(sprintf("Limiting run for balanced downsampling: %s (%d reads)\n", limiting_balanced, num_reads_balanced_limiting))
  } else {
    cat(sprintf("Limiting run: %s (%d reads)\n", limiting_all, min(num_reads_all)))  
  }
  
  ## SET OPTION & CREATE EMPTY VECTOR
  clone_name <- c()
  sample_name <- c()
  replicates <- c()
  
  if (skip_downsampling_flag == 1) {
    for (i in 1:nrow(names_split)) {
      ## assign to each df the correct name
      name <- paste(names_split$Clone[i], names_split$PCR[i], names_split$Day[i], names_split$Replicate[i], sep = "_")
      df <- get(paste0('filt_good_reads_', name))
      df$seed <- 1
      df$replicate <- names_split[i, 4]
      df <- df[, setdiff(colnames(df), "strand")]
      df_downsampled <- df
      assign(paste0("downsampled_", name), df_downsampled, envir = globalenv() ) ## use the variable in the for loop as object one
    }
    ## MERGE THE DIFFERENT PCR FROM THE SAMPLE CLONE
    for (cl in unique(names_split$Clone)) {
      for (n in unique(names_split[which(names_split$Clone == cl), "Replicate"])) {
        # df_names = file downsampled
        ## check if we have clone and replicate binded:
        if (length(ls()[str_detect(ls(), n) & str_detect(ls(), paste0("downsampled_", cl, "_")) & str_detect(ls(), "downsampled_")]) > 0){
          df_names <- ls()[str_detect(ls(), n) & str_detect(ls(), paste0("downsampled_", cl, "_")) & str_detect(ls(), "downsampled_")]
          ## check df_names length to decide whether different PCRs from the same clone should be merged
          if (length(df_names) == 1) {
            temp_df <- get(df_names)
          } else {
            df_downsampled_1_full <- get(df_names[1])
            df_downsampled_2_full <- get(df_names[2]) 
            #merge the two dataframes
            temp_df <- rbind(df_downsampled_1_full, df_downsampled_2_full)
          }
        }
        df <- temp_df %>% group_by(clone, count, day, , seed, replicate) %>% tally()
        df_to_build <- rbind(df_to_build, df)
      }
    }
  } else {
    for (s in n_seed) {
      set.seed(s)
      ## DOWNSAMPLE EACH RUN USING THE LIMITING ONE
      for (i in 1:nrow(names_split)) {
        ## assign to each df the correct name
        name <- paste(names_split$Clone[i], names_split$PCR[i], names_split$Day[i], names_split$Replicate[i], sep = "_")
        df <- get(paste0('filt_good_reads_', name))
        df$seed <- s
        df$replicate <- names_split[i, 4]
        if (balanced_ds == 1) {
          df_plus <- df[which(df$strand == "+"), setdiff(colnames(df), "strand")]
          df_minus <- df[which(df$strand == "-"), setdiff(colnames(df), "strand")]
          df_plus_ds <- df_plus[sample(nrow(df_plus), size = num_reads_balanced_limiting * percentage/100, replace = FALSE), ]
          df_minus_ds <- df_minus[sample(nrow(df_minus), size = num_reads_balanced_limiting * percentage/100, replace = FALSE), ]
          df_downsampled <- rbind(df_plus_ds, df_minus_ds)
        } else {
          df <- df[, setdiff(colnames(df), "strand")]
          df_downsampled <- df[sample(nrow(df), size = num_reads_all_limiting * percentage/100, replace = FALSE), ]
        }
        assign(paste0("downsampled_", name), df_downsampled, envir = globalenv() ) ## use the variable in the for loop as object one
      }
      ## MERGE THE DIFFERENT PCR FROM THE SAMPLE CLONE
      for (cl in unique(names_split$Clone)) {
        for (n in unique(names_split[which(names_split$Clone == cl), "Replicate"])) {
          # df_names = file downsampled
          ## check if we have clone and replicate binded:
          if (length(ls()[str_detect(ls(), n) & str_detect(ls(), paste0("downsampled_", cl, "_")) & str_detect(ls(), "downsampled_")]) > 0){
            df_names <- ls()[str_detect(ls(), n) & str_detect(ls(), paste0("downsampled_", cl, "_")) & str_detect(ls(), "downsampled_")]
            ## check df_names length to decide whether different PCRs from the same clone should be merged
            if (length(df_names) == 1) {
              temp_df <- get(df_names)
            } else {
              df_downsampled_1_full <- get(df_names[1])
              df_downsampled_2_full <- get(df_names[2])
              if (balanced_ds == 1) {
                df_downsampled_1 <- df_downsampled_1_full[sample(nrow(df_downsampled_1_full), size = min(as.numeric(num_reads_balanced_limiting)) * percentage/100, replace = FALSE), ]
                df_downsampled_2 <- df_downsampled_2_full[sample(nrow(df_downsampled_2_full), size = min(as.numeric(num_reads_balanced_limiting)) * percentage/100, replace = FALSE), ]
              } else {
                df_downsampled_1 <- df_downsampled_1_full[sample(nrow(df_downsampled_1_full), size = min(as.numeric(num_reads_all_limiting)/2) * percentage/100, replace = FALSE), ]
                df_downsampled_2 <- df_downsampled_2_full[sample(nrow(df_downsampled_2_full), size = min(as.numeric(num_reads_all_limiting)/2) * percentage/100, replace = FALSE), ]
              }
              #merge the two dataframes
              temp_df <- rbind(df_downsampled_1, df_downsampled_2)
            }
            df <- temp_df %>% group_by(clone, count, day, genotype, seed, replicate) %>% tally()
            df_to_build <- rbind(df_to_build, df)
          }
        }
      }
    }
  }
  rm(list=(setdiff(ls(), c('df_final', 'df_to_build','n_seed','percentage', 'resultsDir', 'alignment_files', 'straglr_files', 'blast_files','type', 'filter', 'queryCovThr', 'targetChr', 'minAlLength', 'dayNorm', 'sampleSheet', 'threshold', 'balanced_ds', 'skip_downsampling_flag'))))
}
cat("Built final database\n")

names(df_to_build)[names(df_to_build) == "genotype"] <- "sample"
df_instability <- as.data.frame(df_to_build)
rm(df_to_build)

write.table(df_instability, paste0(resultsDir,"/instabilityComputation/preInstabilityIndex_downsampling.tsv"), quote = F, row.names = F, sep = "\t")
cat(sprintf("Written pre-Instability Index\n"))

#function to calculate adjusted Instability Index
instability_index <- function(dataframe, threshold, dayNorm) {
  #initialize variable
  temp_df_to_build <- data.frame(matrix(ncol = 10, nrow = 0))
  #cycle across samples
  for (s in unique(dataframe$sample)){
    #retain only entries with day > dayNorm
    dataframe = dataframe %>% filter(day >= dayNorm)
    #retrieve counts for starting day, used for adjusting II
    CN_max_freq <- as.integer(dataframe %>% filter(count > 0 , day == dayNorm , sample == s ) %>% select(count, n) %>% filter(count == count[which(n == max(n))][1]) %>% select(count))
    for (d in unique(dataframe$day)){
      #extract read counts
      df_count <-  dataframe %>% filter(!is.na(count), day == d, sample == s)
      #evaluate steps
      df_count$steps <- df_count$count - CN_max_freq
      #filter the data frame retaining only entries with count > mainPeak*thresh
      df_thresh <- df_count %>% filter(n > max(df_count$n) * threshold / 100 )
      #normalize filtered peaks
      df_norm_peaks <- df_thresh %>% mutate(norm_peaks = n/sum(df_thresh$n)) %>% data.frame
      #multiply steps by peaks heights
      df_norm_steps <- df_norm_peaks %>% mutate(norm_steps = norm_peaks * steps)
      #evaluate instability index
      df_instability_index <- df_norm_steps %>% mutate(instability_index = sum(norm_steps))
      #add threshold variable
      df_instability_index$threshold <- threshold
      #add row to df
      temp_df_to_build <- rbind(temp_df_to_build, df_instability_index)
    }
  }
  #initialize variable for adjusted II
  temp_df_to_build_adj <- data.frame(matrix(ncol = 10, nrow = 0))
  #cycle across samples
  for (s in unique(dataframe$sample)){
    #adjust II by subtracting II at day = dayNorm
    df_index_adj <- temp_df_to_build  %>%
      filter(threshold == threshold, sample == s ) %>%
      mutate(index_adj = instability_index - as.numeric(temp_df_to_build %>%
                                                          filter(threshold == threshold, sample == s , day == dayNorm) %>%
                                                          select(instability_index) %>%
                                                          head(1)))
    #add row to df
    temp_df_to_build_adj = rbind(temp_df_to_build_adj, df_index_adj)
    
  }
  #return adjusted II
  dataframe = temp_df_to_build_adj
  return(dataframe)
}

# 4. Iterate instability calculus for multiple time points and adjust the result with day dayNorm. Verbose Output.
for (clone in unique(df_instability$clone)){
  for (thresh in threshold) {
    for (s in unique(df_instability$seed)){
      for (rep in unique(df_instability$replicate)){
        temp_clone <- clone
        ## check if df_instability is empty:
        if (dim(df_instability %>% filter(seed == s, clone == temp_clone, replicate == rep))[1] > 0) {
          df_instability_index <- df_instability %>% filter(seed == s, clone == temp_clone, replicate == rep)
          test_instability <- instability_index(df_instability_index, thresh, 0)
          test_instability$seed <- s
          test_instability$d_adj <- 'd0'
          if (!dayNorm %in% c(0, "d0", "D0", "day0", "Day0", "DAY0")) {
            test_instability_diff <- instability_index(df_instability_index, thresh, dayNorm)
            test_instability_diff$seed <- s
            test_instability_diff$d_adj <- paste0("d", dayNorm)
            df_final <- rbind(df_final, test_instability, test_instability_diff)
          } else {
            df_final <- rbind(df_final, test_instability)
          }
        }
      }
    }
  }
}
# 5. Write output into a .TSV format.
write.table(df_final, paste0(resultsDir, "/instabilityComputation/InstabilityIndex_downsampling.tsv"), quote = F, row.names = F, sep = "\t")
cat(sprintf("Written adjusted Instability Index\n"))
