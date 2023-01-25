
# plot_cov_cor_hprc_r1.R

rm(list=ls())

library("dplyr")
library("readr")
library("tibble")
library("tidyr")
library("purrr")
library("ggplot2")
library("gridExtra")
library("wesanderson")
library("ggrepel")
library("scales")


parse_file <- function(filename) {
  
  dir_split <- strsplit(dirname(filename), "/")[[1]]
  
  data <- read_table(filename)
  
  data <- data %>%
    add_column(Reads = dir_split[2]) %>%
    add_column(Method = dir_split[3]) %>%
    add_column(Graph = dir_split[4])
  
  return(data)
}

plotStatsBarTwoLayer <- function(data_bar, prefix, cols) {
  
  data_bar <- data_bar %>%
    ungroup() %>%
    add_row(Reads = "SRR1153470", Method = "STAR", Graph = "MC spliced graph", Corr = 0) %>%
    add_row(Reads = "ENCSR000AED (rep1)", Method = "STAR", Graph = "MC spliced graph", Corr = 0) 
  
  data_bar$Reads <- factor(data_bar$Reads, levels = c("SRR1153470", "ENCSR000AED (rep1)"))
  
  data_bar$Graph <- factor(data_bar$Graph, levels = c("MC spliced graph", "Spliced GRCh38 reference"))
  
  data_bar$Method <- factor(data_bar$Method, levels = c("vg mpmap", "STAR"))
  
  data_bar$FacetCol <- data_bar$Reads
  data_bar$FacetRow <- ""
  
  data_bar <- data_bar %>%
    rename(Reference = Graph)
  
  data_bar %>% print(n = 100)
  
  p <- data_bar %>%
    ggplot(aes(Method, y = Corr, fill = Reference)) +
    geom_bar(stat = "identity", width = 0.5, position = position_dodge()) +
    scale_fill_manual(values = cols) +
    facet_grid(FacetRow ~ FacetCol) +
    xlab("") +
    ylab("Iso-Seq exon coverage correlation") +
    theme_bw() +
    theme(strip.background = element_blank()) +
    theme(panel.spacing = unit(0.5, "cm")) +
    theme(text = element_text(size = 10)) +
    theme(legend.text = element_text(size = 7)) +
    theme(legend.text.align = 0) +
    theme(legend.key.size = unit(0.5, 'cm'))
  
  pdf(paste(prefix, ".pdf", sep = ""), height = 4, width = 6, pointsize = 12, useDingbats = F)
  print(p)
  dev.off() 
  
  write.table(data_bar, file = paste(prefix, ".txt", sep = ""), sep = "\t", row.names = F, col.names = T, quote = F)
}

set.seed(12345678)

cols <- c(rev(wes_palette("Rushmore1")[c(1,3,4,5)]))

print(list.files(path = "ENCSR706ANY", pattern = ".*.txt.gz", full.names = T, recursive = T))

iso_coverage <- read_table(list.files(path = "ENCSR706ANY", pattern = ".*.txt.gz", full.names = T, recursive = T)[1]) %>%
  mutate(ReadCoverage = Count * ReadCoverage) %>%
  mutate(BaseCoverage = Count * BaseCoverage) %>%
  group_by(AllelePosition, ExonSize) %>%
  summarise(ReadCoverage = sum(ReadCoverage), BaseCoverage = sum(BaseCoverage))

iso_coverage %>%
  filter(ExonSize == 0) %>%
  print()

print(list.files(pattern = "cov_eval.*.txt", full.names = T, recursive = T))

coverage_data <- map_dfr(list.files(pattern = "cov_eval.*.txt", full.names = T, recursive = T), parse_file)

coverage_data %>%
  filter(ExonSize == 0) %>%
  print()

coverage_data$Graph <- recode_factor(coverage_data$Graph, 
                                     "grch38_gencode38" = "Spliced GRCh38 reference",
                                     "minigraph_cactus_grch38_f1_clip_d9_m1k_D10M_m1k_cat_gencode38_vgrna_k32" = "MC spliced graph")

coverage_data$Method <- recode_factor(coverage_data$Method, 
                                      "star" = "STAR",
                                      "mpmap" = "vg mpmap")

coverage_data$Reads <- recode_factor(coverage_data$Reads, 
                                     "SRR1153470" = "SRR1153470",
                                     "ENCSR000AED_rep1" = "ENCSR000AED (rep1)")


coverage_data_mq <- coverage_data %>%
  mutate(Count = ifelse(MapQ < 30, 0, Count)) %>%
  mutate(ReadCoverage = Count * ReadCoverage) %>%
  mutate(BaseCoverage = Count * BaseCoverage) %>%
  group_by(AllelePosition, ExonSize, Reads, Method, Graph) %>%
  summarise(ReadCoverage = sum(ReadCoverage), BaseCoverage = sum(BaseCoverage))

coverage_data_pb_mq <- right_join(iso_coverage, coverage_data_mq, by = c("AllelePosition", "ExonSize")) %>%
  mutate(BaseCoverage.x_norm = BaseCoverage.x / ExonSize) %>%
  mutate(BaseCoverage.y_norm = BaseCoverage.y / ExonSize) 

coverage_data_pb_mq_corr <- coverage_data_pb_mq %>%
  group_by(Reads, Method, Graph) %>%
  summarise(Corr = cor(BaseCoverage.x_norm, BaseCoverage.y_norm, method = "pearson")) %>%
  add_column(cor_type = "Pearson")


plotStatsBarTwoLayer(coverage_data_pb_mq_corr, "hprc_rnaseq_real_map_cov_cor_ENCSR706ANY", cols)
