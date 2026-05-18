#!/bin/bash
#SBATCH --job-name=repeatmasker
#SBATCH --A=uppmax2026-1-61
#SBATCH --output=logs/repeatmasker_%j.log
#SBATCH --error=logs/repeatmasker_%j.err
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=2
#SBATCH --time=24:00:00

# === MODULES ===
module load RepeatMasker/4.2.1-foss-2024a

# === PARAMETERS ===
ASSEMBLY="/proj/uppmax2026-1-61/nobackup/work/tede0387/polished_assembly.fasta"
LIBRARY="/proj/uppmax2026-1-61/nobackup/work/tede0387/6_Masking/repeatmodeler_output/Niphotrichum_japonicum-families.fa"
OUTDIR="/proj/uppmax2026-1-61/nobackup/work/tede0387/6_Masking/repeatmasker_output"
THREADS=2

# === SETUP ===
mkdir -p ${OUTDIR} logs

# === RepeatMasker ===
echo "[$(date)] Running RepeatMasker with custom library..."
RepeatMasker \
    -lib ${LIBRARY} \
    -xsmall \
    -nolow \
    -pa ${THREADS} \
    -dir ${OUTDIR} \
    ${ASSEMBLY}

if [ $? -ne 0 ]; then
    echo "[$(date)] ERROR: RepeatMasker failed. Exiting."
    exit 1
fi

echo "[$(date)] END - Output in ${OUTDIR}/"
