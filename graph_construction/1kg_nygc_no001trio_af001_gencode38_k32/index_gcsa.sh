set -e

# Set file name prefixes
OUT_PREFIX="1kg_nygc_no001trio_af001_gencode38_k32"

# Prune graphs
/usr/bin/time -v bash -c 'for i in $(seq 1 22; echo X; echo Y; echo M; echo SCA); do echo ${i}; vg prune -p -t '"${CPU}"' -r ${i}/'"${OUT_PREFIX}"'_${i}.pg > '"${OUT_PREFIX}"'_${i}_pruned.pg; done'

# Generate gcsa index
/usr/bin/time -v bash -c 'vg index -p -t '"${CPU}"' -g '"${OUT_PREFIX}"'.gcsa $(for i in $(seq 1 22; echo X; echo Y; echo M; echo SCA); do echo '"${OUT_PREFIX}"'_${i}_pruned.pg; done)'
