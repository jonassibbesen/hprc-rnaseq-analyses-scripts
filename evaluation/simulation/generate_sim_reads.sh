#!/bin/sh

#  generate_sim_reads.sh
#
# create simulated reads and additional files needed for benchmarking mapping accuracy
#  

##
# inputs
##
PANTRANSCRIPTOME = minigraph_cactus_grch38_hg002_cat_gencode38_vgrna_k32.gbwt
GRAPH = minigraph_cactus_grch38_hg002_cat_gencode38_vgrna_k32.pg
TEMPLATES_1 = SRR18109271_1.fastq.gz
TEMPLATES_2 = SRR18109271_2.fastq.gz
HEADER = hprc_header.txt
NUMCPU = 20

##
# outputs
##
BENCHMARK_HSTS = benchmark_hsts.bam
READ_TABLE = sim_mc_grch38_hg002_vgrna_k32.read_origin.txt
READS_1 = sim_mc_grch38_hg002_vgrna_k32_1.fq
READS_2 = sim_mc_grch38_hg002_vgrna_k32_2.fq

# simulate the read data
vg gbwt -T "$PANTRANSCRIPTOME" > hst_thread_names.txt
./synthesize_uniform_tx_profile.py hst_thread_names.txt > benchmark.synthetic_uni.isoforms.results
vg sim -x "$GRAPH" -n 5000000 -a -F "$TEMPLATES_1" -F "$TEMPLATES_2" -p 275 -v 50 -g "$PANTRANSCRIPTOME" -T benchmark.synthetic_uni.isoforms.results -d .001 -r -t "$NUMCPU" -E "$READ_TABLE"  > tmp.gam
vg view -aX tmp.gam | paste - - - - - - - - | tee >(cut -f 1-4 | tr "\t" "\n" > "$READS_1") | cut -f 5-8 | tr "\t" "\n" > "$READS_2"
rm tmp.gam
gzip "$READS_1"
gzip "$READS_2"

# sim paths as BAM
vg paths -x "$GRAPH" -g "$PANTRANSCRIPTOME" -X > benchmark_hsts.gam
vg surject -t 20 -S -b -x "$GRAPH" -F reference_paths.txt benchmark_hsts.gam > "$BENCHMARK_HSTS"
samtools view -H "$BENCHMARK_HSTS".tmp > benchmark_hsts_header.txt
# switch contigs to HPRC contig naming
./hprc_to_1kg_bam_contigs.py "$HEADER" benchmark_hsts_header.txt > benchmark_hsts_reheader.txt
samtools reheader benchmark_hsts_reheader.txt "$BENCHMARK_HSTS".tmp > "$BENCHMARK_HSTS"
rm "$BENCHMARK_HSTS".tmp

