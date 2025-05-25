#' Search for Themes available on OneMap.Sg
#'
#' @description
<<<<<<< Updated upstream
#' This function is a wrapper for the \href{https://docs.onemap.sg/#get-all-themes-info}{Get All Themes Info API}. It allows users to get a tibble of all available themes, and their details, in the OneMap.Sg API. It also provides an additional functionality where users can subset their results using search terms.
=======
#' This function is a wrapper for the \href{https://www.onemap.gov.sg/apidocs/themes/#getAllThemesInfo}{Get All Themes Info API}. It allows users to get a tibble of all available themes, and their details, in the OneMap.Sg API. It also provides an additional functionality where users can subset their results using search terms.
>>>>>>> Stashed changes
#'
#' @param token User's API token. This can be retrieved using \code{\link{get_token}}
#' @param ... Optional Search terms to subset results; results with any of search terms will be returned. Search terms are not case-sensitive.
#' @param more_info Whether more information should be queried, default = \code{FALSE}. If \code{FALSE}, output will contain Theme Name, Query Name and Icon information. If \code{TRUE}, output will additionally contain Category and Theme Owner information.
#' @return If no error occurs, a tibble with the following variables:
#' \describe{
#'   \item{THEMENAME}{Name of the Theme}
#'   \item{QUERYNAME}{Query name of the Theme}
#'   \item{ICON}{Name of image file used as Icon in OneMap Web Map}
#'   \item{EXPIRY_DATE}{Expiry Date of the Theme}
#'   \item{PUBLISHED_DATE}{Published Date of the Theme}
#'   \item{CATEGORY}{Returned only if \code{more_info = TRUE}. Topic that Theme relates to, e.g. Health, Sports, Environment, etc.}
#'   \item{THEME_OWNER}{Returned only if \code{more_info = TRUE}. Government Agency who Owns the Dataset}
#' }
#'
#' If an error occurs, the function throws an error with error message and status code.
#'
#' @export
#' @examples
#' # valid
#' \dontrun{search_themes(token)}
#' \dontrun{search_themes(token, "hdb", "parks")}
#' \dontrun{search_themes(token, more_info = TRUE)}
#'
#' # error
#' \dontrun{search_themes("my_invalid_token")}

search_themes <- function(token, ..., more_info = FALSE) {
  # query API
  url <- "https://www.onemap.gov.sg/api/public/themesvc/getAllThemesInfo"
  more_info <- if_else(more_info, "Y", "N")

  req <- request(url) |>
    req_url_query(moreInfo = more_info) |>
    req_auth_bearer_token(token) |>
    req_error(is_error= \(resp) FALSE)

  response <- req_perform(req)
  output <- resp_body_json(response)

  # error handling
  if ("error" %in% names(output)) {
    stop(str_c("The request returned an error message: ", output$error), " Status Code: ", resp_status(response))
  }

  if ("message" %in% names(output)) {
    stop(str_c("The request returned an error message: ", output$message), " Status Code: ", resp_status(response))
  }

  # else return output
  output <- output %>%
    flatten() %>%
    bind_rows()

  # subset output if user is searching for a term
  search <- c(...)

  if (length(search) != 0) {
    search <- str_c(search, collapse = "|")

    search_matches <- output %>%
      unite(col = "combined", sep = " ") %>%
      unlist() %>%
      map_lgl(str_detect, pattern = regex(search, ignore_case = TRUE))

    output <- output[search_matches, ]
  }

  output
}
