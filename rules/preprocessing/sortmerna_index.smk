## Sortmerna cannot handle sequences shorter than 19 bp, need to filter them out
rule sortmerna_prepare_sequences:
    input:
        contaminant_fasta_path = config['sortmerna']['contaminant_fasta_path']
    output:
        contaminant_fasta_filtered = os.path.join(config['sortmerna']['db_path'], f"{config['sortmerna']['contamination_name']}_minlength-{config['sortmerna']['filter_length']}.fasta")
    params: 
        filter_length=config['sortmerna']['filter_length'],
    resources:
        cpus_per_task = 12,
        runtime = 2880,
        mem = "120GB"
    conda: "../../envs/pullseq_env.yml"
    benchmark: "benchmarks/pullseq_filter_length.txt"
    log: "logs/pullseq_filter_length.txt"
    shell: 
        """
        pullseq -i {input.contaminant_fasta_path} -m {params.filter_length} > {output.contaminant_fasta_filtered}
	"""

## This rule is only in place just in case the databases were not indexed
rule sortmerna_index_database:
    input:
        db_path=config['sortmerna']['db_path'],
        contaminant_fasta_filtered = os.path.join(config['sortmerna']['db_path'], f"{config['sortmerna']['contamination_name']}_minlength-{config['sortmerna']['filter_length']}.fasta")
    output:
        donefile=os.path.join(config['sortmerna']['db_path'], f"{config['sortmerna']['contamination_name']}_minlength-{config['sortmerna']['filter_length']}.done")
    params: 
        db_path=config['sortmerna']['db_path'],
    resources:
        cpus_per_task = 24,
        runtime = 4320,
        mem = "200GB" 
    conda: "../../envs/sortmerna_env.yml"
    benchmark: "benchmarks/sortmerna_index_database.txt"
    log: "logs/sortmerna_index_database.txt"
    shell: 
        """
        sortmerna \
            --workdir {params.db_path} \
            --index 1 \
            --threads {resources.cpus_per_task} \
            --ref {input.contaminant_fasta_filtered} &> {log}

        touch {output.donefile}
	"""
