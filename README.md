# psychimmgen2021

Code to accompany paper Lynall 2021

## Datasets generated

Partitioned LD scores for active regulatory regions for ROADMAP epigenomics tissues are available on Zenodo [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.5153661.svg)](https://doi.org/10.5281/zenodo.5153661)

## Scripts

### ROADMAP ANALYSIS
- psychimmgenA01  Get IDEAS trackhubs and name roadmap samples
- psychimmgenA02  Convert IDEAS tracks to bed file of ranges for the active states
- psychimmgenA03	Make ldcts, annotations, then partition LD scores for the active elements
- psychimmgenA04 	Make nongenic enhancers bed files 
- psychimmgenA05	Make promoter and genicenhancer bed files
- psychimmgenA06	Make thin annots from the separate annotations bed files (promoters and enhancers) and make ldcts regression files
- psychimmgenA07	Submission script for partitioning of LD scores
- psychimmgenA08	Process cross-disorder summary statistics (SS), then do normal and conditional s-LDSC analysis 
- psychimmgenA09	Process MDD SSs and do s-LDSC 
- psychimmgenA10	Process RA SSs and do s-LDSC
- psychimmgenA11	Process SZS SSs and do s-LDSC
- psychimmgenA12	Process BMI SSs and do s-LDSC
- psychimmgenA13	Process ASD SSs and do s-LDSC
- psychimmgenA14	Process Alzheimer's SSs and do s-LDSC
- psychimmgenA15	Process ADHD SSs and do s-LDSC
- psychimmgenA16	Process bipolar disorder SSs and do s-LDSC
- psychimmgenA17	Integrate s-LDSC results across disorders
- psychimmgenA18	s-LDSC for component annotations (separate promoters and enhancers) 
- psychimmgenA19	View promoter/enhancer s-LDSC results from psychimmgenA18
- psychimmgenA20	Test correlations between s-LDSC z-scores and heritability z-scores

### Summary statistic harmonization and lead loci identification detection
- psychimmgenB01	Convert sumstats to format required by harmonization pipeline and call harmonization pipeline for crossdisorder risk
- psychimmgenB02  Repeat of psychimmgenB01 processing for disorder-specific risks
- psychimmgenB03	Convert harmonized tsv to parquet format
- psychimmgenB04	Generate r2 linkage disequilibrium for 1KG EUR hg38 then filter summary stats on 1KG SNPs
- psychimmgenB05	Use Apache Spark to do distance-based clumping for the 1KG filtered SNPs

### CHEERS analysis of BLUEPRINT immune cell subsets and Soskic immune stimulation datasets
- psychimmgenB06	Generate LD blocks and compute CHEERS enrichment for BLUEPRINT and Soskic datasets
- psychimmgenB07	Reformat results to obtain top loci
- psychimmgenB08	Process and visualise BLUEPRINT results
- psychimmgenB09	Process and visualise Soskic dataset results
- psychimmgenB10	Z-test to compare results for stimulated vs. unstimulated immune cells
- psychimmgenB11	Find nearest genes and perform overrepresentation (pathway) analysis

### Response to reviewers
- psychimmgen_revisions01 Identify and visualise Soskic MDD-SZS discordant variant-peak overlaps
- psychimmgen_revisions02 Identify and visualise Blueprint MDD-SZS discordant variant-peak overlaps
- psychimmgen_revisions03 Blueprint vs Soskic – is replication driven by overlap of regulatory elements?
- psychimmgen_revisions04 Characteristics of Soskic and Blueprint MDD-SZS discordant peaks 





