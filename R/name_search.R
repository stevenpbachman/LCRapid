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
#' names <- c("Poa annua L.", "Welwitschia mirabilis Hook.f.")
#'
#' if (requireNamespace("purrr", quietly = TRUE)) {
#' names_out <- purrr::map_dfr(names, name_search)
#' }
#'
#' # if your matched name is a homotypic synonym, you can replace it with the WCVP accepted name
#' name_search("Acacia torrei")

#'
#' @keywords GBIF, KNMS, Plants of the World Online
#'
#' @import dplyr
#' @importFrom kewr match_knms lookup_wcvp tidy
#' @importFrom rlang .data
#'
#' @export

# for WCVP - if match = homotypic synonym, also get the accepted name?

name_search = function(name, homosyn_replace = F){

  # set up default results table
  default_tbl = name_tbl_(name)

  # first search - fuzzy matching to GBIF names backbone
  gbif_result = name_search_gbif(name)

  # catch when search term is too vague or non-plant
  if (is.na(gbif_result$usageKey)[1]) {

  results = default_tbl
  } else {

  # second search - plug search results into KNMS to get match against Kew names lists
  knms_check = match_knms(gbif_result$scientificName)
  knms_check = tidy(knms_check)

  # join up the results
  gbif_knms = left_join(gbif_result, knms_check, by=c("scientificName"="submitted"))

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
  # select the taxonomic status column
  wcvp_check = select(wcvp_check, .data$id, .data$status)

  # join up results again
  results = left_join(gbif_knms, wcvp_check, by=c("ipni_id"="id"))

  # replace homotypic synonym with accepted name
  if (homosyn_replace == TRUE) {

    if (results$status == "homotypic synonym") {

      # get the accepted name
      acc = lookup_wcvp(results$ipni_id)
      acc = paste(acc$accepted$name, acc$accepted$author, sep = " ")

      # now plug back into name search
      results = name_search(acc)

    } else {

      results = results

    }
  }

  results

  }
}

#' Generate the default table for name search results
#'
#' @importFrom tibble tibble
#'
#' @noRd
name_tbl_ = function(query) {
  tibble(
    searchName = query,
    usageKey = NA_integer_,
    scientificName = NA_character_,
    confidence = NA_integer_,
    family = NA_character_,
    matched = NA,
    ipni_id = NA_character_,
    matched_record = NA_character_,
    status = NA_character_
  )
}




