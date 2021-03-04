#' Search plant name against GBIF names backbone
#'
#' This function uses the \code{rgbif} package \url{https://docs.ropensci.org/rgbif/index.html}
#' to query a scientific plant name against the GBIF names backbone - see \url{https://www.gbif.org/}.
#' It restricts the result to species rank constrained to kingdom = 'Plantae'.
#' This function uses the \code{rgbif::name_backbone_verbose} function.
#'
#' @param name A scientific plant species name. Better results can be obtained
#'     when author is included e.g. Poa annua L.
#'
#' @return Returns a data frame with initial search term \code{searchName}, GBIF taxon key \code{usageKey}, GBIF scientific
#'     name \code{scientificName}, and a measure of \code{confidence} in the match. When there is no match it returns a value
#'      of "no_match" under the \code{confidence} field.
#'
#' @examples
#' # single name search
#' name_search_gbif("Poa annua L.")
#'
#' # Or, search multiple names using purrr::map_dfr
#' names <- c("Poa annua L.", "Welwitschia mirabilis Hook.f.")
#'
#' #names_out <- purrr::map_dfr(names, name_search_gbif)
#'
#' @keywords GBIF
#'
#' @import dplyr
#' @importFrom rlang .data
#' @importFrom rgbif name_backbone_verbose
#'
#' @export

# add this for testing: "Aragalus casteteri"

name_search_gbif = function (name) {

  # set up default results table
  default_tbl = gbif_name_tbl_(name)

  # search using verbose to get fuzzy alternatives
  matches = name_backbone_verbose(
    name = name,
    rank = 'species',
    kingdom = 'Plantae',
    strict = FALSE
  )

  # bind together in case there are missing data
  matches = bind_rows(matches$alternatives, matches$data)

  no_match = all(matches$matchType == "NONE")
  all_higher = all(matches$matchType == "HIGHERRANK")

  # catch when search term is too vague or non-plant
  if (no_match | all_higher) {
    results = default_tbl
  } else {
    results = filter(matches, .data$rank == "SPECIES")

    results$searchName = name

    results = select(results, colnames(default_tbl))
    results = arrange(results, desc(.data$confidence))
  }

  results
}

#' Generate the default table for GBIF name search results
#'
#' @importFrom tibble tibble
#'
#' @noRd
gbif_name_tbl_ = function(query) {
  tibble(
    searchName = query,
    usageKey = NA_integer_,
    scientificName = NA_character_,
    confidence = NA_integer_,
    family = NA_character_
  )
}
