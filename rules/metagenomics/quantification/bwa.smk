rule bwa_index_assembly:
    input:
        fasta="{catalogue}/concatenated_catalogue.fa"
    output:
        assembly_amb="{catalogue}/concatenated_catalogue.fa.amb",
        assembly_bwt="{catalogue}/concatenated_catalogue.fa.bwt",
        assembly_pac="{catalogue}/concatenated_catalogue.fa.pac",
        assembly_ann="{catalogue}/concatenated_catalogue.fa.ann",
        assembly_sa="{catalogue}/concatenated_catalogue.fa.sa"
    resources:
        mem_mb = 100000
    threads: 6
    conda: "../../../envs/bwa_env.yml"
    benchmark: "{catalogue}/benchmarks/bwa_indexing.txt"
    log: "{catalogue}/logs/bwa_indexing.txt"
    shell:
        """
        bwa index {input.fasta}
        """

rule bwa_mapping_catalogue:
    input:
        r_1 = "%s/{sample}/{sample}_R1.processed.filtered.fastq.gz" % input_dir,
        r_2 = "%s/{sample}/{sample}_R2.processed.filtered.fastq.gz" % input_dir,
        r_se = "%s/{sample}/{sample}_SE.processed.filtered.fastq.gz" % input_dir,
        assembly="{catalogue}/concatenated_catalogue.fa",
        assembly_amb="{catalogue}/concatenated_catalogue.fa.amb",
        assembly_bwt="{catalogue}/concatenated_catalogue.fa.bwt",
        assembly_pac="{catalogue}/concatenated_catalogue.fa.pac",
        assembly_ann="{catalogue}/concatenated_catalogue.fa.ann",
        assembly_sa="{catalogue}/concatenated_catalogue.fa.sa"
    output:
        '{catalogue}/alignments/{sample}/{sample}.reads.sorted.bam'
    params: 
        prefix = "{catalogue}/alignments/{sample}/{sample}.reads",
        memory = 250
    resources:
        memory = 250
    threads: 24 
    conda: "../../../envs/bwa_env.yml"
    benchmark: "{catalogue}/alignments/{sample}/benchmarks/bwa_mapping.txt"
    log: "{catalogue}/alignments/{sample}/logs/bwa_mapping.txt"
    shell:
        """
        SAMHEADER="@RG\\tID:{wildcards.sample}\\tSM:MG"

        PREFIX={params.prefix}
        
        MEM_PER_CORE=$(({params.memory}/{threads}))

        # merge paired and se
        samtools merge --threads {threads} -f $PREFIX.merged.bam \
         <(bwa mem -v 1 -t {threads} -M -R \"$SAMHEADER\" {input.assembly} {input.r_1} {input.r_2} 2>> {log}| \
         samtools view --threads {threads} -bS -) \
         <(bwa mem -v 1 -t {threads} -M -R \"$SAMHEADER\" {input.assembly} {input.r_se} 2>> {log}| \
         samtools view --threads {threads} -bS -) 2>> {log}

        # sort
        samtools sort --threads {threads} -m ${{MEM_PER_CORE}}G $PREFIX.merged.bam > $PREFIX.sorted.bam 2>> {log}
        rm $PREFIX.merged.bam
        """

rule index_assembly_bam:
    input:
        '{catalogue}/alignments/{sample}/{sample}.reads.sorted.bam'
    output:
        '{catalogue}/alignments/{sample}/{sample}.reads.sorted.bam.bai'
    conda: "../../../envs/bwa_env.yml"
    benchmark: "{catalogue}/alignments/{sample}/benchmarks/index_bam.txt"
    log: "{catalogue}/alignments/{sample}/logs/index_bam.txt"
    shell:
        """
        samtools index {input} > {log} 2>&1
        """

rule flagstat_assembly_bam:
    input:
        '{catalogue}/alignments/{sample}/{sample}.reads.sorted.bam',
    output:
        'flagstats/{catalogue}/{sample}/{sample}.reads.sorted.flagstat.txt'
    conda: "../../../envs/bwa_env.yml"
    benchmark: "{catalogue}/alignments/{sample}/benchmarks/flagstat.txt"
    log: "{catalogue}/alignments/{sample}/logs/flagstat.txt"
    shell:
        """
        samtools flagstat {input} > {output}
        """
