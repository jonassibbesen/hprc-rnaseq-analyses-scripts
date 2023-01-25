HAP_IDX=${1}

samtools sort --threads 4 -n -O BAM sim_mc_grch38_hg002_vgrna_k32_h${HAP_IDX}.linear.gamp.bam > sim_mc_grch38_hg002_vgrna_k32_h${HAP_IDX}.linear.gamp_rsort.bam

samtools flagstat --threads 4 sim_mc_grch38_hg002_vgrna_k32_h${HAP_IDX}.linear.gamp_rsort.bam

calc_vg_benchmark_stats sim_mc_grch38_hg002_vgrna_k32_h${HAP_IDX}.linear.gamp_rsort.bam benchmark_hsts.reheader.bam sim_mc_grch38_hg002_vgrna_k32_h${HAP_IDX}.read_origin.txt 3 null null null null > bam_eval_r1_mpmap_sim_hg002_linear_gen38_h${HAP_IDX}_ovl3.txt
