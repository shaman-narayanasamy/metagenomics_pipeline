rule bedtools_gene_coverage:
    input:
        bed = lambda wildcards: config["catalogues"][wildcards.catalogue]["bed"],
        bam = '{catalogue}/alignments/{sample}/{sample}.reads.sorted.bam'
    output:
        "{catalogue}/gene_coverage/{sample}.tsv"
    threads: 8
    conda: "../../../envs/bedtools_env.yml"
    benchmark: "{catalogue}/gene_coverage/benchmarks/{sample}.txt"
    log: "{catalogue}/gene_coverage/logs/{sample}.log"
    shell:
        """
        mkdir -p {wildcards.catalogue}/gene_coverage 
        bedtools coverage -a {input.bed} -b {input.bam} -d \
        | awk '{{key=$1"\\t"$2"\\t"$3"\\t"$4"\\t"$6; depth[key][7]+=$8; depth[key][8]+=($8>0); depth[key][9]=$3-$2}} 
                END{{for (k in depth) print k, depth[k][7], depth[k][8], depth[k][9]}}' OFS="\\t" \
        > {output}
        """
