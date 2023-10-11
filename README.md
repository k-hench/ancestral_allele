# minimal example swappin reference and ancestral allele 

run `snakemake`:

```sh
snakemake -c 1 --use-singularity --use-conda
```

Note that the info of the ancestral alleles are hidden within the `R` script:

```R
AA = c( "C", "C", "C")
```

(In real life this will be added using `letf_join()` with the `halSnps` summary from the `cactus` output.)

After running the `snakemake` pipeline compare the original input (`base.vcf`) withe the final version (`converted.vcf`):

```sh
grep -v "^##" base.vcf | cut -f 1,2,4,5,10-
#> #CHROM  POS     REF     ALT     sample1 sample2
#> chr1    11      T       C       0/1:30  0/0:30
#> chr1    14      A       C       0/1:30  0/0:30
#> chr14   17      C       A       0/0:30  0/1:30
```

```sh
grep -v "^##" converted.vcf | cut -f 1,2,4,5,10-
#> #CHROM  POS     REF     ALT     sample1 sample2
#> chr1    11      C       T       1/0:30  1/1:30
#> chr1    14      C       A       1/0:30  1/1:30
#> chr14   17      C       A       0/0:30  0/1:30
```