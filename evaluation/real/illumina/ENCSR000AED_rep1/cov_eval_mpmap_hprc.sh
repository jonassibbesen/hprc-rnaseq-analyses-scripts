ALIGN="ENCFF001REX.mgc.gamp"

samtools sort -O BAM --threads 8 -o ${ALIGN}_sort.bam ${ALIGN}.bam
samtools index ${ALIGN}_sort.bam

REGIONS="ENCSR706ANY_primary_mapq30"
OUTPUT="cov_eval_mpmap_ENCSR000AED_rep1_clipped_gen38_freeze1_${REGIONS}"

calc_exon_read_coverage ${ALIGN}_sort.bam ${REGIONS}.bed 1> ${OUTPUT}.txt
gzip ${OUTPUT}.txt
