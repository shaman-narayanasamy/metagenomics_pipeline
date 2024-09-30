rule vamb:
    input:
        fasta = os.path.join(input_dir, "{sample}/megahit_assembly/final.contigs.fa"), 
        bam = os.path.join(input_dir, '{sample}/{sample}.reads.sorted.bam'),
        bai = os.path.join(input_dir, '{sample}/{sample}.reads.sorted.bam.bai'),
    output:
        outdir = '{sample}/vamb',
        done = '{sample}/vamb.done'
    params:
        threads = config["vamb"]["threads"],
        min_contig_length = config["binning"]["min_contig_length"]
#    conda: "../../../envs/vamb_env.yml"
    container: "/ibex/user/naras0c/VAMB/vamb.sif"
    benchmark: os.path.join("{sample}/benchmarks/vamb.txt")
    log: os.path.join("{sample}/logs/vamb.txt")
    shell:
        """
        rm -rf {output.outdir}

        vamb --outdir {output.outdir} \
        --fasta {input.fasta} \
        --bamfiles {input.bam} \
        -m {params.min_contig_length}

        touch {output.done}
        """
