rule index_catalogue:
    input:
        gene_catalogue=config["gene_catalogue"]
    output:
        index_dir=directory("salmon/index/gene_catalogue")
    threads: 14
    conda: 
        "../../../../envs/salmon_env.yml"
    container:
        "https://depot.galaxyproject.org/singularity/salmon:1.8.0--h7e5ed60_1"
    benchmark: "salmon/benchmarks/index.txt"
    log: "salmon/log/index.log"
    shell:
        """
        salmon index -t {input.gene_catalogue} -i {output.index_dir} --gencode -p {threads}
        """
