set -e

# Set file name prefixes
OUT_PREFIX="1kg_nygc_no001trio_af001_gencode38_k32"

# Create xg index
/usr/bin/time -v bash -c 'vg index -p -t '"${CPU}"' -x '"${OUT_PREFIX}"'.xg $(for i in $(seq 1 22; echo X; echo Y; echo M; echo SCA); do echo ${i}/'"${OUT_PREFIX}"'_${i}.pg; done)'
