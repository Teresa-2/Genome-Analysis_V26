#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -n 2
#SBATCH --mem=8G
#SBATCH -t 2:00:00
#SBATCH -J quast_polished

# ── MODULES ──────────────────────────────────────────────────────────────
module load QUAST/5.3.0

# ── PATHS ────────────────────────────────────────────────────────────────
ASSEMBLY="pilon_output/polished_assembly.fasta"
OUTDIR="quast_results"
THREADS=2

mkdir -p "$OUTDIR"

# ── QUAST evaluation ─────────────────────────────────────────────────────
echo "[$(date)] QUAST started"

quast.py \
    "$ASSEMBLY" \
    --threads "$THREADS" \
    --eukaryote \
    --output-dir "$OUTDIR"

echo "[$(date)] QUAST finished. Output in: $OUTDIR"
