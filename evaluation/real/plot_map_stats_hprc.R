
# plot_map_stats_hprc.R

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

plotStatsBarTwoLayer <- function(data_bar, cols) {
  
  p <- ggplot() +
    geom_bar(data = data_bar[data_bar$Filter == "MapQ >= 30",], aes(Graph, y = Frac, fill = Graph, alpha = Filter), stat = "identity", width = 0.5, position = position_dodge()) +
    geom_bar(data = data_bar[data_bar$Filter == "Mapped",], aes(Graph, y = Frac, fill = Graph, alpha = Filter), stat = "identity", width = 0.5, position = position_dodge(), alpha = 0.5) +
    scale_fill_manual(values = cols) +
    scale_alpha_manual(name = "Filter", values = c(0.5, 1), labels = c("Mapped", expression("MapQ ">=" 30")), drop = F) + 
    scale_y_continuous(limits = c(0, 1), oob = rescale_none) +
    facet_grid(FacetRow ~ FacetCol) +
    xlab("") +
    ylab("Mapping rate") +
    theme_bw() +
    theme(strip.background = element_blank()) +
    theme(panel.spacing = unit(0.5, "cm")) +
    theme(axis.text.x = element_blank()) +
    theme(text = element_text(size = 10)) +
    theme(legend.text.align = 0) +
    theme(legend.text = element_text(size = 8))
  print(p)
}

cols <- c(rev(wes_palette("Rushmore1")[c(1,3,4,5)]), wes_palette("Darjeeling1")[c(5)], wes_palette("Royal2")[c(1,2)])
set.seed(12345678)

mapping_data <- map_dfr(list.files(pattern = ".*_stats.txt.gz", full.names = T, recursive = T), parse_file)

mapping_data$Graph <- recode_factor(mapping_data$Graph, 
                                       "grch38_gencode38" = "STAR (spliced reference)",
                                       "1kg_nygc_no001trio_af001_gencode38_k32" = "vg mpmap (1000GP spliced graph)",
                                       "minigraph_cactus_grch38_f1_clip_d9_m1k_D10M_m1k_cat_gencode38_vgrna_k32" = "vg mpmap (HPRC spliced graph)")

mapping_data$Graph <- factor(mapping_data$Graph, levels = c("vg mpmap (HPRC spliced graph)", "vg mpmap (1000GP spliced graph)", "STAR (spliced reference)"))

mapping_data$Reads <- recode_factor(mapping_data$Reads, 
                                     "SRR1153470" = "SRR1153470",
                                     "ENCSR000AED_rep1" = "ENCSR000AED (rep1)")

mapping_data$Reads <- factor(mapping_data$Reads, levels = c("SRR1153470", "ENCSR000AED (rep1)"))

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

mapping_data_stats$FacetCol <- mapping_data_stats$Reads
mapping_data_stats$FacetRow <- ""
  
pdf("hprc_rnaseq_real_map_stats.pdf", height = 4, width = 6, pointsize = 12)
plotStatsBarTwoLayer(mapping_data_stats, cols)
dev.off() 
