zcat gencode.v38.chr_patch_hapl_scaff.annotation_rename_par.gff3.gz | sed 's/source_transcript/transcript_id/g' | gzip -c > gencode.v38.chr_patch_hapl_scaff.annotation_rename_par_id.gff3.gz
