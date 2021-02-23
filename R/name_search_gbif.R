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
name_search_gbif = function (name) {

  # set up the data.frame
  options = data.frame(
    usageKey = NA_integer_,
    acceptedUsageKey = NA_character_,
    scientificName = NA_character_,
    rank = NA_character_,
    status = NA_character_,
    confidence = NA_integer_,
    family = NA_character_,
    acceptedSpecies = NA_character_
  )

  # search using verbose to get fuzy alternatives
  gbif_results =rgbif::name_backbone_verbose(
    name = name,
    rank = 'species',
    kingdom = 'Plantae',
    strict = FALSE
  )

  # bind together in case there are missing data
  merged = dplyr::bind_rows(gbif_results$alternatives, gbif_results$data)

  if (nrow(merged) > 1 | merged$matchType[1] != "HIGHERRANK") {
    # change column names
    merged = dplyr::rename(merged, acceptedSpecies=species)

    if (!"acceptedUsageKey" %in% colnames(merged)) {
      merged$acceptedUsageKey = NA_character_
    }

    # subset the data with the fields you want
    options = dplyr::select(merged, colnames(options))

    # arrange table in descending order to show best guess at top of table
    options = dplyr::arrange(options, desc(confidence), status)
  }

  # add the original search name
  options$searchName = name

  options
}
