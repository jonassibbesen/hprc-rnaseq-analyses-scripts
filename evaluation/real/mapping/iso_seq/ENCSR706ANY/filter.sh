ALIGN="ENCSR706ANY"

samtools merge ${ALIGN}.bam ENCFF247TLH.bam ENCFF431IOE.bam ENCFF520MMC.bam ENCFF626GWM.bam
samtools sort -O BAM --threads 8 -o ${ALIGN}_sort.bam ${ALIGN}.bam; mv ${ALIGN}_sort.bam ${ALIGN}.bam
samtools flagstat ${ALIGN}.bam
samtools view -H ${ALIGN}.bam | sed -e 's/SN:/SN:GRCh38./g' > new_header.sam;
samtools reheader new_header.sam ${ALIGN}.bam | samtools view -F 256 -q 30 -O BAM - > ${ALIGN}_primary_mapq30.bam
samtools index ${ALIGN}_primary_mapq30.bam
samtools flagstat ${ALIGN}_primary_mapq30.bam

rm new_header*
