#' Compare Routes' Travel Time and Distance
#'
#' @description
#' This function is a wrapper for the \href{https://docs.onemap.sg/#route}{Route Service API}. It is similar to \code{\link{get_summ_route}}, except it takes in a dataframe of start and end coordinates and returns the same dataframe with additional total time and total distance columns.
#' The function also accepts multiple arguments for `route` and `pt_mode`, allowing users to compare various route options.
#'
#' @param token User's API token. This can be retrieved using \code{\link{get_token}}
#' @param df The input dataframe of start and end coordinates (the dataframe can have additional variables)
#' @param origin_lat Name of the dataframe column with the start point latitude.
#' @param origin_lon Name of the dataframe column with the start point longitude.
#' @param destination_lat Name of the dataframe column with the end point latitude.
#' @param destination_lon Name of the dataframe column with the end point longitude.
#' @param routes Vector of the types of routes desired. Accepted values are \code{walk}, \code{drive}, \code{pt} (public transport), or \code{cycle}
#' @param date Default = current date. Date for which route is requested.
#' @param time Default = current time. Time for which route is requested.
#' @param pt_mode Vector of public transport modes required. Default = \code{route = c("transit")}. Accepted values are \code{transit}, \code{bus} or \code{rail}
#' @param pt_max_dist Optional if \code{route = "pt"}. Maximum walking distance
#' @param as_wide Default = \code{TRUE}. Whether to return output as a list as a long tibble with each row a route, or a wide tibble with the same number of rows as the input tibble.
#' @param parallel Default = \code{FALSE}. Whether to run API calls in parallel or sequentially (default).
#' @return Original dataframe with total time and total distance for each route type.
#'
#' If an error occurs, the output row will be have \code{NA}s for the additional variables, along with a warning message.
#'
#' @export
#'
#' @examples
#' # sample dataframe
#' sample <- data.frame(start_lat = c(1.3746617, 1.3567797, 1.3361976, 500),
#'     start_lon = c(103.8366159, 103.9347695, 103.6957732, 501),
#'     end_lat = c(1.429443081, 1.380298287, 1.337586882, 601),
#'     end_lon = c(103.835005, 103.7452918, 103.6973215, 600),
#'     add_info = c("a", "b", "c", "d"))
#'
#' # no error, wide format
#' \donttest{compare_routes(token, sample[1:3, ],
#'     "start_lat", "start_lon", "end_lat", "end_lon",
#'     routes = c("cycle", "walk"))}
#' \donttest{compare_routes(token, sample[1:3, ],
#'     "start_lat", "start_lon", "end_lat", "end_lon",
#'     routes = c("drive", "pt"), pt_mode = c("bus", "transit"))}
#'
#' # no error, long format
#' \donttest{compare_routes(token, sample[1:3, ],
#'     "start_lat", "start_lon", "end_lat", "end_lon",
#'     routes = c("walk", "pt"), pt_mode = c("bus", "transit"),
#'     as_wide = FALSE)}
#'
#' # with error
#' \donttest{compare_routes(token, sample,
#'     "start_lat", "start_lon", "end_lat", "end_lon",
#'     routes = c("cycle", "walk"))}


compare_routes <- function(token, df, origin_lat, origin_lon, destination_lat, destination_lon, routes, date = Sys.Date(), time = format(Sys.time(), format = "%T"), pt_mode = "TRANSIT", pt_max_dist = NULL, as_wide = TRUE, parallel = FALSE) {

  # preallocate list to hold each route output
  if ("pt" %in% routes) {
    pt_mode <- map_chr(pt_mode, function(x) paste("pt-", x, sep = ""))
    routes <- c(routes, pt_mode)
    routes <- routes[routes != "pt"]
  }

  output_list <- as.list(rep(NA, length(routes)))
  names(output_list) <- as.character(routes)

  # subset variables used to query API
  var_df <- select(df, olat = origin_lat, olon = origin_lon, dlat = destination_lat, dlon = destination_lon)

  # query API iteratively using get_summ_route()
  for (i in routes) {
    if (str_sub(i, 1, 2) == "pt") {

      # parallel or sequential API call for each iteration
      if (parallel) {
        if (Sys.info()[["sysname"]] == "Windows") {plan(multisession)} else {plan(multicore)}

        route_output <- var_df %>%
          future_pmap(function(olat, olon, dlat, dlon) get_summ_route(token = token, start = c(olat, olon), end = c(dlat, dlon), route = "pt", date = date, time = time, mode = str_remove(i, "pt-"), max_dist = pt_max_dist))
      } else {

        route_output <- var_df %>%
          pmap(function(olat, olon, dlat, dlon) get_summ_route(token = token, start = c(olat, olon), end = c(dlat, dlon), route = "pt", date = date, time = time, mode = str_remove(i, "pt-"), max_dist = pt_max_dist))
      }

      # process output
      route_output <- route_output %>%
        reduce(bind_rows) %>%
        mutate(route = i)

      route_output <- bind_cols(df, route_output) %>% select(- c("origin_lat", "origin_lon", "destination_lat", "destination_lon"))

    } else {

      # parallel or sequential API call for each iteration
      if (parallel) {
        if (Sys.info()[["sysname"]] == "Windows") {plan(multisession)} else {plan(multicore)}

        route_output <- var_df %>%
          future_pmap(function(olat, olon, dlat, dlon) get_summ_route(token = token, start = c(olat, olon), end = c(dlat, dlon), route = i, date = date, time = time))

        } else {

        route_output <- var_df %>%
          pmap(function(olat, olon, dlat, dlon) get_summ_route(token = token, start = c(olat, olon), end = c(dlat, dlon), route = i, date = date, time = time))
      }

      route_output <- route_output %>%
        reduce(bind_rows) %>%
        mutate(route = i)

      route_output <- bind_cols(df, route_output) %>% select(- c("origin_lat", "origin_lon", "destination_lat", "destination_lon"))
    }

    output_list[[i]] <- route_output

  }

  # compile into either long or wide df
  if (as_wide) {
    output <- output_list %>%
      reduce(bind_rows) %>%
      unite(col = "totals", "total_time", "total_dist", sep = "/") %>%
      spread(.data$route, .data$totals)

    for (i in routes) {
      output <- separate(output, col = i, into = c(paste(i, "_time", sep = ""), paste(i, "_distance", sep = "")), sep = "/")
    }

  } else {
    output <- output_list %>%
      reduce(bind_rows)
  }

  return(output)

}
