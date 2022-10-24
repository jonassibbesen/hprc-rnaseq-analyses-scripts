# hprc-rnaseq-analyses-scripts
Scripts used for the RNA-seq analyses presneted in the HPRC draft pangenome paper: *A Draft Human Pangenome Reference*, [bioRxiv](https://www.biorxiv.org/content/10.1101/2022.07.09.499321v1.full) (2022).

The directories contain the scripts used in the analyses, as well as in many cases the corresponding log files. Note that the scripts includes hard-coded paths and file names, and therefore needs to be edited before being used in other projects. Some of the scripts have been slighly updated to reduce the number of hard-coded paths. Some of the log files include a short header which specifies the Docker image that was used. The Docker containers are available at this repository: [s3script-dockerfiles](https://github.com/jonassibbesen/s3script-dockerfiles). Some of the log files have been edited to remove excessive warnings in order to reduce file size. These have the suffix *less_warnings*. 

## Data

Here you can find links to the data used in the paper. This includes both raw data and data constructed as part of the analyses in the paper. The constructed data included here is data that are either not guaranteed to be reproducible (simulated reads) or that are deemed potentially useful in other projects (graphs and indexes).

### Graphs and indexes

The spliced pangenome graphs and indexes:

* http://cgl.gi.ucsc.edu/data/vgrna/hprc_analyses/graphs/

### Reference transcripts

The GENCODE v38 transcript annotation:

* https://ftp.ebi.ac.uk/pub/databases/gencode/Gencode_human/release_38/

### Reads

The simulated RNA-seq reads:

* http://cgl.gi.ucsc.edu/data/vgrna/hprc_analyses/simulated_reads/

The real RNA-seq reads:

* https://www.ncbi.nlm.nih.gov/sra/?term=SRR1153470 (NA12878)
* https://www.encodeproject.org/experiments/ENCSR000AED/ (NA12878, replicate 1)

The Iso-Seq alignments:

* https://www.encodeproject.org/experiments/ENCSR706ANY/ (NA12878, all replicates)
