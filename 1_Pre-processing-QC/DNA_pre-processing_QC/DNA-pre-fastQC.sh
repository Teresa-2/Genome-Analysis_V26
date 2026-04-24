#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -n 1
#SBATCH -t 01:00:00
#SBATCH -J fastqc

module load FastQC

READS_DIR="/proj/uppmax2026-1-61/Genome_Analysis/2_Zhou_2023/reads/genomics_chr3_data"

fastqc $READS_DIR/chr3_illumina_R1.fastq.gz $READS_DIR/chr3_illumina_R2.fastq.gz -o results/
