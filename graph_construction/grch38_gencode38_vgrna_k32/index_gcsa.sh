set -e

# Set file name prefixes
OUT_PREFIX="grch38_gencode38_vgrna_k32"

# Prune graphs
/usr/bin/time -v bash -c "vg prune -p -t ${CPU} -r ${OUT_PREFIX}.pg > graph.pruned.pg"

# Generate gcsa index
/usr/bin/time -v bash -c "vg index -p -t ${CPU} -g ${OUT_PREFIX}.gcsa graph.pruned.pg"
