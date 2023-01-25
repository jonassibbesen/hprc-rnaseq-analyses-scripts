## Benchmarking RNA-seq mapping (simulated data) 

Contains the scripts used for analysing and comparing RNA-seq alignments from *STAR* and *vg mpmap*. 

Each script contains hard-coded filenames, however most of these correspond to the default output names used in the scripts in the preceding steps in the benchmarking pipeline. Note that the number of threads is set to 4 in some of the bash scripts.

Follow the below steps to replicate the analyses presented in the paper. 

### 1. Calculate reference-based mapping statistics

Scripts:

1. `bam_eval*.sh`: Calculates overlap between predicted alignments and simulated alignments on the reference-genome. Run script for each method and reference combination. 

Command line arguments:

* The haplotype index is given as a command line argument (`1` or `2` for the simulated data).

Input files:

* *sim_\*.bam*: Simulated RNA-seq read alignment file (BAM format).
* **read_origin.txt*: True transcript path and position for each simulated read (available [here](http://cgl.gi.ucsc.edu/data/vgrna/hprc_analyses/simulated_reads/) for both haplotype).
* *hg002_hsts_grch38.bam*: Alignments of the transcripts used for generating the simulated reads (available [here](http://cgl.gi.ucsc.edu/data/vgrna/hprc_analyses/simulated_reads/)).

Methods:

* [samtools](https://github.com/samtools/samtools) (v1.15)
* [vgrna_scripts](https://github.com/jonassibbesen/hprc-rnaseq-analyses-scripts/tree/main/evaluation/vgrna_scripts)

### 2. Calculate mapping bias statistics

Scripts:

1. `single_transcripts.sh`: Creates a list of single transcripts, that is, transcripts which are not present on both haplotypes, for example due to heterozygous deletions. 
2. `cov_eval_r1*.sh`: Calculates read alignment coverage across variants for each haplotype. Removes simulated reads stemming from single transcripts. Run script for each method and reference combination. 

Input files:

* *minigraph_cactus_grch38_hg002_cat_gencode38_vgrna_k32.txt*: List of transcripts (with haplotype information) used for generating the simulated reads (available [here](http://cgl.gi.ucsc.edu/data/vgrna/hprc_analyses/simulated_reads/graph/))  
* **read_origin.txt*: True transcript path and position for each simulated read (available [here](http://cgl.gi.ucsc.edu/data/vgrna/hprc_analyses/simulated_reads/) for both haplotypes).
* *sim_\*.bam*: Simulated RNA-seq read alignment file (BAM format).
* *hprc-mc-grch38-hg002-clip10k_norm_exons.vcf.gz*: Variants from the graph that was used for generating the simulated reads (available [here](http://cgl.gi.ucsc.edu/data/vgrna/hprc_analyses/simulated_reads/graph/)).

Methods:

* [samtools](https://github.com/samtools/samtools) (v1.15)
* [vgrna_scripts](https://github.com/jonassibbesen/hprc-rnaseq-analyses-scripts/tree/main/evaluation/vgrna_scripts)

### 3. Plot mapping benchmark

Scripts used to plot the results presented in the paper:

* `plot_vg_sim_overlap_hprc_r1.R`: Creates recall and precision mapping plots.
* `plot_vg_sim_bias_hprc_r1.R`: Creates mapping bias plots.

Please note that the R scripts assume that the data is structured in a specific set of folders. They might therefore require a bit of reworking before they can be used in other environments. 
