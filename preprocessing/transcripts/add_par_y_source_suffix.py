
'''
add_par_y_source_suffix.py 
'''

import sys
import os
import subprocess
import gzip

from utils import *

if len(sys.argv) != 3:

	print("Usage: python add_par_y_source_suffix.py <annotation_gff3_gz_name> <output_gff3_gz_name>\n")
	sys.exit(1)

printScriptHeader()

annotation_file = gzip.open(sys.argv[1], "rb")
out_file = gzip.open(sys.argv[2], "wb")

for line in annotation_file:

	if line[0] == "#":

		out_file.write(line)
		continue

	line_split = line.split("\t")

	if "PAR_Y" in line_split[8]:

		att_split = line_split[8].split(";")

		for i in range(len(att_split)):

			if att_split[i].split("=")[0] == "source_transcript":

				att_split[i] = att_split[i] + "_PAR_Y"

		line_split[8] = ";".join(att_split)
		out_file.write("\t".join(line_split))

	else:

		out_file.write(line)

annotation_file.close()
out_file.close()

print("Done")
