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

## Define catalogues
catalogues = config["catalogues"].keys()

print(catalogues)

workdir:
    output_dir

## All workflow
include:
    '../../rules/metagenomics/quantification/concatenate_sequences.smk'

include:
    '../../rules/metagenomics/quantification/bwa.smk'

include:
    '../../rules/metagenomics/quantification/salmon/indexing.smk'

include:
    '../../rules/metagenomics/quantification/salmon/pseudoalignment.smk'

include:
    '../../rules/metagenomics/quantification/coverm/quantify_genome.smk'

rule all:
    input:
        expand("{cat}/concatenated_catalogue.fa", 
               cat=config["catalogues"].keys()),
        expand("{catalogue}/salmon/{sample}/quant.sf", 
               sample=samples.index,
               catalogue=config["catalogues"].keys()),
        expand("{catalogue}/coverm", catalogue = config["catalogues"].keys())

#        expand("{catalogue}/coverm/{sample}", 
#               catalogue=config["catalogues"].keys(), 
#               sample=samples.index)
#
#        expand("coverm/{catalogue}/{sample}", catalogue = config["catalogues"].keys(), sample = samples)
#        expand("salmon/{sample}_quant", sample = samples.index), 
#        expand("coverm/{sample}", sample = samples.index)
