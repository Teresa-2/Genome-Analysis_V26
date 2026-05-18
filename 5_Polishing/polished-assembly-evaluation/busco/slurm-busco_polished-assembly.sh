#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -n 2
#SBATCH --mem=32G
#SBATCH -t 6:00:00
#SBATCH -J busco_polished

# ── MODULES ──────────────────────────────────────────────────────────────
module load BUSCO/5.8.2-gfbf-2024a

# ── PATHS ────────────────────────────────────────────────────────────────
ASSEMBLY="pilon_output/polished_assembly.fasta"
LINEAGE="/home/bio/2-repeatMasker/busco_downloads/lineages/embryophyta_odb12"
OUTDIR="busco_polished-assembly"
THREADS=2

mkdir -p "$OUTDIR"

# ── BUSCO evaluation ─────────────────────────────────────────────────────
echo "[$(date)] BUSCO started"

busco \
    -i "$ASSEMBLY" \
    -l "$LINEAGE" \
    -o polished_busco \
    --out_path "$OUTDIR" \
    -m genome \
    -c "$THREADS"

echo "[$(date)] BUSCO finished. Output in: $OUTDIR"
