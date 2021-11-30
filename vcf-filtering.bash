# move to your vcf directory
cd ~/vcf

# copy the data file from the data directory
cp /encrypted/e3001/data/200kexomes/ukb23156_cY_b0_v1.vcf.gz .

#Verify the size of our vcf
ls -lh *.vcf.gz
1.9G #Output

#load bcftools module from ibex to analyze the data 
bcftools view -H ukb23156_cY_b0_v1.vcf.gz | wc -l
6306 #output

#Randomly subsampling a vcf to get an idea of how they look for some basic statistics (i.e. minor allele frequency, depth of coverage and so on).The subsampling is random to avoid bias. cvflib is the tool used to subset the data, however the tool cannot handle an uncompressed VCF, so we first open the file using bcftools and then pipe it to the vcfrandomsample utility. We set only a single parameter, -r which is the rate of sampling. This essentially means the fraction of variants we want to retain.(this step takes to much time) (IMPORTANT:vcflib is not available as an ibex module, I installed it using conda)
bcftools view ukb23156_cY_b0_v1.vcf.gz | vcfrandomsample -r 0.012 > ukb23156_cY_b0_v1_subset.vcf

#Before proceeding though, we should compress and index our new subset VCF to make it easier to access by the tools.
# Compress vcf (IMPORTANT: bgzip is an utility of samtools that is not available in the samtools version of ibex modules, so is necessary to install it independently, with conda for instance)
bgzip ukb23156_cY_b0_v1_subset.vcf 
#Index the compressed vcf
bcftools index ukb23156_cY_b0_v1_subset.vcf.gz

#Generating statistics from a VCF file
#In order to generate statistics from our VCF and also actually later apply filters, we are going to use vcftools. Now, we will analyse our VCF in order to get a sensible idea of how to set the filtering thresholds. The main areas we will consider are:deep, quality,MAF and missing data. 
#Fist we need to set up the output folder. 
#Output directory
mkdir vcftools-out
#First we need to load ibex module for vcftools
module load vcftools/0.1.17

#Calculate Allele Frecuency
#First we will calculate the allele frequency for each variant. The --freq2 just outputs the frequencies without information about the alleles, --freq would return their identity. We need to add max-alleles 2 to exclude sites that have more than two alleles.
vcftools --gzvcf ukb23156_cY_b0_v1_subset.vcf.gz --freq2 --out ./vcftools-out/ --max-alleles 2

#Next we calculate the mean depth of coverage per individual.
vcftools --gzvcf ukb23156_cY_b0_v1_subset.vcf.gz --depth --out ./vcftools-out/

#Similarly, we also estimate the mean depth of coverage for each site.
vcftools --gzvcf ukb23156_cY_b0_v1_subset.vcf.gz --site-quality --out ./vcftools-out/

#Calculate proportion of missing data per individual/sample
vcftools --gzvcf ukb23156_cY_b0_v1_subset.vcf.gz --missing-indv --out ./vcftools-out/

#Calculate proportion of missing data per site
vcftools --gzvcf ukb23156_cY_b0_v1_subset.vcf.gz --missing-site --out ./vcftools-out/

#Calculate heterozygosity and inbreeding coefficient per individual
#Computing heterozygosity and the inbreeding coefficient (F) for each individual can quickly highlight outlier individuals that are e.g. inbred (strongly negative F), suffer from high sequencing error problems or contamination with DNA from another individual leading to inflated heterozygosity (high F), or PCR duplicates or low read depth leading to allelic dropout and thus underestimated heterozygosity (stongly negative F). However, note that here we assume Hardy-Weinberg equilibrium. If the individuals are not sampled from the same population, the expected heterozygosity will be overestimated due to the Wahlund-effect. It may still be worth to compute heterozygosities even if the samples are from more than one population to check if any of the individuals stands out which could indicate problems.
vcftools --gzvcf ukb23156_cY_b0_v1_subset.vcf.gz --het --out ./vcftools-out/
# Now, we need to download our output data onto our local machines in order to work with R.
