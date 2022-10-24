
# plot_vg_sim_bias_hprc_r1.R

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

plotBiasBinom <- function(data_bias, prefix, cols, alpha_thres, min_count) {

  data_bias$var <- factor(data_bias$var, levels = c("SNV", "Insertion", "Deletion", "Complex"))
  
  data_bias$Graph <- factor(data_bias$Graph, levels = c("MC spliced graph", "Spliced GRCh38 reference"))
    
  data_bias$Method <- factor(data_bias$Method, levels = c("vg mpmap", "STAR"))
  
  data_bias$FacetCol <- data_bias$var
  data_bias$FacetRow <- "Simulated reads (HG002), primary alignments"
  
  data_bias <- data_bias %>%
    ungroup() %>%
    mutate(ref = (ref_up + ref_down) / 2) %>%
    mutate(alt = (alt_up + alt_down) / 2) %>%
    filter(ref + alt >= min_count) %>%
    mutate(count = ref + alt) %>%
    rowwise() %>%
    mutate(p_val = binom.test(x = c(round(ref), round(alt)), alternative = "two.sided")$p.value) %>%
    group_by(Method, Graph, FacetCol, FacetRow) %>%
    summarise(n = n(), n_bias = sum(p_val <= alpha_thres))
  
  data_bias <- data_bias %>%
    rename(Reference = Graph)
  
  data_bias %>% print(n = 100)

  p <- data_bias %>% 
    ggplot(aes(y = n_bias / n, x = n, color = Reference, shape = Method)) +
    geom_hline(yintercept = alpha_thres, size = 0.25, linetype = 1, alpha = 0.75) + 
    geom_point(size = 1.75) +
    scale_color_manual(values = cols) +
    facet_wrap(~ FacetCol, scales = "free") +
    xlab(bquote("Number of variants (coverage">=.(min_count)*")")) +
    ylab(bquote("Fraction of biased variants ("*alpha==.(alpha_thres)*")")) +
    theme_bw() +
    theme(aspect.ratio = 1) +
    theme(strip.background = element_blank()) +
    theme(panel.spacing = unit(0.5, "cm")) +
    theme(legend.key.width = unit(1.2, "cm")) +
    theme(text = element_text(size = 10)) +
    theme(legend.text = element_text(size = 9))
  
  pdf(paste(prefix, ".pdf", sep = ""), height = 5, width = 8, pointsize = 12, useDingbats = F)
  print(p)
  dev.off()
  
  write.table(data_bias, file = paste(prefix, ".txt", sep = ""), sep = "\t", row.names = F, col.names = T, quote = F)
}

set.seed(12345678)

cols <- c(rev(wes_palette("Rushmore1")[c(1,3,4,5)]))

print(list.files(pattern="cov_eval.*.txt", full.names = T, recursive = T))

coverage_data <- map_dfr(list.files(pattern="cov_eval.*.txt", full.names = T, recursive = T), parse_file)

coverage_data_mq <- coverage_data %>%
  filter(abs(RelativeAlleleLength) <= 50) %>%
  mutate(UpReadCount = ifelse(MapQ < 30, 0, UpReadCount)) %>%
  mutate(DownReadCount = ifelse(MapQ < 30, 0, DownReadCount)) %>%
  group_by(VariantPosition, AlleleId, AlleleType, RelativeAlleleLength, Method, Graph) %>%
  summarise(UpReadCount = sum(UpReadCount), DownReadCount = sum(DownReadCount)) 

coverage_data_mq <- full_join(coverage_data_mq[coverage_data_mq$AlleleId == 1,], coverage_data_mq[coverage_data_mq$AlleleId == 2,], by = c("VariantPosition", "Method", "Graph"))

coverage_data_mq <- coverage_data_mq %>% 
  filter((AlleleType.x != AlleleType.y) & (AlleleType.x == "REF" | AlleleType.y == "REF")) %>% 
  mutate(ref_up = ifelse(AlleleType.x == "REF", UpReadCount.x, UpReadCount.y)) %>%
  mutate(ref_down = ifelse(AlleleType.x == "REF", DownReadCount.x, DownReadCount.y)) %>%
  mutate(alt_up = ifelse(AlleleType.x != "REF", UpReadCount.x, UpReadCount.y)) %>%
  mutate(alt_down = ifelse(AlleleType.x != "REF", DownReadCount.x, DownReadCount.y)) %>%
  mutate(var = ifelse(AlleleType.x == "REF", AlleleType.y, AlleleType.x)) %>%
  mutate(len = ifelse(AlleleType.x == "REF", RelativeAlleleLength.y, RelativeAlleleLength.x))

coverage_data_mq$var = recode_factor(coverage_data_mq$var, 
                                     "SNV" = "SNV", 
                                     "INS" = "Insertion", 
                                     "DEL" = "Deletion", 
                                     "COM" = "Complex")

coverage_data_mq$Graph <- recode_factor(coverage_data_mq$Graph, 
                            "grch38_gencode38" = "Spliced GRCh38 reference",
                            "minigraph_cactus_grch38_f1_clip_d9_m1k_D10M_m1k_cat_gencode38_vgrna_k32" = "MC spliced graph")

coverage_data_mq$Method <- recode_factor(coverage_data_mq$Method, 
                             "star" = "STAR",
                             "mpmap" = "vg mpmap")


plotBiasBinom(coverage_data_mq, "hprc_rnaseq_sim_hg002_map_bias_a001", cols, 0.01, 20)

