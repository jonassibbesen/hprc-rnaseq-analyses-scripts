set -e

# Set file name prefixes
OUT_PREFIX="minigraph_cactus_grch38_f1_clip_d9_m1k_D10M_m1k_cat_gencode38_vgrna_k32"

# Create xg index
/usr/bin/time -v bash -c "vg index -p -t ${CPU} -x ${OUT_PREFIX}.xg ${OUT_PREFIX}.pg"
