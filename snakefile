"""
snakemake -n 
snakemake -c 1 --use-singularity --use-conda
"""

rule all:
  input: "converted.vcf.gz"

rule anc_ref:
  input:
    "base.vcf"
  output:
    "snps.tsv"
  shell:
    """
    grep -v "^##" {input} | cut -f 1,2,4,5 > {output}
    """

rule create_bed:
  input: "snps.tsv"
  output: "anc.bed"
  conda: "r_tidy"
  shell:
    """
    Rscript tsv_to_bed.R
    """

rule idx_bed:
  input: "anc.bed"
  output:
    bg = "anc.bed.gz",
    tbi =  "anc.bed.gz.tbi"
  conda: "popgen_basics"
  shell:
    """
    bgzip {input}
    tabix -s 1 -b 2 -e 3 {output.bg}
    """

rule annotate_vcf:
  input:
    vcf = "base.vcf",
    bed = "anc.bed.gz",
    bed_idx = "anc.bed.gz.tbi"
  output:
    vcf = "annotated.vcf"
  conda: "popgen_basics"
  shell:
    """
    cat {input.vcf} | \
      vcf-annotate -a {input.bed} \
        -d key=INFO,ID=AA,Number=1,Type=String,Description='Ancestral Allele' \
        -c CHROM,FROM,TO,INFO/AA > {output.vcf}
    """

rule convert_vcf:
  input:
    vcf = "annotated.vcf"
  output:
    gzvcf = "converted.vcf.gz",
    vcf = "converted.vcf"
  container: "docker://lindenb/jvarkit:1b2aedf24"
  shell:
    """
    java -jar /opt/jvarkit/dist/jvarkit.jar \
      vcffilterjdk \
      -f script.js {input.vcf} | \
      bgzip > {output.gzvcf}
    zcat {output.gzvcf} > {output.vcf}
    """