set -e

MAF=0.001

# Set file name prefixes 
GENOME_PREFIX="grch38_main"
TRANSCRIPTS_PREFIX="gencode.v38.primary_assembly.annotation_rename_par"
GRAPHS_PREFIX="1kg_nygc_no001trio_af001_gencode38_k32"
OUT_PREFIX="${GRAPHS_PREFIX}_${CHR}"

if [ "${CHR}" = "X" ]; then

	VARIANTS_PREFIX="CCDG_14151_B01_GRM_WGS_2020-08-05_chrX.filtered.eagle2-phased.v2"

elif [ "${CHR}" = "Y" ]; then

	VARIANTS_PREFIX="20201028_CCDG_14151_B01_GRM_WGS_2020-08-05_chrY.recalibrated_variants"

elif [ "${CHR}" = "M" ]; then

	VARIANTS_PREFIX="20201028_CCDG_14151_B01_GRM_WGS_2020-08-05_others.recalibrated_variants"

else

	VARIANTS_PREFIX="CCDG_14151_B01_GRM_WGS_2020-08-05_chr${CHR}.filtered.shapeit2-duohmm-phased"
fi

# Rename contig and normalize
	/usr/bin/time -v bash -c "zcat ${VARIANTS_PREFIX}.vcf.gz | sed -e 's/^chr/GRCh38.chr/g' | sed -e 's/ID=chr/ID=GRCh38.chr/g' | bcftools view -t GRCh38.chr${CHR} -s ^NA12878,NA12891,NA12892 --force-samples -f PASS | bcftools norm -m -any -f ${GENOME_PREFIX}.fa | bcftools view -q ${MAF} | bcftools norm -m +any -O z -f ${GENOME_PREFIX}.fa > ${CHR}.vcf.gz; tabix ${CHR}.vcf.gz"

# Create gbwt index of all haplotypes
/usr/bin/time -v bash -c "vg index -p -t ${CPU} -G ${CHR}.gbwt -v ${CHR}.vcf.gz ${OUT_PREFIX}.pg"

# Find contig transcripts
/usr/bin/time -v bash -c "zcat ${TRANSCRIPTS_PREFIX}.gff3.gz | grep -P '^GRCh38.chr${CHR}\t' > ${CHR}.gtf"

# Calculate graph statistics (pre-rna) 
/usr/bin/time -v bash -c "vg stats -z -l -r ${OUT_PREFIX}.pg"

# Construct pantranscriptome
/usr/bin/time -v bash -c "vg rna -p -t ${CPU} -s source_transcript -o -r -n ${CHR}.gtf -l ${CHR}.gbwt -b ${OUT_PREFIX}.gbwt -f ${OUT_PREFIX}.fa -i ${OUT_PREFIX}.txt ${OUT_PREFIX}.pg > ${OUT_PREFIX}_tmp.pg; mv ${OUT_PREFIX}_tmp.pg ${OUT_PREFIX}.pg"

# Calculate graph statistics (post-rna) 
/usr/bin/time -v bash -c "vg stats -z -l -r ${OUT_PREFIX}.pg"

# Compress pantranscriptome
/usr/bin/time -v bash -c "gzip ${OUT_PREFIX}.fa; gzip ${OUT_PREFIX}.txt"
