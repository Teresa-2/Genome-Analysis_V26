#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -J merqury
#SBATCH -N 1
#SBATCH -n 2
#SBATCH -t 3:00:00
#SBATCH --output=merqury_%j.log
#SBATCH --error=merqury_%j.err

module load merqury/20240628-1ad7c32-gfbf-2024a

ASSEMBLY="/proj/uppmax2026-1-61/nobackup/work/tede0387/6_Masking/new_repeatMasker/polished_assembly.fasta"
READS_R1="/proj/uppmax2026-1-61/Genome_Analysis/2_Zhou_2023/reads/genomics_chr3_data/chr3_illumina_R1.fastq.gz"
READS_R2="/proj/uppmax2026-1-61/Genome_Analysis/2_Zhou_2023/reads/genomics_chr3_data/chr3_illumina_R2.fastq.gz"

OUTDIR="merqury_output"
OUTPUT_PREFIX="merqury_out"
K=21

rm -rf "$OUTDIR"
mkdir -p "$OUTDIR"
cd "$OUTDIR"

echo "[$(date)] Step 1: building meryl db from Illumina reads (k=$K)"
meryl k=$K count threads=2 memory=8 output R1.meryl "$READS_R1"
meryl k=$K count threads=2 memory=8 output R2.meryl "$READS_R2"
meryl union-sum output reads.meryl R1.meryl R2.meryl
rm -rf R1.meryl R2.meryl

echo "[$(date)] Step 2: running Merqury"
merqury.sh reads.meryl "$ASSEMBLY" "$OUTPUT_PREFIX"

echo "[$(date)] Done."
[[ -f "${OUTPUT_PREFIX}.qv" ]] && echo "▸ QV:" && column -t "${OUTPUT_PREFIX}.qv"
[[ -f "${OUTPUT_PREFIX}.completeness.stats" ]] && echo "▸ Completeness:" && column -t "${OUTPUT_PREFIX}.completeness.stats"
