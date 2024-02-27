rule vamb:
    input:
        fasta = "{sample}/megahit_assembly/final.contigs.fa",
        bam = '{sample}/{sample}.reads.sorted.bam',
        bai = '{sample}/{sample}.reads.sorted.bai'
    output:
    params:
        threads = config["vamb"]["threads"]
    conda: "../../../envs/vamb_env.yml"
    benchmark: os.path.join("{sample}/benchmarks/vamb.txt")
    log: os.path.join("{sample}/logs/vamb.txt")
    shell:
        """
        """

