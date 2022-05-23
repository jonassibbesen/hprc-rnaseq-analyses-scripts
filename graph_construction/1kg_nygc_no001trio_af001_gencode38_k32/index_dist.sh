set -e

# Set file name prefixes
OUT_PREFIX="1kg_nygc_no001trio_af001_gencode38_k32"

# Create snarls index
/usr/bin/time -v bash -c "vg snarls -t ${CPU} -T ${OUT_PREFIX}.xg > ${OUT_PREFIX}.snarls"

# Create distance index
/usr/bin/time -v bash -c "vg index -p -t ${CPU} -s ${OUT_PREFIX}.snarls -j ${OUT_PREFIX}.dist ${OUT_PREFIX}.xg"
