#!/bin/bash

source /home/bio/miniconda3/etc/profile.d/conda.sh
conda activate repeatmodeler_exact

# === PARAMETERS ===
ASSEMBLY="/home/bio/2-repeatMasker/polished_assembly.fasta"
LIBRARY="/home/bio/2-repeatMasker/library_LTR/Niphotrichum_japonicum-families.fa"
OUTDIR="/home/bio/2-repeatMasker/repeatmasker_output"
THREADS=8

# === SETUP ===
mkdir -p $OUTDIR

# === RepeatMasker execution ===
echo "[$(date)] Running RepeatMasker with custom library..."
RepeatMasker \
    -lib ${LIBRARY} \
    -xsmall \
    -nolow \
    -pa ${THREADS} \
    -dir ${OUTDIR} \
    ${ASSEMBLY}

echo "[$(date)] END - Output in ${OUTDIR}/"
