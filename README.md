
<!-- README.md is generated from README.Rmd. Please edit that file -->

# LCRapid

<!-- badges: start -->

<!-- badges: end -->

The goal of LCRapid is to generate a rapid Least Concern Red List
assessment for plant species

## Installation

You can install the released version of LCRapid from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("LCRapid")
```

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("stevenpbachman/LCRapid")
```

## Example

This is a basic example which shows you how to solve a common problem:

``` r
library(LCRapid)
## basic example code
name_search_gbif("Poa annua L.")
#> # A tibble: 3 x 9
#>   usageKey acceptedUsageKey scientificName rank  status confidence family
#>      <int>            <int> <chr>          <chr> <chr>       <int> <chr> 
#> 1  2704179               NA Poa annua L.   SPEC~ ACCEP~        100 Poace~
#> 2  8422205          2704194 Poa annua Cha~ SPEC~ SYNON~         83 Poace~
#> 3  7730008               NA Poa annua Ste~ SPEC~ DOUBT~         78 Poace~
#> # ... with 2 more variables: acceptedSpecies <chr>, searchName <chr>
```

What is special about using `README.Rmd` instead of just `README.md`?
You can include R chunks like so:

``` r
summary(cars)
#>      speed           dist       
#>  Min.   : 4.0   Min.   :  2.00  
#>  1st Qu.:12.0   1st Qu.: 26.00  
#>  Median :15.0   Median : 36.00  
#>  Mean   :15.4   Mean   : 42.98  
#>  3rd Qu.:19.0   3rd Qu.: 56.00  
#>  Max.   :25.0   Max.   :120.00
```

You’ll still need to render `README.Rmd` regularly, to keep `README.md`
up-to-date.

You can also embed plots, for example:

<img src="man/figures/README-pressure-1.png" width="100%" />

In that case, don’t forget to commit and push the resulting figure
files, so they display on GitHub\!
