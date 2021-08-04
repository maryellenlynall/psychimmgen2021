CHEERSDIR=/lustre/scratch117/cellgen/team297/mel41/sumstats_clump/cheers/
DATADIR=$CHEERSDIR/peakdata/
f=$1
peaks=$2
python2 $CHEERSDIR/CHEERS_computeEnrichment.py --input $DATADIR/${peaks}_counts_normToMax_quantileNorm_euclideanNorm.txt --ld $CHEERSDIR/${f}_1kg/ --trait ${f}_${peaks} --outdir $CHEERSDIR/cheersout/
# For CHEERS_computeEnrichment.py script, see CHEERS repository at: https://github.com/trynkaLab/CHEERS