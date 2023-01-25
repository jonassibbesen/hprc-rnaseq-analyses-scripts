grep -v ",_thread" minigraph_cactus_grch38_hg002_cat_gencode38_vgrna_k32.txt | cut -f3 | sort | uniq -c | grep -v " 2 " | cut -d ' ' -f8 > single_transcripts.txt

grep -F -f single_transcripts.txt sim_mc_grch38_hg002_vgrna_k32_h1.read_origin.txt | cut -f1 > single_transcripts_reads_h1.txt
grep -F -f single_transcripts.txt sim_mc_grch38_hg002_vgrna_k32_h2.read_origin.txt | cut -f1 > single_transcripts_reads_h2.txt
