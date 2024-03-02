rule concoct_cut_contigs:
    input:
        fasta = os.path.join(input_dir, "{sample}/megahit_assembly/final.contigs.fa"), 
        bam = os.path.join(input_dir, '{sample}/{sample}.reads.sorted.bam'),
#        bai = os.path.join(input_dir, '{sample}/{sample}.reads.sorted.bai')
    output:
        split_contigs_fasta = "{sample}/binning/concoct/split_contigs_len-%s.fa" % config["concoct"]["contig_split_length"],
        split_contigs_bed = "{sample}/binning/concoct/split_contigs_len-%s.bed" % config["concoct"]["contig_split_length"]
    params:
        contig_split_length = config["concoct"]["contig_split_length"]
    conda: "../../../envs/concoct_env.yml"
    benchmark: os.path.join("{sample}/benchmarks/concoct_cut_contigs.txt")
    log: os.path.join("{sample}/logs/concoct_cut_contigs.txt")
    shell:
        """
        cut_up_fasta.py {input.fasta} -c {params.contig_split_length} -o 0 --merge_last -b {output.split_contigs_bed} > {output.split_contigs_fasta}
        """

rule concoct_coverage_table:
    input:
        split_contigs_fasta = "{sample}/binning/concoct/split_contigs_len-%s.fa" % config["concoct"]["contig_split_length"],
        split_contigs_bed = "{sample}/binning/concoct/split_contigs_len-%s.bed" % config["concoct"]["contig_split_length"],
        bam = os.path.join(input_dir, '{sample}/{sample}.reads.sorted.bam'),
#        bai = '{sample}/{sample}.reads.sorted.bai'
    output:
        coverage_table = "{sample}/binning/concoct/split_contigs_len-%s_coverage_table.tsv" % config["concoct"]["contig_split_length"]
    params:
        contig_split_length = config["concoct"]["contig_split_length"]
    conda: "../../../envs/concoct_env.yml"
    benchmark: os.path.join("{sample}/benchmarks/concoct_coverage_table.txt")
    log: os.path.join("{sample}/logs/concoct_coverage_table.txt")
    shell:
        """
        concoct_coverage_table.py {input.split_contigs_fasta} {input.bam} > {output.coverage_table}
        """

rule concoct:
    input:
        split_contigs_fasta = "{sample}/binning/concoct/split_contigs_len-%s.fa" % config["concoct"]["contig_split_length"],
        coverage_table = "{sample}/binning/concoct/split_contigs_len-%s_coverage_table.tsv" % config["concoct"]["contig_split_length"]
    output:
        outdir = directory("{sample}/binning/concoct/results")
    params:
        threads = config["concoct"]["threads"],
        contig_min_length = config["concoct"]["contig_min_length"]
    conda: "../../../envs/concoct_env.yml"
    benchmark: os.path.join("{sample}/benchmarks/concoct.txt")
    log: os.path.join("{sample}/logs/concoct.txt")
    shell:
        """
        concoct --composition_file {input.split_contigs_fasta} -l {params.contig_min_length} \
        --coverage_file {input.coverage_table} -b {output.outdir}/binning
        """

rule concoct_merge_clusters:
    input:
        outdir = "{sample}/binning/concoct/results",
        fasta = os.path.join(input_dir, "{sample}/megahit_assembly/final.contigs.fa"), 
    output:
        merged_table = "{sample}/binning/concoct/bins/clustering_merged.csv",
        bin_dir = directory("{sample}/binning/concoct/bins")
    conda: "../../../envs/concoct_env.yml"
    benchmark: os.path.join("{sample}/benchmarks/concoct_merge_clusters.txt")
    log: os.path.join("{sample}/logs/concoct_merge_clusters.txt")
    shell:
        """
        merge_cutup_clustering.py {input.outdir}/binning.csv > {output.merged_table}
        mkdir {output.bin_dir}
        extract_fasta_bins.py {input.fasta} {output.merged_table} --output_path {output.bin_dir}
        """



