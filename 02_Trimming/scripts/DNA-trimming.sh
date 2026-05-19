#!/bin/bash -l
#SBATCH -A uppmax2026-1-61
#SBATCH -n 2
#SBATCH --mem=16G
#SBATCH -t 02:00:00
#SBATCH -J trim_chr3
#SBATCH -o /proj/uppmax2026-1-61/nobackup/work/tede0387/Genome-Analysis_V26/2_Trimming/logs/trim_chr3_%j.out
#SBATCH -e /proj/uppmax2026-1-61/nobackup/work/tede0387/Genome-Analysis_V26/2_Trimming/logs/trim_chr3_%j.err

# === MODULES ===
module load Trimmomatic/0.39-Java-17

# === PATHS ===
READS_DIR="/proj/uppmax2026-1-61/Genome_Analysis/2_Zhou_2023/reads/genomics_chr3_data"
OUT_DIR="/proj/uppmax2026-1-61/nobackup/work/tede0387/Genome-Analysis_V26/2_Trimming/DNA-trimmed-reads"

R1="$READS_DIR/chr3_illumina_R1.fastq.gz"
R2="$READS_DIR/chr3_illumina_R2.fastq.gz"

OUT_R1_P="$OUT_DIR/chr3_R1_paired.fq.gz"
OUT_R1_UP="$OUT_DIR/chr3_R1_unpaired.fq.gz"
OUT_R2_P="$OUT_DIR/chr3_R2_paired.fq.gz"
OUT_R2_UP="$OUT_DIR/chr3_R2_unpaired.fq.gz"

ADAPTERS="$EBROOTTRIMMOMATIC/adapters/TruSeq3-PE.fa"

# === RUN TRIMMOMATIC ===
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
