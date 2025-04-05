rule megahit:
    input:
        filtered_paired_read_1 = os.path.join(input_dir, "{sample}/{sample}_R1.processed.filtered.fastq.gz"),
        filtered_paired_read_2 = os.path.join(input_dir, "{sample}/{sample}_R2.processed.filtered.fastq.gz"),
        filtered_unpaired_read = os.path.join(input_dir, "{sample}/{sample}_SE.processed.filtered.fastq.gz")
    output:
        assembly_fasta="{sample}/megahit_assembly/final.contigs.fa",
    resources: 
        cpus_per_task=40,
        mem="250GB",
        runtime=7200
    params: 
        preset = config['megahit']['preset']
    threads: 40 
    conda: "../../../envs/megahit_env.yml"
    benchmark: os.path.join(output_dir, "{sample}/benchmarks/assembly.txt")
    log: os.path.join(output_dir, "{sample}/logs/assembly.txt")
    shell:
       """
       ARGS=""
       if [ -s {params.preset} ]; then
            ARGS="--presets {params.preset}"
       fi

       MEMORY_BYTES=$(($(echo {resources.mem} | sed -e s/GB//g) * 1000 * 1000 * 1000))

       rm -rf {wildcards.sample}/megahit_assembly

       megahit \
       --num-cpu-threads {resources.cpus_per_task} \
       --continue \
       -1 {input.filtered_paired_read_1} -2 {input.filtered_paired_read_2} \
       -r {input.filtered_unpaired_read} \
       -o {wildcards.sample}/megahit_assembly \
       -m $MEMORY_BYTES \
       $ARGS \
       --mem-flag 2
       """ 

rule rename_contigs:
    input:
        assembly_fasta="{sample}/megahit_assembly/final.contigs.fa",
    output:
        assembly_fasta="{sample}/{sample}.assembly_contigs.fa",
    shell:
        """
        sample_id="{wildcards.sample}"
        
	awk -v id="${{sample_id}}" '/^>/ {{print ">" id "_contig_" substr($1, 2); next}} 1' \
        {input.assembly_fasta} > {output.assembly_fasta}
        """
