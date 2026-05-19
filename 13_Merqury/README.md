## Notes on k value selection
The optimal k value was defined as 17 by best_k.sh, given chromosome 3 dimension (polished_assembly.fasta size).
This execution reported:
- QV = 26.4 (error rate = 0.231%)
- Completeness = 87%

The result robustness was further tested by running another merqury execution with k = 21.
In such case, an almost identical QV was obtained (QV = 26.3, error rate = 0.234%).
These results highlightned a stable metrics across the k parameter, ensuring reliability
