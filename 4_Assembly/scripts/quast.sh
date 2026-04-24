#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -n 2
#SBATCH -t 01:00:00
#SBATCH -J old_quast
#SBATCH -o quast_old_%j.out
#SBATCH -e quast_old_%j.err

module load QUAST/5.3.0-gfbf-2024a

OUTDIR="/proj/uppmax2026-1-61/nobackup/work/tede0387/Genome-Analysis_V26/4_Assembly/old_flye_chr3_assembly/assembly-evaluation"
QUAST_OUTPUT="${OUTDIR}/old_quast"

cd $OUTDIR

quast.py assembly.fasta \
    -o $QUAST_OUTPUT \
    --threads 2 \
    --contig-thresholds 0,1000,5000,10000
