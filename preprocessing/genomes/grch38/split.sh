samtools faidx grch38.fa $(cut -f1 grch38.fa.fai | grep -v -E "_|EBV") > grch38_main.fa

samtools faidx grch38_main.fa
samtools dict grch38_main.fa > grch38_main.fa.dict

samtools faidx grch38.fa $(cut -f1 grch38.fa.fai | grep -E "_|EBV") > grch38_scaffold.fa

samtools faidx grch38_scaffold.fa
samtools dict grch38_scaffold.fa > grch38_scaffold.fa.dict
