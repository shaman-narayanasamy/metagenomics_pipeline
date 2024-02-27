rule metabat2:
    input:
        fasta = "{sample}/megahit_assembly/final.contigs.fa",
        bam = '{sample}/{sample}.reads.sorted.bam',
        bai = '{sample}/{sample}.reads.sorted.bai'
    output:
    params:
        threads = config["metabat2"]["threads"]
    conda: "../../../envs/metabat2_env.yml"
    benchmark: os.path.join("{sample}/benchmarks/metabat2.txt")
    log: os.path.join("{sample}/logs/metabat2.txt")
    shell:
        """
	runMetaBat.sh -t {params.threads} -s 1000000 ./anmbr_8h/${PREFIX}_spades/${PREFIX}_spa.fa ./anmbr_8h/${PREFIX}_spades/${PREFIX}_1.bam
        """
