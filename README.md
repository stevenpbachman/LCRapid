
<!-- README.md is generated from README.Rmd. Please edit that file -->

# LCRapid

<!-- badges: start -->

[![R-CMD-check](https://github.com/barnabywalker/LCRapid/workflows/R-CMD-check/badge.svg)](https://github.com/barnabywalker/LCRapid/actions)
<!-- badges: end -->

An R package to generate a rapid Least Concern Red List assessment for
plant species

## Overview

Quickly determine if a plant species is likely to be non-threatened
(Least Concern - See [IUCN Red List](https://www.iucnredlist.org/)).
Generate minimal documentation for a Least Concern species and submit to
the IUCN Red List via [SIS Connect](https://connect.iucnredlist.org/)
(registration needed)

## Installation

Not yet on [CRAN](https://CRAN.R-project.org), but you can install the
development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("stevenpbachman/LCRapid")
```

## Usage

The workflow is broken into several steps and each step can be run
independently:

1.  `name_search` check name status against taxonomic backbones
2.  `get_points` gather occurrence records
3.  `filter_native` clean points with native range
4.  `calculate_metrics` calculate metrics
5.  `apply_thresholds` assess whether species is Least Concern
6.  `make_files` generate data files or reports

The batch option allows you to run multiple species.

### Getting started

``` r
library(LCRapid)
## check a name against GBIF, Kew Names Matching Service and Plants of the World Online
name_search("Poa annua L.")
#> # A tibble: 1 x 11
#>   searchName   GBIF_key GBIF_name    GBIF_rank GBIF_confidence GBIF_family
#>   <chr>           <int> <chr>        <chr>               <int> <chr>      
#> 1 Poa annua L.  2704179 Poa annua L. SPECIES               100 Poaceae    
#> # ... with 5 more variables: WCVP_matched <lgl>, WCVP_ipni_id <chr>,
#> #   WCVP_record <chr>, WCVP_status <chr>, WCVP_name <chr>

#get_points()
#etc...
```
