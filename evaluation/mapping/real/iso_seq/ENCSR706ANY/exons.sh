ALIGN="ENCSR706ANY_primary_mapq30"

bedtools.static.binary bamtobed -splitD -i ${ALIGN}.bam | cut -f1-3 > temp.bed
bedtools.static.binary sort -i temp.bed > temp_sort.bed
bedtools.static.binary merge -i temp_sort.bed > ${ALIGN}.bed

rm temp*
