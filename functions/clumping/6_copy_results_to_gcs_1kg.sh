#!/usr/bin/env bash
#

version_date=`date +%y%m%d`
LUSTREDIR=/lustre/scratch117/cellgen/team297/mel41/sumstats_clump/top_loci_and_finemapping_spark_output/

# UPDATE LOCATION
mkdir -p  $LUSTREDIR/1kg_filtered/$version_date

# Copy results
cp -R /home/ubuntu/results/finemapping_1kg/results/ ${LUSTREDIR}/1kg_filtered/$version_date

# Tar the logs and copy over
tar -zcvf logs.tar.gz /home/ubuntu/results/finemapping_1kg/logs
cp logs.tar.gz ${LUSTREDIR}/1kg_filtered/$version_date/logs.tar.gz

