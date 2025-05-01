rule concatenate_all_seqs:
    input:
        catalogue=lambda wildcards: config["catalogues"][wildcards.catalogue]["fasta"],
    output:
        catalogue="{catalogue}/concatenated_catalogue.fa"
    shell:
        """
            echo "{input.catalogue} is not a directory. Only soft-linking..."
            ln -fs {input.catalogue} {output.catalogue}
        """
#        if [ -d {input.catalogue} ]; then
#            echo "{input.catalogue} is a directory. Concatenating..."
#            cat {input.catalogue}/*/*.{params.extension} > {output.catalogue}
#        else
        #fi

