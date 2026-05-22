# Genome Analysis — Niphotrichum japonicum chromosome 3
This project focused on the structural and functional annotation of chromosome 3 of the moss *Niphotrichum japonicum*, as well as differential expression analysis under heat stress.

## Methods
### Steps 1-2-3: Quality control and Trimming
Raw reads were assessed with **FastQC** and trimmed with **Trimmomatic**. All samples passed per-base sequence quality after trimming. However, since their quality slightly declined, the pre-trimming reads were preferred. The remaining FastQC flags, "Per base sequence content" and "Sequence Duplication Levels," are technical artifacts of Illumina random priming and library complexity; they do not indicate errors that trimming can fix

### Step 4: Assembly
The genome was assembled de novo from Nanopore long reads with **Flye**, which produced 57 contigs (around 17.4 Mb total)

### Step 5: Polishing
The assembly was polished with **Pilon**, using the Illumina short reads to correct base-level errors. Assembly quality was evaluated with three complementary tools:
- **QUAST** — contiguity (contig number, N50, largest contig)
- **BUSCO** (`embryophyta_odb12`, miniprot mode) — gene completeness
- **Merqury** (k=21) — base-level accuracy from k-mer spectra

### Step 6: Repeat Masking
A custom repeat library was built *de novo* with **RepeatModeler** (132 families, 34 LTR) and then the assembly was soft-masked with **RepeatMasker**

### Step 7: RNA Mapping
The 6 RNA-seq samples were aligned to the masked assembly with **HISAT2**

### Step 8: Structural annotation
Gene models were predicted thanks to **BRAKER3** (via Singularity), integrating the RNA-seq BAM files with protein homology from *Ceratodon purpureus* (a closely related moss available in the project materials)
 
### Step 9: Functional annotation
Predicted proteins were annotated with **EggNOG-mapper** in **HMM mode** (chosen over Diamond mode due to a known bug)
 
### Step 10: Gene quantification
Reads were counted per gene with **featureCounts**
 
### Step 11: Differential expression
**DESeq2** was used to test for differential expression between Heat and Control, with significance at padj < 0.05 and |log2FC| > 1
 
### Step 12: GO enrichment
Significant differentially expressed genes were tested for GO term enrichment


## Results and biological interpretation
### Assembly quality
The polished assembly comprises 57 contigs totalling ~17 Mb. Polishing with Pilon changed assembly metrics only marginally (total length, N50 and contig number remained essentially the same), suggesting an already optimal assembly quality where the polishing only corrected base-level errors without altering large-scale structure. Later on, Merqury confirmed high base-level accuracy.  
The low BUSCO score (8% circa) shouldn't be considered a sign of a poor assembly. BUSCO, in fact, searches for single-copy orthologs distributed across the entire genome. Since only chromosome 3 was annotated, which represents roughly 8–9% of the full genome, this is a reasonable result. A completeness of circa 8% is hence exactly in agreement with the goal and consistent across all downstream stages (masked assembly, predicted proteins, and predicted transcripts)

### Repeat landscape
20.63% of chromosome 3 is repetitive (RepeatMasker official "bases masked" value):
 
| Repeat class | % of chr3 |
|---|---|
| LTR elements | 8.12 |
| DNA transposons | 0.96 |
| Unclassified | 11.54 |
| Total masked | 20.63 |
 
In particular, the LTR retrotransposons are dominated by the Gypsy/DIRS1 superfamily (6.84%) over Ty1/Copia (0.57%), a commonly present pattern in plant and moss genomes. The large unclassified fraction (11.54%) reflects that N. japonicum is not a non-model species: the custom RepeatModeler library detects repeats but cannot always assign them to known families.
Repeats are not randomly distributed with respect to genes: overlap analysis between repeats and gene features shows that repeats accumulate in flanking (intergenic) regions and largely spare exons. Transposable elements that insert into coding exons disrupt genes and are removed by purifying selection, while intergenic regions tolerate their accumulation instead. This confirms that masking is consistent with gene structure and is not masking coding sequence
 
### Structural annotation
BRAKER3 predicted 2027 genes on chromosome 3, using both RNA-seq evidence and protein homology. Genes appear to be unevenly distributed across contigs. Some regions are gene-rich while others are gene-poor (the latter typically corresponding to repeat-rich regions): this gene/repeat compartmentalisation is a common trait in plant genome organisation
 
### Functional annotation
Of the 2,027 predicted genes:
 
| Category | Genes | % |
|---|---|---|
| Annotated (functional description) | 1,276 | 63.0 |
| Hits but hypothetical (no description) | 149 | 7.4 |
| No EggNOG hit | 602 | 29.7 |
 
About 63% of genes received a functional description, an acceptable value for a non-model plant species. Among COG functional categories, the largest is "Function unknown" [S], which is expected for a Bryophyte phylogenetically distant from the organisms underlying the COG database. Among genes with known function, the most represented categories are post-translational modification, signal transduction, transcription and carbohydrate metabolism.
KEGG pathway mapping highlights general metabolism (Metabolic pathways, Biosynthesis of secondary metabolites, Carbon metabolism) and phenylpropanoid biosynthesis, the latter relevant to plant stress and cell wall biology. Animal and viral KEGG pathways that appeared by homology were excluded as biologically irrelevant to a moss
 
### Differential expression and heat-stress response
DESeq2 identified DE genes between heat-treated and control samples. 
PCA confirmed that the main axis of variation separates Heat from Control, indicating that the treatment is the dominant biological signal. The GO enrichment of differentially expressed genes highlighted several points. The most enriched terms correspond to the canonical plant heat-stress response: response to heat, protein folding, heat-shock protein binding as well as response to oxidative stress. Such results make strong evidence that the pipeline captured a real, interpretable biological signal rather than noise. Under heat stress, N. japonicum chromosome 3 up-regulates the molecular chaperone and reactive-oxygen-species detoxification machinery that protects cells from thermal damage.
 
### Limitations
- Only chromosome 3 was analysed, so genome-wide BUSCO and annotation completeness cannot be assessed by this project
- A large fraction of genes remains functionally uncharacterized, reflecting the non-model status of the species
