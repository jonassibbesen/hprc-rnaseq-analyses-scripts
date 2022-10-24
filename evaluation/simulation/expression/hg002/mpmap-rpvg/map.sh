REF_PREFIX=minigraph_cactus_grch38_f1_clip_d9_m1k_D10M_m1k_cat_gencode38_vgrna_k32
OUT_PREFIX=mpmap_multi_agg_clipped_gen38_freeze1

vg mpmap -t 8 -n rna -M 1 --agglomerate-alns -x ${REF_PREFIX}.xg -g ${REF_PREFIX}.gcsa -d ${REF_PREFIX}.dist -f <(cat sim_mc_grch38_hg002_vgrna_k32_h1_1.fq.gz sim_mc_grch38_hg002_vgrna_k32_h2_1.fq.gz) -f <(cat sim_mc_grch38_hg002_vgrna_k32_h1_2.fq.gz sim_mc_grch38_hg002_vgrna_k32_h2_2.fq.gz) > ${OUT_PREFIX}.gamp
