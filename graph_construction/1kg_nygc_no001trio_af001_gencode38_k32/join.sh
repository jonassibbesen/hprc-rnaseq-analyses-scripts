set -e

# Set file name prefixes 
GRAPHS_PREFIX="1kg_nygc_no001trio_af001_gencode38_k32"

# Calculate graph statistics (pre-ids) 
/usr/bin/time -v bash -c 'for i in $(seq 1 22; echo X; echo Y; echo M; echo SCA); do echo ${i}; vg stats -z -l -r ${i}/'"${GRAPHS_PREFIX}"'_${i}.pg; done'

# Create non-conflicting id space in graphs
/usr/bin/time -v bash -c 'vg ids -j $(for i in $(seq 1 22; echo X; echo Y; echo M; echo SCA); do echo ${i}/'"${GRAPHS_PREFIX}"'_${i}.pg; done) -m empty_node_mapping.map'

# Calculate graph statistics (post-ids) 
/usr/bin/time -v bash -c 'for i in $(seq 1 22; echo X; echo Y; echo M; echo SCA); do echo ${i}; vg stats -z -l -r ${i}/'"${GRAPHS_PREFIX}"'_${i}.pg; done'
