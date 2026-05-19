#!/bin/bash -l
#SBATCH -A uppmax2026-1-61
#SBATCH -n 2
#SBATCH --mem=24G
#SBATCH -t 12:00:00
#SBATCH -J pilon_chr3

# ── MODULES ───────────────────────────────────────────────────────────────
module load bwa-mem2/2.3-GCC-13.3.0
module load SAMtools/1.22.1-GCC-13.3.0
module load Pilon/1.24-Java-17

# ── PATHS ────────────────────────────────────────────────────────────────
ASSEMBLY="assembly.fasta"
R1="/proj/uppmax2026-1-61/Genome_Analysis/2_Zhou_2023/reads/genomics_chr3_data/chr3_illumina_R1.fastq.gz"
R2="/proj/uppmax2026-1-61/Genome_Analysis/2_Zhou_2023/reads/genomics_chr3_data/chr3_illumina_R2.fastq.gz"

THREADS=2
MEM="24G"
OUTDIR="/proj/uppmax2026-1-61/nobackup/work/tede0387/Genome-Analysis_V26/5_Polishing/pilon_output"

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
