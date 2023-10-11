library(tidyverse)

data <- read_tsv("snps.tsv")

data |>
  select(`#CHROM`, FROM = POS, TO = POS) |>
  mutate( AA = c( "C", "C", "C") ) |>
  write_tsv("anc.bed")