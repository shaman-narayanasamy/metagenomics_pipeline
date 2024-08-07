rule get_depth_of_coverage:
    input:
        bam = os.path.join(input_dir, '{sample}/{sample}.reads.sorted.bam'),
        bai = os.path.join(input_dir, '{sample}/{sample}.reads.sorted.bam.bai')
    output:
        depth_file = "{sample}/contig_depth.txt",
        min_contig_length = config["binning"]["min_contig_length"]
    conda: "../../../envs/metabat2_env.yml"
    benchmark: "{sample}/benchmarks/jgi_summarize_bam_contig_depths.txt"
    log: "{sample}/logs/jgi_summarize_bam_contig_depths.txt"
    shell:
        """
	jgi_summarize_bam_contig_depths --outputDepth {output.depth_file} \
        --minContigLength {params.min_contig_length}
        {input.bam}
        """

rule metabat2:
    input:
        fasta = os.path.join(input_dir, "{sample}/megahit_assembly/final.contigs.fa"), 
        bam = os.path.join(input_dir, '{sample}/{sample}.reads.sorted.bam'),
        bai = os.path.join(input_dir, '{sample}/{sample}.reads.sorted.bam.bai'),
        depth_file = "{sample}/contig_depth.txt"
    output:
        done = '{sample}/metabat2.done',
    params:
        threads = config["metabat2"]["threads"],
        min_contig_length = config["binning"]["min_contig_length"],
        prefix = '{sample}/metabat2/metabat_bin_'
    conda: "../../../envs/metabat2_env.yml"
    benchmark: "{sample}/benchmarks/metabat2.txt"
    log: "{sample}/logs/metabat2.txt"
    shell:
        """
        metabat2 -t {params.threads} \
        -i {input.fasta} \
        -o {params.prefix} \
        -a {input.depth_file} \
        -m {params.min_contig_length}

	touch {output.done}
        """

#runMetaBat.sh -t {params.threads} \
#        -m {params.min_contig_length} \
#        -a {input.depth_file} \
#        -o {params.prefix} \
#        {input.fasta} {input.bam}
#

