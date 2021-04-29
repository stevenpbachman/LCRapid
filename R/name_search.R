#' Search plant name against GBIF, KNMS and POWO names backbone.
#'
#' Perform a fuzzy search against three names lists to get best
#' match and POWO taxonomic status.
#'
#' @param name A scientific plant species name. Better results can be obtained
#'     when author is included e.g. Poa annua L.
#'
#' @param homosyn_replace If matched name is classified as a homotypic synonym, the
#'  accepted name is returned
#'
#' @return Returns a data frame with ...
#'
#' @examples
#' # single name search
#' name_search("Poa annua L.")
#'
#' # Or, search multiple names using purrr::map_dfr
#' names <- c("Poa annua L.", "Welwitschia mirabilis Hook.f.", "Acacia torrei")
#'
#' if (requireNamespace("purrr", quietly = TRUE)) {
#' names_out <- purrr::map_dfr(names, name_search)
#' }
#'
#' # if your matched name is a homotypic synonym, you can replace it with the WCVP accepted name
#' # Results retain the original search name, and all other fields are replaced with the accepted name
#' name_search("Acacia torrei", homosyn_replace = TRUE)
#'
#' # and same for multiple species
#' if (requireNamespace("purrr", quietly = TRUE)) {
#' names_out <- purrr::map_dfr(names, name_search, homosyn_replace = TRUE)
#' }

#'
#' @keywords GBIF, KNMS, Plants of the World Online
#'
#' @import dplyr
#' @importFrom kewr match_knms lookup_wcvp tidy
#' @importFrom rlang .data
#'
#' @export

name_search = function(name, homosyn_replace = F){

  # set up default results table
  default_tbl = name_tbl_(name)

  # first search - fuzzy matching to GBIF names backbone
  gbif_result = name_search_gbif(name)

  # catch when search term is too vague or non-plant
  if (is.na(gbif_result$usageKey)[1]) {
  return(default_tbl)
  }

  # second search - plug search results into KNMS to get match against Kew names lists
  knms_check = match_knms(gbif_result$scientificName)
  knms_check = tidy(knms_check)

  # join up the results
  gbif_knms = left_join(gbif_result, knms_check, by=c("scientificName"="submitted"))

  # check if there were ANY matches in KNMS - if not return GBIF
  if (!any(gbif_knms$matched)) {

    # and filter on maximum confidence from GBIF search
    # ensures there is only one result
    gbif_knms = slice_max(gbif_knms, .data$confidence, n=1)

    # return only the GBIF results
    results = rename(gbif_knms,
                     GBIF_key = usageKey,
                     GBIF_name = scientificName,
                     GBIF_rank = rank,
                     GBIF_confidence = confidence,
                     GBIF_family = family,
                     WCVP_matched = matched,
                     WCVP_ipni_id = ipni_id,
                     WCVP_record = matched_record)
    results$WCVP_status = NA_character_
    results$WCVP_name = NA_character_

    return(results)
  }

  # filter only on those that matched KNMS
  gbif_knms = filter(gbif_knms, .data$matched == "TRUE")

  # remove duplicates if KNMS matched more than one
  gbif_knms = distinct(gbif_knms, .data$ipni_id, .keep_all = TRUE)

  # and filter on maximum confidence from GBIF search
  # ensures there is only one result
  gbif_knms = slice_max(gbif_knms, .data$confidence, n=1)

  # third search - check WCVP status
  wcvp_check = lookup_wcvp(gbif_knms$ipni_id)
  wcvp_check = tidy(wcvp_check)

  # get taxonomic status and names
  wcvp_check = select(wcvp_check, .data$id, .data$status, .data$name, .data$authors)

  # check if homotypic synonym and if user wants to replace with accepted
  if (homosyn_replace & wcvp_check$status == "homotypic synonym") {

    wcvp_check = lookup_wcvp(wcvp_check$id)
    acc = paste(wcvp_check$accepted$name, wcvp_check$accepted$author, sep = " ")

    results = name_search(acc)
    results = mutate(results, searchName = name)

    return(results)


  }

  # join up the binomial and author strings
  wcvp_check = tidyr::unite(wcvp_check, name, c(name, authors), sep = " ")

  # join up results again
  results = left_join(gbif_knms, wcvp_check, by=c("ipni_id"="id"))

  # rename the results for clarity
  results = rename(results, GBIF_key = usageKey,
                   GBIF_name = scientificName,
                   GBIF_rank = rank,
                   GBIF_confidence = confidence,
                   GBIF_family = family,
                   WCVP_matched = matched,
                   WCVP_ipni_id = ipni_id,
                   WCVP_record = matched_record,
                   WCVP_status = status,
                   WCVP_name = name)

  return(results)
}

#' Generate the default table for name search results
#'
#' @importFrom tibble tibble
#'
#' @noRd
name_tbl_ = function(query) {
  tibble(
    searchName = query,
    GBIF_key = NA_integer_,
    GBIF_name = NA_character_,
    GBIF_rank = NA_character_,
    GBIF_confidence = NA_integer_,
    GBIF_family = NA_character_,
    WCVP_matched = NA,
    WCVP_ipni_id = NA_character_,
    WCVP_record = NA_character_,
    WCVP_status = NA_character_,
    WCVP_name = NA_character_
  )
}
