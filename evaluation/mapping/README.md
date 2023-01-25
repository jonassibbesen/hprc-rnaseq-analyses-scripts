## Benchmarking RNA-seq mapping

Contains the scripts used for mapping RNA-seq read using *STAR* and *vg mpmap*. 

Each script contains hard-coded filenames, however, many of these names are identical to the output names used in the preceding steps in the benchmarking pipeline. Note that the number of threads is set to 20 in all the bash scripts.

Follow the below steps to replicate the analyses presented in the paper. 

### 1. Map RNA-seq reads (*STAR*)

Scripts:

1. `map_reads_star.sh`: Map RNA-seq reads to reference genome using *STAR*. Run script for each read set.

Input files:

* `INDEXES_DIR`: Reference genome index directory.
* `READS_1`, and `READS_2`: Paired RNA-seq read files (see main [README](https://github.com/jonassibbesen/hprc-rnaseq-analyses-scripts/blob/main/README.md) for links to datasets).

Methods:

* [STAR](https://github.com/alexdobin/STAR) (v2.7.10a)

### 2. Map RNA-seq reads (*vg mpmap*)

Scripts:

1. `map_reads_mpmap.sh`: Map RNA-seq reads to a spliced pangenome graphs using *vg mpmap* and surject alignments to the reference genome. Run script for each graph and read set combination.

Input files:

* `GRAPH`, `GCSA`, and `DIST_INDEX`: Graph and associated indexes (available [here](http://cgl.gi.ucsc.edu/data/vgrna/hprc_analyses/graphs/) for different graphs).
* `READS_1`, and `READS_2`: Paired RNA-seq read files (see main [README](https://github.com/jonassibbesen/hprc-rnaseq-analyses-scripts/blob/main/README.md) for links to datasets).
* *reference_paths.txt*: List containing the names of the reference genome paths (used for surjection).

Methods:

* [vg](https://github.com/vgteam/vg) (commit c0c4816)

### 3. Run mapping benchmark

* See `simulation` subfolder for information on the simulated data mapping benchmark.
* See `real` subfolder for information on the real data mapping benchmark.


