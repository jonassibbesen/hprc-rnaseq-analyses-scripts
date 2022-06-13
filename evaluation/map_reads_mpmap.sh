#!/bin/sh

#  map_reads_mpmap.sh
#  
# map reads using vg mpmap
#

##
# inputs
##
GRAPH = minigraph_cactus_grch38_f1_clip_d9_m1k_D10M_m1k_cat_gencode38_vgrna_k32.xg
GCSA = minigraph_cactus_grch38_f1_clip_d9_m1k_D10M_m1k_cat_gencode38_vgrna_k32.gcsa
DIST_INDEX = minigraph_cactus_grch38_f1_clip_d9_m1k_D10M_m1k_cat_gencode38_vgrna_k32.dist
READS_1 = sim_mc_grch38_hg002_vgrna_k32_1.fq.gz
READS_2 = sim_mc_grch38_hg002_vgrna_k32_2.fq.gz
NUMCPU = 20
REF_PATHS = reference_paths.txt

##
# outputs
##
GAMP = sim_mc_grch38_hg002_vgrna_k32.gamp
BAM = sim_mc_grch38_hg002_vgrna_k32.gamp.bam

# map to graph
vg mpmap -x "$GRAPH" -g "$GCSA" -d "$DIST_INDEX" -t "$NUMCPU" -f "$READS_1" -f "$READS_2" > "$GAMP"
# project down to linear reference
vg surject -x "$GRAPH" -t "$NUMCPU" -m -b -S -A -F "$REF_PATHS" "$GAMP" > "$BAM"
