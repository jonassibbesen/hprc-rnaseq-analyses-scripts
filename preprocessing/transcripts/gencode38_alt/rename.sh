gunzip -c gencode.v38.chr_patch_hapl_scaff.annotation.gff3.gz | sed 's/transcript_id/source_transcript/g' | gzip -c > gencode.v38.chr_patch_hapl_scaff.annotation_rename.gff3.gz
