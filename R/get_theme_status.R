#' Check Theme Status
#'
#' @description
#' This function is a wrapper for the \href{https://www.onemap.gov.sg/apidocs/themes/#checkThemeStatus}{Check Theme Status API}. It returns a named logical indicating if the theme is updated at a specific date.
#'
#' @param token User's API token. This can be retrieved using \code{\link{get_token}}
#' @param theme Query name of theme. Themes’ query names can be retrieved using \code{\link{search_themes}}.
#' @param date Default = current date. Date to check for updates. Format YYYY-MM-DD
#' @param time Default = current time. Time to check for updates. Format: HH:MM:SS:FFFZ
#'
#' @return A named logical indicating if the theme is updated at a specific date.
#' If an error occurred, the function throws an error with the status code and API's error message.
#'
#' @export
#'
#' @examples
#' # returns named logical
#' \dontrun{get_theme_status(token, "kindergartens")}
#' \dontrun{get_theme_status(token, "hotels", "2020-01-01", "12:00:00")}
#'
#' # throws an error with error message and status code
#' \dontrun{get_theme_status("invalid_token", "blood_bank")}
#'
#' # throws an error with error message and status code
#' \dontrun{get_theme_status(token, "invalid_theme")}

get_theme_status <- function(token, theme, date = Sys.Date(), time = format(Sys.time(), format = "%T")) {

  date_time <- str_c(date, "T", time)

  # query API
  url <- "https://www.onemap.gov.sg/api/public/themesvc/checkThemeStatus"

  req <- request(url) |>
    req_url_query(queryName = theme, dateTime = date_time) |>
    req_auth_bearer_token(token) |>
    req_error(is_error= \(resp) FALSE)

  response <- req_perform(req)

  output <- resp_body_json(response)

  if ("error" %in% names(output)) {
    stop(str_c("The request returned an error message: ", output$error), " Status Code: ", resp_status(response))
  }

  if ("message" %in% names(output)) {
    stop(str_c("The request returned an error message: ", output$message), " Status Code: ", resp_status(response))
  }

  output <- output |>
    unlist()

  return(output)

}
