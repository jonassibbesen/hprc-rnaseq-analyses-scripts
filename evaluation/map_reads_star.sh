#!/bin/sh

#  map_reads_star.sh
#  
#
#  Created by Jordan Eizenga on 6/13/22.
#  

##
# inputs
##
INDEXES_DIR = indexes/
READS_1 = sim_mc_grch38_hg002_vgrna_k32_1.fq.gz
READS_2 = sim_mc_grch38_hg002_vgrna_k32_2.fq.gz
NUMCPU = 20

##
# outputs
##
BAM = sim_mc_grch38_hg002_vgrna_k32.star.bam

STAR --runThreadN "$NUMCPU" --genomeDir "$INDEXES_DIR" --readFilesCommand zcat --readFilesIn "$READS_1"  "$READS_2" --outSAMunmapped Within --outFileNamePrefix tmp
samtools sort -O BAM --threads "$NUMCPU" tmpAligned.out.sam > "$BAM"
rm tmpAligned.out.sam
