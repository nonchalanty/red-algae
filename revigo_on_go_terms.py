#!/usr/bin/env python3

# Python script for programtic access to Revigo. Run it with (last output file name is optional):
# python3 revigo.py example.csv result.csv

import requests
import time
import sys

# Read enrichments file
userData = open(sys.argv[1],'r').read()

# Submit job to Revigo
payload = {'cutoff':'0.7', 'valueType':'pvalue', 'speciesTaxon':'0', 'measure':'SIMREL', 'goList':userData}
r = requests.post("http://revigo.irb.hr/Revigo.aspx", data=payload)

# Write results to a file - if file name is not provided the default is result.csv
with open(sys.argv[2] if len(sys.argv)>=3 else 'result.csv','w') as f:
    f.write(r.text)
