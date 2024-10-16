rule concatenate_all_seqs:
    input:
        catalogue=lambda wildcards: config["salmon"]["catalogues"][wildcards.catalogue]['path'],
    output:
        catalogue="salmon/{catalogue}/concatenated_catalogue.fa"
    params:
        extension=lambda wildcards: config["salmon"]["catalogues"][wildcards.catalogue]['extension']
    shell:
        """
        if [ -d {input.catalogue} ]; then
            echo "{input.catalogue} is a directory. Concatenating..."
            cat {input.catalogue}/*/*.{params.extension} > {output.catalogue}
        else
            echo "{input.catalogue} is not a directory. Only soft-linking..."
            ln -s {input.catalogue} {output.catalogue}
        fi
        """

rule salmon_index_catalogue:
    input:
        catalogue="salmon/{catalogue}/concatenated_catalogue.fa"
    output:
        index_dir=directory("salmon/{catalogue}/index"),
        fixed_fasta="salmon/{catalogue}/fixed.fasta"
    threads: 14
    conda: 
        "../../../../envs/salmon_env.yml"
    container:
        "https://depot.galaxyproject.org/singularity/salmon:1.8.0--h7e5ed60_1"
    benchmark: "salmon/{catalogue}/benchmark/index.txt"
    log: "salmon/{catalogue}/log/index.log"
    shell:
        """
        mkdir -p {output.index_dir}

        cat {input.catalogue} | sed -e 's/ //g' | \
        sed -e 's/|/_/g' > {output.fixed_fasta}

        salmon index -t {output.fixed_fasta} \
        -i {output.index_dir} --gencode -p {threads}
        """
