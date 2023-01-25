ALIGN_PREFIX=${1}

calc_read_regions_overlap_stats ${ALIGN_PREFIX}.bam empty.bed 1> map_stats_r1_${ALIGN_PREFIX}.txt
