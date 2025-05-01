rule link_processed_reads:
    input:
        paired_read_1 = "{sample}/{sample}_R1.processed.fastq.gz",
        paired_read_2 = "{sample}/{sample}_R2.processed.fastq.gz",
        paired_read_se = "{sample}/{sample}_SE.processed.fastq.gz",
    output:
        paired_read_1 = "{sample}/{sample}_R1.processed.filtered.fastq.gz",
        paired_read_2 = "{sample}/{sample}_R2.processed.filtered.fastq.gz",
        paired_read_se = "{sample}/{sample}_SE.processed.filtered.fastq.gz",
    shell:
        """
        ln -sf ../{input.paired_read_1} {output.paired_read_1}
        ln -sf ../{input.paired_read_2} {output.paired_read_2}
        ln -sf ../{input.paired_read_se} {output.paired_read_se}
        """
