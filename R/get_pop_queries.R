#' Get Population Data (Multiple)
#'
#' @description
#' This function is a wrapper for the \href{https://docs.onemap.sg/#population-query}{Population Query API}. It is similar to \code{\link{get_pop_query}} but allows for querying of multiple data types for multiple towns and years.
#'
#' @param token User's API token. This can be retrieved using \code{\link{get_token}}
#' @param data_types Type of data to be retrieved, should correspond to one of the API endpoints. E.g. to get economic status data, \code{data_type = "getEconomicStatus"}. The API endpoints can be found on the documentation page.
#' @param planning_areas Town for which the data should be retrieved.
#' @param years Year for which the data should be retrieved.
#' @param gender Optional, if specified only records for that gender will be returned. This parameter is only valid for the \code{"getEconomicStatus"}, \code{"getEthnicGroup"}, \code{"getMaritalStatus"} and \code{"getPopulationAgeGroup"} endpoints. If specified for other endpoints, the parameter will be dropped.
#' @param sleep Optional sleep time for iterative calls
#' @return A tibble with each row representing a town in a particular year for a particular gender, and columns with the variables returned by the API endpoint.
#' If any API call returns no data, the values will be NA but the row will be returned. However, if all data_types do not return data for that town and year, no row will be returned for it.
#'
#' @export
#'
#' @examples
#' # output with no NA
#' \donttest{get_pop_queries(token, c("getOccupation", "getLanguageLiterate"), c("Bedok", "Yishun"), "2010")}
#' \donttest{get_pop_queries(token, c("getEconomicStatus", "getEthnicGroup"), "Yishun", "2010", "female")}
#'
#' ## note behaviour if data types is a mix of those that accept gender params
#' ### only total will have all records
#' \donttest{get_pop_queries(token, c("getEconomicStatus", "getOccupation", "getLanguageLiterate"),
#'     "Bedok", "2010")}
#' ### data type that does not accept gender params will be in gender = Total
#' \donttest{get_pop_queries(token, c("getEconomicStatus", "getOccupation", "getLanguageLiterate"),
#'     "Bedok", "2010", gender = "female")}
#'
#' # output with some town-year queries without record due to no data
#' \donttest{get_pop_queries(token, c("getEconomicStatus", "getOccupation"),
#'     "Bedok", c("2010", "2012"))} # no records for 2012


get_pop_queries <- function(token, data_types, planning_areas, years, gender = NULL, sleep = NULL) {

  # make tibble of query params
  query_params = crossing(planning_areas, years)

  # preallocate output list
  output_list <- as.list(rep(NA, length(data_types)))
  names(output_list) <- as.character(data_types)

  # query params for each data type
  for (i in data_types) {
    query_outputs <- query_params %>%
      pmap(function(planning_areas, years) get_pop_query(token = token, data_type = i, planning_area = planning_areas, year = years, gender = gender, sleep = sleep)) %>%
      reduce(bind_rows)

    output_list[[i]] <- query_outputs
  }

  output <- output_list %>%
    reduce(full_join, by = c("planning_area", "year", "gender"))

  output
}