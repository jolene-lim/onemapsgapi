#' Get Theme Information
#'
#' @description
#' This function is a wrapper for the \href{https://www.onemap.gov.sg/apidocs/themes/#getThemesInfo}{Get Theme Info API}. It returns a named character vector of Theme Name and Query Name.
#'
#' @param token User's API token. This can be retrieved using \code{\link{get_token}}
#' @param theme Query name of theme. Themes’ query names can be retrieved using \code{\link{search_themes}}.
#'
#' @return A named character vector of Theme Name and Query Name.
#' If an error occurred, the function throws an error with the status code and API's error message.
#'
#' @export
#'
#' @examples
#' # returns named character vector
#' \dontrun{get_theme_info(token, "kindergartens")}
#'
#' # throws an error with error message and status code
#' \dontrun{get_theme_info(token, "invalid_theme")}
#'
#' # throws an error with error message and status code
#' \dontrun{get_theme_info("invalid_token", "blood_bank")}

get_theme_info <- function(token, theme) {

  # query API
  url <- "https://www.onemap.gov.sg/api/public/themesvc/getThemeInfo"

  req <- request(url) |>
    req_url_query(queryName = theme) |>
    req_auth_bearer_token(token) |>
    req_error(is_error= \(resp) FALSE)

  response <- req_perform(req)

  content <- resp_body_json(response)

  if ("error" %in% names(content)) {
    stop(str_c("The request returned an error message: ", content$error), " Status Code: ", resp_status(response))
  }

  if ("message" %in% names(content)) {
    stop(str_c("The request returned an error message: ", content$message), " Status Code: ", resp_status(response))
  }

  output <- content |>
    unlist()

  return(output)
}
