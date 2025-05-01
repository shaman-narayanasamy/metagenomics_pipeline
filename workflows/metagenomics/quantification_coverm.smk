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

print(samples)

catalogues = config["catalogues"]

print(catalogues)

#for cat_name, cat_info in catalogues.items():
#    fasta_path = cat_info["fasta"]
#    bed_path = cat_info.get("bed", None)

    # always run coverm
    # if bed_path is provided → run bedtools-based quantification


workdir:
    output_dir

## All workflow
include:
    '../../rules/metagenomics/quantification/concatenate_sequences.smk'

include:
    '../../rules/metagenomics/quantification/bwa.smk'

include:
    '../../rules/metagenomics/quantification/coverm/quantify_contigs.smk'

include:
    '../../rules/metagenomics/quantification/quantify_genes.smk'

rule all:
    input:
        expand("{cat}/concatenated_catalogue.fa", 
               cat=config["catalogues"].keys()),
        expand("{catalogue}/alignments/{sample}/{sample}.reads.sorted.bam", catalogue = config["catalogues"].keys(), sample = samples.index),
        expand("{catalogue}/coverm", catalogue = config["catalogues"].keys()),
        expand("{catalogue}/gene_coverage/{sample}.tsv", catalogue = config["catalogues"].keys(), sample = samples.index)
