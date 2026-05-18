#!/bin/bash
#SBATCH --job-name=repeatmodeler
#SBATCH --account=uppmax2026-1-61
#SBATCH --output=logs/repeatmodeler_%j.log
#SBATCH --error=logs/repeatmodeler_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --time=48:00:00

# === MODULES ===
module load RepeatModeler/2.0.7-foss-2024a

# === PARAMETERS ===
ASSEMBLY="/proj/uppmax2026-1-61/nobackup/work/tede0387/polished_assembly.fasta"
SPECIES_NAME="Niphotrichum_japonicum"
OUTDIR="/proj/uppmax2026-1-61/nobackup/work/tede0387/6_Masking/repeatmodeler_output"
THREADS=2

# === SETUP ===
mkdir -p ${OUTDIR} logs
cd ${OUTDIR}

# === STEP 1: Build database ===
echo "[$(date)] 1. Building database"
BuildDatabase \
    -name ${SPECIES_NAME} \
    ${ASSEMBLY}

if [ $? -ne 0 ]; then
    echo "[$(date)] ERROR: BuildDatabase failed. Exiting."
    exit 1
fi

# === STEP 2: RepeatModeler ===
echo "[$(date)] 2. Running RepeatModeler with LTRStruct"
RepeatModeler \
    -database ${SPECIES_NAME} \
    -threads ${THREADS} \
    -LTRStruct \
    2>&1 | tee repeatmodeler_run.log

echo "[$(date)] END"
