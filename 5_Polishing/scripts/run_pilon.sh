#!/bin/bash

# ── PATHS ────────────────────────────────────────────────────────────────
ASSEMBLY="assembly.fasta"
R1="chr3_illumina_R1.fastq.gz"
R2="chr3_illumina_R2.fastq.gz"

THREADS=8   # locally executed
MEM="12g"          # locally executed
OUTDIR="pilon_output"

mkdir -p "$OUTDIR"

# ── 1. Assembly indexing ────────────────────────────────────────────────────
echo "[$(date)] 1. Assembly indexing"
bwa index "$ASSEMBLY"

# ── 2. Illumina reads alignment ─────────────────────────────────────────────
echo "[$(date)] 2. Illumina reads alignment"
bwa mem -t "$THREADS" "$ASSEMBLY" "$R1" "$R2" \
    | samtools sort -@ "$THREADS" -o illumina_sorted.bam

# ── 3. BAM indexing ─────────────────────────────────────────────────────────
echo "[$(date)] 3. BAM indexing"
samtools index illumina_sorted.bam

# ── 4. Pilon polishing ───────────────────────────────────────────────────────
echo "[$(date)] 4. Pilon has started"
java -Xmx"$MEM" -jar /home/bio/miniconda3/envs/pilon_env/share/pilon-1.24-0/pilon.jar \
    --genome "$ASSEMBLY" \
    --frags illumina_sorted.bam \
    --output polished_assembly \
    --outdir "$OUTDIR" \
    --changes \
    --vcf \
    --threads "$THREADS"

echo "[$(date)] 5. Pilon finished. Output in: $OUTDIR"
