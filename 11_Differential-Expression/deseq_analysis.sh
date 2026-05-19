#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -n 2
#SBATCH -t 2:00:00
#SBATCH -J DESeq2_analysis
#SBATCH -o /proj/uppmax2026-1-61/nobackup/work/tede0387/11_Differential-Expression/logs/deseq2_%j.log
#SBATCH -e /proj/uppmax2026-1-61/nobackup/work/tede0387/11_Differential-Expression/logs/deseq2_%j.err

# === SETUP ===
OUTPUT_DIR="/proj/uppmax2026-1-61/nobackup/work/tede0387/11_Differential-Expression"
mkdir -p ${OUTPUT_DIR}/logs

# === MODULES ===
module load R-bundle-Bioconductor/3.20-foss-2024a-R-4.4.2

# === RUN DESEQ2 ===
echo "[$(date)] Starting DESeq2 analysis..."
Rscript deseq2_analysis.R

echo "[$(date)] DESeq2 analysis complete!"
echo "Results in: ${OUTPUT_DIR}"
