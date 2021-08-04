cd /lustre/scratch117/cellgen/team297/mel41/sumstats_clump/cheers/1KG_HG38_EUR

chr=$1
OUTPUT3="/lustre/scratch117/cellgen/team297/mel41/sumstats_clump/cheers/1KG_HG38_EUR/EUR.chr${chr}.shapeit2_integrated_snvindels_v2a_27022019.GRCh38.phased.maf0.01.annot.vcf.gz"
FILE_R2="/lustre/scratch117/cellgen/team297/mel41/sumstats_clump/cheers/1KG_HG38_EUR/EUR_r2_maf0p01/chr${chr}_GRCh38.EUR"
mkdir -p "${FILE_R2%/*}"
bcftools query -f'%ID\n' --output ${FILE_R2}.snplist.txt $OUTPUT3 
plink --vcf $OUTPUT3 --r2 --ld-window 100 --ld-window-kb 1000 --vcf-half-call h --out $FILE_R2 --ld-snp-list ${FILE_R2}.snplist.txt
EURSNPS="/lustre/scratch117/cellgen/team297/mel41/sumstats_clump/cheers/1KG_HG38_EUR/EUR.chr${chr}.shapeit2_integrated_snvindels_v2a_27022019.GRCh38.phased.maf0.01.snplist.tsv"
bcftools query -f'%ID %CHROM %POS %REF %ALT %INFO/EUR_AF\n' --output $EURSNPS --print-header $OUTPUT3 
head $EURSNPS
echo "Chromosome ${chr} done"