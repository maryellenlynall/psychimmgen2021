#!/bin/bash

# ARGUMENTS;
# $1 LDSCDIR (input and output dir)
# $2 ANNOTDIR (e.g /IDEASv1_ldscores, where annots are and where ldscores will go)
# $3 PREFIX (e.g. IDEASv1_active)
# $4 TISSUES (array, eg.. E001 E002 etc)
# $5 NUMTHREADS (e.g. 22 for ldsc as 22 chromosomes)
# $6 ANNOT e.g. 4_Enh, promoters (thin annot files you have generated earlier)
# $7 FAILED JOB INDEX (will be a tissue and chr)

# This takes the annot files and makes partitioned LD scores files for each tissue and chromosome

# Extra argument to fix failed jobs
if [ ! -z "$7" ] ; then # -z = empty
LSB_JOBINDEX=$7
fi

LDSCDIR=$1
ANNOTDIR=$2
PREFIX=$3
TISSUEFILE=$4
NUMTHREADS=$5
ANNOT=$6

LDSC=/nfs/users/nfs_m/ml14/Software/ldsc/ldsc.py

# Chromosomes
chromosomes=($(seq 21 1 22))

# Check appropriate arguments
if [ ! -f "$LDSC" ] ; then 
echo "Sorry ldsc.py not available "
exit 1
fi

if [ -z "$NUMTHREADS" ] ; then
echo "Please set number of threads to use (ARG 5)"
exit 1
fi

if [ -z "$LDSCDIR" ] ; then
echo "Please include a directory of input directories (ARG 1)"
exit 1
fi

if [ -z "$ANNOTDIR" ] ; then
echo "Please include a directory of annotation files (ARG 2)"
exit 1
fi

if [ -z "$TISSUEFILE" ] ; then
echo "Please include file of tissue names"
exit 1
fi

if [ -z "$ANNOT" ] ; then
echo "Please include annotation name"
exit 1
fi

if [ -z "$PREFIX" ] ; then
echo "Warning: no annotation prefix included"
fi

ARRAYINDEX=$(($LSB_JOBINDEX-1))
echo Doing Array index "${ARRAYINDEX}"
TISSUES=(`cat "${TISSUEFILE}"`)
t=${TISSUES[$ARRAYINDEX]}
echo Doing tissue "${t}"

# Run LDSC
echo $t
for CHR in "${chromosomes[@]}"
  do
  echo $CHR
  if [[ -f ${ANNOTDIR}/${PREFIX}_${ANNOT}_${t}.${CHR}.l2.ldscore.gz ]]; then
    echo "LDSCORES already made"
  else
    echo "Making partitioned LDSCORES"
    python $LDSC \
--l2 \
--bfile ${LDSCDIR}/1000G_EUR_Phase3_plink/1000G.EUR.QC.${CHR} \
--ld-wind-cm 1 \
--annot ${ANNOTDIR}/${PREFIX}_${ANNOT}_${t}.${CHR}.annot.gz \
--thin-annot \
--out ${ANNOTDIR}/${PREFIX}_${ANNOT}_${t}.${CHR} \
--print-snps ${LDSCDIR}/listHM3.txt
  fi
done
    
echo $?
