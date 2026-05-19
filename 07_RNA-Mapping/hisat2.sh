#!/bin/bash

source /home/bio/miniconda3/etc/profile.d/conda.sh
conda activate repeatmodeler_exact

# === PARAMETERS ===
MASKED_ASSEMBLY="/home/bio/2-repeatMasker/repeatmasker_output/polished_assembly.fasta.masked"
RNA_DIR="/proj/uppmax2026-1-61/Genome_Analysis/2_Zhou_2023/reads/transcriptomic_data/"
INDEX_DIR="/home/bio/hisat2/index"
BAM_DIR="/home/bio/hisat2/bam"
THREADS=8 # local number of threads

# === SETUP ===
mkdir -p ${INDEX_DIR} ${BAM_DIR}

# === STEP 1: Build genome index ===
echo "1. Building HISAT2 index"
hisat2-build \
    -p ${THREADS} \
    ${MASKED_ASSEMBLY} \
    ${INDEX_DIR}/niphotrichum_masked

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

    echo "2. Aligning ${NAME}"
    hisat2 \
        -p ${THREADS} \
        --dta \
        -x ${INDEX_DIR}/niphotrichum_masked \
        -1 ${RNA_DIR}/${R1} \
        -2 ${RNA_DIR}/${R2} \
        -S ${BAM_DIR}/${NAME}.sam \
        2> ${BAM_DIR}/${NAME}_hisat2.log

    echo "3. Converting, sorting, indexing ${NAME}"
    samtools view -bS ${BAM_DIR}/${NAME}.sam | \
        samtools sort -o ${BAM_DIR}/${NAME}.sorted.bam
    samtools index ${BAM_DIR}/${NAME}.sorted.bam

    # Removing SAM to save space
    rm ${BAM_DIR}/${NAME}.sam

    echo "*** ${NAME} done!"
done

echo "[$(date)] ALL DONE - BAM files in ${BAM_DIR}/"
