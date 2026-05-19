#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -n 1
#SBATCH -t 01:00:00
#SBATCH -J DNA-post-fastqc
#SBATCH -o logs/DNA-post-fastqc_%j.out
#SBATCH -e logs/DNA-post-fastqc_%j.err

module load FastQC

SRC_DIR="/proj/uppmax2026-1-61/nobackup/work/tede0387/2_Trimming/DNA-trimmed-reads"

fastqc $SRC_DIR/chr3_R1_paired.fq.gz $SRC_DIR/chr3_R2_paired.fq.gz -o /proj/uppmax2026-1-61/nobackup/work/tede0387/3_Post-processing-QC/DNA_post-processing_QC/new_results/
