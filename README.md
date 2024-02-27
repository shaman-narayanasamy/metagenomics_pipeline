## Using the launcher

To download the data, we can use the following script:
```{sh}
scripts/download_data.sh <input metadata table> <download folder>
```
The input metadata table shoule contain the following tables:
sample_alias
MG
MG

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


