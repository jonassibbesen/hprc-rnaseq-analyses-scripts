set -e

# Set file name prefixes
OUT_PREFIX="minigraph_cactus_grch38_f1_clip_d9_m1k_D10M_m1k_cat_gencode38_vgrna_k32"

# Convert pangenome
/usr/bin/time -v bash -c "vg convert -t ${CPU} -p GRCh38-f1g-90-mc-aug11-clip.d9.m1000.D10M.m1000.xg > GRCh38-f1g-90-mc-aug11-clip.d9.m1000.D10M.m1000.pg"

# Construct pantranscriptome
/usr/bin/time -v bash -c "gunzip gencode.v38.primary_assembly.annotation_rename_par.gff3.gz; vg rna -t ${CPU} -p -s source_transcript -j -k 32 -u -n gencode.v38.primary_assembly.annotation_rename_par.gff3 -n <(zcat CHM13.hg38.gff3.gz) -n <(zcat HG00438.1.hg38.gff3.gz) -n <(zcat HG00438.2.hg38.gff3.gz) -n <(zcat HG00621.1.hg38.gff3.gz) -n <(zcat HG00621.2.hg38.gff3.gz) -n <(zcat HG00673.1.hg38.gff3.gz) -n <(zcat HG00673.2.hg38.gff3.gz) -n <(zcat HG00733.1.hg38.gff3.gz) -n <(zcat HG00733.2.hg38.gff3.gz) -n <(zcat HG00735.1.hg38.gff3.gz) -n <(zcat HG00735.2.hg38.gff3.gz) -n <(zcat HG00741.1.hg38.gff3.gz) -n <(zcat HG00741.2.hg38.gff3.gz) -n <(zcat HG01071.1.hg38.gff3.gz) -n <(zcat HG01071.2.hg38.gff3.gz) -n <(zcat HG01106.1.hg38.gff3.gz) -n <(zcat HG01106.2.hg38.gff3.gz) -n <(zcat HG01109.1.hg38.gff3.gz) -n <(zcat HG01109.2.hg38.gff3.gz) -n <(zcat HG01123.1.hg38.gff3.gz) -n <(zcat HG01123.2.hg38.gff3.gz) -n <(zcat HG01175.1.hg38.gff3.gz) -n <(zcat HG01175.2.hg38.gff3.gz) -n <(zcat HG01243.1.hg38.gff3.gz) -n <(zcat HG01243.2.hg38.gff3.gz) -n <(zcat HG01258.1.hg38.gff3.gz) -n <(zcat HG01258.2.hg38.gff3.gz) -n <(zcat HG01358.1.hg38.gff3.gz) -n <(zcat HG01358.2.hg38.gff3.gz) -n <(zcat HG01361.1.hg38.gff3.gz) -n <(zcat HG01361.2.hg38.gff3.gz) -n <(zcat HG01891.1.hg38.gff3.gz) -n <(zcat HG01891.2.hg38.gff3.gz) -n <(zcat HG01928.1.hg38.gff3.gz) -n <(zcat HG01928.2.hg38.gff3.gz) -n <(zcat HG01952.1.hg38.gff3.gz) -n <(zcat HG01952.2.hg38.gff3.gz) -n <(zcat HG01978.1.hg38.gff3.gz) -n <(zcat HG01978.2.hg38.gff3.gz) -n <(zcat HG02055.1.hg38.gff3.gz) -n <(zcat HG02055.2.hg38.gff3.gz) -n <(zcat HG02080.1.hg38.gff3.gz) -n <(zcat HG02080.2.hg38.gff3.gz) -n <(zcat HG02109.1.hg38.gff3.gz) -n <(zcat HG02109.2.hg38.gff3.gz) -n <(zcat HG02145.1.hg38.gff3.gz) -n <(zcat HG02145.2.hg38.gff3.gz) -n <(zcat HG02148.1.hg38.gff3.gz) -n <(zcat HG02148.2.hg38.gff3.gz) -n <(zcat HG02257.1.hg38.gff3.gz) -n <(zcat HG02257.2.hg38.gff3.gz) -n <(zcat HG02486.1.hg38.gff3.gz) -n <(zcat HG02486.2.hg38.gff3.gz) -n <(zcat HG02559.1.hg38.gff3.gz) -n <(zcat HG02559.2.hg38.gff3.gz) -n <(zcat HG02572.1.hg38.gff3.gz) -n <(zcat HG02572.2.hg38.gff3.gz) -n <(zcat HG02622.1.hg38.gff3.gz) -n <(zcat HG02622.2.hg38.gff3.gz) -n <(zcat HG02630.1.hg38.gff3.gz) -n <(zcat HG02630.2.hg38.gff3.gz) -n <(zcat HG02717.1.hg38.gff3.gz) -n <(zcat HG02717.2.hg38.gff3.gz) -n <(zcat HG02723.1.hg38.gff3.gz) -n <(zcat HG02723.2.hg38.gff3.gz) -n <(zcat HG02818.1.hg38.gff3.gz) -n <(zcat HG02818.2.hg38.gff3.gz) -n <(zcat HG02886.1.hg38.gff3.gz) -n <(zcat HG02886.2.hg38.gff3.gz) -n <(zcat HG03098.1.hg38.gff3.gz) -n <(zcat HG03098.2.hg38.gff3.gz) -n <(zcat HG03453.1.hg38.gff3.gz) -n <(zcat HG03453.2.hg38.gff3.gz) -n <(zcat HG03486.1.hg38.gff3.gz) -n <(zcat HG03486.2.hg38.gff3.gz) -n <(zcat HG03492.1.hg38.gff3.gz) -n <(zcat HG03492.2.hg38.gff3.gz) -n <(zcat HG03516.1.hg38.gff3.gz) -n <(zcat HG03516.2.hg38.gff3.gz) -n <(zcat HG03540.1.hg38.gff3.gz) -n <(zcat HG03540.2.hg38.gff3.gz) -n <(zcat HG03579.1.hg38.gff3.gz) -n <(zcat HG03579.2.hg38.gff3.gz) -n <(zcat NA18906.1.hg38.gff3.gz) -n <(zcat NA18906.2.hg38.gff3.gz) -n <(zcat NA20129.1.hg38.gff3.gz) -n <(zcat NA20129.2.hg38.gff3.gz) -n <(zcat NA21309.1.hg38.gff3.gz) -n <(zcat NA21309.2.hg38.gff3.gz) -l GRCh38-f1g-90-mc-aug11-clip.d9.m1000.D10M.m1000.gbwt -b ${OUT_PREFIX}.gbwt -f ${OUT_PREFIX}.fa -i ${OUT_PREFIX}.txt GRCh38-f1g-90-mc-aug11-clip.d9.m1000.D10M.m1000.pg > tmp_graph.pg"

# Add reference transcripts
/usr/bin/time -v bash -c "vg rna -t ${CPU} -p -s source_transcript -e -o -r -n gencode.v38.primary_assembly.annotation_rename_par.gff3 tmp_graph.pg > ${OUT_PREFIX}.pg"

# Calculate graph statistics
/usr/bin/time -v bash -c "vg stats -z -l -r tmp_graph.pg; vg paths -L -x tmp_graph.pg | wc -l; vg stats -z -l -r ${OUT_PREFIX}.pg; vg paths -L -x ${OUT_PREFIX}.pg | wc -l"

# Compress pantranscriptome info
/usr/bin/time -v bash -c "gzip ${OUT_PREFIX}.fa; gzip ${OUT_PREFIX}.txt"
