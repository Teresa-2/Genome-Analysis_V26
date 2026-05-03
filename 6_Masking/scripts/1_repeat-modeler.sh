#!/bin/bash

source /home/bio/miniconda3/etc/profile.d/conda.sh
conda activate 2_repeatmodeler

ASSEMBLY="/home/bio/2-repeatMasker/polished_assembly.fasta"
SPECIES_NAME="Niphotrichum_japonicum"
OUTDIR="/home/bio/2-repeatMasker/library_LTR"
THREADS=8  # max core amount (local execution)

mkdir -p $OUTDIR
cd $OUTDIR

echo "[$(date)] 1. Building database"
BuildDatabase \
    -name ${SPECIES_NAME} \
    ${ASSEMBLY}

echo "[$(date)] 2. Running RepeatModeler with LTRStruct"
RepeatModeler \
    -database ${SPECIES_NAME} \
    -threads ${THREADS} \
    -LTRStruct \
    2>&1 | tee repeatmodeler_run.log

echo "[$(date)] END"
