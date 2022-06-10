ALIGN="ENCSR706ANY_primary_mapq30"

calc_exon_read_coverage ${ALIGN}.bam ${ALIGN}.bed > ${ALIGN}_cov.txt
gzip ${ALIGN}_cov.txt
