set -e

# Set file name prefixes
OUT_PREFIX="grch38_gencode38_vgrna_k32"

# Generate gcsa index
/usr/bin/time -v bash -c "vg gbwt -p --num-threads ${CPU} -r ${OUT_PREFIX}.gbwt.ri ${OUT_PREFIX}.gbwt"
