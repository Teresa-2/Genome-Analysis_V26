#!/bin/bash -l
#SBATCH -A uppmax2026-1-61
#SBATCH -n 2
#SBATCH --mem=16G
#SBATCH -t 04:00:00
#SBATCH -J trim_rnaseq
#SBATCH -o /proj/uppmax2026-1-61/nobackup/work/tede0387/Genome-Analysis_V26/2_Trimming/RNA-trimmed-reads/logs/trim_rnaseq_%j.out
#SBATCH -e /proj/uppmax2026-1-61/nobackup/work/tede0387/Genome-Analysis_V26/2_Trimming/RNA-trimmed-reads/logs/trim_rnaseq_%j.err

# === MODULES ===
module load Trimmomatic/0.39-Java-17

# === PATHS ===
READS_DIR="/proj/uppmax2026-1-61/Genome_Analysis/2_Zhou_2023/reads/transcriptomic_data"
OUT_DIR="/proj/uppmax2026-1-61/nobackup/work/tede0387/Genome-Analysis_V26/2_Trimming/RNA-trimmed-reads"
ADAPTERS="$EBROOTTRIMMOMATIC/adapters/TruSeq3-PE.fa"

mkdir -p $OUT_DIR

# === SAMPLES ===
SAMPLES=(
    "Control_1"
    "Control_2"
    "Control_3"
    "Heat_treated_42_12h_1"
    "Heat_treated_42_12h_2"
    "Heat_treated_42_12h_3"
)

# === RUN TRIMMOMATIC FOR EACH SAMPLE ===
for SAMPLE in "${SAMPLES[@]}"; do
    echo "Processing $SAMPLE..."

    R1="$READS_DIR/${SAMPLE}_f1.fq.gz"
    R2="$READS_DIR/${SAMPLE}_r2.fq.gz"

    OUT_R1_P="$OUT_DIR/${SAMPLE}_R1_paired.fq.gz"
    OUT_R1_UP="$OUT_DIR/${SAMPLE}_R1_unpaired.fq.gz"
    OUT_R2_P="$OUT_DIR/${SAMPLE}_R2_paired.fq.gz"
    OUT_R2_UP="$OUT_DIR/${SAMPLE}_R2_unpaired.fq.gz"

    trimmomatic PE \
        -threads 4 \
        $R1 $R2 \
        $OUT_R1_P $OUT_R1_UP \
        $OUT_R2_P $OUT_R2_UP \
        ILLUMINACLIP:$ADAPTERS:2:30:10 \
        LEADING:3 \
        TRAILING:3 \
        SLIDINGWINDOW:4:15 \
        MINLEN:36

    echo "Done: $SAMPLE"
done

echo "All samples have been processed"
