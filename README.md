## Description
This repository is a "fork" of my [own repository for a different project](https://github.com/shaman-narayanasamy/soil_experiment).

## Data preparation
Prepare a table with the  follwoing columns:
1. sample\_ID -- shortened names of the samples
2. R1 -- full/absolute path  of the R1 read fastq.gz file
3. R2 -- R2 equivaluent of the above

Here  is a nice command to  generate such a  table:
```{sh}
cd /ibex/project/e3015/fatima/Lane2/version_01

paste <(echo -e 'sample_alias\tR1\tR2'; \ls *R1_001.fastq.gz | cut -d "_" -f2) <(echo; \ls $PWD/*R1_001.fastq.gz) <(echo; \ls $PWD/*R1_001.fastq.gz | sed -e 's/_R1_/_R2_/g') > /ibex/project/e3015/fatima/sample_table.tsv
```

## Reference sequence preparation
Since we know specific sequences that we are interested in, we create a sequence database to perform reference-based
analysis. To prepare the sequences for programs like salmon
(pseudoalignment-based quantification), ensure that the fasta file is in
appropriate format, specifically the headers: 

```{sh}
cat * | grep -v "^$" | sed -e 's/ /_/g'  > sequence_catalogue.fasta 
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

Quantification:
```{sh}
nohup launchers/sbatch_quantification.sh > nohup_logs/quantification_launch_$(date +'%Y%m%d_%H%M%S').log 2>&1 &
```

Assembly:
```{sh}
nohup launchers/sbatch_assembly.sh > nohup_logs/assembly_launch_$(date +'%Y%m%d_%H%M%S').log 2>&1 &
```

Binning:
```{sh}
nohup launchers/sbatch_binning.sh > nohup_logs/binning_launch_$(date +'%Y%m%d_%H%M%S').log 2>&1 &
```
