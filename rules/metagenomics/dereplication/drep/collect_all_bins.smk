rule drep_collect_all_bins:
    input:
        checkfile = expand("{input_dir}/{sample}/magscot/MAGScoT.refined.contig_to_bin.out", input_dir = input_dir, sample = samples),
        sample_bins = expand("{input_dir}/{sample}/magscot_bins", input_dir = input_dir, sample=samples),
    output:
        bins = "bin_paths.txt"
    threads: 1
    benchmark: "benchmarks/collect_all_bins.txt"
    log: "logs/collect_all_bins.txt"
    shell:
        """
        find {input.sample_bins} -type f | grep ".fasta$" > {output.bins}
        """
