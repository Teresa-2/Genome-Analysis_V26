#!/usr/bin/env Rscript
# ============================================================================
# GO Enrichment Analysis using rrvgo - LOCAL EXECUTION
# Niphotrichum japonicum DEGs from heat treatment study
# ============================================================================

# ============================================================================
# CONFIGURATION - MODIFY THESE PATHS FOR YOUR LOCAL SETUP
# ============================================================================

# Input files
degs_file <- "/home/teresa/UU/Genome-Analysis/11_Differential-Expression/deseq2_results_significant.csv"
eggnog_file <- "/home/teresa/UU/Genome-Analysis/9_Functional-Annotation/niphotrichum_eggnog.emapper.annotations"

# Output directory
output_dir <- "/home/teresa/UU/Genome-Analysis/12_GO-Enrichment"

# ============================================================================
# SETUP
# ============================================================================

dir.create(output_dir, showWarnings=FALSE)
dir.create(file.path(output_dir, "logs"), showWarnings=FALSE)

log_file <- file.path(output_dir, "logs", "go_enrichment.log")
cat(paste("[", format(Sys.time(), "%Y-%m-%d %H:%M:%S"), "] GO Enrichment Analysis Started\n"),
    file=log_file, append=TRUE)

# Redirect output
sink(log_file, append=TRUE)

# ============================================================================
# INSTALL REQUIRED PACKAGES (if needed)
# ============================================================================

cat("Checking and installing required packages...\n")

if (!require("BiocManager", quietly=TRUE)) {
  cat("Installing BiocManager...\n")
  install.packages("BiocManager", repos="https://cloud.r-project.org")
}

if (!require("topGO", quietly=TRUE)) {
  cat("Installing topGO...\n")
  BiocManager::install("topGO", ask=FALSE)
}

if (!require("rrvgo", quietly=TRUE)) {
  cat("Installing rrvgo...\n")
  BiocManager::install("rrvgo", ask=FALSE)
}

if (!require("igraph", quietly=TRUE)) {
  cat("Installing igraph...\n")
  install.packages("igraph", repos="https://cloud.r-project.org")
}

if (!require("org.At.tair.db", quietly=TRUE)) {
  cat("Installing org.At.tair.db...\n")
  BiocManager::install("org.At.tair.db", ask=FALSE)
}

cat("Loading libraries...\n")
library(topGO)
library(rrvgo)
library(igraph)

cat("Libraries loaded successfully\n")

# ============================================================================
# 1. READ INPUT DATA
# ============================================================================

cat("\n=== READING DATA ===\n")

if (!file.exists(degs_file)) {
  cat("ERROR: DEGs file not found at:\n")
  cat(paste("  ", degs_file, "\n"))
  sink()
  stop("DEGs file not found")
}

if (!file.exists(eggnog_file)) {
  cat("ERROR: eggNOG annotations file not found at:\n")
  cat(paste("  ", eggnog_file, "\n"))
  sink()
  stop("eggNOG file not found")
}

# Read DEGs
degs <- read.csv(degs_file, row.names=1)
cat(paste("DEGs loaded: ", nrow(degs), " significant genes\n", sep=""))

# Read eggNOG annotations
eggnog <- read.table(eggnog_file, sep="\t", header=TRUE, skip=4,
                     comment.char="", quote="", fill=TRUE)
colnames(eggnog)[1] <- "query"
cat(paste("eggNOG annotations loaded: ", nrow(eggnog), " genes\n", sep=""))

# ============================================================================
# 2. CREATE GENE-TO-GO MAPPING
# ============================================================================

cat("\n=== BUILDING GENE-TO-GO MAPPING ===\n")

go_data <- eggnog[, c("query", "GOs")]
colnames(go_data) <- c("gene", "GO")

# Remove rows with missing GO
go_data <- go_data[go_data$GO != "-" & go_data$GO != "", ]

cat(paste("Genes with GO annotations: ", nrow(go_data), "\n", sep=""))

# Split GO terms (comma-separated), remove .t1/.t2 isoform suffixes
gene_to_go <- list()
for (i in 1:nrow(go_data)) {
  gene <- sub("\\.t\\d+$", "", go_data$gene[i])
  go_terms <- unlist(strsplit(as.character(go_data$GO[i]), ","))
  go_terms <- go_terms[!is.na(go_terms) & go_terms != "NA" & go_terms != "-" & go_terms != ""]
  if (length(go_terms) > 0) {
    if (gene %in% names(gene_to_go)) {
      gene_to_go[[gene]] <- unique(c(gene_to_go[[gene]], go_terms))
    } else {
      gene_to_go[[gene]] <- go_terms
    }
  }
}

cat(paste("Gene-to-GO mapping created for ", length(gene_to_go), " genes\n", sep=""))

# ============================================================================
# 3. CREATE topGO OBJECT
# ============================================================================

cat("\n=== CREATING topGO OBJECT ===\n")

all_go_terms <- unique(unlist(gene_to_go))
cat(paste("Total unique GO terms: ", length(all_go_terms), "\n", sep=""))

deg_names <- rownames(degs)
gene_factor <- factor(as.integer(names(gene_to_go) %in% deg_names), levels=c(0,1))
names(gene_factor) <- names(gene_to_go)

cat(paste("DEGs in annotation set: ", sum(gene_factor == 1), "\n", sep=""))

go_object <- new("topGOdata",
                description = "N. japonicum heat-responsive genes",
                ontology = "BP",
                allGenes = gene_factor,
                annot = annFUN.gene2GO,
                gene2GO = gene_to_go,
                nodeSize = 5)

cat("topGO object created successfully\n")

# ============================================================================
# 4. RUN GO ENRICHMENT ANALYSIS (Fisher's exact test)
# ============================================================================

cat("\n=== RUNNING GO ENRICHMENT (Fisher's exact test) ===\n")

result_fisher <- runTest(go_object, algorithm = "classic", statistic = "fisher")

go_table <- GenTable(go_object,
                    Fisher = result_fisher,
                    orderBy = "Fisher",
                    ranksOf = "Fisher",
                    topNodes = length(usedGO(go_object)))

# Convert p-values to numeric
go_table$Fisher <- as.numeric(go_table$Fisher)

# Calculate adjusted p-value (kept for reference)
go_table$padj <- p.adjust(go_table$Fisher, method="BH")

# Filter significant GO terms using raw Fisher p < 0.05
# Note: topGO already accounts for GO hierarchy, so raw p-value is standard practice
go_sig <- go_table[!is.na(go_table$Fisher) & go_table$Fisher < 0.05, ]

cat(paste("Significant GO terms (Fisher p < 0.05): ", nrow(go_sig), "\n", sep=""))

# ============================================================================
# 5. EXPORT RESULTS
# ============================================================================

cat("\n=== EXPORTING RESULTS ===\n")

go_all_file <- file.path(output_dir, "go_enrichment_all.csv")
write.csv(go_table, go_all_file, row.names=FALSE)
cat(paste("All GO results saved to: ", go_all_file, "\n", sep=""))

if (nrow(go_sig) > 0) {
  go_sig_file <- file.path(output_dir, "go_enrichment_significant.csv")
  write.csv(go_sig, go_sig_file, row.names=FALSE)
  cat(paste("Significant GO results saved to: ", go_sig_file, "\n", sep=""))
} else {
  cat("WARNING: No significant GO terms found at Fisher p < 0.05\n")
}

# ============================================================================
# 6. VISUALIZATIONS WITH rrvgo
# ============================================================================

cat("\n=== CREATING VISUALIZATIONS ===\n")

if (nrow(go_sig) > 0) {
  scores <- setNames(-log10(go_sig$Fisher), go_sig$GO.ID)

  cat("Calculating semantic similarity matrix...\n")
  sim_matrix <- calculateSimMatrix(go_sig$GO.ID,
                                   orgdb="org.At.tair.db",
                                   ont="BP",
                                   method="Rel")

  reduced_terms <- reduceSimMatrix(sim_matrix,
                                     scores=scores,
                                     threshold=0.5,
                                     orgdb="org.At.tair.db")

  pdf(file.path(output_dir, "go_treemap.pdf"), width=12, height=10)
  treemapPlot(reduced_terms)
  dev.off()
  cat("Treemap visualization saved\n")

  cat(paste("Reduced terms clusters: ", nrow(reduced_terms), "\n", sep=""))
cat(paste("Unique clusters: ", length(unique(reduced_terms$cluster)), "\n", sep=""))

if (nrow(reduced_terms) > 1) {
  pdf(file.path(output_dir, "go_scatterplot.pdf"), width=10, height=8)
  print(scatterPlot(sim_matrix, reduced_terms, labelSize=3))
  dev.off()
  cat("Scatter plot visualization saved\n")
} else {
  cat("Too few clusters for scatterplot - skipping\n")
}

} else {
  cat("Skipping rrvgo visualizations (no significant GO terms)\n")
}

# ============================================================================
# 7. SUMMARY STATISTICS
# ============================================================================

cat("\n=== SUMMARY ===\n")

cat(paste("Total genes analyzed: ", length(gene_factor), "\n", sep=""))
cat(paste("DEGs with GO annotations: ", sum(gene_factor == 1), "\n", sep=""))
cat(paste("Total GO terms found: ", nrow(go_table), "\n", sep=""))
cat(paste("Significant GO terms (Fisher p < 0.05): ", nrow(go_sig), "\n", sep=""))

if (nrow(go_sig) > 0) {
  cat("\nTop 10 significant GO terms:\n")
  print(head(go_sig[, c("GO.ID", "Term", "Annotated", "Significant", "Fisher", "padj")], 10))
}

cat("\n")
separator <- paste(rep("=", 60), collapse="")
print(separator)
print("GO ENRICHMENT ANALYSIS COMPLETE")
print(separator)
print(paste("Output directory: ", output_dir))
print(separator)
print(paste("Analysis finished at: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S")))

# Close logging
sink()
