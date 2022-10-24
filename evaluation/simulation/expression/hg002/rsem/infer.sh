INDEX_PREFIX=rsem_bowtie2_gc38_prim_index
OUT_PREFIX=rsem_bowtie2_gc38_prim_index

rsem-calculate-expression -p 8 --bowtie2 --bowtie2-path bowtie2-2.4.5-linux-x86_64/ --seed 123456 --paired-end <(cat sim_mc_grch38_hg002_vgrna_k32_h1_1.fq.gz sim_mc_grch38_hg002_vgrna_k32_h2_1.fq.gz) <(cat sim_mc_grch38_hg002_vgrna_k32_h1_2.fq.gz sim_mc_grch38_hg002_vgrna_k32_h2_2.fq.gz) ${INDEX_PREFIX} ${OUT_PREFIX}
