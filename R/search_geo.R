#' Get Location Data from keyword
#'
#' @description
#' This function is a wrapper for the \href{https://www.onemap.gov.sg/apidocs/search/}{Search API}. It allows for geocoding of data such as postal codes or address information.
#' This is an internal function for the \code{geocode_onemap} function.
#' @param search_val Keyword(s) to be geocoded, e.g. column of postal codes
#' @param return_geom Default = \code{FALSE}. Whether to return the coordinate information
#' @param address_details Default = \code{FALSE}. Whether to return address information

search_geo <- function(search_val = NULL, return_geom = FALSE, address_details = FALSE) {

  # query API
  url <- "https://www.onemap.gov.sg/api/common/elastic/search"
  req <- request(url) |>
    req_url_query(
      searchVal = search_val,
      returnGeom = ifelse(return_geom, "Y", "N"),
      getAddrDetails = ifelse(address_details, "Y", "N")
    ) |>
    req_error(is_error= \(resp) FALSE)

  response <- req_perform(req)
  output <- resp_body_json(response)

  # error handling
  if (!"results" %in% names(output)) {
    warning("An error occurred for the request: ", search_val, ". ", ifelse("error" %in% names(output), output$error, NULL),
         " Status Code: ", resp_status(response))

    output <- tibble(SEARCHVAL = character())
    if (return_geom) {output <- bind_cols(output, X = character(), Y = character(), LATITUDE = character(), LONGITUDE = character())}
    if (address_details) {output <- bind_cols(output, BLK_NO = character(), ROAD_NAME = character(), BUILDING = character(), ADDRESS = character(), POSTAL = character())}

    return(output)
  }

  output <- output$results |>
    bind_rows()

  output[1, ]
}
