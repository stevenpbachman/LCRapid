#' @title Search plant name against GBIF, KNMS and POWO names backbone
#'
#' @description Perform a fuzzy search against three names list to get best match and POWO taxonomic status
#' @param name A scientific plant species name. Better results can be obtained
#'     when author is included e.g. Poa annua L.
#' @keywords GBIF, KNMS, Plants of the World Online
#' @export
#' @return Returns a data frame with ...
#' @examples
#' # single name search
#' name_search("Poa annua L.")
#'
#' # Or, search multiple names using purrr::map_dfr
#' names <- c("Poa annua L.", "Welwitschia mirabilis Hook.f.")
#' names_out <- purrr::map_dfr(names, name_search)

# check Baz methods to get names - include synonyms
# check for homotypic
# matched their names to the WCVP
# updated the accepted names of assessments matched to homotypic synonyms.

name_search = function(name){

  # first search - fuzzy matching to GBIF names backbone
  gbif_result = name_search_gbif(name)

  # second search - plug search results into KNMS to get match against Kew names lists
  knms_check = kewr::match_knms(gbif_result$scientificName)
  knms_format = format(knms_check)

  # join up the results and filter on maximum confidence and remove IPNI ID duplicates
  gbif_knms = dplyr::bind_cols(knms_format, gbif_result) %>%

    # filter only on those that matched KNMS
    dplyr::filter(matched == "TRUE") %>%

    # remove duplicates if KNMS matched more than one
    dplyr::distinct(ipni_id, .keep_all = TRUE) %>%

    # and filter on maximum confidence from GBIF search
    # ensures there is only one result
    dplyr::filter(confidence == max(confidence))

  # third search - check POWO status
  powo_check = kewr::lookup_powo(gbif_knms$ipni_id)
  powo_format = format(powo_check) %>%

    # select the taxonomic status column
    dplyr::select(taxonomicStatus)

  # join up results again
  gbif_knms_powo = dplyr::bind_cols(powo_format, gbif_knms)

  return(gbif_knms_powo)
}



