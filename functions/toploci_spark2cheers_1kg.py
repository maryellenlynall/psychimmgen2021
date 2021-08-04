import pandas as pd
import os

in_json='/lustre/scratch117/cellgen/team297/mel41/sumstats_clump/top_loci_and_finemapping_spark_output/1kg_filtered/210401/results/top_loci.json.gz'

df=pd.read_json(in_json, lines=True)
print(df.head())

grouped = df.groupby(df.study_id)
grouped.head

# Rename columns to what CHEERS needs i.e. 'Chrom', 'SNP','BP'
df.rename(columns={'hm_rsid':'SNP','chrom':'Chrom','pos':'BP'}, inplace=True)
df.head()

df['Chrom'] = 'chr' + df['Chrom'].astype(str)

df["study_id"].unique()

adhd = grouped.get_group("adhd_demontis2017_hg38")
alz = grouped.get_group('alz_jansen2019_hg38')
asd = grouped.get_group("asd_grove2017_hg38")
bip = grouped.get_group('bip_stahl2018_hg38')
bmi = grouped.get_group('bmi_pulit2018_hg38')
crossdis = grouped.get_group('crossdisorder_lee2019_hg38')
mdd = grouped.get_group('mdd_mvp2020_hg38')
szs = grouped.get_group('szs_ripke2014_hg38')
ra = grouped.get_group('ra_okada2014_hg38')

print("See example output: this is ASD")
print(asd.head())

# How many top hits are there per study? 
print("adhd top hits:", adhd.shape[0])
print("asd top hits:", asd.shape[0])
print("alz top hits:", alz.shape[0])
print("bip top hits:", bip.shape[0])
print("bmi top hits:", bmi.shape[0])
print("crossdis top hits:", crossdis.shape[0])
print("mdd top hits:", mdd.shape[0])
print("szs top hits:", szs.shape[0])
print("ra top hits:", ra.shape[0])

# Now save
adhd.to_csv('forcheers_adhd_1kg.tsv', sep='\t', index=False, na_rep='NA')
alz.to_csv('forcheers_alz_1kg.tsv', sep='\t', index=False, na_rep='NA')
bip.to_csv('forcheers_bip_1kg.tsv', sep='\t', index=False, na_rep='NA')
bmi.to_csv('forcheers_bmi_1kg.tsv', sep='\t', index=False, na_rep='NA')
crossdis.to_csv('forcheers_crossdis_1kg.tsv', sep='\t', index=False, na_rep='NA')
mdd.to_csv('forcheers_mdd_1kg.tsv', sep='\t', index=False, na_rep='NA')
szs.to_csv('forcheers_szs_1kg.tsv', sep='\t', index=False, na_rep='NA')
asd.to_csv('forcheers_asd_1kg.tsv', sep='\t', index=False, na_rep='NA')
ra.to_csv('forcheers_ra_1kg.tsv', sep='\t', index=False, na_rep='NA')

print("Finished")
