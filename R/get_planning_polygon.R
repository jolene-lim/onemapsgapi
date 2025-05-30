#' Get Planning Polygon for a Specific Point
#'
#' @description
#' This function is a wrapper for the \href{https://www.onemap.gov.sg/apidocs/planningarea/#planningAreaPolygon}{Planning Area Query API}. It returns the spatial polygon data matching the specified location point, either in raw format or as an sf tibble.
#'
#' @param token User's API token. This can be retrieved using \code{\link{get_token}}
#' @param lat Latitude of location point
#' @param lon Longitude of location point
#' @param year Optional, check \href{https://www.onemap.gov.sg/docs/#planning-area-query}{documentation} for valid options. Invalid requests will are ignored by the API.
#' @param return_spatial Optional, defaults to \code{FALSE}. If \code{TRUE}, result will be returned as a \code{sf} tibble, otherwise the raw JSON object will be returned.
#'
#' @return If the parameter \code{read} is not specified, the function returns a raw JSON object a list containing the planning area name and a geojson string representing the polygon. \cr \cr
#' If \code{read = "sf"}, the function returns a 1 x 2 "sf" dataframe: "name" (name of planning area) and "geometry", which contains the simple feature. \cr \cr
#' If an error occurs, the function throws an error with the API error message and status code.
#'
#' @note
#' If the user specifies a \code{return_spatial = TRUE} but does not have the \code{sf} package installed, the function will return the raw JSON and print a warning message.
#'
#' @export
#'
#' @examples
#' # returns raw JSON object
#' \dontrun{get_planning_polygon(token, lat = 1.429443081, lon = 103.835005)}
#' \dontrun{get_planning_polygon(token, lat = 1.429443081, lon = 103.835005, year = 2008)}
#'
#' # returns dataframe of class "sf"
#' \dontrun{get_planning_polygon(token, lat = 1.429443081, lon = 103.835005, return_spatial = TRUE)}
#'
#' # error: output is NULL, warning message shows status code
#' \dontrun{get_planning_polygon("invalid_token", lat = 1.429443081, lon = 103.835005)}
#' \dontrun{get_planning_polygon(token, "invalidlat", "invalidlon")}


get_planning_polygon <- function(token, lat, lon, year = NULL, return_spatial = FALSE) {

  # query API
  url <- "https://www.onemap.gov.sg/api/public/popapi/getPlanningarea"

  req <- request(url) |>
    req_url_query(latitude = lat, longitude = lon, year = year) |>
    req_auth_bearer_token(token) |>
    req_error(is_error= \(resp) FALSE)

  response <- req_perform(req)
  output <- resp_body_json(response)

  # error handling
  if ("message" %in% names(output)) {
    stop(str_c("The request returned an error message: ", output$message), " Status Code: ", resp_status(response))
  }

  if ("error" %in% names(output)) {
    stop(str_c("The request returned an error message: ", output$error), " Status Code: ", resp_status(response))
  }

    # read into requested format
  if (return_spatial) {
    if (requireNamespace("sf", quietly = TRUE)) {
      output <- bind_cols(name = output[[1]][["pln_area_n"]], sf::st_read(output[[1]][["geojson"]], quiet = TRUE))
      sf::st_geometry(output) <- output$geometry

    } else {
      warning(paste0("Failed to read geojson. Please ensure you have the sf package installed."))
    }
  }


  return(output)

}
