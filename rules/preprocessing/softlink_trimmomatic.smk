rule trimmomatic_trimming:
    input:
        paired_read_1 = "{sample}/{sample}_R1.processed.fastq.gz",
        paired_read_2 = "{sample}/{sample}_R2.processed.fastq.gz",
        unpaired_read = "{sample}/{sample}_SE.processed.fastq.gz"
    output: 
        filtered_paired_read_1 = "{sample}/{sample}_R1.processed.filtered.fastq.gz",
        filtered_paired_read_2 = "{sample}/{sample}_R2.processed.filtered.fastq.gz",
        filtered_unpaired_read = "{sample}/{sample}_SE.processed.filtered.fastq.gz"
    shell:
        """
        ln -fs {input.paired_read_1} {output.filtered_paired_read_1}
        ln -fs {input.paired_read_2} {output.filtered_paired_read_2}
        ln -fs {input.unpaired_read} {output.filtered_unpaired_read}
        """
