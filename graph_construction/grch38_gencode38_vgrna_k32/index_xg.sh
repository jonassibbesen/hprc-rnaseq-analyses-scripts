set -e

# Set file name prefixes
OUT_PREFIX="grch38_gencode38_vgrna_k32"

# Create xg index
/usr/bin/time -v bash -c "vg index -p -t ${CPU} -x ${OUT_PREFIX}.xg ${OUT_PREFIX}.pg"
