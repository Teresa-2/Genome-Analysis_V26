#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -n 2
#SBATCH -t 02:00:00
#SBATCH -J busco_braker_prot
#SBATCH -e logs/busco_braker-proteins_%j.err
#SBATCH -o logs/busco_braker-proteins_%j.out

module load BUSCO

INPUT="../braker.aa"
OUTDIR="busco_braker-proteins"
LINEAGE="embryophyta_odb12"
THREADS=2

mkdir -p $(dirname $OUTDIR)
cd $(dirname $OUTDIR)

busco \
    -i $INPUT \
    -m protein \
    -l $LINEAGE \
    -o $(basename $OUTDIR) \
    -c $THREADS
