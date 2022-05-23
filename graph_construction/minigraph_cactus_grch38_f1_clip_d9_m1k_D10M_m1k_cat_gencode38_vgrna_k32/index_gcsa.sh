set -e

# Set file name prefixes
OUT_PREFIX="minigraph_cactus_grch38_f1_clip_d9_m1k_D10M_m1k_cat_gencode38_vgrna_k32"

# Prune graphs
/usr/bin/time -v bash -c "vg prune -p -t ${CPU} -k 64 -M 64 -r ${OUT_PREFIX}.pg > graph.pruned.pg"

# Generate gcsa index
/usr/bin/time -v bash -c "vg index -p -t ${CPU} -g ${OUT_PREFIX}.gcsa graph.pruned.pg"
