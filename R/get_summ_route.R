#' Get Summary Route Information
#'
#' @description
#' This function is a wrapper for the \href{https://docs.onemap.sg/#route}{Route Service API}. It is similar to \code{\link{get_route}}, except it returns a tibble with only total time and total distance, and also optionally, the start coordinates and end coordinates.
#' If \code{route = "pt"}, only the best route is chosen (i.e. \code{n_itineraries = 1}).
#'
#' @param token User's API token. This can be retrieved using \code{\link{get_token}}
#' @param start Vector of c(lat, lon) coordinates for the route start point
#' @param end Vector of c(lat, lon) coordinates for the route end point
#' @param route Type of route. Accepted values are \code{walk}, \code{drive}, \code{pt} (public transport), or \code{cycle}
#' @param date Default = current date. Date for which route is requested.
#' @param time Default = current time. Time for which route is requested.
#' @param mode Required if \code{route = "pt"}. Accepted values are \code{transit}, \code{bus} or \code{rail}
#' @param max_dist Optional if \code{route = "pt"}. Maximum walking distance
#' @param show_OD Default = \code{TRUE}. Whether to return variables \code{origin_lat}, \code{origin_lon}, \code{destination_lat} and \code{destination_lon}, which represent the start and end coordinates of the route.
#' @return If no error occurs and \code{show_OD = TRUE}, a tibble of 1 x 6 with the variables:
#' \describe{
#'   \item{total_time}{The total time taken for this route}
#'   \item{total_dist}{The total distance travelled for this route}
#'   \item{origin_lat}{Coordinate of start point latitude}
#'   \item{origin_lon}{Coordinate of start point longitude}
#'   \item{destination_lat}{Coordinate of end point latitude}
#'   \item{destination_lon}{Coordinate of end point longitude}
#' }
#'
#' If \code{show_OD = FALSE}, a 1 x 2 tibble with only \code{total_time} and \code{total_dist} will be returned.
#' If an error occurs, the output will be \code{NA}, along with a warning message.
#'
#' @export
#'
#' @examples
#' # returns output tibble
#' \donttest{get_summ_route(token, c(1.319728, 103.8421), c(1.319728905, 103.8421581), "drive")}
#' \donttest{get_summ_route(token, c(1.319728, 103.8421), c(1.319728905, 103.8421581), "pt",
#'     mode = "bus", max_dist = 300)}
#'
#' # error: output is NA, warning message shows status code
#' \donttest{get_summ_route("invalid_token", c(1.319728, 103.8421), c(1.319728905, 103.8421581), "drive")}
#'
#' # error: output is NA, warning message shows error message from request
#' \donttest{get_summ_route(token, c(300, 300), c(400, 500), "cycle")}
#' \donttest{get_summ_route(token, c(1.319728, 103.8421), c(1.319728905, 103.8421581), "fly")}

get_summ_route <- function(token, start, end, route, date = Sys.Date(), time = format(Sys.time(), format = "%T"), mode = NULL, max_dist = NULL, show_OD = TRUE) {
  # query API
  url <- "https://developers.onemap.sg/privateapi/routingsvc/route?"
  route <- str_to_lower(route)
  query <- paste(url,
                 "start=", str_c(start, collapse = ","),
                 "&end=", str_c(end, collapse = ","),
                 "&routeType=", route,
                 "&token=", token,
                 sep = "")
  if (route == "pt") {
    query <- paste(query,
                   "&date=", date,
                   "&time=", time,
                   "&mode=", str_to_upper(mode),
                   "&maxWalkDistance=", max_dist,
                   "&numItineraries=", "1",
                   sep = "")
  }
  response <- GET(query)

  # error handling
  if (http_error(response)) {
    status <- status_code(response)
    output <- tibble(total_time = NA,
                     total_dist = NA)
    warning(paste("The request produced a", status, "error", sep = " "))

    # break function
    return(output)
  }

  # else return output
  output <- content(response)

  # error check: invalid parameters
  if (names(output)[1] == "error") {
    warning(output$error)
    output <- tibble(total_time = NA,
                     total_dist = NA)
    return(output)

  } else if (route == "pt") {
    total_dist <- sum(map_dbl(output$plan$itineraries[[1]]$legs, function(x) x$distance))
    output <- tibble(total_time = output$plan$itineraries[[1]]$duration,
                     total_dist = round(total_dist, 0))

  } else {
    output <- tibble(total_time = output$route_summary$total_time,
                     total_dist = output$route_summary$total_dist)

  }

  if (show_OD) {
    OD <- tibble(origin_lat = start[2], origin_lon = start[1],
                 destination_lat = end[2], destination_lon = end[1])

    output <- OD %>%
      bind_cols(output)
  }

  output

}