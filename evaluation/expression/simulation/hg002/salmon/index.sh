SEQ_PREFIX=rsem_bowtie2_gc38_prim_index.transcripts
GENOME_PREFIX=grch38
OUT_PREFIX=salmon_gc38_prim_index

grep ">" grch38.fa | cut -d ' ' -f 1 | sed -e 's/>//g' > decoys.txt

salmon index -p 8 --keepDuplicates -d decoys.txt -i ${OUT_PREFIX} -t <(cat ${SEQ_PREFIX}.fa ${GENOME_PREFIX}.fa)
