#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH --job-name=braker3
#SBATCH --output=braker3_%j.log
#SBATCH --error=braker3_%j.err
#SBATCH --ntasks=2
#SBATCH --mem=64G
#SBATCH --time=24:00:00

# === PARAMETERS ===
SIF="/proj/uppmax2026-1-61/Genome_Analysis/2_Zhou_2023/braker3.sif"
GENOME="/proj/uppmax2026-1-61/nobackup/work/tede0387/new_repeatMasker/repeatmasker_output/polished_assembly.fasta.masked"
BAM_DIR="/proj/uppmax2026-1-61/nobackup/work/tede0387/hisat2/bam"
PROTEINS="/proj/uppmax2026-1-61/Genome_Analysis/2_Zhou_2023/Ceratodon_purpureus/C_purpureus.faa"
OUTDIR="/proj/uppmax2026-1-61/nobackup/work/tede0387/braker3/braker3_output"
THREADS=2

# === SETUP ===
mkdir -p ${OUTDIR}

# === Modules ===
module load AUGUSTUS/3.5.0-gfbf-2024a

# === Writable copy of AUGUSTUS config ===
cp -dR --preserve=mode,timestamps --no-preserve=ownership \
    $AUGUSTUS_CONFIG_PATH ${OUTDIR}/AUGUSTUS_config
chmod -R +w ${OUTDIR}/AUGUSTUS_config
export AUGUSTUS_CONFIG_PATH=${OUTDIR}/AUGUSTUS_config

# === GeneMark key copy ===
cp -vf /sw/bioinfo/GeneMark/4.33-es/snowy/gm_key $HOME/.gm_key

# === Access to species directory ===
chmod a+w -R ${AUGUSTUS_CONFIG}/species/

# === BRAKER3 via Singularity ===
echo "[$(date)] *** Running BRAKER3"
singularity exec \
    --bind /proj/uppmax2026-1-61 \
    --env AUGUSTUS_CONFIG_PATH=${AUGUSTUS_CONFIG_PATH} \
    ${SIF} \
    braker.pl \
        --genome=${GENOME} \
        --bam=${BAM_DIR}/Control_1.sorted.bam,${BAM_DIR}/Control_2.sorted.bam,${BAM_DIR}/Control_3.sorted.bam,${BAM_DIR}/Heat_1.sorted.bam,${BAM_DIR}/Heat_2.sorted.bam,${BAM_DIR}/Heat_3.sorted.bam \
        --prot_seq=${PROTEINS} \
        --threads=${THREADS} \
        --workingdir=${OUTDIR} \
        --species=niphotrichum_japonicum \
        --useexisting \
        --softmasking \
        --AUGUSTUS_CONFIG_PATH=${AUGUSTUS_CONFIG_PATH} \
        --AUGUSTUS_BIN_PATH=/opt/Augustus/bin \
        --AUGUSTUS_SCRIPTS_PATH=/opt/Augustus/scripts \
        --GENEMARK_PATH=/opt/ETP/bin \

echo "[$(date)] *** END - Output in ${OUTDIR}/"
