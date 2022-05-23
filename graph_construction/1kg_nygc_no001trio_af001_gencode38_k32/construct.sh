set -e

MAF=0.001

# Set file name prefixes 
TRANSCRIPTS_PREFIX="gencode.v38.primary_assembly.annotation_rename_par"
GRAPHS_PREFIX="1kg_nygc_no001trio_af001_gencode38_k32"
OUT_PREFIX="${GRAPHS_PREFIX}_${CHR}"

# Chromosome is scaffold
if [ "${CHR}" = "SCA" ]; then

	GENOME_PREFIX="grch38_scaffold"
	VARIANTS_PREFIX="20201028_CCDG_14151_B01_GRM_WGS_2020-08-05_others.recalibrated_variants"

	# Rename contig and normalize
	/usr/bin/time -v bash -c "zcat ${VARIANTS_PREFIX}.vcf.gz | grep -v 'HLA-' | grep -v '_alt' | sed -e 's/^chr/GRCh38.chr/g' | sed -e 's/ID=chr/ID=GRCh38.chr/g' | bcftools view -t ^GRCh38.chrM -s ^NA12878,NA12891,NA12892 --force-samples -f PASS | bcftools norm -m -any -f ${GENOME_PREFIX}.fa | bcftools view -q ${MAF} | bcftools norm -m +any -O z -f ${GENOME_PREFIX}.fa > ${CHR}.vcf.gz; tabix ${CHR}.vcf.gz"

	# Construct variation graph
	/usr/bin/time -v bash -c "vg construct -p -t ${CPU} -v ${CHR}.vcf.gz -r ${GENOME_PREFIX}.fa > ${CHR}.vg"

	# Convert variation graph to PackedGraph format
	/usr/bin/time -v bash -c "vg convert -p ${CHR}.vg > ${CHR}.pg"

	# Find contig transcripts
	/usr/bin/time -v bash -c "zcat ${TRANSCRIPTS_PREFIX}.gff3.gz | grep '_KI\|_GL' > ${CHR}.gtf"

	# Construct spliced variation graph
	/usr/bin/time -v bash -c "vg rna -p -t ${CPU} -s source_transcript -e -k 32 -r -n ${CHR}.gtf ${CHR}.pg > ${OUT_PREFIX}.pg"

# Chromosome is main
else 

	GENOME_PREFIX="grch38_main"

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

	# Construct variation graph
	/usr/bin/time -v bash -c "vg construct -p -t ${CPU} -R GRCh38.chr${CHR} -C -a -v ${CHR}.vcf.gz -r ${GENOME_PREFIX}.fa > ${CHR}.vg"

	# Convert variation graph to PackedGraph format
	/usr/bin/time -v bash -c "vg convert -p ${CHR}.vg > ${CHR}.pg"

	# Find contig transcripts
	/usr/bin/time -v bash -c "zcat ${TRANSCRIPTS_PREFIX}.gff3.gz | grep -P '^GRCh38.chr${CHR}\t' > ${CHR}.gtf"

	# Construct spliced variation graph
	/usr/bin/time -v bash -c "vg rna -p -t ${CPU} -s source_transcript -e -k 32 -n ${CHR}.gtf ${CHR}.pg > ${OUT_PREFIX}.pg"

fi
