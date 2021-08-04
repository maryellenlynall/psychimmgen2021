import pandas as pd
import os
in_af = '/nfs/team205/MRC_lab/mel41/gnomad/variant-annotation.parquet'
parquet = '/nfs/team205/MRC_lab/mel41/gnomad/variant-annotation-hg38cols.parquet'
parquet_toy = '/nfs/team205/MRC_lab/mel41/gnomad/variant-annotation-hg38cols-toy.parquet'
pd.set_option('display.max_columns', 500) 
afs = pd.read_parquet(in_af, columns=['chrom_b38', 'pos_b38', 'ref', 'alt', 'af'])
print(afs.dtypes)
print(afs.head())
print(afs.shape) 

afs_af = pd.DataFrame(afs['af'].tolist(), index=afs.index)

df = pd.concat([afs.drop('af', axis=1), pd.DataFrame(afs_af['gnomad_nfe'])], axis=1)
df.rename(columns={"gnomad_nfe": "af.gnomad_nfe"}, inplace=True)

df.dropna(axis=0, inplace=True)
print(df.head())
print(df.dtypes)
print(df.shape)
df.to_parquet(parquet)
df_toy=df.iloc[0:1000,]
df_toy.to_parquet(parquet_toy)
quit()
