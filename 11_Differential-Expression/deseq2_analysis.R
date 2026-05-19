#!/usr/bin/env Rscript
# ============================================================================
# DESeq2 Differential Expression Analysis
# Niphotrichum japonicum chr3 - Heat treatment vs Control
# ============================================================================

# Setup logging
output_dir <- "/proj/uppmax2026-1-61/nobackup/work/tede0387/11_Differential-Expression"
dir.create(output_dir, showWarnings=FALSE)
dir.create(file.path(output_dir, "logs"), showWarnings=FALSE)

log_file <- file.path(output_dir, "logs", "deseq2_analysis.log")
cat(paste("[", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "] DESeq2 Analysis Started\n"), 
    file=log_file, append=TRUE)

# Redirect output and warnings
sink(log_file, append=TRUE)

# Load libraries
cat("Loading libraries...\n")
library(DESeq2)
library(ggplot2)
library(pheatmap)
library(BiocParallel)

# Setup parallel processing (2 threads)
register(MulticoreParam(workers=2))

cat("Libraries loaded successfully\n")

# ============================================================================
# 1. LOAD FEATURECOUNTS DATA
# ============================================================================

# Read the counts file (skip first row which is comment)
counts_file <- "/proj/uppmax2026-1-61/nobackup/work/tede0387/10_Gene-Quantification/counts.txt"
counts <- read.table(counts_file, header=TRUE, row.names=1, skip=1)

# Remove unnecessary columns (chr, start, end, strand, length)
counts <- counts[, -c(1:5)]

# Rename columns to sample names
colnames(counts) <- c("Control_1", "Control_2", "Control_3", "Heat_1", "Heat_2", "Heat_3")

print("Counts matrix head:")
print(head(counts))
print(paste("Total genes:", nrow(counts)))

# ============================================================================
# 2. CREATE SAMPLE METADATA
# ============================================================================

# Create metadata dataframe
sample_metadata <- data.frame(
  sample = c("Control_1", "Control_2", "Control_3", "Heat_1", "Heat_2", "Heat_3"),
  condition = c("Control", "Control", "Control", "Heat", "Heat", "Heat"),
  row.names = c("Control_1", "Control_2", "Control_3", "Heat_1", "Heat_2", "Heat_3")
)

print("Sample metadata:")
print(sample_metadata)

# ============================================================================
# 3. CREATE DESEQ2 OBJECT
# ============================================================================

# Create DESeqDataSet
dds <- DESeqDataSetFromMatrix(
  countData = counts,
  colData = sample_metadata,
  design = ~ condition
)

# Remove genes with very low counts (pre-filtering)
# Keep genes with at least 10 counts in at least 3 samples
keep <- rowSums(counts(dds)) >= 10
dds <- dds[keep,]

print(paste("Genes after filtering:", nrow(dds)))

# ============================================================================
# 4. RUN DESEQ2 ANALYSIS
# ============================================================================

# Run DESeq2 pipeline
dds <- DESeq(dds)

# Get results
res <- results(dds)

# Filter out rows with NA padj (outliers) BEFORE any subsetting
# This prevents errors with logical subscripting
res <- res[!is.na(res$padj), ] 

# Order by p-value
res <- res[order(res$pvalue),]

print("DESeq2 results summary:")
print(summary(res))

# ============================================================================
# 5. EXPORT RESULTS
# ============================================================================

# Create output directory
output_dir <- "/proj/uppmax2026-1-61/nobackup/work/tede0387/11_Differential-Expression"
dir.create(output_dir, showWarnings=FALSE)

# Save all results
results_file <- file.path(output_dir, "deseq2_results_all.csv")
write.csv(as.data.frame(res), results_file)
print(paste("Results saved to:", results_file))

# Save significant genes (padj < 0.05)
# NA values already filtered above, so this is safe
sig_res <- res[res$padj < 0.05, ]
sig_file <- file.path(output_dir, "deseq2_results_significant.csv")
write.csv(as.data.frame(sig_res), sig_file)
print(paste("Significant genes (padj<0.05):", nrow(sig_res)))
print(paste("Saved to:", sig_file))

# ============================================================================
# 6. VISUALIZATIONS
# ============================================================================

# MA plot
pdf(file.path(output_dir, "MA_plot.pdf"), width=8, height=6)
plotMA(res, ylim=c(-5, 5))
dev.off()
print("MA plot saved")

# Volcano plot
# NA values already filtered, so we can safely plot
pdf(file.path(output_dir, "volcano_plot.pdf"), width=8, height=6)
plot(res$log2FoldChange, -log10(res$padj),
     main="Volcano Plot",
     xlab="log2(FoldChange)",
     ylab="-log10(adjusted p-value)",
     pch=20, cex=0.5)
abline(v=c(-1, 1), col="red", lty=2)
abline(h=-log10(0.05), col="red", lty=2)
dev.off()
print("Volcano plot saved")

# PCA plot
vst <- vst(dds, blind=FALSE)
pdf(file.path(output_dir, "PCA_plot.pdf"), width=8, height=6)
plotPCA(vst, intgroup="condition")
dev.off()
print("PCA plot saved")

# Heatmap of top 30 significant genes
if(nrow(sig_res) > 0) {
  top_genes <- head(rownames(sig_res), min(30, nrow(sig_res)))
  mat <- assay(vst)[top_genes,]
  
  pdf(file.path(output_dir, "heatmap_top30.pdf"), width=8, height=10)
  pheatmap(mat, annotation_col = as.data.frame(colData(vst)[,"condition", drop=FALSE]))
  dev.off()
  print("Heatmap saved")
} else {
  print("No significant genes found for heatmap")
}

# ============================================================================
# 7. SUMMARY
# ============================================================================

separator <- paste(rep("=", 60), collapse="")
print(separator)
print("DESeq2 ANALYSIS COMPLETE")
print(separator)
print(paste("Total genes analyzed:", nrow(dds)))
print(paste("Significant genes (padj<0.05):", nrow(sig_res)))
print(paste("Upregulated (Heat vs Control):", sum(sig_res$log2FoldChange > 0, na.rm=TRUE)))
print(paste("Downregulated (Heat vs Control):", sum(sig_res$log2FoldChange < 0, na.rm=TRUE)))
print(paste("\nOutput directory:", output_dir))
print(separator)
print(paste("Analysis finished at:", format(Sys.time(), "%Y-%m-%d %H:%M:%S")))

# Close logging
sink()


