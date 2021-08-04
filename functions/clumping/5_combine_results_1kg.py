#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Ed Mountjoy
#

import pyspark.sql
from pyspark.sql.types import *
from pyspark.sql.functions import *
import os
from shutil import copyfile
from glob import glob

def main():

    # Make spark session
    # Using `ignoreCorruptFiles` will skip empty files
    spark = (
        pyspark.sql.SparkSession.builder
        .config("spark.sql.files.ignoreCorruptFiles", "true")
        .config("spark.master", "local[*]")
        .getOrCreate()
    )
    # sc = spark.sparkContext
    print('Spark version: ', spark.version)

    # Args
    # UPDATE THESE PATHS
    in_top_loci_pattern = '/home/ubuntu/results/finemapping_1kg/output/study_id=*/phenotype_id=*/bio_feature=*/chrom=*/top_loci.json.gz'
    in_credset_pattern = '/home/ubuntu/results/finemapping_1kg/output/study_id=*/phenotype_id=*/bio_feature=*/chrom=*/credible_set.json.gz'
    out_top_loci = '/home/ubuntu/results/finemapping_1kg/results/top_loci'
    out_credset = '/home/ubuntu/results/finemapping_1kg/results/credset'

    # Process top loci 
    (
        spark.read.json(in_top_loci_pattern)
        .coalesce(1)
        .orderBy('study_id', 'phenotype_id', 'bio_feature',
                 'chrom', 'pos')
        .write.json(out_top_loci,
                    compression='gzip',
                    mode='overwrite')
    )
    
    # Copy to single file
    copyfile(
        glob(out_top_loci + '/part-*.json.gz')[0],
        out_top_loci + '.json.gz'
    )
    
    # Process cred set
    (
        spark.read.json(in_credset_pattern)
        .repartitionByRange('lead_chrom', 'lead_pos')
        .sortWithinPartitions('lead_chrom', 'lead_pos')
        .write.json(out_credset,
                    compression='gzip',
                    mode='overwrite')
    )
    


    return 0

if __name__ == '__main__':

    main()
