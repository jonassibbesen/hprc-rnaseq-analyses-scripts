ALIGN=sim_mc_grch38_hg002_vgrna_k32.star.bam
SAMTOOLS=samtools

${SAMTOOLS} merge -O BAM sim_mc_grch38_hg002_vgrna_k32.star_fixed.bam <(${SAMTOOLS} view -h -f 128 ${ALIGN} | awk -v OFS='\t' '{gsub("_1$", "_2", $1)} 1' | ${SAMTOOLS} view -O BAM) <(${SAMTOOLS} view -h -F 128 ${ALIGN} | ${SAMTOOLS} view -O BAM)

calc_vg_benchmark_stats sim_mc_grch38_hg002_vgrna_k32.star_fixed.bam benchmark_hsts.reheader.bam sim_mc_grch38_hg002_vgrna_k32.read_origin.txt 3 empty.vcf.gz HG002 0 1> bam_eval_star_sim_hg002_gen38_ovl3.txt
