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

library("dplyr")
library("ggplot2")
library("emmeans")
library("ggpubr")
library("gridExtra")

Stats_II = function(II_full_file, thr = 20, dNorm = "d21", logFile = "", plotFile = "", Gt = "") {
  #read II file
  II_full <- read.table(II_full_file, sep = "\t", header = TRUE, quote = "")
  #extract filtered II at threshold thr
  II_full <- II_full[which(II_full$threshold == thr), ]
  #split file
  II_tmp <- split(x = data.frame(II_full$clone, II_full$day, II_full$replicate, II_full$seed, II_full$index_adj, II_full$d_adj), f = list(II_full$clone, II_full$day, II_full$replicate, II_full$seed, II_full$d_adj))
  #extract II for each downsampling (only first element for each seed is needed)
  II <- do.call(rbind, lapply(II_tmp, function(x) x[1, ]))
  colnames(II) <- c("Clone", "Day", "Replicate", "Seed", "II_index_adj", "d_adj")
  II <- na.omit(II)
  #extract II adjusted at dNorm
  II <- II[which(II$d_adj == dNorm), ]
  #reorder II
  II <- II[with(II, order(Clone, Day, Seed, Replicate)), ]
  #split II by Clone, Day and Replicate
  II_by_CloneDayReplicate <- split(x = II, f = list(II$Clone, II$Day, II$Replicate))
  #remove empty elements
  II_by_CloneDayReplicate <- II_by_CloneDayReplicate[which(unlist(lapply(II_by_CloneDayReplicate, function(x) dim(x)[1] > 0)))]
  #evaluate median II among all downsamplings, for each Clone, Day and Replicate
  II_median_downsampling_tmp <- lapply(II_by_CloneDayReplicate, function(x) {
    II_adj_median <- median(x$II_index_adj)
    data <- data.frame(Clone = as.character(x$Clone[1]), Day = as.numeric(x$Day[1]), Replicate = as.character(x$Replicate[1]), II_adj = as.numeric(II_adj_median))
  })
  II_median_downsampling <- do.call(rbind, II_median_downsampling_tmp)
  II_median_downsampling <- II_median_downsampling[names(apply(II_median_downsampling, 1, function(x) which(!any(is.na(x))))), ]
  #refactor variables
  II_median_downsampling$Clone <- as.factor(II_median_downsampling$Clone)
  II_median_downsampling$Replicate <- as.factor(II_median_downsampling$Replicate)
  rep_byClone <- unlist(lapply(split(II_median_downsampling$Replicate, II_median_downsampling$Clone), function(x) length(unique(x))))
  #if there are > 1 replicates
  if (any(rep_byClone > 1)) {
    p0 <- list()
    #for each clone, learn a linear model for each replicate and compare slopes -> evaluate whether replicates can be merged
    for (i in 1:length(which(rep_byClone > 1))) {
      clone_curr <- names(rep_byClone[which(rep_byClone > 1)][i])
      fit_byRep <- lm(II_adj ~ Day * Replicate, data = II_median_downsampling[which(II_median_downsampling$Clone == clone_curr), ])
      EMM_byRep <- emtrends(object = fit_byRep, specs = "Replicate", var = "Day")
      EMM_byRep_pairs <- pairs(EMM_byRep)
      EMM_byRep_pairs_pvalue <- summary(EMM_byRep_pairs)$p.value
      II_median_downsampling_clone_curr <- II_median_downsampling[II_median_downsampling$Clone == clone_curr, ]
      cat("", file = logFile)
      for (j in 1:length(EMM_byRep_pairs_pvalue)) {
        cat(sprintf("Clone: %s; comparing replicates: %s; p-value = %.3f\n", clone_curr, EMM_byRep_pairs@levels$contrast[j], EMM_byRep_pairs_pvalue[j]), file = logFile, append = TRUE)
      }
      p0[[i]] <- ggplot(II_median_downsampling_clone_curr, aes(x = Day, y = II_adj, group = Replicate, col = Replicate, shape = Clone)) +
        geom_point(size = 5) +
        ylab("Adjusted Instability Index") +
        xlab("Time (Days)") +
        theme(axis.text=element_text(size=10)) + 
        theme(axis.title=element_text(size=12)) +
        geom_smooth(method = 'lm', se = FALSE) +
        ggtitle(paste0(Gt, " - Adjusted II(t) by Replicate\nH0: Replicates are not different\n", paste0(sprintf("%s, p-value = %.3f", EMM_byRep_pairs@levels$contrast, EMM_byRep_pairs_pvalue), collapse = "\n"))) +
        theme(plot.title = element_text(size = 12)) +
        theme_classic() +
        scale_x_continuous(breaks = unique(II_median_downsampling_clone_curr$Day))
    }
    #average II among replicates
    cat(sprintf("Clone: %s; averaging replicates: %s\n", clone_curr, paste0(unique(II_median_downsampling$Replicate), collapse = ", ")), file = logFile, append = TRUE)
    II_median_downsampling_avgRep_tmp <- split(x = II_median_downsampling, f = list(II_median_downsampling$Clone, II_median_downsampling$Day))
    II_median_downsampling_avgRep_tmp <- II_median_downsampling_avgRep_tmp[which(unlist(lapply(II_median_downsampling_avgRep_tmp, function(x) dim(x)[1] > 0)))]
    II_median_downsampling_avgRep <- do.call(rbind, lapply(II_median_downsampling_avgRep_tmp, function(x) {if (dim(x)[1] > 1) { avgII_adj <- mean(x$II_adj); out <- data.frame(Clone = x$Clone[1], Day = x$Day[1], Replicate = "Avg", II_adj = avgII_adj)} else { out <- data.frame(Clone = x$Clone, Day = x$Day, Replicate = x$Replicate, II_adj = x$II_adj) }}))
  } else {
    p0 <- c()
    II_median_downsampling_avgRep <- II_median_downsampling
    cat("", file = logFile)
  }
  #if there are > 1 clones
  if (length(unique(II_median_downsampling$Clone)) > 1) {
    #learn a linear model for each clone and compare slopes -> evaluate whether clones can be merged
    fit_byClone <- lm(II_adj ~ Day * Clone, data = II_median_downsampling_avgRep)
    EMM_byClone <- emtrends(object = fit_byClone, specs = "Clone", var = "Day")
    EMM_byClone_pairs <- pairs(EMM_byClone)
    EMM_byClone_pairs_pvalue <- summary(EMM_byClone_pairs)$p.value
    for (j in 1:length(EMM_byClone_pairs_pvalue)) {
      cat(sprintf("Comparing clones: %s; p-value = %.3f\n", EMM_byClone_pairs@levels$contrast[j], EMM_byClone_pairs_pvalue[j]), file = logFile, append = TRUE)
    }
    p1 <- ggplot(II_median_downsampling_avgRep, aes(x = Day, y = II_adj, group = Clone, col = Clone)) +
      geom_point(size = 5) +
      ylab("Adjusted Instability Index") +
      xlab("Time (Days)") +
      theme(axis.text=element_text(size=10)) + 
      theme(axis.title=element_text(size=12)) +
      geom_smooth(method = 'lm', se = FALSE) +
      ggtitle(paste0(Gt, " - Adj. II(t) by Clone\nH0: Clones are not different\n",  paste0(sprintf("%s, p-value = %.3f", EMM_byClone_pairs@levels$contrast, EMM_byClone_pairs_pvalue), collapse = "\n"))) +
      theme(plot.title = element_text(size = 12)) +
      theme_classic() +
      scale_x_continuous(breaks = unique(II_median_downsampling_avgRep$Day))
  } else {
    p1 <- c()
  }
  #learn a linear model merging replicates and clones (if more than 1)
  fit_all <- lm(II_adj ~ Day, data = II_median_downsampling_avgRep)
  p2 <- ggplot(II_median_downsampling_avgRep, aes(x = Day, y = II_adj)) +
    geom_point(size = 5) +
    ylab("Adjusted Instability Index") +
    xlab("Time (Days)") +
    theme(axis.text=element_text(size=10)) + 
    theme(axis.title=element_text(size=12)) +
    geom_smooth(method = 'lm', se = FALSE, aes(color = c())) +
    ggtitle(paste0(Gt, " - Adj. II(t)")) +
    theme(plot.title = element_text(size = 12)) +
    theme_classic() +
    scale_x_continuous(breaks = unique(II_median_downsampling_avgRep$Day))
  #plot results
  if (length(p0) == 0) {
    p_tmp <- list(p1, p2)
  } else {
    p_tmp <- c(p0, list(p1, p2))
  }
  p <- marrangeGrob(grobs = p_tmp, nrow = 1, ncol = 1, top = NULL)
  ggsave(plotFile, p, device = "pdf", width = 6, height = 6)
  II_median_downsampling_avgRep$Gt <- Gt
  II_median_downsampling$Gt <- Gt
  write.table(II_median_downsampling, file = paste0(dirname(logFile), "/II_thr_", thr, "_dNorm_", dNorm, ".tsv"), sep = "\t", col.names = TRUE, row.names = FALSE, quote = FALSE)
  write.table(II_median_downsampling_avgRep, file = paste0(dirname(logFile), "/II_avgRep_thr_", thr, "_dNorm_", dNorm, ".tsv"), sep = "\t", col.names = TRUE, row.names = FALSE, quote = FALSE)
  return(list(fit_all, II_median_downsampling, II_median_downsampling_avgRep))
}
Compare_gt = function(II_full_files_split, group, thr, dNorm) {
  #initialize variables
  fit_currGroup <- list()
  II_currGroup <- list()
  II_currGroup_avgRep <- list()
  #cycle across available genotypes in the current group
  for (currGt in 1:length(II_full_files_split[[which(names(II_full_files_split) == group)]])) {
    #extract file corresponding to current genotype
    II_full_file <- II_full_files_split[[which(names(II_full_files_split) == group)]][currGt]
    #set output files for plots and logs
    logFile <- paste0(dirname(II_full_file), "/logFile.txt")
    plotFile <- paste0(dirname(II_full_file), "/plotFile.pdf")
    #extract Genotype
    Gt <- gsub(x = gsub(x = basename(dirname(dirname(II_full_file))), pattern = "_output", replacement = ""), pattern = "_Diff", replacement = "")
    #do plots, extract adjusted II for each clone and day, keeping the median value of downsamplings and averaging replicates
    tmp <- Stats_II(II_full_file, thr, dNorm, logFile, plotFile, Gt)
    #extract variables of interest
    fit_currGroup[[currGt]] <- tmp[[1]]
    II_currGroup[[currGt]] <- tmp[[2]]
    II_currGroup_avgRep[[currGt]] <- tmp[[3]]
    #assign genotype
    names(fit_currGroup[currGt]) <- Gt
    names(II_currGroup)[currGt] <- Gt
    names(II_currGroup_avgRep)[currGt] <- Gt
  }
  #convert into dataframe
  II_currGroup_avgRep_df <- do.call(rbind, II_currGroup_avgRep)
  return(II_currGroup_avgRep_df)
}
Do_ANOVA = function(II_adj_df, logFile) {
  II_adj_df$Day <- factor(II_adj_df$Day, levels = unique(sort(II_adj_df$Day)))
  #perform two-way ANOCA
  two.way <- aov(II_adj ~ Gt * Day, data = II_adj_df)
  sink(logFile)
  print(summary(two.way))
  #perform post-hoc comparisons
  tukey.two.way <- TukeyHSD(x = two.way, which = "Gt")
  print(tukey.two.way)
  sink()
  #plot(tukey.two.way, las = 2, cex.axis = 0.5)
}

II_full_files <- list.files(path = "/path/to/results/dir/", pattern = "^InstabilityIndex_downsampling\\.tsv", full.names = TRUE, recursive = TRUE)

polyQLen <- gsub(x = gsub(x = basename(dirname(dirname(II_full_files))), pattern = "_.*", replacement = ""), pattern = "_Diff", replacement = "")
ind_Diff <- rep("SR", length(II_full_files))
ind_Diff[grep(x = II_full_files, pattern = "_Diff")] <- "Diff"
ind_Mod <- rep("Mod", length(II_full_files))
ind_Mod[grep(x = II_full_files, pattern = "_NO_MOD_")] <- "No_mod"

II_full_files_SR_No_mod <- II_full_files[intersect(which(ind_Diff == "SR"), which(ind_Mod == "No_mod"))]
II_full_files_Diff_No_mod <-  II_full_files[intersect(which(ind_Diff == "Diff"), which(ind_Mod == "No_mod"))]
II_full_files_SR_Mod_45Q <-  II_full_files[intersect(which(ind_Diff == "SR"), which(polyQLen == "45Q"))]
II_full_files_SR_Mod_81Q <-  II_full_files[intersect(which(ind_Diff == "SR"), which(polyQLen == "81Q"))]
II_full_files_SR_Mod_107Q <-  II_full_files[intersect(which(ind_Diff == "SR"), which(polyQLen == "107Q"))]
II_full_files_Diff_Mod_107Q <-  II_full_files[intersect(which(ind_Diff == "Diff"), which(polyQLen == "107Q"))]

II_full_files_split <- list(SR_No_mod = II_full_files_SR_No_mod, Diff_No_mod = II_full_files_Diff_No_mod,
                          SR_45Q_Mod = II_full_files_SR_Mod_45Q, SR_81Q_Mod = II_full_files_SR_Mod_81Q, 
                          SR_107Q_Mod = II_full_files_SR_Mod_107Q, Diff_107Q_Mod = II_full_files_Diff_Mod_107Q)

#Self-Renewal No Modifications
II_SR_No_mod_df = Compare_gt(II_full_files_split = II_full_files_split, group = "SR_No_mod", thr = 20, dNorm = "d0")
II_SR_No_mod_df$Gt <- gsub(x = II_SR_No_mod_df$Gt, pattern = "_NO_MOD", replacement = "")
II_SR_No_mod_df$Gt <- factor(II_SR_No_mod_df$Gt, levels = c("21Q", "45Q", "50Q", "81Q", "107Q"))
#Differentiation No Modifications
II_Diff_No_mod_df = Compare_gt(II_full_files_split = II_full_files_split, group = "Diff_No_mod", thr = 20, dNorm = "d21")
II_Diff_No_mod_df$Gt <- gsub(x = II_Diff_No_mod_df$Gt, pattern = "_NO_MOD", replacement = "")
II_Diff_No_mod_df$Gt <- factor(II_Diff_No_mod_df$Gt, levels = c("21Q", "45Q", "50Q", "81Q", "107Q"))
#Self-Reneval Modifications 45Q
II_SR_45Q_Mod_df = Compare_gt(II_full_files_split = II_full_files_split, group = "SR_45Q_Mod", thr = 20, dNorm = "d0")
II_SR_45Q_Mod_df$Gt <- gsub(x = II_SR_45Q_Mod_df$Gt, pattern = "_NO_MOD", replacement = "")
II_SR_45Q_Mod_df$Gt[which(II_SR_45Q_Mod_df$Gt == "45Q_LOI")] <- "43Q_LOI"
II_SR_45Q_Mod_df$Gt <- factor(II_SR_45Q_Mod_df$Gt, levels = c("45Q", "43Q_LOI"))
#Self-Reneval Modifications 81Q
II_SR_81Q_Mod_df = Compare_gt(II_full_files_split = II_full_files_split, group = "SR_81Q_Mod", thr = 20, dNorm = "d0")
II_SR_81Q_Mod_df$Gt <- gsub(x = II_SR_81Q_Mod_df$Gt, pattern = "_NO_MOD", replacement = "")
II_SR_81Q_Mod_df$Gt <- factor(II_SR_81Q_Mod_df$Gt, levels = c("81Q", "81Q_LOI", "81Q_DUP"))
#Self-Reneval Modifications 107Q
II_SR_107Q_Mod_df = Compare_gt(II_full_files_split = II_full_files_split, group = "SR_107Q_Mod", thr = 20, dNorm = "d0")
II_SR_107Q_Mod_df$Gt <- gsub(x = II_SR_107Q_Mod_df$Gt, pattern = "_NO_MOD", replacement = "")
II_SR_107Q_Mod_df$Gt <- factor(II_SR_107Q_Mod_df$Gt, levels = c("107Q", "107Q_LOI", "107Q_DUP", "107Q_CI"))
#Differentiation Modifications 107Q
II_Diff_107Q_Mod_df = Compare_gt(II_full_files_split = II_full_files_split, group = "Diff_107Q_Mod", thr = 20, dNorm = "d21")
II_Diff_107Q_Mod_df$Gt <- gsub(x = II_Diff_107Q_Mod_df$Gt, pattern = "_NO_MOD", replacement = "")
II_Diff_107Q_Mod_df$Gt <- factor(II_Diff_107Q_Mod_df$Gt, levels = c("107Q", "107Q_LOI", "107Q_DUP", "107Q_CI"))
############
p4 <- ggplot(II_SR_No_mod_df, aes(x = Day, y = II_adj, group = Gt, col = Gt, fill = Gt)) +
  geom_point(size = 5) +
  ylab("Adjusted Instability Index") +
  xlab("Time (Days)") +
  theme(axis.text=element_text(size=10)) + 
  theme(axis.title=element_text(size=12)) +
  theme_classic() +
  geom_smooth(method = 'lm', se = FALSE) +
  scale_x_continuous(breaks = unique(II_SR_No_mod_df$Day)) +
  scale_color_manual(values=c("red", "#619CFF", "blue", "purple", "#00BA3B")) +
  scale_fill_manual(values=c("red", "#619CFF", "blue", "purple", "#00BA3B"))
ggsave("SR_No_mod.pdf", p4, device = "pdf", width = 6, height = 6)
Do_ANOVA(II_SR_No_mod_df, "SR_No_mod.txt")

p5 <- ggplot(II_Diff_No_mod_df, aes(x = Day, y = II_adj, group = Gt, col = Gt, fill = Gt)) +
  geom_point(size = 5) +
  ylab("Adjusted Instability Index") +
  xlab("Time (Days)") +
  theme(axis.text=element_text(size=10)) + 
  theme(axis.title=element_text(size=12)) +
  theme_classic() +
  geom_smooth(method = 'lm', se = FALSE) +
  scale_x_continuous(breaks = unique(II_Diff_No_mod_df$Day))+
  scale_color_manual(values=c("red", "#619CFF", "purple", "#00BA3B")) +
  scale_fill_manual(values=c("red", "#619CFF", "purple", "#00BA3B"))

ggsave("Diff_No_mod.pdf", p5, device = "pdf", width = 6, height = 6)
Do_ANOVA(II_Diff_No_mod_df, "Diff_No_mod.txt")

p6 <- ggplot(II_SR_45Q_Mod_df, aes(x = Day, y = II_adj, group = Gt, col = Gt, fill = Gt)) +
  geom_point(size = 5) +
  ylab("Adjusted Instability Index") +
  xlab("Time (Days)") +
  theme(axis.text=element_text(size=10)) + 
  theme(axis.title=element_text(size=12)) +
  theme_classic() +
  geom_smooth(method = 'lm', se = FALSE) +
  scale_x_continuous(breaks = unique(II_SR_45Q_Mod_df$Day))+
  scale_color_manual(values=c("#619CFF", "#90EE90")) +
  scale_fill_manual(values=c("#619CFF", "#90EE90"))
ggsave("SR_45Q_Mod.pdf", p6, device = "pdf", width = 6, height = 6)
Do_ANOVA(II_SR_45Q_Mod_df, "SR_45Q_Mod.txt")

II_SR_81Q_Mod_df_noLOI <- II_SR_81Q_Mod_df[II_SR_81Q_Mod_df$Gt != "81Q_LOI", ]
p7 <- ggplot(II_SR_81Q_Mod_df_noLOI, aes(x = Day, y = II_adj, group = Gt, col = Gt, fill = Gt)) +
  geom_point(size = 5) +
  ylab("Adjusted Instability Index") +
  xlab("Time (Days)") +
  theme(axis.text=element_text(size=10)) + 
  theme(axis.title=element_text(size=12)) +
  theme_classic() +
  geom_smooth(method = 'lm', se = FALSE) +
  scale_x_continuous(breaks = unique(II_SR_81Q_Mod_df$Day)) +
  scale_color_manual(values=c("purple", "#F3C6EF")) +
  scale_fill_manual(values=c("purple", "#F3C6EF"))
ggsave("SR_81Q_Mod.pdf", p7, device = "pdf", width = 6, height = 6)
Do_ANOVA(II_SR_81Q_Mod_df, "SR_81Q_Mod.txt")

p8 <- ggplot(II_SR_107Q_Mod_df, aes(x = Day, y = II_adj, group = Gt, col = Gt, fill = Gt)) +
  geom_point(size = 5) +
  ylab("Adjusted Instability Index") +
  xlab("Time (Days)") +
  theme(axis.text=element_text(size=10)) + 
  theme(axis.title=element_text(size=12)) +
  theme_classic() +
  geom_smooth(method = 'lm', se = FALSE) +
  scale_x_continuous(breaks = unique(II_SR_107Q_Mod_df$Day))  +
  scale_color_manual(values=c("#00BA3B", "#E924B6", "#FF6C00", "aquamarine")) +
  scale_fill_manual(values=c("#00BA3B", "#E924B6", "#FF6C00", "aquamarine"))
ggsave("SR_107Q_Mod.pdf", p8, device = "pdf", width = 6, height = 6)
Do_ANOVA(II_SR_107Q_Mod_df, "SR_107Q_Mod.txt")

p9 <- ggplot(II_Diff_107Q_Mod_df, aes(x = Day, y = II_adj, group = Gt, col = Gt, fill = Gt)) +
  geom_point(size = 5) +
  ylab("Adjusted Instability Index") +
  xlab("Time (Days)") +
  theme(axis.text=element_text(size=10)) + 
  theme(axis.title=element_text(size=12)) +
  theme_classic() +
  geom_smooth(method = 'lm', se = FALSE) +
  scale_x_continuous(breaks = unique(II_Diff_107Q_Mod_df$Day))
ggsave("Diff_107Q_Mod.pdf", p9, device = "pdf", width = 6, height = 6)
Do_ANOVA(II_Diff_107Q_Mod_df, "Diff_107Q_Mod.txt")

ggarrange(p4, p5, ncol = 1, nrow = 2)
ggsave("/Users/SimoneMaestri/Pipelines/Rainbowdash/No_mods.pdf", width = 6, height = 6)
ggarrange(p6, p7, p8, ncol = 1, nrow = 3)
ggsave("/Users/SimoneMaestri/Pipelines/Rainbowdash/Mods.pdf", width = 6, height = 6)