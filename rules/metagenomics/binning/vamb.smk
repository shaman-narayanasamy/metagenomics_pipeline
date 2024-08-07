rule vamb:
    input:
        fasta = os.path.join(input_dir, "{sample}/megahit_assembly/final.contigs.fa"), 
        depth_file = "{sample}/contig_depth.txt"
    output:
        outdir = '{sample}/vamb',
        done = '{sample}/vamb.done'
    params:
        threads = config["vamb"]["threads"],
        min_contig_length = config["binning"]["min_contig_length"]
    conda: "../../../envs/vamb_env.yml"
    benchmark: os.path.join("{sample}/benchmarks/vamb.txt")
    log: os.path.join("{sample}/logs/vamb.txt")
    shell:
        """
        vamb --outdir {output.outdir} \
        --fasta {input.fasta} \
        --jgi {input.depth_file} \
        -m 1000 \
        --cuda

        touch {output.done}
        """
