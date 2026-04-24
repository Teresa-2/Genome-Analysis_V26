#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -n 1
#SBATCH -t 01:00:00
#SBATCH -J fastqc
#SBATCH -o logs/%j.out
#SBATCH -e logs/%j.err

module load FastQC
SRC_DIR="/proj/uppmax2026-1-61/nobackup/work/tede0387/Genome-Analysis_V26/2_Trimming/RNA-trimmed-reads"

fastqc $SRC_DIR/Control_*_R*_paired.fq.gz $SRC_DIR/Heat_treated_42_12h_*_R*_paired.fq.gz -o results/
