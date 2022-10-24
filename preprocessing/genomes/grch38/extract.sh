vg paths -F -Q GRCh38 -x GRCh38-f1g-90-mc-aug11.xg > grch38.fa
samtools faidx grch38.fa
samtools dict grch38.fa > grch38.fa.dict
