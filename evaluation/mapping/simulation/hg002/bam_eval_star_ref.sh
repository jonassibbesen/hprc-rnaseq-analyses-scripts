HAP_IDX=${1}

samtools merge -O BAM sim_mc_grch38_hg002_vgrna_k32_h${HAP_IDX}.star_fixed.bam <(samtools view -h -f 128 sim_mc_grch38_hg002_vgrna_k32_h${HAP_IDX}.star.bam | awk -v OFS='\t' '{gsub("_1$", "_2", $1)} 1' | samtools view -O BAM) <(samtools view -h -F 128 sim_mc_grch38_hg002_vgrna_k32_h${HAP_IDX}.star.bam | samtools view -O BAM)

samtools sort --threads 4 -n -O BAM sim_mc_grch38_hg002_vgrna_k32_h${HAP_IDX}.star_fixed.bam > sim_mc_grch38_hg002_vgrna_k32_h${HAP_IDX}.star_fixed_rsort.bam

samtools flagstat --threads 4 sim_mc_grch38_hg002_vgrna_k32_h${HAP_IDX}.star_fixed_rsort.bam

calc_vg_benchmark_stats sim_mc_grch38_hg002_vgrna_k32_h${HAP_IDX}.star_fixed_rsort.bam hg002_hsts_grch38.bam sim_mc_grch38_hg002_vgrna_k32_h${HAP_IDX}.read_origin.txt 3 null null null null > bam_eval_r1_star_sim_hg002_gen38_h${HAP_IDX}_ovl3.txt
