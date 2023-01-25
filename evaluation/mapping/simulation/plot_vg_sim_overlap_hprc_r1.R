
# plot_vg_sim_overlap_hprc_r1.R

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
library("grid")
library("gridExtra")


parse_file <- function(filename) {
  
  dir_split <- strsplit(dirname(filename), "/")[[1]]
  
  data <- read_table(filename)
  data <- data %>%
    add_column(Method = dir_split[2]) %>%
    add_column(Graph = dir_split[3]) 

  return(data)
}

plotBars <- function(data, prefix, cols) {
  
  data <- data %>%
    mutate(TP = Count * Correct) %>% 
    mutate(FP = Count * !Correct)
  
  data_roc <- data %>% 
    mutate(MapQ = ifelse(IsMapped, MapQ, -1)) %>% 
    group_by(Eval, Method, Graph, MapQ) %>%
    summarise(TP = sum(TP), FP = sum(FP)) %>% 
    arrange(desc(MapQ), .by_group = T) %>%
    group_by(Eval, Method, Graph) %>%
    mutate(N = sum(TP) + sum(FP)) %>%
    mutate(TPcs = cumsum(TP), FPcs = cumsum(FP)) %>%
    mutate(FNcs = N - TPcs - FPcs) %>%
    mutate(TPR = TPcs / (TPcs + FNcs), PPV = TPcs / (FPcs + TPcs)) %>%
    filter(MapQ >= 0)
  
  data_roc %>% filter(Method == "STAR") %>% print() 
  
  data_prim <- data_roc %>% 
    filter(Eval == "Primary") %>%
    filter((Method == "vg mpmap" & MapQ == 30) | (Method == "STAR" & MapQ == 255))
  
  data_multi <- data_roc %>% 
    filter(Eval == "Mulit-mapping") %>%
    filter(MapQ == 0) 
  
  data_prim_multi <- rbind(data_prim, data_multi) %>%
    select(Eval, Method, Graph, N, TPR, PPV)
  
  data_prim_multi <- data_prim_multi %>%
    ungroup() %>%
    add_row(Eval = "Primary", Method = "STAR", Graph = "MC spliced graph", TPR = 0, PPV = 0) %>%
    add_row(Eval = "Mulit-mapping", Method = "STAR", Graph = "MC spliced graph", TPR = 0, PPV = 0) 
    
  data_prim_multi$Eval <- recode_factor(data_prim_multi$Eval, 
                                       "Primary" = "Unique alignments",
                                       "Mulit-mapping" = "Multi alignments")

  data_prim_multi$Eval <- factor(data_prim_multi$Eval, levels = c("Unique alignments", "Multi alignments"))
  
  data_prim_multi$Graph <- factor(data_prim_multi$Graph, levels = c("MC spliced graph", "Spliced GRCh38 reference"))
  
  data_prim_multi$Method <- factor(data_prim_multi$Method, levels = c("vg mpmap", "STAR"))

  data_prim_multi$FacetCol <- ""
  data_prim_multi$FacetRow <- "Simulated reads (HG002)"
  
  data_prim_multi <- data_prim_multi %>%
    rename(Reference = Graph)
  
  min_frac_tpr <- data_prim_multi %>% filter(TPR > 0) %>% ungroup() %>% summarise(frac = min(TPR))
  min_frac_ppv <- data_prim_multi %>% filter(PPV > 0) %>% ungroup() %>% summarise(frac = min(PPV))
  
  data_prim_multi %>% print(n = 100)
  
  p1 <- data_prim_multi %>% 
    ggplot(aes(Method, y = TPR, fill = Reference)) +
    geom_bar(stat = "identity", width = 0.5, position = position_dodge()) +
    scale_fill_manual(values = cols) +
    scale_y_continuous(limits = c(floor(min_frac_tpr$frac * 20) / 20, 1), oob = rescale_none) +
    facet_grid(FacetRow ~ Eval) +
    xlab("") +
    ylab("Mapping recall") +
    theme_bw() +
    theme(strip.background = element_blank()) +
    theme(panel.spacing = unit(0.5, "cm")) +
    theme(text = element_text(size = 10)) +
    theme(legend.text = element_text(size = 7)) +
    theme(legend.key.size = unit(0.5, 'cm'))
  
  p2 <- data_prim_multi %>% 
    ggplot(aes(Method, y = PPV, fill = Reference)) +
    geom_bar(stat = "identity", width = 0.5, position = position_dodge()) +
    scale_fill_manual(values = cols) +
    scale_y_continuous(limits = c(floor(min_frac_ppv$frac * 20) / 20, 1), oob = rescale_none) +
    facet_grid(FacetRow ~ Eval) +
    xlab("") +
    ylab("Mapping precision") +
    theme_bw() +
    theme(strip.background = element_blank()) +
    theme(panel.spacing = unit(0.5, "cm")) +
    theme(text = element_text(size = 10)) +
    theme(legend.text = element_text(size = 7)) +
    theme(legend.key.size = unit(0.5, 'cm'))
  
  pdf(paste(prefix, ".pdf", sep = ""), height = 6, width = 5, pointsize = 12, useDingbats = F)
  grid.arrange(p1, p2, nrow = 2)
  dev.off()
  
  write.table(data_prim_multi, file = paste(prefix, ".txt", sep = ""), sep = "\t", row.names = F, col.names = T, quote = F)
}

plotPoints <- function(data, prefix, cols) {
  
  data <- data %>%
    mutate(TP = Count * Correct) %>% 
    mutate(FP = Count * !Correct)
  
  data_roc <- data %>% 
    mutate(MapQ = ifelse(IsMapped, MapQ, -1)) %>% 
    group_by(Eval, Method, Graph, MapQ) %>%
    summarise(TP = sum(TP), FP = sum(FP)) %>% 
    arrange(desc(MapQ), .by_group = T) %>%
    group_by(Eval, Method, Graph) %>%
    mutate(N = sum(TP) + sum(FP)) %>%
    mutate(TPcs = cumsum(TP), FPcs = cumsum(FP)) %>%
    mutate(FNcs = N - TPcs - FPcs) %>%
    mutate(TPR = TPcs / (TPcs + FNcs), PPV = TPcs / (FPcs + TPcs)) %>%
    filter(MapQ >= 0)
  
  data_roc %>% filter(Method == "STAR") %>% print() 
  
  data_prim <- data_roc %>% 
    filter(Eval == "Primary") %>%
    filter((Method == "vg mpmap" & MapQ == 30) | (Method == "STAR" & MapQ == 255))
  
  data_multi <- data_roc %>% 
    filter(Eval == "Mulit-mapping") %>%
    filter(MapQ == 0) 
  
  data_prim$Method <- recode_factor(data_prim$Method, 
                                        "vg mpmap" = "vg mpmap (unique)",
                                        "STAR" = "STAR (unique)")
  
  data_multi$Method <- recode_factor(data_multi$Method, 
                                    "vg mpmap" = "vg mpmap (multi)",
                                    "STAR" = "STAR (multi)")
  
  data_prim_multi <- rbind(data_prim, data_multi) %>%
    select(Eval, Method, Graph, N, TPR, PPV)
  
  data_prim_multi$Graph <- factor(data_prim_multi$Graph, levels = c("MC spliced graph", "Spliced GRCh38 reference"))
  
  data_prim_multi$Method <- factor(data_prim_multi$Method, levels = c("vg mpmap (unique)", "vg mpmap (multi)", "STAR (unique)", "STAR (multi)"))
  
  data_prim_multi$FacetCol <- "Simulated reads (HG002)"
  data_prim_multi$FacetRow <- ""
  
  data_prim_multi <- data_prim_multi %>%
    rename(Reference = Graph)
  
  min_frac_tpr <- data_prim_multi %>% filter(TPR > 0) %>% ungroup() %>% summarise(val = min(TPR))
  min_frac_ppv <- data_prim_multi %>% filter(PPV > 0) %>% ungroup() %>% summarise(val = min(PPV))
  
  data_prim_multi %>% print(n = 100)
  
  p <- data_prim_multi %>% 
    ggplot(aes(y = PPV, x = TPR, color = Reference, shape = Method)) +
    geom_point(size = 2) +
    scale_color_manual(values = cols) +
    facet_grid(FacetRow ~ FacetCol) +
    xlab("Mapping recall") +
    ylab("Mapping precision") +
    xlim(c(min(min_frac_tpr$val, min_frac_ppv$val), 1)) +
    ylim(c(min(min_frac_tpr$val, min_frac_ppv$val), 1)) +
    theme_bw() +
    theme(aspect.ratio = 1) +
    theme(strip.background = element_blank()) +
    theme(panel.spacing = unit(0.5, "cm")) +
    theme(legend.key.width = unit(1.2, "cm")) +
    theme(text = element_text(size = 10)) +
    theme(legend.text = element_text(size = 9))
  
  pdf(paste(prefix, ".pdf", sep = ""), height = 5, width = 6, pointsize = 12, useDingbats = F)
  print(p)
  dev.off()
  
  write.table(data_prim_multi, file = paste(prefix, ".txt", sep = ""), sep = "\t", row.names = F, col.names = T, quote = F)
}

set.seed(12345678)

cols <- c(rev(wes_palette("Rushmore1")[c(1,3,4,5)]))

print(list.files(pattern="bam_eval.*ovl3.txt", full.names = T, recursive = T))

overlap_data_raw <- map_dfr(list.files(pattern="bam_eval.*ovl3.txt", full.names = T, recursive = T), parse_file) %>%
  filter(TruthAlignmentLength >= 75) 

overlap_data_raw %>% group_by(Graph, Method) %>%
  summarise(Count = sum(Count)) %>%
  print(n = 100)

overlap_data_raw_prim <- overlap_data_raw %>%
  mutate(MapQ = PrimaryMapq) %>%
  mutate(Overlap = PrimaryOverlap) %>%
  mutate(Eval = "Primary")

overlap_data_raw_multi <- overlap_data_raw %>%
  mutate(MapQ = GroupMapQ) %>%
  mutate(Eval = "Mulit-mapping")

overlap_data <- rbind(overlap_data_raw_prim, overlap_data_raw_multi) %>%
  mutate(Correct = Overlap >= 0.9) 

overlap_data$Graph <- recode_factor(overlap_data$Graph, 
                            "grch38_gencode38" = "Spliced GRCh38 reference",
                            "minigraph_cactus_grch38_f1_clip_d9_m1k_D10M_m1k_cat_gencode38_vgrna_k32" = "MC spliced graph")

overlap_data$Method <- recode_factor(overlap_data$Method, 
                             "star" = "STAR",
                             "mpmap" = "vg mpmap")


plotBars(overlap_data, "hprc_rnaseq_sim_hg002_map_eval_bars", cols)

plotPoints(overlap_data, "hprc_rnaseq_sim_hg002_map_eval_points", cols)

