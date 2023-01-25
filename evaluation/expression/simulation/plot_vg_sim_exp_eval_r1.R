
# plot_vg_sim_exp_eval_r1.R

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


parse_salmon <- function(filename) {
  
  dir_split <- strsplit(dirname(filename), "/")[[1]]
  
  exp_data <- read_table(filename, col_names = T) %>%
    add_column(Method = dir_split[3]) %>%
    add_column(Reference = dir_split[4]) %>%
    rename(name = Name, tpm_est = TPM, count_est = NumReads, length = Length) %>%
    select(-EffectiveLength)

  return(exp_data)
}

parse_rsem <- function(filename) {
  
  dir_split <- strsplit(dirname(filename), "/")[[1]]
  
  exp_data <- read_table(filename, col_names = T) %>%
    add_column(Method = dir_split[3]) %>%
    add_column(Reference = dir_split[4]) %>%
    rename(name = transcript_id, tpm_est = TPM, count_est = expected_count) %>%
    select(-gene_id, -effective_length, -FPKM, -IsoPct)

  return(exp_data)
}

parse_rpvg <- function(filename) {
  
  dir_split <- strsplit(dirname(filename), "/")[[1]]
  
  exp_data <- read_table(filename, col_names = T) %>%
    add_column(Method = dir_split[3]) %>%
    add_column(Reference = dir_split[4]) %>%
    filter(Name != "Unknown") %>%
    rename(name = Name, tpm_est = TPM, count_est = ReadCount, length = Length) %>%
    select(-ClusterID, -EffectiveLength)

  return(exp_data)
}

set.seed(12345678)

cols <- c(rev(wes_palette("Rushmore1")[c(1,3,4,5)]))

exp_truth_h1 <- read_table("truth/sim_mc_grch38_hg002_vgrna_k32_h1.read_origin.txt") %>%
  group_by(path) %>%
  summarise(count = n()) %>%
  mutate(count = count / 2)

exp_truth_h2 <- read_table("truth/sim_mc_grch38_hg002_vgrna_k32_h2.read_origin.txt") %>%
  group_by(path) %>%
  summarise(count = n()) %>%
  mutate(count = count / 2)

exp_truth <- bind_rows(exp_truth_h1, exp_truth_h2) %>%
  mutate(path = gsub("_R1#0#0#0", "", path)) %>%
  mutate(path = gsub("_R2#0#0#0", "", path)) %>%
  group_by(path) %>%
  summarise(count = sum(count)) %>%
  rename(name = path, count_sim = count)
  
annotation <- read_table("annotations/gencode38_alt/gencode.v38.chr_patch_hapl_scaff.annotation_rename_par_id_alt_names.txt", col_names = F)

print(list.files(pattern="quant.sf", full.names = T, recursive = T))
print(list.files(pattern="*.isoforms.results", full.names = T, recursive = T))
print(list.files(pattern="rpvg.*.txt", full.names = T, recursive = T))

exp_data_salmon <- map_dfr(list.files(pattern="quant.sf", full.names = T, recursive = T), parse_salmon)
exp_data_rsem <- map_dfr(list.files(pattern="*.isoforms.results", full.names = T, recursive = T), parse_rsem)
exp_data_rpvg <- map_dfr(list.files(pattern="rpvg.*.txt", full.names = T, recursive = T), parse_rpvg)

exp_data <- rbind(exp_data_salmon, exp_data_rsem, exp_data_rpvg) 

exp_truth %>% filter(!(name %in% exp_data$name)) %>% print()

exp_data_truth <- exp_data %>%
  left_join(exp_truth, by = "name") %>%
  replace_na(list(count_sim = 0)) %>%
  left_join(annotation, by = c("name" = "X2"))

exp_data_truth %>% filter(is.na(X4)) %>% print()

exp_data_truth_stats <- exp_data_truth %>%
  group_by(Method, Reference, X4) %>%
  summarise(count_est = sum(count_est), count_sim = sum(count_sim)) %>%
  mutate(ard = abs(count_est - count_sim) / (count_est + count_sim)) %>%
  replace_na(list(ard = 0)) %>%
  group_by(Method, Reference) %>%
  summarise(n = n(), count_est_sum = sum(count_est), count_sim_sum = sum(count_sim), mard = mean(ard), spear = cor(count_est, count_sim, method = "spearman")) 

exp_data_truth_stats$Reference <- recode_factor(exp_data_truth_stats$Reference, 
                                    "gencode38_primary" = "GRCh38 transcriptome",
                                    "gencode38_alt" = "GRCh38 transcriptome + alt contigs",
                                    "linear_gen38" = "GRCh38 transcriptome",
                                    "clipped_gen38_freeze1" = "MC pantranscriptome")

exp_data_truth_stats$Method <- recode_factor(exp_data_truth_stats$Method, 
                                     "rsem" = "RSEM",
                                     "salmon" = "Salmon",
                                     "mpmap-rpvg" = "mpmap-rpvg")

exp_data_truth_stats <- exp_data_truth_stats %>%
  ungroup() %>%
  add_row(Method = "mpmap-rpvg", Reference = "GRCh38 transcriptome + alt contigs", mard = 0, spear = 0) %>%
  add_row(Method = "RSEM", Reference = "MC pantranscriptome", mard = 0, spear = 0) %>%
  add_row(Method = "Salmon", Reference = "MC pantranscriptome", mard = 0, spear = 0) 

exp_data_truth_stats$Reference <- factor(exp_data_truth_stats$Reference, levels = c("MC pantranscriptome", "GRCh38 transcriptome", "GRCh38 transcriptome + alt contigs"))

exp_data_truth_stats$Method <- factor(exp_data_truth_stats$Method, levels = c("mpmap-rpvg", "RSEM", "Salmon"))

exp_data_truth_stats$FacetCol <- "Simulated reads (HG002)"
exp_data_truth_stats$FacetRow <- ""

min_spear <- exp_data_truth_stats %>% filter(spear > 0) %>% ungroup() %>% summarise(spear = min(spear))

exp_data_truth_stats %>% print(n = 100)

p1 <- exp_data_truth_stats %>% 
  ggplot(aes(Method, y = spear, fill = Reference)) +
  geom_bar(stat = "identity", width = 0.5, position = position_dodge()) +
  scale_fill_manual(values = cols) +
  scale_y_continuous(limits = c(floor(min_spear$spear * 20) / 20, 1), oob = rescale_none) +
  facet_grid(FacetRow ~ FacetCol) +
  xlab("") +
  ylab("Spearman correlation (gene expression)") +
  theme_bw() +
  theme(strip.background = element_blank()) +
  theme(panel.spacing = unit(0.5, "cm")) +
  theme(text = element_text(size = 10)) +
  theme(legend.text = element_text(size = 8)) +
  theme(legend.key.size = unit(0.5, 'cm')) 

p2 <- exp_data_truth_stats %>% 
  ggplot(aes(Method, y = mard, fill = Reference)) +
  geom_bar(stat = "identity", width = 0.5, position = position_dodge()) +
  scale_fill_manual(values = cols) +
  facet_grid(FacetRow ~ FacetCol) +
  xlab("") +
  ylab("Mean absolute relative difference (gene expression)") +
  theme_bw() +
  theme(strip.background = element_blank()) +
  theme(panel.spacing = unit(0.5, "cm")) +
  theme(text = element_text(size = 10)) +
  theme(legend.text = element_text(size = 8)) +
  theme(legend.key.size = unit(0.5, 'cm')) +
  theme(legend.position = "none")

# http://www.sthda.com/english/wiki/wiki.php?id_contents=7930
get_legend<-function(myggplot){
  tmp <- ggplot_gtable(ggplot_build(myggplot))
  leg <- which(sapply(tmp$grobs, function(x) x$name) == "guide-box")
  legend <- tmp$grobs[[leg]]
  return(legend)
}

legend <- get_legend(p1)

p1 <- p1 +
  theme(legend.position = "none")

pdf("hprc_rnaseq_sim_hg002_exp_eval.pdf", height = 5, width = 7.5, pointsize = 12, useDingbats = F)
grid.arrange(p1, p2, legend, ncol = 3, widths=c(2, 2, 1.5))
dev.off()

write.table(exp_data_truth_stats, file = "hprc_rnaseq_sim_hg002_exp_eval.txt", sep = "\t", row.names = F, col.names = T, quote = F)

  
