
# plot_vg_sim_overlap_hprc.R

rm(list=ls())

library("dplyr")
library("readr")
library("tibble")
library("tidyr")
library("purrr")
library("ggplot2")
library("wesanderson")
library("ggrepel")
library("scales")

parse_file <- function(filename) {
  
  dir_split <- strsplit(dirname(filename), "/")[[1]]
  
  data <- read_table(filename)
  data <- data %>%
    add_column(Method = dir_split[2]) %>%
    add_column(Graph = dir_split[3]) 

  return(data)
}

plotRocCurveMapq <- function(data, cols) {
  
  data$Graph <- recode_factor(data$Graph, 
                                      "grch38_gencode38" = "Spliced reference",
                                      "1kg_nygc_no001trio_af001_gencode38_k32" = "1000GP spliced graph",
                                      "minigraph_cactus_grch38_f1_clip_d9_m1k_D10M_m1k_cat_gencode38_vgrna_k32" = "HPRC spliced graph")
  
  data$Graph <- factor(data$Graph, levels = c("HPRC spliced graph", "1000GP spliced graph", "Spliced reference"))
  
  data$Method <- recode_factor(data$Method, 
                                       "star" = "STAR",
                                       "mpmap" = "vg mpmap")
  
  data$Method <- factor(data$Method, levels = c("vg mpmap", "STAR"))
  
  data <- data %>%
    mutate(TP = Count * Correct) %>% 
    mutate(FP = Count * !Correct)
  
  data %>% group_by(Method, Graph, FacetRow, FacetCol) %>% summarise(Count = sum(Count)) %>% print()
  
  data_roc <- data %>% 
    mutate(MapQ = ifelse(IsMapped, MapQ, -1)) %>% 
    group_by(Method, Graph, FacetRow, FacetCol, MapQ) %>%
    summarise(TP = sum(TP), FP = sum(FP)) %>% 
    arrange(desc(MapQ), .by_group = T) %>%
    group_by(Method, Graph, FacetRow, FacetCol) %>%
    mutate(N = sum(TP) + sum(FP)) %>%
    mutate(TPcs = cumsum(TP), FPcs = cumsum(FP)) %>%
    mutate(FNcs = N - TPcs - FPcs) %>%
    mutate(TPR = TPcs / (TPcs + FNcs), FDR = FPcs / (FPcs + TPcs)) %>%
    filter(MapQ >= 0)
  
  min_lim_x <- min(data_roc$TPR)
  
  data_roc %>% filter(MapQ == 0 | MapQ == 60 | MapQ == 255) %>% print()
  
  a <- annotation_logticks(sides = "l")
  a$data <- data.frame(x = NA, FacetCol = c(as.character(data_roc$FacetCol[1])))
  
  p <- data_roc %>%
    ggplot(aes(y = FDR, x = TPR, color = Method, linetype = Graph, shape = Graph, label = MapQ)) +
    a +
    geom_line(size = 1) +
    geom_point(data = subset(data_roc, MapQ == 0 | MapQ == 1 | MapQ == 60 | MapQ == 255), size = 2, alpha = 1) +
    geom_text_repel(data = subset(data_roc, MapQ == 0 | MapQ == 1 | MapQ == 60| MapQ == 255), size = 3.5, fontface = 2, show.legend = FALSE, nudge_y = -0.06) +
    scale_y_continuous(trans='log10') +
    facet_grid(FacetRow ~ FacetCol) +
    scale_color_manual(values = cols) +
    xlim(c(min_lim_x, 1)) +
    xlab("Mapping true positive rate") +
    ylab("Mapping false discovery rate") +
    theme_bw() +
    theme(aspect.ratio = 1) +
    theme(strip.background = element_blank()) +
    theme(panel.spacing = unit(0.5, "cm")) +
    theme(legend.key.width = unit(1.2, "cm")) +
    theme(text = element_text(size = 13)) +
    theme(legend.text = element_text(size = 12))
  print(p)   
}

cols <- c(rev(wes_palette("Rushmore1")[c(1,3,4,5)]), wes_palette("Darjeeling1")[c(5)], wes_palette("Royal2")[c(1,2)])

set.seed(12345678)
overlap_threshold <- 90

overlap_data <- map_dfr(list.files(pattern=".*_ovl3.txt", full.names = T, recursive = T), parse_file)  %>%
  mutate(Correct = Overlap >= (overlap_threshold / 100)) %>%
  filter(TruthAlignmentLength > 50) 

overlap_data <- overlap_data 

overlap_data$FacetCol <- "Simulated reads (HG002)"
overlap_data$FacetRow <- ""

pdf("hprc_rnaseq_sim_hg002_map_roc_2605.pdf", height = 5, width = 7, pointsize = 12)
plotRocCurveMapq(overlap_data, cols)
dev.off() 
