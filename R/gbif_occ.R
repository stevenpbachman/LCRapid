#' Search for GBIF occurrences
#'
#'
#' @param key A GBIF name/taxon key
#'
#' @param gbif_limit Number of records to return
#'
#' @param out_format Format of output file options = gbif(Darwin Core), IUCN SIS, combined (SIS and gbif)
#'
#' @return Returns a data frame with occurrence points
#'
#' @examples
#'
#' @keywords GBIF, KNMS, Plants of the World Online
#'
##' @import dplyr
##' @importFrom kewr match_knms lookup_wcvp tidy
##' @importFrom rlang .data
#'
#' @export

# get gbif format first
# then another script to convert to SIS if needed


get_gbif_points = function(key, gbif_limit, out_format) {
  result_name_map <- c(
    BasisOfRec = "basisOfRecord",
    DEC_LAT = "decimalLatitude",
    DEC_LONG = "decimalLongitude",
    EVENT_YEAR = "year",
    BINOMIAL = "scientificName",
    CATALOG_NO = "catalogNumber"
  )

  results = tibble(
    basisOfRecord = NA_character_,
    scientificName = NA_character_,
    decimalLatitude = -999,
    decimalLongitude = -999,
    year = -999L,
    catalogNumber = NA_character_,
    SPATIALREF = "WGS84",
    PRESENCE = "1",
    ORIGIN = "1",
    SEASONAL = "1",
    DATA_SENS = "No",
    SOURCE = NA_character_,
    YEAR = NA_character_,
    COMPILER = NA_character_,
    CITATION = NA_character_,
    recordedBy = NA_character_,
    recordNumber = NA_character_,
    issues = NA_character_,
    datasetKey = NA_character_
  )

  if (key != "" & !is.na(key)) {
    gbif_results <- occ_data(
      taxonKey = key,
      hasGeospatialIssue = FALSE,
      hasCoordinate = TRUE,
      limit = gbif_limit
    )

    results_count <- gbif_results$meta$count
  } else {
    results_count <- 0
  }

  if (results_count > 0) {
    gbif_points <- gbif_results$data
  } else {
    gbif_points <- results
  }

  if (nrow(gbif_points) > 0) {
    columns_to_add = setdiff(colnames(results), colnames(gbif_points))
    default_data = as.list(results)
    gbif_points = tibble::add_column(gbif_points,!!!default_data[columns_to_add])

    gbif_points$YEAR = format(Sys.Date(), "%Y")
    gbif_points$SOURCE = paste0("https://www.gbif.org/dataset/",
                                gbif_points$datasetKey,
                                sep = "")

    # reformat to iucn standard
    gbif_points = mutate(
      gbif_points,
      basisOfRecord = recode(
        basisOfRecord,
        "FOSSIL_SPECIMEN" = "FossilSpecimen",
        "HUMAN_OBSERVATION" = "HumanObservation",
        "LITERATURE" = "",
        "LIVING_SPECIMEN" = "LivingSpecimen",
        "MACHINE_OBSERVATION" = "MachineObservation",
        "OBSERVATION" = "",
        "PRESERVED_SPECIMEN" = "PreservedSpecimen",
        "UNKNOWN" = "Unknown"
      )
    )

    results = select(gbif_points, colnames(results))
  }

  results <- rename(results,!!!result_name_map)
  return(results)
}


#####################################
#' Generate the default table for name search results
#'
#' @importFrom tibble tibble
#'
#' @noRd
result_name_map <- c(
  BasisOfRec = "basisOfRecord",
  DEC_LAT = "decimalLatitude",
  DEC_LONG = "decimalLongitude",
  EVENT_YEAR = "year",
  BINOMIAL = "scientificName",
  CATALOG_NO = "catalogNumber"
  )




