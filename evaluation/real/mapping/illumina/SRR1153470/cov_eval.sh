ALIGN_PREFIX=${1}

samtools sort -O BAM --threads 4 -o ${ALIGN_PREFIX}_sort.bam ${ALIGN_PREFIX}.bam

samtools index ${ALIGN_PREFIX}_sort.bam

samtools flagstat ${ALIGN_PREFIX}_sort.bam

calc_exon_read_coverage ${ALIGN_PREFIX}_sort.bam ENCSR706ANY_primary_mapq30.bed 1> cov_eval_ENCSR706ANY_primary_mapq30_${ALIGN_PREFIX}.txt
