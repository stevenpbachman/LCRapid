#' @title Search plant name against GBIF names backbone
#'
#' @description This function uses the \code{rgbif} package \url{https://docs.ropensci.org/rgbif/index.html}
#'     to query a scientific plant name against the GBIF names backbone - see \url{https://www.gbif.org/}.
#'     It restricts the result to species rank constrained to kingdom = 'Plantae'.
#'     This function uses the \code{rgbif::name_backbone_verbose} function.
#' @param name A scientific plant species name. Better results can be obtained
#'     when author is included e.g. Poa annua L.
#' @keywords GBIF
#' @export
#' @return Returns a data frame with initial search term \code{searchName}, GBIF taxon key \code{usageKey}, GBIF scientific
#'     name \code{scientificName}, and a measure of \code{confidence} in the match. When there is no match it returns a value
#'      of "no_match" under the \code{confidence} field.
#' @examples
#' # single name search
#' name_search_gbif("Poa annua L.")
#'
#' # Or, search multiple names using purrr::map_dfr
#' names <- c("Poa annua L.", "Welwitschia mirabilis Hook.f.")
#'
#' #names_out <- purrr::map_dfr(names, name_search_gbif)

# add this for testing: "Aragalus casteteri"

name_search_gbif = function (name) {

  # set up the data.frame
  options = data.frame(
    usageKey = NA_integer_,
    scientificName = NA_character_,
    confidence = NA_integer_,
    family = NA_character_
  )

  # search using verbose to get fuzy alternatives
  gbif_results = rgbif::name_backbone_verbose(
    name = name,
    rank = 'species',
    kingdom = 'Plantae',
    strict = FALSE
  )

  # bind together in case there are missing data
  merged = dplyr::bind_rows(gbif_results$alternatives, gbif_results$data)

  # catch when search term is too vague or non-plant
  if (merged$matchType[1] == "HIGHERRANK") {

    options = data.frame(
      searchName = name,
      usageKey = NA_integer_,
      scientificName = name,
      confidence = "no_match",
      family = NA_character_,
      stringsAsFactors = FALSE
    )

  }

  else {

  options = merged %>%
    # in case higher ranks are returned
    dplyr::filter(rank=="SPECIES") %>%
    # match to options df
    dplyr::select(colnames(options)) %>%
    # show highest confidence match first
    dplyr::arrange(desc(confidence))

  # add the initial search term
  options$searchName = name

  options = dplyr::select(options, c(searchName, usageKey, scientificName, confidence))

  # add warning if name matched to multiple

  }

  return(options)

}
