rule get_depth_of_coverage:
    input:
        bam = os.path.join(input_dir, '{sample}/{sample}.reads.sorted.bam'),
        bai = os.path.join(input_dir, '{sample}/{sample}.reads.sorted.bam.bai')
    output:
        depth_file = "{sample}/contig_depth.txt",
    conda: "../../../envs/metabat2_env.yml"
    shadow: "shallow"
    benchmark: "{sample}/benchmarks/jgi_summarize_bam_contig_depths.txt"
    log: "{sample}/logs/jgi_summarize_bam_contig_depths.txt"
    shell:
        """
	jgi_summarize_bam_contig_depths --outputDepth {output.depth_file} \
        {input.bam}
        """

rule metabat2:
    input:
        fasta = os.path.join(input_dir, "{sample}/megahit_assembly/final.contigs.fa"), 
        bam = os.path.join(input_dir, '{sample}/{sample}.reads.sorted.bam'),
        bai = os.path.join(input_dir, '{sample}/{sample}.reads.sorted.bam.bai'),
        depth_file = "{sample}/contig_depth.txt"
    output:
        bin_dir = directory('{sample}/metabat2'),
        done = '{sample}/metabat2.done'
    params:
        threads = config["metabat2"]["threads"],
        min_contig_length = config["binning"]["min_contig_length"],
        prefix = '{sample}/metabat2/metabat_bin_'
    shadow: "shallow"
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

rule metabat2_contig_to_bin:
    input:
        bin_dir = "{sample}/metabat2"
    output:
        contig_to_bin="{sample}/metabat2/contig_to_bin.tsv",
    shadow: "shallow"
    shell:
       """
       gunzip {input.bin_dir}/*.fa.gz

       ls {input.bin_dir}/*.fa | \
       xargs -I{{}} bash -c 'paste <(yes "{{}}" | \
       head -n $(grep -c "^>" {{}})) <(grep "^>" {{}} | \
       sed -e "s/>//g") <(yes "metabat2" | \
       head -n $(grep -c "^>" {{}}))' | \
       sed -e 's/\.fa//g' > {output.contig_to_bin}
       """
