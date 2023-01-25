#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Convert HPRC contig names to the 1000 GP contig names for contigs in GRCh38
"""

import sys
import re

if __name__ == "__main__":
    
    hprc_header = sys.argv[1]
    thousand_gp_header = sys.argv[2]
    
    mapper = {}
    
    main_regex = "SN:(GRCh38.chr([0-9XYM]+))\t"
    ki_regex = "SN:(GRCh38.chr\w+_(KI[0-9]+)v([0-9]+)\S*)\t"
    gl_regex = "SN:(GRCh38.chr\w+_(GL[0-9]+)v([0-9]+)\S*)\t"
    
    for line in open(hprc_header):
        
        m = re.search(ki_regex, line)
        if m is not None:
            mapper["{}.{}".format(m.group(2), m.group(3))] = m.group(1)
            continue
        
        m = re.search(gl_regex, line)
        if m is not None:
            mapper["{}.{}".format(m.group(2), m.group(3))] = m.group(1)
            continue
        
        m = re.search(main_regex, line)
        if m is not None:
            mapper[m.group(2)] = m.group(1)
            mapper["chr"+ m.group(2)] = m.group(1)
            continue
        
    
    #print("\n".join("{}\t{}".format(k, mapper[k]) for k in mapper))
    
    sq_regex = "@SQ\tSN:(\S+)"
    
    for line in open(thousand_gp_header):
        line = line.strip()
        m = re.match(sq_regex, line)
        if m is not None:
            to_map = m.group(1)
            if to_map == "MT":
                to_map = "M"
            if to_map in mapper:
                line = line[:7] + mapper[to_map] + line[7+len(m.group(1)):]
                
        print(line)
            
            
