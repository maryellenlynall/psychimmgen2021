"""
Code to convert harmonised.qc.tsv to parquet file for the open targets finemapping pipeline
Also does much of the filtering as in process.py Mountjoy ingest Spark file (recoded here to python): https://github.com/opentargets/genetics-sumstat-data/blob/master/ingest/gwas_catalog/scripts/process.py

Authors:
Mary-Ellen Lynall, James Hayhurst

Usage:
python tsv2parquet.py -inFile crossdisorder_lee2019_hg38_harmonised.qc.tsv -outFile testOut/out.parquet

"""

import pandas as pd
import os
import argparse
from pathlib import Path
import scipy.stats as st
import numpy as np # Needed for nan
import sys # Needed for minimum float

pd.set_option('display.max_columns', 500)

"""
pos has to be Int64 not int64 because of NAs
META = {
            'study_id': 'object',
            'phenotype_id': 'object',
            'bio_feature': 'object',
            'chrom': str,
            'pos': 'Int64',
            'ref': 'object',
            'alt': 'object',
            'beta': 'float64',
            'se': 'float64',
            'pval': 'float64',
            'n_total': 'float64',
            'n_cases': 'float64',
            'eaf': 'float64',
            'is_cc': 'bool'
        }
"""

def make_dir(path):
    directory = os.path.dirname(path)
    Path(directory).mkdir(parents=True, exist_ok=True)

def study_from_filename(tsv):
    base = Path(tsv).stem
    study = base.split('_')[0] + '_' + base.split('_')[1] + '_' + base.split('_')[2]
    return study 

def load_sumstats(tsv):
    df = pd.read_csv(tsv, delimiter='\t',
                         dtype = {'hm_chrom': str,
                                  'hm_pos': 'Int64',
                                  'hm_beta': 'float64',
                                  'se': 'float64',
                                  'pval': 'float64',
                                  'n_total': 'float64',
                                  'n_cases': 'float64',
                                  'eaf': 'float64'
                                 }
                        )
    df = df.loc[:, df.columns.isin(['hm_variant_id',
                                    'hm_rsid',
                                    'hm_chrom',
                                    'hm_pos',
                                    'hm_other_allele',
                                    'hm_effect_allele',
                                    'hm_effect_allele_frequency',
                                    'hm_beta',
                                    'hm_odds_ratio',
                                    'hm_code',
                                    'p_value',
                                    'standard_error',
                                    'INFO',
                                    'info'
                                    ])]
    df = df.rename(columns = {'hm_chrom':'chrom', 
                                    'hm_pos':'pos', 
                                    'hm_other_allele':'ref', 
                                    'hm_effect_allele':'alt', 
                                    'hm_effect_allele_frequency':'eaf', 
                                    'hm_beta':'beta', 
                                    'standard_error':'se', 
                                    'p_value':'pval', 
                                    'INFO':'info'
                                    }
                                )
    return df


def eaf_clean_and_impute(df, in_af):
    if df['eaf'].isnull().sum() > 0:
        print('Some/all EAFs are NA - imputing allele frequencies from gnomAD')
        afs=pd.read_parquet(in_af)
        afs.rename(columns={'chrom_b38':'chrom','pos_b38':'pos'}, inplace=True)
        afs.dropna(axis=0,inplace=True)
        afs=afs.astype({'chrom': 'str', 'pos':'Int64'})
        df = df.merge(afs, on=['chrom', 'pos', 'ref', 'alt'], how='left') 
        print('EAF and gnomad AF prior to imputation (head):')
        print(df.head(20))
        df['eaf'] = df.apply(lambda x: x['af.gnomad_nfe'] if pd.isna(x['eaf']) else x['eaf'], axis=1)
        nrows = df.count()
        print("Size and missing data per column once gnomAD allele frequencies imputed:")
        print('Total rows:',nrows)
        print(df.isnull().sum()) 
        df = df.dropna(subset=['eaf'])
        df.drop(columns=['af.gnomad_nfe'], inplace=True)
    else:
        print('EAF all present, no need for gnomAD imputation')
        df=df
    return df

class argstry:
    def __init__(self, inFile = None, outFile = None, ncases = None):
        self.inFile = inFile
        self.outFile = outFile
        self.n_cases = ncases

def parse_args():
    argparser = argparse.ArgumentParser()
    argparser.add_argument('-inFile', help='The path to the tsv in', required=False)
    argparser.add_argument('-outFile', help='The path to the parquet out', required=False)
    argparser.add_argument('-min_mac', help='Minimum minor allele count', required=False, type=int)
    argparser.add_argument('-n_cases', help='Number of cases in GWAS', required=False, type=int)
    argparser.add_argument('-n_total', help='Total number participants in GWAS', required=False, type=int)
    argparser.add_argument('-in_af', help='External allele frequency file (ensure build is matched)', required=False)
    argparser.add_argument('-min_rows', help='Minimum number of SNPs', required=False, type=int)
    args = argparser.parse_args()
    return args

def main(): # TOCHECK THIS
    args = parse_args()
    
    print("Input arguments:", vars(args))
    in_file=args.inFile
    out_file=args.outFile
    parquet=out_file
    study=study_from_filename(in_file)
    print("Study is", study)
    
    df=load_sumstats(in_file)
    print("Size of tsv is", df.shape)
    
    df = df.dropna(
    subset=['chrom', 'pos', 'ref', 'alt', 'pval', 'beta'])
    print("Size once drop NA rows (i.e. SNPs which coudln't be harmonised):", df.shape)
    
    nrows = df.count()
    maxrows = len(df)
    print("Total rows:", maxrows)
    print("Missing EAF data:", df.isnull().sum()) 
    if maxrows < args.min_rows:
        print('Skipping as only {0} rows in {1}'.format(maxrows, args.inFile))
        return 0
    else:
        print('Enough rows, continuing with clean and impute')
    
    df=eaf_clean_and_impute(df, args.in_af)
    
    print('Generating maf, mac')
    df['n_total']=args.n_total
    df['n_cases']=args.n_cases
    df['maf'] = df.apply(lambda x: x['eaf'] if x['eaf']<=0.5 else 1-x['eaf'], axis=1)
    df['mac'] = df.apply(lambda x: x['n_total'] * 2 * x['maf'], axis=1)
    if args.n_cases is None:
        print('Not calculating mac_cases as not case-control study')
        df['mac_cases']=np.nan
    else:
        df['mac_cases']=df.apply(lambda x: x['n_cases'] * 2 * x['maf'], axis=1)
    print("Shape prior to filtering on mac:")
    print(df.shape)
    df = df[ df['mac'] >= args.min_mac & ((df['mac_cases'] >= args.min_mac) | df['mac_cases'].isnull().all()) ]
    print("Shape after filtering on MAC >=", args.min_mac)
    print(df.shape)
    
    df['type']='gwas'    
    df['phenotype_id']=np.nan
    df['bio_feature']=np.nan
    df['gene_id']=np.nan
    df['study_id']=study

    if 'info' not in df:
        print('Adding blank info column')
        df['info']=np.nan
    
    if args.n_cases is None:
        print('No case numbers provided so assuming study is not case-control')
        df['is_cc']=False
    else:
        print('Study is case-control')
        df['is_cc']=True
    
    col_order = [
        'type',
        'study_id',
        'phenotype_id',
        'bio_feature',
        'gene_id',
        'chrom',
        'pos',
        'ref',
        'alt',
        'beta',
        'se',
        'pval',
        'n_total',
        'n_cases',
        'eaf',
        'mac',
        'mac_cases',
        'info',
        'is_cc'
        ]
    df = pd.concat([df[col_order],df.drop(columns=col_order)],axis=1)
    
    df['pval'] = df.apply(lambda x: sys.float_info.min if x['pval']==0.0 else x['pval'], axis=1)

    print("Out file at:", parquet)
    make_dir(parquet)

    print('Following saved to parquet:')
    print(df.head())
    df.to_parquet(parquet)

if __name__ == "__main__":
    main()
