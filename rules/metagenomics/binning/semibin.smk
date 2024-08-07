rule semibin:
    input:
        fasta = os.path.join(input_dir, "{sample}/megahit_assembly/final.contigs.fa"), 
        bam = os.path.join(input_dir, '{sample}/{sample}.reads.sorted.bam'),
        bai = os.path.join(input_dir, '{sample}/{sample}.reads.sorted.bam.bai'),
        depth_file = "{sample}/contig_depth.txt"
    output:
        done = '{sample}/semibin.done',
        outdir = '{sample}/semibin'
    params:
        tmpdir = config["tmp_dir"],
        threads = config["semibin"]["threads"],
        min_contig_length = config["binning"]["min_contig_length"],
        environment_type = config["semibin"]["environment_type"]
    conda: "../../../envs/semibin2_env.yml"
    benchmark: "{sample}/benchmarks/semibin2.txt"
    log: "{sample}/logs/semibin2.txt"
    shell:
        """
        SemiBin2 \ 
        single_easy_bin \
        --tmpdir {params.tmpdir} \
        --engine auto \
        -m {params.min_contig_length} \
        --input-fasta {input.fasta} \
        --input-bam {input.bam} \
        --environment {params.environment_type} \
        --output {output.outdir}

        touch {output.done}
        """
