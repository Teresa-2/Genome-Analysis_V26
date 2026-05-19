#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -n 2
#SBATCH -t 02:00:00
#SBATCH -J busco_braker_trans
#SBATCH -e logs/busco_braker-transcripts_%j.err
#SBATCH -o logs/busco_braker-transcripts_%j.out

module load BUSCO

INPUT="../braker.codingseq"
OUTDIR="busco_braker-transcripts"
LINEAGE="embryophyta_odb12"
THREADS=2

mkdir -p $(dirname $OUTDIR)
cd $(dirname $OUTDIR)

busco \
    -i $INPUT \
    -m transcriptome \
    -l $LINEAGE \
    -o $(basename $OUTDIR) \
    -c $THREADS
