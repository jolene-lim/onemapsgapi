#' Get Theme Data from OneMap.Sg
#'
#' @description
#' This function is a wrapper for the \href{https://www.onemap.gov.sg/apidocs/themes/#retrieveTheme}{Retrieve Theme API}. It returns the data as cleaned tibbles.
#'
#' @param token User's API token. This can be retrieved using \code{\link{get_token}}
#' @param theme OneMap theme in its \code{QUERYNAME} format. A tibble of available themes can be retrieved using \code{\link{search_themes}}
#' @param extents Optional, Location Extents for search. This should be in the format "Lat1,\%20Lng1,Lat2,\%20Lng2". For more information, consult the \href{https://docs.onemap.sg/#retrieve-theme}{API Documentation}.
#' @param return_info Default = \code{FALSE}. If \code{FALSE}, function only returns a tibble for query results. If \code{TRUE}, function returns output as a list containing a tibble for query information and a tibble for query results.
#' @param return_spatial Default = \code{FALSE}. If \code{FALSE}, function returns a tibble. If \code{TRUE}, function returns an \code{sf} tibble.
#'
#' @return If no error occurs:
#' \describe{
#'   \item{query_info}{A 1 x 7 tibble containing information about the query. The variables are \code{FeatCount}, \code{Theme_Name}, \code{Category}, \code{Owner}, \code{DateTime.date}, \code{DateTime.timezone_type}, \code{DateTime.timezone}}
#'   \item{query_result}{Returned if return_info = \code{TRUE}. A tibble containing the data retrieved from the query. The columns and rows vary depending on theme and user specification, however all tibbles will contain the variables: \code{NAME}, \code{DESCRIPTION}, \code{ADDRESSPOSTALCODE}, \code{ADDRESSSTREETNAME}, \code{Lat}, \code{Lng}, \code{ICON_NAME}}
#' }
#'
#' If an error occurs, an error will be raised, along with the API's error message and status code.
#' For non-error queries where 0 results are returned, the output will be \code{query_info}, along with a warning message.
#'
#' @export
#'
#' @examples
#' # returns a tibble of output
#' \dontrun{get_theme(token, "hotels")}
#' \dontrun{get_theme(token, "monuments",
#'     extents = "1.291789,%20103.7796402,1.3290461,%20103.8726032")}
#'
#' # returns a sf dataframe
#' \dontrun{get_theme(token, "hotels", return_spatial = TRUE)}
#'
#' # returns a list of status tibble and output tibble
#' \dontrun{get_theme(token, "funeralparlours", return_info = TRUE)}
#'
#' # error: throws an error with error message and status code
#' \dontrun{get_theme("invalid_token", "hotels")}
#'
#' # error: throws an error with error message and status code
#' \dontrun{get_theme(token, "non-existent-theme")}
#'
#' # error: output is \code{query_info}, warning message query did not return any records
#' \dontrun{get_theme(token, "ura_parking_lot", "1.291789,%20103.7796402,1.3290461,%20103.8726032")}

get_theme <- function(token, theme, extents = NULL, return_info = FALSE, return_spatial = FALSE) {
  # query API
  url <- "https://www.onemap.gov.sg/api/public/themesvc/retrieveTheme"

  req <- request(url) |>
    req_url_query(queryName = theme, extents = extents) |>
    req_auth_bearer_token(token) |>
    req_error(is_error= \(resp) FALSE)

  response <- req_perform(req)
  query_results <- resp_body_json(response)

    # error check: invalid token
    if ("message" %in% names(query_results)) {
      stop(str_c("The request returned an error message: ", query_results$message), " Status Code: ", resp_status(response))
    }

  # error check: output length 0
  if (length(query_results$SrchResults) == 1) {
    if("ErrorMessage" %in% names(query_results$SrchResults[[1]])) {
      stop(str_c("The request returned an error message: ", query_results$SrchResults[[1]]$ErrorMessage), " Status Code: ", resp_status(response))
    }
    output <- query_results[[1]][[1]] |>
      unlist() |> t() |>
      as_tibble()
    warning("There are 0 matching records for your query.")

    # transform output to dataframe
  } else{
    output <- query_results[[1]][-1] %>%
      reduce(bind_rows) %>%
      separate(col = "LatLng", into = c("Lat", "Lng"), sep = ",")

    if (return_spatial & requireNamespace("sf", quietly = TRUE)) {
      output <- sf::st_as_sf(output, coords = c("Lng", "Lat"))
    }


    # transform output to a list containing query info and query results if user wants info
    if (return_info) {

      # store query info
      query_info <- query_results[[1]][[1]] %>%
        unlist() %>% t() %>%
        as_tibble()

      # reformat output
      output <- list(query_info = query_info, query_results = output)
    }
  }
  output

}
