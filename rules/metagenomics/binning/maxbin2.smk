rule maxbin2:
    input:
        fasta = os.path.join(input_dir, "{sample}/megahit_assembly/final.contigs.fa"), 
        depth_file = "{sample}/contig_depth.txt"
    output:
        done = '{sample}/maxbin2.done',
        outdir = '{sample}/maxbin2'
    params:
        threads = config["maxbin2"]["threads"],
        min_contig_length = config["binning"]["min_contig_length"]
    conda: "../../../envs/maxbin2_env.yml"
    benchmark: os.path.join("{sample}/benchmarks/maxbin2.txt")
    log: os.path.join("{sample}/logs/maxbin2.txt")
    shell:
        """
	run_MaxBin.pl -contig {input.fasta} \
        -thread {params.threads} \
        -abund {input.depth_file} \
        -min_contig_length {params.min_contig_length} \
        -out {output.outdir}
        touch {output.done}
        """
