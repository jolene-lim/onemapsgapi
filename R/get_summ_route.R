#' Get Summary Route Information
#'
#' @description
<<<<<<< Updated upstream
#' This function is a wrapper for the \href{https://docs.onemap.sg/#route}{Route Service API}. It is similar to \code{\link{get_route}}, except it returns a tibble with only total time and total distance, and also optionally, the start coordinates and end coordinates.
=======
#' This function is a wrapper for the \href{https://www.onemap.gov.sg/apidocs/routing/}{Route Service API}. However, it only returns the total time, distance and optionally the route geometry between two points.
>>>>>>> Stashed changes
#' If \code{route = "pt"}, only the best route is chosen (i.e. \code{n_itineraries = 1}).
#'
#' @param token User's API token. This can be retrieved using \code{\link{get_token}}
#' @param start Vector of c(lat, lon) coordinates for the route start point
#' @param end Vector of c(lat, lon) coordinates for the route end point
#' @param route Type of route. Accepted values are \code{walk}, \code{drive}, \code{pt} (public transport), or \code{cycle}
#' @param date Default = current date. Date for which route is requested.
#' @param time Default = current time. Time for which route is requested.
#' @param mode Required if \code{route = "pt"}. Accepted values are \code{TRANSIT}, \code{BUS} or \code{RAIL}
#' @param max_dist Optional if \code{route = "pt"}. Maximum walking distance
#' @param route_geom Default = FALSE. Whether to return decoded route_geometry. Please ensure packages \link[googlePolylines]{googlePolylines} and \link[sf]{sf} are installed and note that this is a lossy conversion.
#' @return If no error occurs, a tibble of 1 x 2 with the variables:
#' \describe{
#'   \item{total_time}{The total time taken for this route}
#'   \item{total_dist}{The total distance travelled for this route}
#' }
#'
#' If an error occurs, the output will be \code{NA}, along with a warning message.
#'
#' @export
#'
#' @examples
#' # returns output tibble
#' \dontrun{get_summ_route(token, c(1.320981, 103.844150), c(1.326762, 103.8559), "drive")}
#' \dontrun{get_summ_route(token, c(1.320981, 103.844150), c(1.326762, 103.8559), "pt",
#'     mode = "bus", max_dist = 300)}
#'
#' # returns output sf dataframe
#' \dontrun{get_summ_route(token, c(1.320981, 103.844150), c(1.326762, 103.8559),
#'     "drive", route_geom = TRUE)}
#' \dontrun{get_summ_route(token, c(1.320981, 103.844150), c(1.326762, 103.8559), "pt",
#'     mode = "bus", max_dist = 300, route_geom = TRUE)}
#'#'
#' # error: output is NULL, warning message shows status code
#' \dontrun{get_summ_route("invalid_token", c(1.320981, 103.844150), c(1.326762, 103.8559), "drive")}
#'
#' # error: output is NULL, warning message shows error message from request
#' \dontrun{get_summ_route(token, c(300, 300), c(400, 500), "cycle")}
#' \dontrun{get_summ_route(token, c(1.320981, 103.844150), c(1.326762, 103.8559), "fly")}

get_summ_route <- function(token, start, end, route, date = format(Sys.Date(), "%m-%d-%Y"), time = format(Sys.time(), "%T"), mode = NULL, max_dist = NULL, route_geom = FALSE) {
  # query API
  url <- "https://www.onemap.gov.sg/api/public/routingsvc/route"

  req <- request(url) |>
    req_url_query(start = str_c(start, collapse = ","),
                  end = str_c(end, collapse = ","),
                  routeType = str_to_lower(route),
                  date = date,
                  time = time,
                  mode = str_to_upper(mode),
                  maxWalkDistance = max_dist) |>
    req_auth_bearer_token(token) |>
    req_error(is_error= \(resp) FALSE)

  response <- req_perform(req)
  output <- resp_body_json(response)

  # error handling
  if ("message" %in% names(output)) {
     warning(str_c(
       "The request (", str_c(start, collapse = ",") , "/", str_c(end, collapse = ","), "/", mode, ") ",
       "produced an error: ", output$message,
       " Status Code: ", resp_status(response))
     )
    output <- tibble(total_time = NA,
                     total_dist = NA)

    return(output)
  }

  # else return output

  # error check: invalid parameters
  if ("error" %in% names(output)) {
    warning(str_c(
      "The request (", str_c(start, collapse = ",") , "/", str_c(end, collapse = ","), "/", route, "/", mode, ") ",
      "produced an error: ", output$error,
      " Status Code: ", resp_status(response))
    )
    output <- tibble(total_time = NA,
                     total_dist = NA)

    return(output)
  }

  # else return results (pt)
  if (route == "pt") {
    total_dist <- sum(map_dbl(output$plan$itineraries[[1]]$legs, function(x) x$distance))
    result <- tibble(total_time = output$plan$itineraries[[1]]$duration,
                     total_dist = round(total_dist, 0))

  # else return results (non-pt)
  } else {
    result <- tibble(total_time = output$route_summary$total_time,
                     total_dist = output$route_summary$total_dist)
  }

  # append route_geom if requested
  if (route_geom & requireNamespace("googlePolylines", quietly = TRUE) & requireNamespace("sf", quietly = TRUE)) {

    if (route == "pt") {
<<<<<<< Updated upstream
      route_geometry <- map_chr(output$plan$itineraries[[1]]$legs, function(x) x$legGeometry$points) %>%
        map(function(x) googlePolylines::decode(x)) %>%
        map(function(x) map(x, function(x) select(x, lon, lat) %>% data.matrix())) %>%
        map(function(x) sf::st_multilinestring(x)) %>%
        sf::st_sfc(crs=4326)
    } else {
      dec <- googlePolylines::decode(output$route_geom[[1]])
      route_geometry <- dec[[1]] %>%
        select(lon, lat) %>%
        data.matrix %>%
        sf::st_linestring() %>%
=======
      route_geometry <- map_chr(output$plan$itineraries[[1]]$legs, function(x) x$legGeometry$points) |>
        map(function(x) googlePolylines::decode(x)) |>
        map(function(x) map(x, function(x) select(x, "lon", "lat") |> data.matrix())) |>
        map(function(x) sf::st_multilinestring(x)) |>
        sf::st_sfc(crs=4326)
    } else {
      dec <- googlePolylines::decode(output$route_geom[[1]])
      route_geometry <- dec[[1]] |>
        select("lon", "lat") |>
        data.matrix() |>
        sf::st_linestring() |>
>>>>>>> Stashed changes
        sf::st_sfc(crs = 4326)
    }
    sf::st_geometry(result) <- sf::st_combine(route_geometry)
  }

  return(result)

}
