# Now make tabix for LD
cd /lustre/scratch117/cellgen/team297/mel41/sumstats_clump/cheers/1KG_HG38_EUR/EUR_r2_maf0p01/
chr=$1
FILE_R2="chr${chr}_GRCh38.EUR"
sed "s/^[ \t]*//" -i ${FILE_R2}.ld
tr -s ' ' \\t < ${FILE_R2}.ld | sort -n -k 2 | bgzip > ${FILE_R2}.ld.bgz
tabix --sequence 1 --begin 2 --end 2 --force --skip-lines 1 ${FILE_R2}.ld.bgz
