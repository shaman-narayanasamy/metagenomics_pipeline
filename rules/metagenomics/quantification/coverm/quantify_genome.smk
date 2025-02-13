rule coverm_genomes:
    input:
        genomes = config["coverm"]["genomes_dir"], 
        r1 = "%s/{sample}/{sample}_R1.processed.filtered.fastq.gz" % input_dir,
        r2 = "%s/{sample}/{sample}_R2.processed.filtered.fastq.gz" % input_dir,
        se = "%s/{sample}/{sample}_SE.processed.filtered.fastq.gz" % input_dir
    output:
        out_dir = directory("coverm/{sample}"),
        bam_dir = directory("coverm/bam_dir/{sample}")
    threads: 24
    conda: 
        "../../../../envs/coverm_env.yml"
    benchmark: "benchmarks/coverm/{sample}.txt"
    log: "log/coverm/{sample}.log"
    shell:
        """
        mkdir -p {output.out_dir}
        mkdir -p {output.bam_dir}
 
        coverm genome -1 {input.r1} -2 {input.r2} --single {input.se} \
        -d {input.genomes} -x fasta \
        --min-covered-fraction 0
        -m relative_abundance mean trimmed_mean counts reads_per_base rpkm tpm covered_fraction covered_bases length \
        -o {output.out_dir}/output --bam-file-cache-directory {output.bam_dir}/bamfile \
	--use-full-contig-names
        -t {threads}
        """
