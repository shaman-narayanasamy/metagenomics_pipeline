import subprocess
import pandas as pd

## Define input directory
input_dir = config["input_dir"]["mg_binning_input"]

## Define output directory
output_dir = os.path.join(config['output_dir'],  "metagenomics", "binning")

## Define input files
# Read the sample table
samples = pd.read_table(config["data_table"], sep="\t", comment = "#").set_index("sample_alias", drop=False)

workdir:
    output_dir

include:
    '../../rules/metagenomics/binning/concoct.smk'

rule all:
     input:
        expand("{sample}/binning/concoct/bins", sample = samples.index)

