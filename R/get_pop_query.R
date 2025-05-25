#' Get Population Data
#'
#' @description
<<<<<<< Updated upstream
#' This function is a wrapper for the \href{https://docs.onemap.sg/#population-query}{Population Query API}. It only allows for querying of one data type (i.e. one of the API endpoints) for a particular town and year.
=======
#' This function is a wrapper for the \href{https://www.onemap.gov.sg/apidocs/populationquery}{Population Query API}. It only allows for querying of one data type (i.e. one of the API endpoints) for a particular town and year.
>>>>>>> Stashed changes
#'
#' @param token User's API token. This can be retrieved using \code{\link{get_token}}
#' @param data_type Type of data to be retrieved, should correspond to one of the API endpoints. E.g. to get economic status data, \code{data_type = "getEconomicStatus"}. The API endpoints can be found on the documentation page.
#' @param planning_area Town for which the data should be retrieved.
#' @param year Year for which the data should be retrieved.
#' @param gender Optional, valid values include \code{male} and \code{female}. If specified, only records for that gender will be returned. This parameter is only valid for the \code{"getEconomicStatus"}, \code{"getEthnicGroup"}, \code{"getMaritalStatus"} and \code{"getPopulationAgeGroup"} endpoints. If specified for other endpoints, the parameter will be dropped. If gender is not specified for valid endpoints, records for total, male and female will be returned.
#' @return A tibble with 1 row and values for all the corresponding variables returned by the API endpoint.
#' If an error occurs, the function returns NULL and a warning message. This differs from the error handling of other functions in this package to prevent collective failure for \code{get_pop_queries}.
#'
#' @export
#'
#' @examples
#' # output with no NA
#' \dontrun{get_pop_query(token, "getReligion", "Yishun", "2010")}
#' \dontrun{get_pop_query(token, "getModeOfTransportSchool", "Bishan", "2015", "female")}
#'
#' # if gender parameter is not specified, results for both genders and total will be returned
#' \dontrun{get_pop_query(token, "getMaritalStatus", "Bedok", "2010")}
#' \dontrun{get_pop_query(token, "getEthnicGroup", "Bedok", "2010")}
#' \dontrun{get_pop_query(token, "getPopulationAgeGroup", "Bedok", "2010")}
#'
#' # output due to error
#' \dontrun{get_pop_query(token, "getSpokenAtHome", "Bedok", "2043")}
#'

get_pop_query <- function(token, data_type, planning_area, year, gender = NULL) {

  # query API
  url <- str_c("https://www.onemap.gov.sg/api/public/popapi/", data_type)

  req <- request(url) |>
    req_url_query(planningArea = planning_area, year = year, gender= gender) |>
    req_auth_bearer_token(token) |>
    req_error(is_error= \(resp) FALSE)

  response <- req_perform(req)
  output <- resp_body_json(response)

  # error handling
  if ("message" %in% names(output)) {
    warning(str_c("The request returned an error message: ", output$message), " Status Code: ", resp_status(response))
    output <- NULL
<<<<<<< Updated upstream
    warning(paste("The request (", data_type , "/", planning_area, "/", year, "/", gender, ") ",
                  "produced a ",
                  status, " error", sep = ""))

  } else {
    output <- content(response)
    # error check: invalid parameters
    if ("error" %in% names(output)) {
      warning("The request (", data_type , "/", planning_area, "/", year, "/", gender, ") ",
              "produced an error: ",
              output$error)
      output <- NULL

    } else if (class(output) == "character") {
      warning("The request (", data_type , "/", planning_area, "/", year, "/", gender, ") ",
              "produced an error: ",
              output)
      output <- NULL

    # error check: no results
    } else if ("Result" %in% names(output)) {
      warning("The request (", data_type , "/", planning_area, "/", year, "/", gender, ") ",
              "produced an error: ",
              output$Result)
      output <- NULL

    # else return output
    } else {
      # replace NULLs with NA so tibble is of consistent length
      output <- output %>%
        map(function(i) map(i, function(j) ifelse(is.null(j), NA, j))) %>%

      # bind rows and turn into tibble
        reduce(bind_rows) %>% as_tibble()

      # endpoints which allow gender parameter have different return behaviour when gender=NULL
      # getPopulationAgeGroup returns total, male & female
      # getEconomicStatus and getMaritalStatus returns only male & female
      # getEthnicGroup only returns total and does not include the gender parameter
      # this code block standardises output to include total, male & female

      if (is.null(gender) & data_type %in% c("getEconomicStatus", "getMaritalStatus")) {
        output <- output %>%
          select(planning_area, year, gender, everything())
        total <- colSums(output[ , -(1:3)], na.rm = FALSE) %>%
          t() %>% as_tibble() %>%
          mutate(planning_area = str_to_title(planning_area),
                 year = as.integer(year),
                 gender = "Total") %>%
          select(planning_area, year, gender, everything())

        output <- output %>%
          bind_rows(total)

      } else if (data_type == "getEthnicGroup" & is.null(gender)) {
          output <- output %>%
            mutate(gender = "Total") %>%
            bind_rows(get_pop_query(token, data_type, planning_area, year, gender = "male")) %>%
            bind_rows(get_pop_query(token, data_type, planning_area, year, gender = "female"))
      } else if (! data_type %in% c("getEconomicStatus", "getEconomicStatus", "getEthnicGroup", "getPopulationAgeGroup")) {
          output <- output %>%
            mutate(gender = "Total")
      }
=======
>>>>>>> Stashed changes
  }

  # error check: invalid parameters
  if ("error" %in% names(output)) {
    warning("The request (", data_type , "/", planning_area, "/", year, "/", gender, ") ",
            "returned an error message: ",
            output$error,
            "Status Code: ",
            resp_status(response))
    output <- NULL

  } else if (is.character(output)) {
    warning("The request (", data_type , "/", planning_area, "/", year, "/", gender, ") ",
            "produced an error: ",
            output)
    output <- NULL

  # error check: no results
  } else if ("Result" %in% names(output)) {
    warning("The request (", data_type , "/", planning_area, "/", year, "/", gender, ") ",
            "produced an error: ",
            output$Result)
    output <- NULL

  # else return output
  } else {
    # replace NULLs with NA so tibble is of consistent length
    output <- output |>
      map(function(i) map(i, function(j) ifelse(is.null(j), NA, j))) |>

    # bind rows and turn into tibble
      reduce(bind_rows) |> as_tibble()

    # endpoints which allow gender parameter have different return behaviour when gender=NULL
    # getPopulationAgeGroup returns total, male & female
    # getEconomicStatus and getMaritalStatus returns only male & female
    # getEthnicGroup only returns total and does not include the gender parameter
    # this code block standardises output to include total, male & female

    if (is.null(gender) & data_type %in% c("getEconomicStatus", "getMaritalStatus")) {
      output <- output |>
        select(planning_area, year, gender, everything())
      total <- colSums(output[ , -(1:3)], na.rm = FALSE) |>
        t() |> as_tibble() |>
        mutate(planning_area = str_to_title(planning_area),
               year = as.integer(year),
               gender = "Total") |>
        select(planning_area, year, gender, everything())

      output <- output |>
        bind_rows(total)

    } else if (data_type == "getEthnicGroup" & is.null(gender)) {
        output <- output |>
          mutate(gender = "Total") |>
          bind_rows(get_pop_query(token, data_type, planning_area, year, gender = "male")) |>
          bind_rows(get_pop_query(token, data_type, planning_area, year, gender = "female"))
    } else if (! data_type %in% c("getEconomicStatus", "getEconomicStatus", "getEthnicGroup", "getPopulationAgeGroup")) {
        output <- output |>
          mutate(gender = "Total")
    }

  output

  }
}
