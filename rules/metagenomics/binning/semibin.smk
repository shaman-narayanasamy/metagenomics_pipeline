rule semibin:
    input:
        fasta = os.path.join(input_dir, "{sample}/megahit_assembly/final.contigs.fa"), 
        bam = os.path.join(input_dir, '{sample}/{sample}.reads.sorted.bam'),
        bai = os.path.join(input_dir, '{sample}/{sample}.reads.sorted.bam.bai'),
        depth_file = "{sample}/contig_depth.txt"
    output:
        done = '{sample}/semibin.done',
        done = '{sample}/metabat2.done',
    params:
        threads = config["metabat2"]["threads"]
        prefix = '{sample}/metabat2/metabat_bin_'
    conda: "../../../envs/metabat2_env.yml"
    benchmark: "{sample}/benchmarks/metabat2.txt"
    log: "{sample}/logs/metabat2.txt"
    shell:
        """
        SemiBin2 \ 
        single_easy_bin \
        --input-fasta {input.fasta} \
        --input-bam {input.bam} \
        --environment {params.environment_type} \
        --output {output}

        touch {output.done}
        """
