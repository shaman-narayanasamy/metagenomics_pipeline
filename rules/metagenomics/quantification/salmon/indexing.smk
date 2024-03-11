rule index_all_mags:
    input:
        gene_catalogue=config["gene_catalogue"]
    output:
        index_dir=directory("salmon/index/gene_catalogue")
    threads: 14
    conda: 
        "../../../../envs/salmon_env.yml"
    container:
        "https://depot.galaxyproject.org/singularity/salmon:1.8.0--h7e5ed60_1"
    benchmark: "quantification/benchmarks/salmon/index/all.txt"
    log: "quantification/log/salmon/index/all.log"
    shell:
        """
        salmon index -t {input.all_bins} -i {output.index_dir} --gencode -p {threads}
        """
