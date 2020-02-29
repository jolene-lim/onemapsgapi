#' Get Planning Polygon for a Specific Point
#'
#' @description
#' This function is a wrapper for the \href{https://docs.onemap.sg/#planning-area-query}{Planning Area Query API}. It returns the spatial polygon data matching the specified location point, either in raw format, as an sf or sp object.
#'
#' @param token User's API token. This can be retrieved using \code{\link{get_token}}
#' @param lat Latitude of location point
#' @param lon Longitude of location point
#' @param year Optional, check \href{https://docs.onemap.sg/#planning-area-query}{documentation} for valid options. Invalid requests will are ignored by the API.
#' @param read Optional, which package to use to read geojson object. For "sf" objects, specify \code{read = "sf"} and for "sp" objects use \code{read = "rgdal"}.
#'
#' @return If the parameter \code{read} is not specified, the function returns a raw JSON object a list containing the planning area name and a geojson string representing the polygon. \cr \cr
#' If \code{read = "sf"}, the function returns a 1 x 2 "sf" dataframe: "name" (name of planning area) and "geometry", which contains the simple feature. \cr \cr
#' If \code{read = "rgdal"}, the function returns a SpatialPolygonsDataFrame of "sp" class. The names of the planning area is recorded in the "name" column of the dataframe. \cr \cr
#' If an error occurs, the function returns NULL and a warning message is printed.
#'
#' @note
#' If the user specifies a \code{read} method but does not have the corresponding package installed, the function will return the raw JSON and print a warning message.
#'
#' @export
#'
#' @examples
#' # returns raw JSON object
#' \dontrun{get_planning_polygon(token)}
#' \dontrun{get_planning_polygon(token, 2008)}
#'
#' # returns dataframe of class "sf"
#' \dontrun{get_planning_polygon(token, read = "sf")}
#'
#' # returns SpatialPolygonsDataFrame ("sp" object)
#' \dontrun{get_planning_polygon(token, read = "rgdal")}
#'
#' # error: output is NULL, warning message shows status code
#' \dontrun{get_planning_polygon("invalid_token")}
#' \dontrun{get_planning_polygon(token, "invalidlat", "invalidlon")}


get_planning_polygon <- function(token, lat, lon, year = NULL, read = NULL) {

  # query API
  url <- "https://developers.onemap.sg/privateapi/popapi/getPlanningarea"

  query <- paste(url, "?",
                 "token=", token,
                 "&lat=", lat,
                 "&lng=", lon,
                 sep = "")
  if (!is.null(year)) {
    query <- paste(query,
                   "&year=", year,
                   sep = "")
  }

  response <- GET(query)

  # error handling
  if (http_error(response)) {
    status <- status_code(response)
    output <- NULL
    warning(paste("The request produced a", status, "error", sep = " "))
    return(output)

  }

  # return output
  output <- content(response)

  # read into requested format
  if (read == "sf" & requireNamespace("sf", quietly = TRUE)) {

    output <- bind_cols(name = output[[1]]$pln_area_n, sf::st_read(output[[1]]$geojson, quiet = TRUE))

  } else if (read == "rgdal" & requireNamespace("rgdal", quietly = TRUE)) {

    output <- merge(rgdal::readOGR(output[[1]]$geojson, verbose = FALSE), tibble(name = output[[1]]$pln_area_n))

  } else if (!is.null(read)) {
    warning(paste0("Failed to read geojson. Please ensure you have package ", read, " installed.
                   Only packages sf and rgdal (for sp) are supported currently."))
  }

  return(output)

}
