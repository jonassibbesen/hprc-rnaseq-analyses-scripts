set -e

# Set file name prefixes
OUT_PREFIX="grch38_gencode38_vgrna_k32"

# Extract sequences
/usr/bin/time -v bash -c "vg paths -F -Q GRCh38 -x GRCh38-f1g-90-mc-aug11.xg > sequences.fa; grep '^>' sequences.fa | wc -l"

# Construct pangenome
/usr/bin/time -v bash -c "vg construct -p -t ${CPU} -r sequences.fa > graph.vg"

# Convert pangenome
/usr/bin/time -v bash -c "vg convert -t ${CPU} -p graph.vg > graph.pg"

# Construct pantranscriptome
/usr/bin/time -v bash -c "gunzip gencode.v38.primary_assembly.annotation_rename_par.gff3.gz; vg rna -t ${CPU} -p -s source_transcript -e -k 32 -r -u -n gencode.v38.primary_assembly.annotation_rename_par.gff3 -b ${OUT_PREFIX}.gbwt -f ${OUT_PREFIX}.fa -i ${OUT_PREFIX}.txt graph.pg > ${OUT_PREFIX}.pg"

# Compress pantranscriptome info
/usr/bin/time -v bash -c "gzip ${OUT_PREFIX}.fa; gzip ${OUT_PREFIX}.txt"
