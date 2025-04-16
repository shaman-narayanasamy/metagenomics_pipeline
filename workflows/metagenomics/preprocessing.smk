import subprocess
import pandas as pd

tmp_dir = os.environ.get("tmp_dir", config['tmp_dir'])

## Define output directory
output_dir = os.path.join(config['output_dir'],  "metagenomics", "preprocessing")

## Define input files
# Read the sample table
samples = pd.read_table(config["data_table"], sep="\t", comment="#", dtype={"sample_alias": str})
samples.set_index("sample_alias", drop=False, inplace=True)

workdir:
    output_dir

include:
    '../../rules/metagenomics/preprocessing/trimmomatic.smk'

if "sortmerna" in config:
    include: "../../rules/metagenomics/preprocessing/sortmerna_filter.smk"  
    include: "../../rules/metagenomics/preprocessing/sortmerna_index.smk"  
else:
    include: "../../rules/metagenomics/preprocessing/softlink.smk"

rule all:
     input:
        expand("{sample}/{sample}_SE.processed.filtered.fastq.gz", sample = samples.index), 
        expand("{sample}/{sample}_R1.processed.filtered.fastq.gz", sample = samples.index),
        expand("{sample}/{sample}_R2.processed.filtered.fastq.gz", sample = samples.index)
