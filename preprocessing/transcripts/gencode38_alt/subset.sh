cut -f4 ../gencode38/gencode.v38.primary_assembly.annotation_rename_par_id_names.txt | sort | uniq | sed -e 's/^/gene_name=/g' | sed -e 's/$/;/g' > alt_genes.txt

zcat gencode.v38.chr_patch_hapl_scaff.annotation_rename_par_id.gff3.gz | grep -F -f alt_genes.txt | gzip -c > gencode.v38.chr_patch_hapl_scaff.annotation_rename_par_id_alt.gff3.gz
