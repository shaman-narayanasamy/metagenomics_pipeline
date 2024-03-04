import subprocess
import pandas as pd

## Define input directory
input_dir = config["input_dir"]["mg_assembly_input"]

## Define output directory
output_dir = os.path.join(config['output_dir'],  "metagenomics", "assembly")

## Define input files
# Read the sample table
samples = pd.read_table(config["data_table"], sep="\t", comment = "#").set_index("sample_alias", drop=False)

workdir:
    output_dir

include:
    '../../rules/metagenomics/assembly/megahit.smk'

include:
    '../../rules/metagenomics/assembly/bwa.smk'

rule all:
     input:
        expand("{sample}/megahit_assembly/final.contigs.fa", sample = samples.index),
        expand('{sample}/{sample}.reads.sorted.bam', sample = samples.index),
        expand('{sample}/{sample}.reads.sorted.bam.bai', sample = samples.index),
        expand('{sample}/{sample}.reads.sorted.flagstat.txt', sample = samples.index)

