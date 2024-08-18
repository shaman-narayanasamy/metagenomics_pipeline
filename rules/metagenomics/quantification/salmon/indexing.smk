rule index_catalogue:
    input:
        gene_catalogue=lambda wildcards: config["salmon"]["catalogues"][wildcards.catalogue]
    output:
        index_dir=directory("salmon/index/{catalogue}"),
        fixed_fasta="salmon/index/{catalogue}/fixed.fasta"
    threads: 14
    conda: 
        "../../../../envs/salmon_env.yml"
    container:
        "https://depot.galaxyproject.org/singularity/salmon:1.8.0--h7e5ed60_1"
    benchmark: "salmon/benchmarks/index/{catalogue}_index.txt"
    log: "salmon/log/index/{catalogue}_index.log"
    shell:
        """
        mkdir -p {output.index_dir}

        cat {input.gene_catalogue} | sed -e 's/ //g' | \
        sed -e 's/|/_/g' > {output.fixed_fasta}

        salmon index -t {output.fixed_fasta} \
        -i {output.index_dir} --gencode -p {threads}
        """
