#!/bin/bash
#SBATCH --job-name=hisat2_alignment
#SBATCH --A=uppmax2026-1-61
#SBATCH --output=logs/hisat2_%j.log
#SBATCH --error=logs/hisat2_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --time=24:00:00

# === MODULES ===
module load HISAT2/2.2.1-gompi-2024a
module load SAMtools/1.22.1-GCC-13.3.0

# === PARAMETERS ===
MASKED_ASSEMBLY="/proj/uppmax2026-1-61/nobackup/work/tede0387/6_Masking/repeatmasker_output/polished_assembly.fasta.masked"
RNA_DIR="/proj/uppmax2026-1-61/Genome_Analysis/2_Zhou_2023/reads/transcriptomic_data/"
INDEX_DIR="/proj/uppmax2026-1-61/nobackup/work/tede0387/7_RNA-Mapping/hisat2/index"
BAM_DIR="/proj/uppmax2026-1-61/nobackup/work/tede0387/7_RNA-Mapping/hisat2/bam"
THREADS=2

# === SETUP ===
mkdir -p ${INDEX_DIR} ${BAM_DIR} logs

# === STEP 1: Build genome index ===
echo "[$(date)] 1. Building HISAT2 index..."
hisat2-build \
    -p ${THREADS} \
    ${MASKED_ASSEMBLY} \
    ${INDEX_DIR}/niphotrichum_masked

if [ $? -ne 0 ]; then
    echo "[$(date)] ERROR: hisat2-build failed. Exiting."
    exit 1
fi

# === STEP 2 & 3: Align each sample, convert, sort, index ===
SAMPLES=(
    "Control_1:Control_1_f1.fq.gz:Control_1_r2.fq.gz"
    "Control_2:Control_2_f1.fq.gz:Control_2_r2.fq.gz"
    "Control_3:Control_3_f1.fq.gz:Control_3_r2.fq.gz"
    "Heat_1:Heat_treated_42_12h_1_f1.fq.gz:Heat_treated_42_12h_1_r2.fq.gz"
    "Heat_2:Heat_treated_42_12h_2_f1.fq.gz:Heat_treated_42_12h_2_r2.fq.gz"
    "Heat_3:Heat_treated_42_12h_3_f1.fq.gz:Heat_treated_42_12h_3_r2.fq.gz"
)

for SAMPLE in "${SAMPLES[@]}"; do
    NAME=$(echo $SAMPLE | cut -d: -f1)
    R1=$(echo $SAMPLE | cut -d: -f2)
    R2=$(echo $SAMPLE | cut -d: -f3)

    echo "[$(date)] 2. Aligning ${NAME}..."
    hisat2 \
        -p ${THREADS} \
        --dta \
        -x ${INDEX_DIR}/niphotrichum_masked \
        -1 ${RNA_DIR}/${R1} \
        -2 ${RNA_DIR}/${R2} \
        -S ${BAM_DIR}/${NAME}.sam \
        2> logs/${NAME}_hisat2.log

    if [ $? -ne 0 ]; then
        echo "[$(date)] ERROR: hisat2 failed for ${NAME}. Skipping."
        continue
    fi

    echo "[$(date)] 3. Converting, sorting, indexing ${NAME}..."
    samtools view -bS ${BAM_DIR}/${NAME}.sam | \
        samtools sort -@ ${THREADS} -o ${BAM_DIR}/${NAME}.sorted.bam

    if [ $? -ne 0 ]; then
        echo "[$(date)] ERROR: samtools failed for ${NAME}. Skipping."
        continue
    fi

    samtools index ${BAM_DIR}/${NAME}.sorted.bam
    rm ${BAM_DIR}/${NAME}.sam

    echo "[$(date)] *** ${NAME} done"
done

echo "[$(date)] ALL DONE - BAM files in ${BAM_DIR}/"
