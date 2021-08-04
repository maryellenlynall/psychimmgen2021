#!/bin/bash

snakemake_dir=$(pwd)
source .venv/bin/activate
cd $snakemake_dir
pwd
MEM=2000
CORES=1

for f in toharmonise/*.tsv; do
    n=$snakemake_dir/$(echo $f | sed "s/.tsv//g")
    echo $n
    jobname=$(echo $f | sed "s/.tsv//g")
    echo $jobname
    h=$n/harmonised.qc.tsv
    if bjobs -w | grep -q $n || [ -e $h ] ; then
        :
    else
        echo "Submitting $n for harmonisation"
        mkdir -p $n
	bsub -q long -n${CORES} -o ${snakemake_dir}/hg38_test%J -e ${snakemake_dir}/hg38_error%J -R"select[mem>${MEM}] rusage[mem=${MEM}] span[ptile=${CORES}]" -M${MEM} -J"snakemake-harmonise" "snakemake --rerun-incomplete -d $n --configfile $snakemake_dir/config_hg19tohg38.yaml --profile lsf_farm $h"
    fi
done