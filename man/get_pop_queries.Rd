% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_pop_queries.R
\name{get_pop_queries}
\alias{get_pop_queries}
\title{Get Population Data (Multiple)}
\usage{
get_pop_queries(
  token,
  data_types,
  planning_areas,
  years,
  gender = NULL,
  parallel = FALSE
)
}
\arguments{
\item{token}{User's API token. This can be retrieved using \code{\link{get_token}}}

\item{data_types}{Type of data to be retrieved, should correspond to one of the API endpoints. E.g. to get economic status data, \code{data_type = "getEconomicStatus"}. The API endpoints can be found on the documentation page.}

\item{planning_areas}{Town for which the data should be retrieved.}

\item{years}{Year for which the data should be retrieved.}

\item{gender}{Optional, if specified only records for that gender will be returned. This parameter is only valid for the \code{"getEconomicStatus"}, \code{"getEthnicGroup"}, \code{"getMaritalStatus"} and \code{"getPopulationAgeGroup"} endpoints. If specified for other endpoints, the parameter will be dropped.}

\item{parallel}{Default = \code{FALSE}. Whether to run API calls in parallel or sequentially (default). Enabling parallel iterations is highly recommended for when querying multiple data types/years/towns.}
}
\value{
A tibble with each row representing a town in a particular year for a particular gender, and columns with the variables returned by the API endpoint.
If any API call returns no data, the values will be NA but the row will be returned. However, if all data_types do not return data for that town and year, no row will be returned for it.
}
\description{
This function is a wrapper for the \href{https://www.onemap.gov.sg/apidocs/populationquery}{Population Query API}. It allows for querying of multiple Popquery data types for multiple towns and years.
}
\examples{
# output with no NA
\dontrun{get_pop_queries(token, c("getReligion", "getLanguageLiterate"),
    c("Bedok", "Yishun"), "2010")}
\dontrun{get_pop_queries(token, c("getEconomicStatus", "getEthnicGroup"),
    "Yishun", "2010", "female")}

## note behaviour if data types is a mix of those that accept gender params
### only total will have all records
\dontrun{get_pop_queries(token, c("getEconomicStatus", "getOccupation", "getLanguageLiterate"),
    "Bedok", "2010")}
### data type that does not accept gender params will be in gender = Total
\dontrun{get_pop_queries(token, c("getEconomicStatus", "getOccupation", "getLanguageLiterate"),
    "Bedok", "2010", gender = "female")}

# output with some town-year queries without record due to no data
# warning message will show data_type/town/year/gender for which an error occurred
\dontrun{get_pop_queries(token, c("getEconomicStatus", "getOccupation"),
    "Bedok", c("2010", "2012"))} # no records for 2012
}
