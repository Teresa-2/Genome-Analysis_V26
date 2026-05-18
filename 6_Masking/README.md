**Note on repeatModeler scripts**
This step was executed locally (`1_repeat-modeler.sh`) during a server downtime period to maintain project continuity, rather than on the HPC cluster.
Since the masking step is computationally intensive and time-consuming, the computation was not repeated.
Both a local (`1_repeat-modeler.sh`) and a SLURM-compatible (`slurm-1_repeat-modeler.sh`) version are provided for reference and future reproducibility.

**Note on repeatMasker scripts**
This step was executed locally (`2_repeat-masker.sh`) during a server downtime period to maintain project continuity, rather than on the HPC cluster.
Since the masking step is computationally intensive and time-consuming, the computation was not repeated.
Both a local (`2_repeat-masker.sh`) and a SLURM-compatible (`slurm-2_repeat-masker.sh`) version are provided for reference and future reproducibility.
Note: Execution logs were not retained form the local run

**Note on Busco scripts**
This step was executed locally (`busco_masked-assembly.sh`) during a server downtime period to mantain project continuity, rather than on the HPC cluster.
Both a local (`busco_masked-assembly.sh`) and a SLURM-compatible (`slurm-busco_masked-assembly.sh`)  version are provided for reference and future reproducibility.
Note: Execution logs were not retained form the local run
