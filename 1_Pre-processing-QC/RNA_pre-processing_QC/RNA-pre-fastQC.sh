#!/bin/bash -l
#SBATCH -A uppmax2026-1-61
#SBATCH -n 1
#SBATCH -t 01:00:00
#SBATCH -J RNA-fastqc

READS_DIR="/proj/uppmax2026-1-61/Genome_Analysis/2_Zhou_2023/reads/transcriptomic_data"

fastqc \
$READS_DIR/Control_1_f1.fq.gz \
$READS_DIR/Control_1_r2.fq.gz \
$READS_DIR/Control_2_f1.fq.gz \
$READS_DIR/Control_2_r2.fq.gz \
$READS_DIR/Control_3_f1.fq.gz \
$READS_DIR/Control_3_r2.fq.gz \
$READS_DIR/Heat_treated_42_12h_1_f1.fq.gz \
$READS_DIR/Heat_treated_42_12h_1_r2.fq.gz \
$READS_DIR/Heat_treated_42_12h_2_f1.fq.gz \
$READS_DIR/Heat_treated_42_12h_2_r2.fq.gz \
$READS_DIR/Heat_treated_42_12h_3_f1.fq.gz \
$READS_DIR/Heat_treated_42_12h_3_r2.fq.gz \
-o results
