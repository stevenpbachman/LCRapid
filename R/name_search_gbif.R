#' @title Search plant name against GBIF names backbone
#'
#' @description This function uses rgbif package to search a name against the GBIF names backbone.
#' @param name A plant species binomial with or without author e.g. Poa annua L.
#' @keywords GBIF
#' @export
#' @return Returns a data frame with IPNI identifier, binomial, author and accepted status
#' @examples
#' name_search_gbif("Poa annua L.")

# working GBIF name search function
# need this to work with batch - see below
# batch_test = SRLI_combined_MASTER[1:10, 4]
# batch_search <- purrr::map_dfr(batch_test$BRAHMS_orig_name_auth,name_search_gbif)

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
      scientificName = "No match",
      confidence = NA_integer_,
      family = NA_character_
    )

  }

  else {

  options = merged %>%
    dplyr::select(colnames(options)) %>%
    dplyr::arrange(desc(confidence))

  options$searchName = name

  options = dplyr::select(options, c(searchName, usageKey, scientificName, confidence))

  }

  return(options)

}
