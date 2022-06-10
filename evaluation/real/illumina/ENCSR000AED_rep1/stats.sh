OUTPUT="${1}_stats"

calc_read_regions_overlap_stats ${1}.bam empty.bed 1> ${OUTPUT}.txt
gzip ${OUTPUT}.txt
