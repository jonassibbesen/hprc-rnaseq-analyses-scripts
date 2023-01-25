HAP_IDX=${1}

samtools sort --threads 4 -n -O BAM sim_mc_grch38_clipped_hg002_vgrna_k32_h${HAP_IDX}.gamp.bam > sim_mc_grch38_clipped_hg002_vgrna_k32_h${HAP_IDX}.gamp_rsort.bam

samtools flagstat --threads 4 sim_mc_grch38_clipped_hg002_vgrna_k32_h${HAP_IDX}.gamp_rsort.bam

calc_vg_benchmark_stats sim_mc_grch38_clipped_hg002_vgrna_k32_h${HAP_IDX}.gamp_rsort.bam hg002_hsts_grch38.bam sim_mc_grch38_hg002_vgrna_k32_h${HAP_IDX}.read_origin.txt 3 null null null null > bam_eval_r1_mpmap_sim_hg002_clipped_gen38_freeze1_h${HAP_IDX}_ovl3.txt
