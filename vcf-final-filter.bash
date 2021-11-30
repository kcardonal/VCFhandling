## Script to filter vcf files

## Import the packages to use

module load vcftools/0.1.17 
module load bcftools/1.10.2

## Define input and output file as variables

VCF_IN= /path/to/input/vcf.gz
VCF_OUT= /path/to/output/vcf-filtered.gz

# Set our choosen filters
MAF= 0.1
MISS= 0.9
QUAL= 30
MIN_DEPTH= 5
MAX_DEPTH= 12

## move to the directory which contains the raw vcf files
cd path/to/raw/vcf/

## Run the vcftools command on the data to produce a filtered vcf

## Parameters Meaning:
##	--gvcf - input path – denotes a gzipped vcf file
##	--remove-indels - remove all indels (this is to keep Single variants only)
##	--maf - set minor allele frequency - 0.1 here
##	--max-missing - set minimum missing data. To keep in mind: 0 is totally missing, 1 is none missing.
##	--minQ - the minimum quality score required for a site to pass our filtering threshold.
##	--min-meanDP - the minimum mean depth for a site.
##	--max-meanDP - the maximum mean depth for a site.
##	--minDP - the minimum depth allowed for a genotype - any individual failing this threshold is marked as having a 		missing genotype.
##	--maxDP - the maximum depth allowed for a genotype - any individual failing this threshold is marked as having a 		missing genotype.
##	--recode - recode the output - necessary to output a vcf
##	--stdout - pipe the vcf out to the stdout (easier for file handling)

## The command

vcftools --gzvcf $VCF_IN \
--remove-indels --maf $MAF --max-missing $MISS --minQ $QUAL \
--min-meanDP $MIN_DEPTH --max-meanDP $MAX_DEPTH \
--minDP $MIN_DEPTH --maxDP $MAX_DEPTH --recode --stdout | gzip -c > \ $VCF_OUT

## Check the effect of the filter in the variants, there are two ways
## 1. look at the vcftools log file
cat out.log
## 2. use bcftools to check how many variants remain
bcftools view -H $VCF_OUT | wc -l
