#!/bin/bash

#By: Ryan K Schott

# FASTQC (https://www.bioinformatics.babraham.ac.uk/projects/fastqc/)
# fastp (https://github.com/OpenGene/fastp)
# multiqc (https://github.com/MultiQC/MultiQC)
# GNU   parallel (https://www.gnu.org/software/parallel/)

# Requires GNU parallel, fastqc, fastp, and multiqc to be installed and in your PATH
# Raw reads must be in the current working directory and named with _R1.fq.gz and _R2.fq.gz for paired end reads

# Usage: bash parallel_QC.sh


#Create samples file from reads in current directory
ls *R1* > R1.txt

ls *R2* > R2.txt

cat R1.txt | parallel basename {} _R1.fq.gz >> samples.txt

echo "R1,R2,Sample" > Samples.csv

paste -d "," R1.txt R2.txt samples.txt >> Samples.csv

rm R1.txt R2.txt samples.txt

#FASTQC on raw reads
mkdir -p FASTQC_raw

parallel "fastqc {} -o FASTQC_raw" ::: *.fq.gz

#Run fastp on raw reads
mkdir -p fastp

cat Samples.csv | parallel --header : --colsep , \
"fastp -i {R1} -o fastp/{Sample}_fastp_R1.fq.gz -I {R2} -O fastp/{Sample}_fastp_R2.fq.gz"

cd fastp

#Run FASTQC on trimmed files
mkdir -p FASTQC_fastp

parallel "fastqc {} -o FASTQC_fastp" ::: *fq.gz

#Run MultiQC on all FASTQC results
cd ..

multiqc .
