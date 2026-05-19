**Note on hisat2 scripts**
This step was executed locally (`hisat2.sh`) during a server downtime period to maintain project continuity, rather than on the HPC cluster.
Since the masking step is computationally intensive and time-consuming, the computation was not repeated.
Both a local (`hisat2.sh`) and a SLURM-compatible (`slurm-hisat2.sh`) version are provided for reference and future reproducibility.

**Note on hisat2 results**
Due to their large size, output BAM files are not included in this repo but can be found on UPPMAX cluster at: /proj/uppmax2026-1-61/nobackup/work/tede0387/7_RNA-Mapping.
All the log files can be found in the "logs/" folder

**Note on alignment quality evaluation**
The alignment quality from all the per-sample hisat2 alignment statistics can be found in the MultiQC HTML report in the current folder

