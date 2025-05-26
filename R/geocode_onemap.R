#' Geocode a dataframe of keywords
#'
#' @description
#' This function is a wrapper for the \href{https://www.onemap.gov.sg/apidocs/search/}{Search API}. It allows for geocoding of data such as postal codes or address information. Users input a dataframe with a column to geocode (e.g. postal codes, address information).
#' It returns a tibble with additional columns of coordinate data. Optionally, it can also return the output as an \code{sf} object.
#' @param df Input tibble with column to be geocoded
#' @param search_val Column name containing keyword(s) to be geocoded, e.g. column of postal codes
#' @param return_geom Default = \code{FALSE}. Whether to return the coordinate information
#' @param address_details Default = \code{FALSE}. Whether to return address information
#' @param return_spatial Default = \code{FALSE}. Whether to return the output as an \code{sf} object. Please ensure \code{}
#' @param spatial_lnglat Default = \code{TRUE}. If \code{TRUE}, the WGS84 coordinates will be used to create the \code{sf} tibble. If \code{FALSE}, the SVY21 coordinates will be used.
#' @param parallel Default = \code{FALSE}. Whether to run API calls in parallel or sequentially (default).
#'
#' @return Please note only the top result matching the search will be returned. If no error occurs:
#' \describe{
#' \item{SEARCH_VAL}{Detailed search name}
#' \item{X}{Longitude in SVY21. Returned only if \code{return_geom = TRUE}}
#' \item{Y}{Latitude in SVY21. Returned only if \code{return_geom = TRUE}}
#' \item{LONGITUDE}{Longitude in WGS84. Returned only if \code{return_geom = TRUE}}
#' \item{LATITUDE}{Latitude in WGS84. Returned only if \code{return_geom = TRUE}}
#' \item{BLK_NO}{Block number}
#' \item{ROAD_NAME}{Road Name}
#' \item{BUILDING}{Building Name}
#' \item{ADDRESS}{Address}
#' \item{POSTAL}{Postal Code}
#' }
#'
#' If an error occurs, an empty result will be returned for that row. A warning message will be printed with the serach value, API error message and status code.
#'
#' @export
#'
#' @examples
#' # sample dataframe. the last record does not return any API results.
#' df <- data.frame(
#'   places = c("a", "b", "c", "d"),
#'   address = c("raffles place mrt", "suntec city", "nus", "100353")
#' )
#'
#' # Returns the original df with additional columns
#' \dontrun{geocode_onemap(df, "address",
#'   return_geom=TRUE, address_details = TRUE, return_spatial=TRUE)
#' }
#' # If an error occurs for any of the rows, an empty row will be returned.

geocode_onemap <- function(df, search_val, return_geom = FALSE, address_details = FALSE, return_spatial = FALSE, spatial_lnglat = TRUE, parallel = FALSE) {

  # set up parallel option if requested
  if (parallel) {
    if (Sys.info()[["sysname"]] == "Windows") {plan(multisession)} else {plan(multicore)}

    output <- df$address |>
      future_map(function(search_val) search_geo(search_val, return_geom = return_geom, address_details = address_details)) |>
      bind_rows()

  } else {
  output <- df$address |>
    map(function(search_val) search_geo(search_val, return_geom = return_geom, address_details = address_details)) |>
    bind_rows()
  }

  output <- df |>
    bind_cols(output)

  if (return_spatial) {
    if (!return_geom) {
      warning("Spatial geometry was requested but return_geom = FALSE. Output will not be a spatial dataframe.")
      return(output)
    }

    if (!requireNamespace("sf", quietly = TRUE)) {
      warning("Spatial geometry was requested but sf package is not installed. Output will not be a spatial dataframe.")
      return(output)
    }

    coords <- if(spatial_lnglat) c("LONGITUDE", "LATITUDE") else c("X", "Y")
    output <- sf::st_as_sf(output, coords = coords, na.fail = FALSE)
  }

  output
}
