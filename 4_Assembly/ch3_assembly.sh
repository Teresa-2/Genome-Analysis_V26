#!/bin/bash -l
#SBATCH -A uppmax2026-1-61
#SBATCH -n 2
#SBATCH --mem=100
#SBATCH -t 36:00:00
#SBATCH -J flye_chr3
#SBATCH -o /proj/uppmax2026-1-61/nobackup/work/tede0387/Genome-Analysis_V26/4_Assembly/logs/flye_chr3_%j.out
#SBATCH -e /proj/uppmax2026-1-61/nobackup/work/tede0387/Genome-Analysis_V26/4_Assembly/logs/flye_chr3_%j.err

module load Flye/2.9

READS="/proj/uppmax2026-1-61/Genome_Analysis/2_Zhou_2023/reads/genomics_chr3_data/chr3_clean_nanopore.fq.gz"
OUTDIR="/proj/uppmax2026-1-61/nobackup/work/tede0387/Genome-Analysis_V26/4_Assembly/flye_chr3_assembly"
THREADS=2

mkdir -p $OUTDIR

flye \
    --nano-raw $READS \
    --out-dir $OUTDIR \
    --threads $THREADS
