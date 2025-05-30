#' Get Planning Area Names
#'
#' @description
#' This function is a wrapper for the \href{https://www.onemap.gov.sg/apidocs/planningarea/#namesofPlanningArea}{Names of Planning Area API}. It returns the data as a tibble.
#'
#' @param token User's API token. This can be retrieved using \code{\link{get_token}}
#' @param year Optional, check \href{https://www.onemap.gov.sg/apidocs/planningarea/#namesofPlanningArea}{documentation} for valid options. Invalid requests will are ignored by the API.
#'
#' @return A tibble with 2 columns:
#' \describe{
#'   \item{id}{Planning area id}
#'   \item{pln_area_n}{Planning area name}
#' }
#' @export
#'
#' @examples
#' # returns tibble
#' \dontrun{get_planning_names(token)}
#' \dontrun{get_planning_names(token, 2008)}
#'
#' # error: output is NULL, warning message shows status code
#' \dontrun{get_planning_names("invalid_token")}

get_planning_names <- function(token, year = NULL) {

  # query API
  url <- "https://www.onemap.gov.sg/api/public/popapi/getPlanningareaNames"

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

  # convert JSON to dataframe
  output <- output %>%
    reduce(bind_rows)

  return(output)

}
