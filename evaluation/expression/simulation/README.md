## Benchmarking RNA-seq expression inference (simulated data) 

Contains the scripts used for estimating and comparing expression values from *mpmap-rpvg*, *RSEM* and *Salmon*. 

Each script contains hard-coded filenames, however, many of these names are identical to the output names used in the preceding steps in the benchmarking pipeline. Note that the number of threads is set to 8 in all the bash scripts.

The *log_files* subfolders contain the log files from running the scripts. 

The *results* subfolders contain the expression data output from the scripts, which is used as input to the plotting script.

Follow the below steps to replicate the analyses presented in the paper. 

### 1. Create and index transcriptome (*RSEM*)

Scripts (`rsem` folder):

1. `index.sh`: Create transcriptome from annotation and generate Bowtie2 index. Run script for each annotation. 

Input files:

* `ANNO_PREFIX`: Prefix for the transcript annotation (available [here](http://cgl.gi.ucsc.edu/data/vgrna/hprc_analyses/transcript_annotations/)).
* `GENOME_PREFIX`: Prefix for the reference genome (see [genomes](https://github.com/jonassibbesen/hprc-rnaseq-analyses-scripts/tree/main/preprocessing/genomes) folder under preprocessing).

Methods:

* [RSEM](https://github.com/deweylab/RSEM) (v1.3.3)
* [Bowtie2](https://github.com/BenLangmead/bowtie2) (v2.4.5)

### 2. Index transcriptome (*Salmon*)

Scripts (`salmon` folder):

1. `index.sh`: Generate Salmon index from transcriptome sequences created by *RSEM*. Run script for each annotation.

Input files:

* `SEQ_PREFIX`: Prefix for the transcriptome sequences (FASTA format) created by RSEM (see previous step).
* `GENOME_PREFIX`: Prefix for the reference genome used a decoy (see [genomes](https://github.com/jonassibbesen/hprc-rnaseq-analyses-scripts/tree/main/preprocessing/genomes) folder under preprocessing).

Methods:

* [Salmon](https://github.com/COMBINE-lab/salmon) (v1.9.0)

### 3. Infer expression values (*RSEM* and *Salmon*)

Scripts (`rsem` and `salmon` folders):

1. `infer.sh`: Infer transcript expression values from simulated RNA-seq reads using either *RSEM* or *Salmon*. Run script for each method and index (annotation) combination.

Input files:

* `INDEX_PREFIX`: Prefix for the transcriptome index (see previous steps).
* *sim_mc_grch38_hg002_vgrna_k32\*.fq.gz*: Simulated RNA-seq read files (available [here](http://cgl.gi.ucsc.edu/data/vgrna/hprc_analyses/simulated_reads/)).

Methods:

* [RSEM](https://github.com/deweylab/RSEM) (v1.3.3)
* [Bowtie2](https://github.com/BenLangmead/bowtie2) (v2.4.5)
* [Salmon](https://github.com/COMBINE-lab/salmon) (v1.9.0)

### 4. Map RNA-seq reads (*vg mpmap*)

Scripts (`mpmap-rpvg` folder):

1. `map.sh`: Map simulated RNA-seq reads to a spliced pangenome graph using *vg mpmap*. Run script for each graph.

Input files:

* `REF_PREFIX`: Prefix for graph and associated indexes (available [here](http://cgl.gi.ucsc.edu/data/vgrna/hprc_analyses/graphs/) for different graphs).
* *sim_mc_grch38_hg002_vgrna_k32\*.fq.gz*: Simulated RNA-seq read files (available [here](http://cgl.gi.ucsc.edu/data/vgrna/hprc_analyses/simulated_reads/)).

Methods:

* [vg](https://github.com/vgteam/vg) (v1.43.0)

### 5. Infer expression values (*rpvg*)

Scripts (`mpmap-rpvg` folder):

1. `infer.sh`: Infer transcript expression values from mapped simulated RNA-seq reads using *rpvg*. Run script for each graph/pantranscriptome.

Input files:

* `PT_PREFIX`: Prefix for the pantranscriptome and associated graph (available [here](http://cgl.gi.ucsc.edu/data/vgrna/hprc_analyses/graphs/) for different pantranscriptomes).
* `ALIGN_PREFIX`: Prefix for the RNA-seq reads mapped using *vg mpmap* (see previous step).

Methods:

* [rpvg](https://github.com/jonassibbesen/rpvg) (commit 1d91a9e)

### 6. Plot expression benchmark

Script used to plot the results presented in the paper:

* `plot_vg_sim_exp_eval_r1.R`: Creates gene expression correlation and relative difference plots.

Please note that the R script assumes that the data is structured in a specific set of folders. They might therefore require a bit of reworking before they can be used in other environments. 
