rule sortmerna_filter_paired:
    input:
        paired_read_1 = "{sample}/{sample}_R1.processed.fastq.gz",
        paired_read_2 = "{sample}/{sample}_R2.processed.fastq.gz",
        contaminant_genome = os.path.join(config['sortmerna']['db_path'], f"{config['sortmerna']['contamination_name']}_minlength-{config['sortmerna']['filter_length']}.fasta"),
        donefile=os.path.join(config['sortmerna']['db_path'], f"{config['sortmerna']['contamination_name']}_minlength-{config['sortmerna']['filter_length']}.done")
    output:
        filtered_paired_read_1 = "{sample}/{sample}_R1.processed.filtered.fastq.gz",
        filtered_paired_read_2 = "{sample}/{sample}_R2.processed.filtered.fastq.gz",
        filtered_unpaired_read_1 = temp("{sample}/{sample}_unpaired_R1.processed.filtered.fastq.gz"),
        filtered_unpaired_read_2 = temp("{sample}/{sample}_unpaired_R2.processed.filtered.fastq.gz")
    params: 
        db_path=config['sortmerna']['db_path'],
        out_prefix_paired = "{sample}/{sample}_paired.non_contaminant", # output prefix for paired reads
        workdir=temp(directory("/tmp/{sample}/{sample}_paired_sortmerna_workdir"))
    resources:
        cpus_per_task=24,
        runtime=4320
    conda: "../../../envs/sortmerna_env.yml"
    benchmark: "{sample}/benchmarks/preprocessing_filtering_paired.txt"
    #log: "{sample}/logs/preprocessing_filtering_paired.txt"
    shell: 
        """ 
        # Run SortMeRNA for paired-end reads
        sortmerna \
                  --workdir {params.workdir} \
                  --ref {input.contaminant_genome} \
                  --idx-dir {params.db_path}/idx \
                  --reads {input.paired_read_1} \
                  --reads {input.paired_read_2} \
                  --threads {resources.cpus_per_task} \
                  --other /tmp/{params.out_prefix_paired} \
                  --fastx \
                  --out2 \
                  --sout

        # Since SortMeRNA appends _1 and _2 to the file names for paired reads, 
        # and automatically adds .fastq extension, we can just move them directly.
        mv /tmp/{params.out_prefix_paired}_paired_fwd.fq.gz {output.filtered_paired_read_1}
        mv /tmp/{params.out_prefix_paired}_paired_rev.fq.gz {output.filtered_paired_read_2}
        mv /tmp/{params.out_prefix_paired}_singleton_fwd.fq.gz {output.filtered_unpaired_read_1}
        mv /tmp/{params.out_prefix_paired}_singleton_rev.fq.gz {output.filtered_unpaired_read_2}
        """

rule sortmerna_filter_single:
    input:
        unpaired_read = "{sample}/{sample}_SE.processed.fastq.gz",
        filtered_unpaired_read_1 = "{sample}/{sample}_unpaired_R1.processed.filtered.fastq.gz",
        filtered_unpaired_read_2 = "{sample}/{sample}_unpaired_R2.processed.filtered.fastq.gz",
        contaminant_genome = os.path.join(config['sortmerna']['db_path'], f"{config['sortmerna']['contamination_name']}_minlength-{config['sortmerna']['filter_length']}.fasta"),
        donefile=os.path.join(config['sortmerna']['db_path'], f"{config['sortmerna']['contamination_name']}_minlength-{config['sortmerna']['filter_length']}.done")
    output:
        filtered_unpaired_read = "{sample}/{sample}_SE.processed.filtered.fastq.gz"
    params: 
        db_path=config['sortmerna']['db_path'],
        out_prefix_unpaired = "{sample}/{sample}_SE.non_contaminant", # output prefix for unpaired reads
        workdir=temp(directory("/tmp/{sample}/{sample}_unpaired_sortmerna_workdir"))
    resources:
        cpus_per_task=12,
        runtime=2880,
    conda: "../../../envs/sortmerna_env.yml"
    benchmark: "{sample}/benchmarks/preprocessing_filtering_single.txt"
    log: "{sample}/logs/preprocessing_filtering_single.txt"
    shell: 
        """
        # Check if file is empty
        if [[ -s {input.unpaired_read} ]]; then
            # Run SortMeRNA for unpaired reads
            sortmerna \
                      --workdir {params.workdir} \
                      --ref {input.contaminant_genome} \
                      --idx-dir {params.db_path}/idx \
                      --reads {input.unpaired_read} \
                      --threads {resources.cpus_per_task} \
                      --other /tmp/{params.out_prefix_unpaired} \
                      --fastx

            zcat /tmp/{params.out_prefix_unpaired}.fq.gz \
                 {input.filtered_unpaired_read_1} \
                 {input.filtered_unpaired_read_2} | gzip > \
                 {output.filtered_unpaired_read}
        else
            touch {output.filtered_unpaired_read}
        fi
        """
