rule maxbin2:
    input:
        fasta = "{sample}/megahit_assembly/final.contigs.fa",
        bam = '{sample}/{sample}.reads.sorted.bam',
        bai = '{sample}/{sample}.reads.sorted.bai'
    output:
    params:
        threads = config["maxbin2"]["threads"]
    conda: "../../../envs/maxbin2_env.yml"
    benchmark: os.path.join("{sample}/benchmarks/maxbin2.txt")
    log: os.path.join("{sample}/logs/maxbin2.txt")
    shell:
        """
        """

