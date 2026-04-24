#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -n 1
#SBATCH -t 01:00:00
#SBATCH -J fastqc

module load FastQC
SRC_DIR="/proj/uppmax2026-1-61/nobackup/work/tede0387/Genome-Analysis_V26/2_Trimming/DNA-trimmed-reads"

fastqc $SRC_DIR/chr3_R1_paired.fq.gz $SRC_DIR/chr3_R2_paired.fq.gz -o results/
