#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Adapted from code by Ed Mountjoy (see README)
#
'''

export PYSPARK_SUBMIT_ARGS="--driver-memory 80g pyspark-shell"
export SPARK_HOME=/usr/local/spark
export PYTHONPATH=$SPARK_HOME/python:$SPARK_HOME/python/lib/py4j-0.10.7-src.zip/$PYTHONPATH

'''

import pyspark.sql
from pyspark.sql.types import *
from pyspark.sql.functions import *
from glob import glob
from functools import reduce

def main():

    # Make spark session
    spark = (
        pyspark.sql.SparkSession.builder
        .config("spark.master", "local[*]")
        .getOrCreate()
    )
    # sc = spark.sparkContext
    print('Spark version: ', spark.version)

    # Args
    gwas_pval_threshold = 5e-8

    # Paths
    gwas_pattern = '/lustre/scratch117/cellgen/team297/mel41/sumstats_clump/filtered/parquets/*_1kg.parquet'
    out_path = '/home/ubuntu/results/finemapping_1kg/tmp/filtered_input'

    # Load GWAS dfs
    strip_path_gwas = udf(lambda x: x.replace('file:', '').split('/part-')[0], StringType())
    gwas_dfs = (
        spark.read.parquet(gwas_pattern)
            .withColumn('pval_threshold', lit(gwas_pval_threshold))
            .withColumn('input_name', strip_path_gwas(input_file_name()))
    )

    mol_dfs = []

    # Take union
    df = reduce(
        pyspark.sql.DataFrame.unionByName,
        [gwas_dfs] + mol_dfs
    )
    
    # Process
    df = (
        df.filter(col('pval') < col('pval_threshold'))
          .select('type', 'study_id', 'phenotype_id', 'bio_feature', 'gene_id', 'chrom', 'pval_threshold', 'input_name')
          .distinct()
    )

    # Write
    (
        df
          .coalesce(300)
          .write.json(out_path,
                      compression='gzip',
                      mode='overwrite')
    )

    return 0

if __name__ == '__main__':

    main()
