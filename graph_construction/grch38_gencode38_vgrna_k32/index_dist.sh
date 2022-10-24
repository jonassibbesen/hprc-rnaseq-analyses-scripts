set -e

# Set file name prefixes
OUT_PREFIX="grch38_gencode38_vgrna_k32"

# Create snarls index
/usr/bin/time -v bash -c "vg snarls -t ${CPU} -T ${OUT_PREFIX}.pg > ${OUT_PREFIX}.snarls"

# Create distance index
/usr/bin/time -v bash -c "vg index -p -t ${CPU} -s ${OUT_PREFIX}.snarls -j ${OUT_PREFIX}.dist ${OUT_PREFIX}.pg"
