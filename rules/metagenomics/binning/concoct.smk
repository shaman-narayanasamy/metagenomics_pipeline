rule concoct:
    input:
        fasta = "{sample}/megahit_assembly/final.contigs.fa",
        bam = '{sample}/{sample}.reads.sorted.bam',
        bai = '{sample}/{sample}.reads.sorted.bai'
    output:
    params:
        threads = config["concoct"]["threads"]
    conda: "../../../envs/concoct_env.yml"
    benchmark: os.path.join("{sample}/benchmarks/concoct.txt")
    log: os.path.join("{sample}/logs/concoct.txt")
    shell:
        """
        """

