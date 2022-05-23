# hprc-rnaseq-analyses-scripts
Scripts used for the RNA-seq analyses in the HPRC draft pangenome paper.

The directories contain the scripts used in the analyses, as well as in many cases the corresponding log files. Note that the scripts includes hard-coded paths and file names, and therefore needs to be edited before being used in other projects. Most of the log files include a short header which specifies the Docker image that was used. The Docker containers are available at this repository: [s3script-dockerfiles](https://github.com/jonassibbesen/s3script-dockerfiles). Some of the log files have been edited to remove excessive warnings in order to reduce file size. These have the suffix *less_warnings*. 
