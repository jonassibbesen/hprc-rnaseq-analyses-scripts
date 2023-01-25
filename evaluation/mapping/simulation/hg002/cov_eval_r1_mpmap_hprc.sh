samtools view -h sim_mc_grch38_clipped_hg002_vgrna_k32_h1.gamp.bam | grep -v -F -f single_transcripts_reads_h1.txt | samtools sort --threads 4 -O BAM - > sim_mc_grch38_clipped_hg002_vgrna_k32_h1.gamp_nosingle_psort.bam
samtools view -h sim_mc_grch38_clipped_hg002_vgrna_k32_h2.gamp.bam | grep -v -F -f single_transcripts_reads_h2.txt | samtools sort --threads 4 -O BAM - > sim_mc_grch38_clipped_hg002_vgrna_k32_h2.gamp_nosingle_psort.bam

samtools index sim_mc_grch38_clipped_hg002_vgrna_k32_h1.gamp_nosingle_psort.bam
samtools index sim_mc_grch38_clipped_hg002_vgrna_k32_h2.gamp_nosingle_psort.bam

samtools flagstat sim_mc_grch38_clipped_hg002_vgrna_k32_h1.gamp_nosingle_psort.bam
samtools flagstat sim_mc_grch38_clipped_hg002_vgrna_k32_h2.gamp_nosingle_psort.bam

calc_allele_read_coverage sim_mc_grch38_clipped_hg002_vgrna_k32_h1.gamp_nosingle_psort.bam sim_mc_grch38_clipped_hg002_vgrna_k32_h2.gamp_nosingle_psort.bam <(zcat hprc-mc-grch38-hg002-clip10k_norm_exons.vcf.gz) > cov_eval_r1_mpmap_sim_hg002_clipped_gen38_freeze1.txt
