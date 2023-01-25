PT_PREFIX=minigraph_cactus_grch38_f1_clip_d9_m1k_D10M_m1k_cat_gencode38_vgrna_k32
ALIGN_PREFIX=mpmap_multi_agg_clipped_gen38_freeze1
OUT_PREFIX=rpvg_mpmap_multi_agg_clipped_gen38_freeze1

rpvg -t 8 -r 12345678 -i transcripts -g ${PT_PREFIX}.xg -p ${PT_PREFIX}.gbwt -f ${PT_PREFIX}.txt.gz -a ${ALIGN_PREFIX}.gamp -o ${OUT_PREFIX}
