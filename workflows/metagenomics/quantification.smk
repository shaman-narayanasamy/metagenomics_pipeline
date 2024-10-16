import subprocess
import yaml
import pandas as pd

tmp_dir = os.environ.get("tmp_dir", config['tmp_dir'])

## Define input directory
input_dir = config["input_dir"]["mg_quantification_input"]

## Define output directory
output_dir = os.path.join(config['output_dir'], "metagenomics", "quantification")

## Define input files
# Read the sample table
samples = pd.read_table(config["data_table"], sep="\t", comment = "#").set_index("sample_alias", drop=False)

workdir:
    output_dir

## All workflow
include:
    '../../rules/metagenomics/quantification/salmon/indexing.smk'

include:
    '../../rules/metagenomics/quantification/salmon/pseudoalignment.smk'

include:
    '../../rules/metagenomics/quantification/coverm/quantify_genome.smk'

rule all:
    input:
        expand("salmon/{catalogue}/{sample}_quant", 
               sample=samples.index,
               catalogue=config["salmon"]["catalogues"].keys()),
#        expand("salmon/{sample}_quant", sample = samples.index), 
#        expand("coverm/{sample}", sample = samples.index)
