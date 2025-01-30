import subprocess
import pandas as pd

## Define input directory
input_dir = config["input_dir"]["mg_binning_input"]

## Define output directory
output_dir = os.path.join(config['output_dir'],  "binning")

## Define input files
# Read the sample table
samples = pd.read_table(config["data_table"], sep="\t", comment = "#").set_index("sample_alias", drop=False)

workdir:
    output_dir

include:
    '../../rules/metagenomics/binning/contig_sorting.smk'

include:
    '../../rules/metagenomics/binning/concoct.smk'

include:
    '../../rules/metagenomics/binning/metabat2.smk'

include:
    '../../rules/metagenomics/binning/maxbin2.smk'

include:
    '../../rules/metagenomics/binning/vamb.smk'

include:
    '../../rules/metagenomics/binning/semibin.smk'

include:
    '../../rules/metagenomics/binning/marker_genes.smk'

include:
    '../../rules/metagenomics/binning/contig_to_bin.smk'

include:
    '../../rules/metagenomics/binning/bin_refinement.smk'

include:
    '../../rules/metagenomics/binning/separate_bins.smk'

include:
    '../../rules/metagenomics/binning/semibin_multi_sample.smk'

rule all:
     input:
        'semibin_multi_sample/concatenated.fa',
        'semibin_multi_sample/binning.done',
        expand("{sample}/concoct/bins", sample = samples.index),
        expand("{sample}/metabat2.done", sample = samples.index),
        expand("{sample}/maxbin2.done", sample = samples.index),
        expand("{sample}/semibin.done", sample = samples.index),
        expand("{sample}/vamb.done", sample = samples.index),
        expand("{sample}/magscot/MAGScoT.refined.contig_to_bin.out", sample = samples.index),
        expand("{sample}/magscot", sample = samples.index),
        expand("{sample}/magscot_bins", sample = samples.index),
	expand("{sample}/DeepMicroClass/prokaryotes.fa", sample = samples.index),
	expand("{sample}/DeepMicroClass/eukaryotes.fa", sample = samples.index),
	expand("{sample}/DeepMicroClass/prokaryotic_viruses.fa", sample = samples.index),
	expand("{sample}/DeepMicroClass/eukaryotic_viruses.fa", sample = samples.index),
	expand("{sample}/DeepMicroClass/plasmids.fa", sample = samples.index),
        expand('semibin_multi_sample/contigs_to_bins/{sample}_contig_to_bin.tsv', sample = samples.index)
