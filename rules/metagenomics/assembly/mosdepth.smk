rule generate_bedfile:
    input:
        assembly_fasta="{sample}/megahit_assembly/final.contigs.fa",
    output:
        coassembly_bed="{sample}/{sample}.coassembly_contigs.fa.bed",
    conda: "../../../envs/bwa_env.yml"
    shell:
        """
	samtools faidx {input.coassembly_fasta}
        awk '{{print $1 "\t0\t" $2}}' {input.coassembly_fasta}.fai > {output.coassembly_bed}
        """

rule mosdepth_mg:
    input:
        mg_bam = '{sample}/{sample}.reads.sorted.bam'
    output:
        output = "{sample}/{sample}.mosdepth.summary.txt"
    params:
        prefix = "{sample}/{sample}",
        threads = config["mosdepth"]["threads"]
    conda: "../../../envs/mosdepth.yml"
    benchmark: "{sample}/benchmarks/mosdepth.txt"
    log: "{sample}/logs/mosdepth.txt"
    shell:
        """
        mosdepth -n -t {prefix.threads} --fast-mode --by {input.coassembly_bed} {params.prefix}_metaG {input.mg_bam}
        """
