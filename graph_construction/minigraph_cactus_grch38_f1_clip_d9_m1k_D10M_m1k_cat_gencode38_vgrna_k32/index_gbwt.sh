set -e

# Set file name prefixes
OUT_PREFIX="minigraph_cactus_grch38_f1_clip_d9_m1k_D10M_m1k_cat_gencode38_vgrna_k32"

# Generate gcsa index
/usr/bin/time -v bash -c "vg gbwt -p --num-threads ${CPU} -r ${OUT_PREFIX}.gbwt.ri ${OUT_PREFIX}.gbwt"
