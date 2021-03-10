
<!-- README.md is generated from README.Rmd. Please edit that file -->

# LCRapid

<!-- badges: start -->

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
#> # A tibble: 1 x 9
#>   searchName   usageKey scientificName confidence family  matched ipni_id 
#>   <chr>           <int> <chr>               <int> <chr>   <lgl>   <chr>   
#> 1 Poa annua L.  2704179 Poa annua L.          100 Poaceae TRUE    320035-2
#> # ... with 2 more variables: matched_record <chr>, status <chr>

#get_points()
#etc...
```
