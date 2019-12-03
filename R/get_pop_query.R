#' Get Population Data
#'
#' @description
#' This function is a wrapper for the \href{https://docs.onemap.sg/#population-query}{Population Query API}. It only allows for querying of one data type (i.e. one of the API endpoints) for a particular town and year.
#'
#' @param token User's API token. This can be retrieved using \code{\link{get_token}}
#' @param data_type Type of data to be retrieved, should correspond to one of the API endpoints. E.g. to get economic status data, \code{data_type = "getEconomicStatus"}. The API endpoints can be found on the documentation page.
#' @param planning_area Town for which the data should be retrieved.
#' @param year Year for which the data should be retrieved.
#' @param gender Optional, if specified only records for that gender will be returned. This parameter is only valid for the \code{"getEconomicStatus"}, \code{"getEthnicGroup"}, \code{"getMaritalStatus"} and \code{"getPopulationAgeGroup"} endpoints. If specified for other endpoints, the parameter will be dropped.
#' @param sleep Optional sleep time for iterative calls
#' @return A tibble with 1 row and values for all the corresponding variables returned by the API endpoint.
#' If gender is not specified for endpoints with a gender parameter, records for total, male and female will be returned. The notable exception to this is for the \code{"getEthnicGroup"} endpoint, which only returns the total record if gender is not specified. This is because by default, this is the only API endpoint with a gender parameter that does not return gender breakdown by default.
#' If an error occurs, the function will return a NULL value
#' @export
#'
#' @examples
#' # returns data
#' \donttest{get_pop_query(token, "getOccupation", "Bedok", "2010")}
#' \donttest{get_pop_query(token, "getEthnicStatus", "Central", "2010")}
#' \donttest{get_pop_query(token, "getMaritalStatus", "Central", "2010")}
#' \donttest{get_pop_query(token, "getEconomicStatus", "Yishun", "2010", "female")}
#'
#' # returns NULL, warning message shows status code
#' \donttest{get_pop_query("invalid_token", "getOccupation", "Bedok", "2010")}
#'
#' # returns NULL, warning message shows the error
#' \donttest{get_pop_query(token, "getInvalidData", "Bedok", "2010")}
#' \donttest{get_pop_query(token, "getOccupation", "Bedok", "fakeyear")}
#' \donttest{get_pop_query(token, "getReligion", "faketown", "2010")}


get_pop_query <- function(token, data_type, planning_area, year, gender = NULL, sleep = NULL) {
  # clean planning_area
  planning_area <- str_replace(planning_area, " ", "+")

  # query API
  url <- "https://developers.onemap.sg/privateapi/popapi/"
  query <- paste(url, data_type, "?",
                 "token=", token,
                 "&planningArea=", planning_area,
                 "&year=", year,
                 "&gender=", gender,
                 sep = "")

  response <- GET(query)
  if (!is.null(sleep)) {Sys.sleep(sleep)}

  # error handling
  if (http_error(response)) {
    status <- status_code(response)
    output <- NULL
    warning(paste("The request produced a", status, "error", sep = " "))

  } else {
    output <- content(response)

    # error check: invalid parameters
    if ("error" %in% names(output)) {
      warning(output$error)
      output <- NULL

    } else if (class(output) == "character") {
      warning(output)
      output <- NULL

    # error check: no results
    } else if ("Result" %in% names(output)) {
      warning(output$Result)
      output <- NULL

    # else return output
    } else {
      # replace NULLs with NA so tibble is of consistent length
      output <- output %>%
        map(function(i) map(i, function(j) ifelse(is.null(j), NA, j))) %>%

      # bind rows and turn into tibble
        reduce(bind_rows) %>% as_tibble()

      # attach gender = Total for output without gender,
      # and ensure if gender is not specified, Total data is returned - i.e. fix Economic Status and Marital Status
      if (data_type %in% c("getEconomicStatus", "getMaritalStatus")) {
        if (is.null(gender)) {
          output <- output %>%
            select(planning_area, year, gender, everything())
          total <- colSums(output[ , -(1:3)], na.rm = FALSE) %>%
            t() %>% as_tibble() %>%
            mutate(planning_area = planning_area,
                   year = as.integer(year),
                   gender = "Total") %>%
            select(planning_area, year, gender, everything())

          output <- output %>%
            bind_rows(total)
        }

      } else if (!(data_type %in% c("getEthnicGroup", "getPopulationAgeGroup") & !is.null(gender))) {
        output <- output %>% mutate(gender = "Total")
      }
    }

  }

  output

}
