# OneMapSGAPI

[![Maintenance](https://img.shields.io/badge/Maintained%3F-yes-green.svg)](https://github.com/jolene-lim/onemapsgapi/graphs/commit-activity) [![CRAN version](https://www.r-pkg.org/badges/version/onemapsgapi)](https://www.r-pkg.org/badges/version/onemapsgapi)
![!Downloads](https://cranlogs.r-pkg.org/badges/grand-total/onemapsgapi)

## Getting Started
### Introduction
The OneMapSGAPI package provides useful wrappers for the [OneMapSG API](https://www.onemap.gov.sg/docs/#introduction) client. It allows users to easily query spatial data from the API in a tidy format and provides additional functionalities to allow easy data manipulation. 

:tada: **Version 1.1.0 is now available!** Version update features greater options to return results in spatial formats, including features to return decoded route geometry for spatial analysis and visualisation.

The OneMapSg API package is now **available on CRAN-R**! :tada: :confetti_ball:
To download the release version, run:
```{r}
install.packages("onemapsgapi")
```

The development version can be downloaded via:
```{r}
# install.packages("devtools")
devtools::install_github("jolene-lim/onemapsgapi")
```
The development version is recommended as this package is early in its lifecycle. Please submit any problems via a github issues. Pull requests are also encouraged for anyone looking to contribute!

### Features
* Built-in data wrangling: Where output may be useful in either long or wide formats, depending on user objective, functions provide parameters for users to indicate if the output should be long or wide. All necessary data wrangling will be done within the function.  
* Built-in spatial data wrangling: API calls return spatial data as string vectors of geojson objects. This package allows users the option to return outputs compatible the with `sf` and `sp` packages.
* Parallel computing functionality: Some functions handle iterative API calls. In cases where there will be a large number of calls are needed to be made, functions will allow a parallel computing option to speed up the return of an output.  
* User friendliness through built-in regex: Some API calls return a lot of data, which may not be relevant to the user. Where appropriate, the functions allow users to input search terms and internally uses regular expressions to filter relevant records.  

### Status
Currently, the following API endpoints are supported:

| API | Coverage | Supported Endpoints |
| --- | --- | --- |
| **Post** | :white_check_mark: Full | [getToken](https://www.onemap.gov.sg/docs/#authentication-service-post) |
| **Themes** | :white_check_mark: Full | [checkThemeStatus](https://www.onemap.gov.sg/docs/#check-theme-status), [getThemeInfo](https://www.onemap.gov.sg/docs/#get-theme-info), [getAllThemesInfo](https://www.onemap.gov.sg/docs/#get-all-themes-info), [retrieveTheme](https://www.onemap.gov.sg/docs/#retrieve-theme)
| **Planning Area** | :white_check_mark: Full | [getAllPlanningarea](https://www.onemap.gov.sg/docs/#planning-area-polygons), [getPlanningareaNames](https://www.onemap.gov.sg/docs/#names-of-planning-area), [getPlanningarea](https://www.onemap.gov.sg/docs/#planning-area-query)
| **Population Query** | :white_check_mark: Full | [getEconomicStatus](https://www.onemap.gov.sg/docs/#economic-status-data), [getEducationAttending](https://www.onemap.gov.sg/docs/#education-status-data), [getEthnicGroup](https://www.onemap.gov.sg/docs/#ethnic-distribution-data), [getHouseholdMonthlyIncomeWork](https://www.onemap.gov.sg/docs/#work-income-for-household-monthly), [getHouseholdSize](https://www.onemap.gov.sg/docs/#household-size-data), [getHouseholdStructure](https://www.onemap.gov.sg/docs/#household-structure-data), [getIncomeFromWork](https://www.onemap.gov.sg/docs/#income-from-work-data), [getIndustry](https://www.onemap.gov.sg/docs/#industry-of-population-data), [getLanguageLiterate](https://www.onemap.gov.sg/docs/#language-literacy-data), [getMaritalStatus](https://www.onemap.gov.sg/docs/#marital-status-data), [getModeOfTransportSchool](https://www.onemap.gov.sg/docs/#mode-of-transports-to-school-data), [getModeOfTransportWork](https://www.onemap.gov.sg/docs/#mode-of-transport-to-work-data), [getOccupation](https://www.onemap.gov.sg/docs/#occupation-data), [getPopulationAgeGroup](https://www.onemap.gov.sg/docs/#age-data), [getReligion](https://www.onemap.gov.sg/docs/#religion-data), [getSpokenAtHome](https://www.onemap.gov.sg/docs/#spoken-language-data), [getTenancy](https://www.onemap.gov.sg/docs/#tenancy-data), [getTypeOfDwellingHousehold](https://www.onemap.gov.sg/docs/#tenancy-data), [getTypeOfDwellingPop](https://www.onemap.gov.sg/docs/#dwelling-type-population-data)
| **Routing Service** | :white_check_mark: Full | [route](https://www.onemap.gov.sg/docs/#routing-service)<br> **Note**: [Route Decoder](https://docs.onemap.sg/#routing-service) V1.1.0 features internal decoding capabilities via the `googlePolylines` package

## Usage
### Authentication
In order to query data, most API endpoints in the OneMapSG API require a token. First-time users can register themselves using the [OneMapSG registration form](https://developers.onemap.sg/register/). Subsequently, they can retrieve their tokens using the `get_token()` function with their email and password, for example:

```{r}
token <- get_token("user@email.com",  "password")
```

The function will also print a message informing users of the token's expiry date and time.

### Themes
Themes in the OneMap SG API refer to types of locations, such as kindergartens, parks, hawker centres etc. This package provides functions related to querying themes:

- `get_theme_status()` allows users to check if data associated with a theme has been updated after a certain time. It returns a named logical.

```{r}
# example: returns named logical if theme has been updated at time of query

get_theme_status(token, "hotels")
```

- `get_theme_info()` allows users to get information related to a specific theme. It returns a named character vector with Theme Name and Query Name.

```{r}
# example: returns character vector related to kindergaterns theme

get_theme_info(token, "kindergartens")
```
- `search_themes()` allows users to find details of themes of interest. It returns a tibble of themes matching user's search terms. Alternatively, if no search terms are added, a tibble of all themes available through the API is returned. The variable **THEMENAME** in the output tibble serves as the input for getting theme data.

```{r}
# example: return all themes related to "hdb" or "parks"
search_themes(token, "hdb", "parks")

# example: return all possible themes
search_themes(token)
```

- `get_theme()` returns data related to a particular theme, often location coordinates and other information. It returns the output as a tibble, or prints a warning message when an error is encountered. All tibbles will contain the variables: **NAME**, **DESCRIPTION**, **ADDRESSPOSTALCODE**, **ADDRESSSTREETNAME**, **Lat**, **Lng**, **ICON_NAME**, and some provide additional information; for example, query hawker centres gives additional information about the completion date of each hawker centre.

```{r}
# example: return the location coordinates + other data of all hotels in Singapore
get_theme(token, "hotels")
```

### Planning Area
Planning Area API endpoints allow users to get spatial data and data related to the planning areas in Singapore. This package provides users with the ability to query the data and optionally handles necessary spatial data wrangling on behalf of the user.

- `get_planning_areas` allows users to query all the spatial polygons associated with Singapore's planning areas, for certain years. The function also optionally helps users transform raw geojson strings into `sf` or `sp` objects.

```{r}
# example: return dataframe of class "sf" for planning areas in 2014
get_planning_areas(token, 2014, read = "sf")
```

- `get_planning_names()` allows users to query all planning area names for certain years. The function returns a tibble with planning area code and planning area name.

```{r}
# example: return dataframe of planning areas in 2014
get_planning_names(token, 2014)
```

- `get_planning_polygon()` allows users to query a particular planning area polygon containing the specified location point. The function also optionally helps users transform raw geojson string output into `sf` or `sp` objects.

```{r}
# example: return spatial polygon of class "sf" for planning area matching the input point in 2014
get_planning_polygon(token, 1.3, 103.8, 2014, read = "sf")
```

### Population Query
Population Query API endpoints allow users to pull socio-economic datasets by planning area, which each endpoint representing a dataset (e.g. `getPopulationAgeGroup` provides age group summary statistics by planning area). This package combines querying different Popquery API endpoints into a single function.

- `get_pop_queries()` allows users to query multiple datasets for multiple towns, years and genders (optional, supported by only a few endpoints). For large queries, allowing parallel iterations is recommended as it can halve the return time. Note that for queries involving a large volume of API calls, return time will still be limited by the API call speed.

```{r}
# example: return occupation summary data and literacy summary data for Bedok and Yishun towns in year 2010
get_pop_queries(token, c("getOccupation", "getLanguageLiterate"), c("Bedok", "Yishun"), "2010")
```

### Route Service
The Route Service API provides users a way to query the route taken from one point to another. It provides information about the total time and distance taken for the route, route instructions and other infomation e.g. elevation, for a variety of routes (public transport, drive, walk, cycle). This package provides three different functions associated with this API, each serving different purposes. 

- `get_route()` returns all API output but with standardized column names, which allows for subsequent merging if desired. This is particularly useful as API output variable names may vary depending on parameters (e.g. start point is named differently between `route = drive` and `route = pt`). If desired, both status information and the results will be returned.

```{r}
# example: return route data only in tibble format
get_route(token, c(1.319728, 103.8421), c(1.319728905, 103.8421581), "drive")

# example: return route data (tibble) and status information (list) as list of 2
get_route(token, c(1.319728, 103.8421), c(1.319728905, 103.8421581), "drive", status_info = TRUE)
```

- `get_travel()` allows the calculation of total time and distance for a tibble of start and end points. Users input a tibble of start and end points (and potentially other variables) and the function returns a tibble with additional columns, `total_time` and `total_dist`. Recognising that this API is most valuable for calculating total time travelled (as a improved measure of spatial distance compared to Euclidean distance), this function produces a cleaner output containing only the main variables of interest. It is also possible to return the route geometry which enables more analysis and visualisation capabilities.

For large queries, allowing parallel iterations is recommended as it can halve the return time. Note that for queries involving a large volume of API calls, return time will still be limited by the API call speed.

```{r}
# example: return tibble named df
get_travel(token, df,
    "start_lat", "start_lon", "end_lat", "end_lon",
    routes = c("cycle", "walk"))
```
