
# plot_cov_cor_hprc.R

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

plotMapQCurve <- function(data, cols) {
  
  p <- data %>%
    ggplot(aes(y = Corr, x = Threshold, color = Method, linetype = Graph, shape = Graph)) +
    geom_line(size = 0.75) +
    geom_point(size = 1.25) +
    facet_grid(FacetRow ~ FacetCol) +
    scale_color_manual(values = cols) +
    xlab("Mapping quality threshold") +
    ylab("Iso-Seq exon coverage correlation") +
    theme_bw() +
    theme(aspect.ratio = 1) +
    theme(strip.background = element_blank()) +
    theme(panel.spacing = unit(0.5, "cm")) +
    theme(legend.key.width = unit(1, "cm")) +
    theme(text = element_text(size = 11)) +
    theme(legend.text = element_text(size = 10))
  print(p)
}

cols <- c(rev(wes_palette("Rushmore1")[c(1,3,4,5)]), wes_palette("Darjeeling1")[c(5)], wes_palette("Royal2")[c(1,2)])
set.seed(12345678)

iso_coverage <- read_table(list.files(path = "ENCSR706ANY", pattern = ".*.txt.gz", full.names = T, recursive = T)[1]) %>%
  mutate(ReadCoverage = Count * ReadCoverage) %>%
  mutate(BaseCoverage = Count * BaseCoverage) %>%
  group_by(AllelePosition, ExonSize) %>%
  summarise(ReadCoverage = sum(ReadCoverage), BaseCoverage = sum(BaseCoverage))

iso_coverage %>%
  filter(ExonSize == 0) %>%
  print()
  
coverage_data <- map_dfr(list.files(pattern = ".*cov_eval.*primary_mapq30.txt.gz", full.names = T, recursive = T), parse_file) %>%
  mutate(MapQ = ifelse(MapQ > 60, 60, MapQ))

coverage_data %>%
  filter(ExonSize == 0) %>%
  print()

coverage_data$Graph <- recode_factor(coverage_data$Graph, 
                                    "grch38_gencode38" = "Spliced reference",
                                    "1kg_nygc_no001trio_af001_gencode38_k32" = "1000GP spliced graph",
                                    "minigraph_cactus_grch38_f1_clip_d9_m1k_D10M_m1k_cat_gencode38_vgrna_k32" = "HPRC spliced graph")

coverage_data$Graph <- factor(coverage_data$Graph, levels = c("HPRC spliced graph", "1000GP spliced graph", "Spliced reference"))

coverage_data$Method <- recode_factor(coverage_data$Method, 
                                     "star" = "STAR",
                                     "mpmap" = "vg mpmap")

coverage_data$Method <- factor(coverage_data$Method, levels = c("vg mpmap", "STAR"))

coverage_data$Reads <- recode_factor(coverage_data$Reads, 
                                      "SRR1153470" = "SRR1153470",
                                      "ENCSR000AED_rep1" = "ENCSR000AED (rep1)")

coverage_data$Reads <- factor(coverage_data$Reads, levels = c("SRR1153470", "ENCSR000AED (rep1)"))

coverage_data_pb_mq_corr_list <- list()

for (i in c(0, 1, seq(5, 60, 5))) { 
  
  print(i)
  
  coverage_data_mq <- coverage_data %>%
    mutate(Count = ifelse(MapQ < i, 0, Count)) %>%
    mutate(ReadCoverage = Count * ReadCoverage) %>%
    mutate(BaseCoverage = Count * BaseCoverage) %>%
    group_by(AllelePosition, ExonSize, Reads, Method, Graph) %>%
    summarise(ReadCoverage = sum(ReadCoverage), BaseCoverage = sum(BaseCoverage))
  
  coverage_data_pb_mq <- right_join(iso_coverage, coverage_data_mq, by = c("AllelePosition", "ExonSize")) %>%
    mutate(BaseCoverage.x_norm = BaseCoverage.x / ExonSize) %>%
    mutate(BaseCoverage.y_norm = BaseCoverage.y / ExonSize) 
  
  coverage_data_pb_mq_corr_pear <- coverage_data_pb_mq %>%
    group_by(Reads, Method, Graph) %>%
    summarise(num_bases = sum(BaseCoverage.y), Corr = cor(BaseCoverage.x_norm, BaseCoverage.y_norm, method = "pearson")) %>%
    add_column(Threshold = i) %>%
    add_column(cor_type = "Pearson")
    
  coverage_data_pb_mq_corr_list[[as.character(i)]] <- coverage_data_pb_mq_corr_pear
}

coverage_data_pb_mq_corr <- do.call(rbind, coverage_data_pb_mq_corr_list)

coverage_data_pb_mq_corr$FacetCol <- coverage_data_pb_mq_corr$Reads
coverage_data_pb_mq_corr$FacetRow <- ""

pdf(paste("hprc_rnaseq_real_map_cov_cor_ENCSR706ANY.pdf", sep = ""), height = 5, width = 7, pointsize = 12)
plotMapQCurve(coverage_data_pb_mq_corr, cols)
dev.off() 

