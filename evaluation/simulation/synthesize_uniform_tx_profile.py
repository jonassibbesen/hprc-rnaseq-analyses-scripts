#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Feb 25 19:58:26 2022

@author: Jordan
"""

import sys
import re
import collections

if __name__ == "__main__":
    
    
    thread_names_fp = sys.argv[1]
    
    hst_regex = "(ENST\d+\.\d+)(_H\d+)"
    
    hsts = collections.defaultdict(list)
    for name in open(thread_names_fp):
        m = re.search(hst_regex, name)
        hsts[m.group(1)].append(m.group(2))
    
    print("transcript_id\tgene_id\tlength\teffective_length\texpected_count\tTPM\tFPKM\tIsoPct")
    for tx in sorted(hsts):
        for hst in sorted(hsts[tx]):
            print("{0}\t{0}\t1\t1\t{1}\t{1}\t{1}\t{1}".format("{}{}".format(tx, hst), 100.0 / len(hsts[tx])))

