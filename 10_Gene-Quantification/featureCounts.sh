#!/bin/bash
#SBATCH -A uppmax2026-1-61
#SBATCH -n 2
#SBATCH -t 12:00:00
#SBATCH -J featureCounts
#SBATCH -o /proj/uppmax2026-1-61/nobackup/work/tede0387/10_Gene-Quantification/logs/featureCounts_%j.log
#SBATCH -e /proj/uppmax2026-1-61/nobackup/work/tede0387/10_Gene-Quantification/logs/featureCounts_%j.err

module load Subread/2.1.1-GCC-13.3.0

SRC_DIR=/proj/uppmax2026-1-61/nobackup/work/tede0387
BAM_DIR=$SRC_DIR/7_RNA-Mapping/updated_hisat2/bam
GTF=$SRC_DIR/8_Structural-Annotation/new_braker/braker3_last-exec/braker.gtf
OUT=$SRC_DIR/10_Gene-Quantification/counts.txt

featureCounts \
  -T 2 \
  -p \
  --countReadPairs \
  -s 0 \
  -t exon \
  -g gene_id \
  -a $GTF \
  -o $OUT \
  $BAM_DIR/Control_1.sorted.bam \
  $BAM_DIR/Control_2.sorted.bam \
  $BAM_DIR/Control_3.sorted.bam \
  $BAM_DIR/Heat_1.sorted.bam \
  $BAM_DIR/Heat_2.sorted.bam \
  $BAM_DIR/Heat_3.sorted.bam
