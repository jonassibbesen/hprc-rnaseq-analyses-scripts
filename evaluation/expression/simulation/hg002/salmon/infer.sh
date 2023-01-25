INDEX_PREFIX=salmon_gc38_prim_index
OUT_PREFIX=salmon_gc38_prim

salmon quant -p 8 -l A -i ${INDEX_PREFIX} -1 <(cat sim_mc_grch38_hg002_vgrna_k32_h1_1.fq.gz sim_mc_grch38_hg002_vgrna_k32_h2_1.fq.gz) -2 <(cat sim_mc_grch38_hg002_vgrna_k32_h1_2.fq.gz sim_mc_grch38_hg002_vgrna_k32_h2_2.fq.gz) -o ${OUT_PREFIX}
