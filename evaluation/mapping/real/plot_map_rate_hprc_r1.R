
# plot_map_rate_hprc_r1.R

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
    add_row(Reads = "SRR1153470", Method = "STAR", Graph = "MC spliced graph", Filter = "Mapped", Frac = 0) %>%
    add_row(Reads = "ENCSR000AED (rep1)", Method = "STAR", Graph = "MC spliced graph", Filter = "Mapped", Frac = 0) %>%
    add_row(Reads = "SRR1153470", Method = "STAR", Graph = "MC spliced graph", Filter = "MapQ >= 30", Frac = 0) %>%
    add_row(Reads = "ENCSR000AED (rep1)", Method = "STAR", Graph = "MC spliced graph", Filter = "MapQ >= 30", Frac = 0) 
  
  data_bar$Reads <- factor(data_bar$Reads, levels = c("SRR1153470", "ENCSR000AED (rep1)"))
  
  data_bar$Graph <- factor(data_bar$Graph, levels = c("MC spliced graph", "Spliced GRCh38 reference"))
  
  data_bar$Method <- factor(data_bar$Method, levels = c("vg mpmap", "STAR"))

  data_bar$Filter <- factor(data_bar$Filter, levels = c("Mapped", "MapQ >= 30"))
  
  data_bar$FacetCol <- data_bar$Reads
  data_bar$FacetRow <- ""
  
  data_bar <- data_bar %>%
    rename(Reference = Graph)
  
  min_frac <- data_bar %>% filter(Frac > 0) %>% ungroup() %>% summarise(frac = min(Frac))
  
  data_bar %>% print(n = 100)
  
  p <- ggplot() +
    geom_bar(data = data_bar[data_bar$Filter == "MapQ >= 30",], aes(Method, y = Frac, fill = Reference, alpha = Filter), stat = "identity", width = 0.5, position = position_dodge()) +
    geom_bar(data = data_bar[data_bar$Filter == "Mapped",], aes(Method, y = Frac, fill = Reference, alpha = Filter), stat = "identity", width = 0.5, position = position_dodge(), alpha = 0.5) +
    scale_fill_manual(values = cols) +
    scale_alpha_manual(name = "Filter", values = c(0.5, 1), labels = c("Mapped", expression("MapQ ">=" 30")), drop = F) + 
    scale_y_continuous(limits = c(floor(min_frac$frac * 2) / 2, 1), oob = rescale_none) +
    facet_grid(FacetRow ~ FacetCol) +
    xlab("") +
    ylab("Mapping rate") +
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

print(list.files(pattern = "map_stats.*.txt", full.names = T, recursive = T))

mapping_data <- map_dfr(list.files(pattern = "map_stats.*.txt", full.names = T, recursive = T), parse_file)

mapping_data$Reads <- recode_factor(mapping_data$Reads, 
                                    "SRR1153470" = "SRR1153470",
                                    "ENCSR000AED_rep1" = "ENCSR000AED (rep1)")

mapping_data$Graph <- recode_factor(mapping_data$Graph, 
                                    "grch38_gencode38" = "Spliced GRCh38 reference",
                                    "minigraph_cactus_grch38_f1_clip_d9_m1k_D10M_m1k_cat_gencode38_vgrna_k32" = "MC spliced graph")

mapping_data$Method <- recode_factor(mapping_data$Method, 
                                     "star" = "STAR",
                                     "mpmap" = "vg mpmap")

mapping_data_stats <- mapping_data %>%
  mutate(MapQ = ifelse(IsMapped, MapQ, -1)) %>% 
  mutate(MapQ0 = Count * (MapQ >= 0)) %>% 
  mutate(MapQ30 = Count * (MapQ >= 30)) %>% 
  group_by(Reads, Method, Graph) %>%
  summarise(count = sum(Count), MapQ0 = sum(MapQ0), MapQ30 = sum(MapQ30)) %>%
  mutate(MapQ0_frac = MapQ0 / count, MapQ30_frac = MapQ30 / count) %>%
  gather("MapQ0_frac", "MapQ30_frac", key = "Filter", value = "Frac")

mapping_data_stats$Filter <- recode_factor(mapping_data_stats$Filter, 
                                                 "MapQ0_frac" = "Mapped", 
                                                 "MapQ30_frac" = "MapQ >= 30")

  
plotStatsBarTwoLayer(mapping_data_stats, "hprc_rnaseq_real_map_rate_bars", cols)

