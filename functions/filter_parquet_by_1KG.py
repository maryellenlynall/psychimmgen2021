
import pandas as pd
import os
import argparse
from pathlib import Path

"""
# Filtering summary stats on the EUR hg38 1KG SNP list 
"""

def study_from_filename(tsv):
    base = Path(tsv).stem
    study = base.split('_')[0] + '_' + base.split('_')[1] + '_' + base.split('_')[2]
    return study

def parse_args():                                   
    argparser = argparse.ArgumentParser()
    argparser.add_argument('-inFile', help='The path to the parquet in', required=True)
    argparser.add_argument('-outFile', help='The path to the parquet out', required=True)
    argparser.add_argument('-filterSnps', help='The path of file with list of SNPs to filter by, in format CHR_POS_REF_ALT', required=True)
    args = argparser.parse_args()
    return args

def main():
  args = parse_args()
  study = study_from_filename(args.inFile)
  print(study)

  # Read in summary stats
  df = pd.read_parquet(args.inFile)
  print("Size of parquet is", df.shape)

  # Read in SNP file
  snps = pd.read_csv(args.filterSnps,header=None)

  snps=snps.rename(columns={0: "variant_id"})
  print(snps.head)

  filtered=df.set_index('hm_variant_id').join(snps.set_index('variant_id'), how="inner")
  filtered['hm_variant_id']=filtered.index
  print(filtered.head)

  filtered.to_parquet(args.outFile)

if __name__ == "__main__":
    main()

    