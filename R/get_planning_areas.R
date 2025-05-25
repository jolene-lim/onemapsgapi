#' Get Planning Areas (All)
#'
#' @description
<<<<<<< Updated upstream
#' This function is a wrapper for the \href{https://docs.onemap.sg/#planning-area-polygons}{Planning Area Polygons API}. It returns the data either in raw format or a combined sf or sp object.
#'
#' @param token User's API token. This can be retrieved using \code{\link{get_token}}
#' @param year Optional, check \href{https://docs.onemap.sg/#planning-area-polygons}{documentation} for valid options. Invalid requests will are ignored by the API.
#' @param read Optional, which package to use to read geojson object. For "sf" objects, specify \code{read = "sf"} and for "sp" objects use \code{read = "rgdal"}. Note that if used, any missing geojson objects will be dropped (this affects the "Others" planning area returned by the API).
=======
#' This function is a wrapper for the \href{https://www.onemap.gov.sg/docs/#planning-area-polygons}{Planning Area Polygons API}. It returns the data either in raw format or a combined sf object.
#'
#' @param token User's API token. This can be retrieved using \code{\link{get_token}}
#' @param year Optional, check \href{https://www.onemap.gov.sg/docs/#planning-area-polygons}{documentation} for valid options. Invalid requests will are ignored by the API.
#' @param return_spatial Optional, whether to return the result as a \code{sf} tibble instead of JSON object. Default value is \code{FALSE}
>>>>>>> Stashed changes
#'
#' @return If the parameter \code{read} is not specified, the function returns a raw JSON object with planning names and geojson string vectors. \cr \cr
#' If \code{return_spatial = TRUE}, the function returns a single "sf" tibble with 2 columns: "name" (name of planning area) and "geometry", which contains the simple features. \cr \cr
#' If an error occurs, the function throws an error with the API error message and status code.
#'
#' @note
#' If the user specifies \code{return_spatial = TRUE}  but does not have the \code{sf} package installed, the function will return the raw JSON and print a warning message.
#'
#' @export
#'
#' @examples
#' # returns raw JSON object
#' \dontrun{get_planning_areas(token)}
#' \dontrun{get_planning_areas(token, 2008)}
#'
#' # returns dataframe of class "sf"
#' \dontrun{get_planning_areas(token, return_spatial=TRUE)}
#'
#' # error: output is NULL, warning message shows status code
#' \dontrun{get_planning_areas("invalid_token")}


get_planning_areas <- function(token, year = NULL, return_spatial = FALSE) {

  # query API
  url <- "https://www.onemap.gov.sg/api/public/popapi/getAllPlanningarea"

  req <- request(url) |>
    req_url_query(year = year) |>
    req_auth_bearer_token(token) |>
    req_error(is_error= \(resp) FALSE)

  response <- req_perform(req)
  output <- resp_body_json(response)

  # error handling
  if ("message" %in% names(output)) {
    stop(str_c("The request returned an error message: ", output$message), " Status Code: ", resp_status(response))
  }

  # return output
  if (!return_spatial) {
    return(output)

  # read into requested format
  } else {
    output_empty <- output$SearchResults |>
      map_lgl(function(x) !is.null(x$geojson))

    output <- output$SearchResults[output_empty]

  }

  if (return_spatial & requireNamespace("sf", quietly = TRUE)) {
    output <- output %>%
      map(function(x) sf::st_sf(name = x$pln_area_n, geometry = flatten(sf::st_read(x$geojson, quiet = TRUE)))) %>%
      reduce(rbind)

  } else {
    warning(paste0("Failed to read geojson. Please ensure you have the sf package installed."))
  }

  return(output)

}

