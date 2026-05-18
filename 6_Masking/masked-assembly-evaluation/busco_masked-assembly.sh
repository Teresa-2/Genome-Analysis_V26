#!/bin/bash

source /home/bio/miniconda3/etc/profile.d/conda.sh
conda activate busco_env

# === PARAMETERS ===
ASSEMBLY="/home/bio/2-repeatMasker/repeatmasker_output/polished_assembly.fasta.masked"
LINEAGE="/home/bio/2-repeatMasker/busco_downloads/lineages/embryophyta_odb12"
OUTDIR="/home/bio/2-repeatMasker/busco_polished-assembly"
THREADS=8

# === STEP 1: BUSCO on polished assembly ===
echo "[$(date)] Running BUSCO on polished assembly..."
busco \
    -i ${ASSEMBLY} \
    -l ${LINEAGE} \
    -o masked_busco \
    --out_path ${OUTDIR} \
    -m genome \
    -c ${THREADS} \

echo "[$(date)] END"
