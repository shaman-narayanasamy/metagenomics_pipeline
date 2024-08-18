rule semibin:
    input:
        fasta = os.path.join(input_dir, "{sample}/megahit_assembly/final.contigs.fa"), 
        bam = os.path.join(input_dir, '{sample}/{sample}.reads.sorted.bam'),
        bai = os.path.join(input_dir, '{sample}/{sample}.reads.sorted.bam.bai'),
        depth_file = "{sample}/contig_depth.txt"
    output:
        done = '{sample}/semibin.done',
        outdir = directory('{sample}/semibin')
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

rule semibin_contig_to_bin:
    input:
        bin_dir = "{sample}/semibin/output_bins"
    output:
        contig_to_bin="{sample}/semibin/contig_to_bin.tsv",
    shadow: "shallow"
    shell:
       """
       gunzip {input.bin_dir}/*.fa.gz

       ls {input.bin_dir}/*.fa | \
       xargs -I{{}} bash -c 'paste <(yes "{{}}" | \
       head -n $(grep -c "^>" {{}})) <(grep "^>" {{}} | \
       sed -e "s/>//g") <(yes "semibin" | \
       head -n $(grep -c "^>" {{}}))' | \
       sed -e 's/\.fa//g' > {output.contig_to_bin}
       """
