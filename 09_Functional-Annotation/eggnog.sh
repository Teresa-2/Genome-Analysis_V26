#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH --job-name=eggnog
#SBATCH --output=eggnog_%j.log
#SBATCH --error=eggnog_%j.err
#SBATCH --ntasks=2
#SBATCH --mem=128G
#SBATCH --time=48:00:00

module load eggnog-mapper/2.1.13-gfbf-2024a

# === PARAMETERS ===
PROTEINS="/proj/uppmax2026-1-61/nobackup/work/tede0387/braker3/braker3_output/braker.aa"
OUTDIR="/proj/uppmax2026-1-61/nobackup/work/tede0387/eggnog/eggnog_output"
DB_DIR="/sw/data/uppnex/eggNOG/5.0/rackham"
THREADS=2

# === SETUP ===
mkdir -p ${OUTDIR}

# === EggNOG mapper ===
echo "[$(date)] Running EggNOG mapper ***"

# -i: input proteins from BRAKER3
# -m hmmer: use HMM over Diamond (see student manual)
# --data_dir: path to cluster EggNOG db
# --go_evidence all: includes all GO terms, not only experimental ones (suggested for poorly characterized organisms such as N. japonicum)
# --pfam: also annotates Pfam domains (useful for interpretation)
# --override: overwrites existing output if present
# --dbmem: uploading the whole DB in the memory when fetching, to avoid several access to the memory disk
# --pfam_realign de novo failed (error: Could not create server number 1/1)
# originally --override, after pfam_realign failure --resume

emapper.py \
    -i ${PROTEINS} \
    --itype proteins \
    -m hmmer \
    -d Viridiplantae \
    --data_dir ${DB_DIR} \
    --output niphotrichum_eggnog \
    --output_dir ${OUTDIR} \
    --cpu ${THREADS} \
    --go_evidence all \
    --pfam_realign realign \
    --dbmem \
    --resume

echo "[$(date)] END - Output in ${OUTDIR}/"
