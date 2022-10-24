ANNO_PREFIX=gencode.v38.primary_assembly.annotation_rename_par_id
GENOME_PREFIX=grch38
OUT_PREFIX=rsem_bowtie2_gc38_prim_index

rsem-prepare-reference -p 8 --bowtie2 --bowtie2-path bowtie2-2.4.5-linux-x86_64/ --gff3 <(zcat ${ANNO_PREFIX}.gff3.gz) ${GENOME_PREFIX}.fa ${OUT_PREFIX}
