#' Extract API token from OneMap.Sg
#'
#' @description
#' This function is a wrapper for the \href{https://www.onemap.gov.sg/apidocs/authentication}{OneMap Authentication Service API}. It allows users to generate a API token from OneMap.Sg.
#' Using the API requires that users have a registered email address with Onemap.Sg. Users can register themselves using \href{https://www.onemap.gov.sg/apidocs/register}{OneMap.Sg's form}.
#'
#' @param email User's registered email address.
#' @param password User's password.
#' @param hide_message Default = \code{FALSE}. Whether to hide message telling user when the token expires.
#' @return API token, or NULL if an error occurs. If error occurs, a warning message will be printed with the error code.
#' @export
#'
#' @examples
#' \dontrun{get_token("user@@example.com",  "password")}

get_token <- function(email, password, hide_message = FALSE) {
  # query API
  url <- "https://www.onemap.gov.sg/api/auth/post/getToken"
  details <- list(email = email, password = password)
  req <- request(url) |>
    req_body_json(details) |>
    req_error(is_error= \(resp) FALSE)

  response <- req_perform(req)

  if (resp_status(response) != 200) {
    stop(str_c("The request returned an error message: ", resp_body_json(response)$error), " Status Code: ", resp_status(response))
  }

  content <- resp_body_json(response)
  output <- content$access_token

  # optionally, tell user when the token will expire
  if (!hide_message) {
    expiry_time <- as.POSIXct(as.integer(content$expiry_timestamp),
                              origin = "1970-01-01", tz = Sys.timezone())
    message(paste("This token will expire on", expiry_time))
  }

  output

}
