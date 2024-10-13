## Description
This repository is a "fork" of my [own repository for a different project](https://github.com/shaman-narayanasamy/soil_experiment).

## Data preparation
Prepare a table with the  follwoing columns:
1. sample\_ID -- shortened names of the samples
2. R1 -- full/absolute path  of the R1 read fastq.gz file
3. R2 -- R2 equivaluent of the above

Here  is a nice command to  generate such a  table:
```{sh}
cd /ibex/project/e3015/FLW_STG_multiomics/Lane2/version_01

paste <(echo -e 'sample_alias\tR1\tR2'; \ls *R1_001.fastq.gz | cut -d "_" -f2) <(echo; \ls $PWD/*R1_001.fastq.gz) <(echo; \ls $PWD/*R1_001.fastq.gz | sed -e 's/_R1_/_R2_/g') > /ibex/project/e3015/FLW_STG_multiomics/sample_table.tsv
```

## Using the launcher
To download the data, we can use the following script:
```{sh}
scripts/download_data.sh <input metadata table> <download folder>
```
The input metadata table shoule contain the following tables:
sample_alias
MG_R1
MG_R2

Dry run:
```{sh}
launchers/sbatch_preprocessing.sh
```
NOTE: There are also other flags `--touch`

Launch and push to the background.
Preprocessing:
```{sh}
nohup launchers/sbatch_preprocessing.sh > nohup_logs/preprocessing_launch_$(date +'%Y%m%d_%H%M%S').log 2>&1 &
```

Assembly:
```{sh}
nohup launchers/sbatch_assembly.sh > nohup_logs/assembly_launch_$(date +'%Y%m%d_%H%M%S').log 2>&1 &
```

Binning:
```{sh}
nohup launchers/sbatch_binning.sh > nohup_logs/binning_launch_$(date +'%Y%m%d_%H%M%S').log 2>&1 &
```
Dereplication:
```{sh}
nohup launchers/sbatch_dereplication.sh > nohup_logs/dereplication_launch_$(date +'%Y%m%d_%H%M%S').log 2>&1 &
```

Annotation:
```{sh}
nohup launchers/sbatch_annotation.sh > nohup_logs/annotation_launch_$(date +'%Y%m%d_%H%M%S').log 2>&1 &
```

Prepare protein database:
This step is performed manually where all the protein sequences from all MAGs are pasted into a single file.
```{sh}
## Append all to a single file:
ls */*.faa | grep -v "hypotheticals" | xargs -I{} cat {} >> all_proteins.faa

## Some sanity checks:
### Check the total no of protein sequences in the all proteins file
grep -c "^>" all_proteins.faa 
1530223

### Check if the sum of all proteins in individual MAGs equals to the one in the all proteins file
ls */*.faa | grep -v "hypotheticals" | xargs -I{} grep -c "^>" {} | awk '{s+=$1} END {print s}'
1530223
```

Quantification:
```{sh}
nohup launchers/sbatch_quantification.sh > nohup_logs/quantification_launch_$(date +'%Y%m%d_%H%M%S').log 2>&1 &
```

