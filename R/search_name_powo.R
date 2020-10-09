#' @title Search plant name in POWO
#'
#' @description This function searches Plants of the World Online (http://www.plantsoftheworldonline.org/) and returns name status
#' @param name_in A plant species binomial e.g. Poa annua
#' @keywords POWO
#' @export
#' @return Returns a data frame with IPNI identifier, binomial, author and accepted status
#' @examples
#' search_name_powo('Poa annua')

search_name_powo = function(name_in) {

  powo_results <- tibble::tibble(
    IPNI_ID=NA_character_,
    name=NA_character_,
    author=NA_character_,
    accepted=NA
  )

  # use name full name to search API
  full_url =  paste("http://plantsoftheworldonline.org/api/1/search?q=name:", name_in, sep = "")

  # encode
  full_url = utils::URLencode(full_url)

  # get raw json data
  raw_data <- readLines(full_url, warn = "F", encoding = "UTF-8")

  # organise
  rd = jsonlite::fromJSON(raw_data)

  if (length(rd$results) > 0) {

    # make data frame
    results = rd$results

    # get IPNI ID
    results = dplyr::mutate(results, IPNI_ID=stringr::str_extract(url, "(?<=names\\:)[\\d\\-]+$"))

    # only include these fields - you don't want synonym of
    powo_results = dplyr::select(results, colnames(powo_results))
  }

  return(powo_results)

}
