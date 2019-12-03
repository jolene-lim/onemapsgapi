# OneMapSGAPI

## Getting Started
### Introduction
The OneMapSGAPI package provides useful wrappers for the [OneMapSG API](https://docs.onemap.sg/#introduction) client. It allows users to easily query spatial data from the API in a tidy format and provides additional functionalities to allow easy data manipulation. 

To download the package, run the code:
```{r}
# install.packages("devtools")
devtools::install_github("jolene-lim/onemapsgapi")
```
### Status
Currently, the following API endpoints are supported:

- **POST** (`post`): [getToken](https://docs.onemap.sg/#authentication-service-post)  
- **Themes** (`themesvc`): [getAllThemesInfo](https://docs.onemap.sg/#get-all-themes-info), [retrieveTheme](https://docs.onemap.sg/#retrieve-theme)  
- **Population Query** (`popapi`): full coverage; [getEconomicStatus](https://docs.onemap.sg/#economic-status-data), [getEducationAttending](https://docs.onemap.sg/#education-status-data), [getEthnicGroup](https://docs.onemap.sg/#ethnic-distribution-data), [getHouseholdMonthlyIncomeWork](https://docs.onemap.sg/#work-income-for-household-monthly), [getHouseholdSize](https://docs.onemap.sg/#household-size-data), [getHouseholdStructure](https://docs.onemap.sg/#household-structure-data), [getIncomeFromWork](https://docs.onemap.sg/#income-from-work-data), [getIndustry](https://docs.onemap.sg/#industry-of-population-data), [getLanguageLiterate](https://docs.onemap.sg/#language-literacy-data), [getMaritalStatus](https://docs.onemap.sg/#marital-status-data), [getModeOfTransportSchool](https://docs.onemap.sg/#mode-of-transports-to-school-data), [getModeOfTransportWork](https://docs.onemap.sg/#mode-of-transport-to-work-data), [getOccupation](https://docs.onemap.sg/#occupation-data), [getPopulationAgeGroup](https://docs.onemap.sg/#age-data), [getReligion](https://docs.onemap.sg/#religion-data), [getSpokenAtHome](https://docs.onemap.sg/#spoken-language-data), [getTenancy](https://docs.onemap.sg/#tenancy-data), [getTypeOfDwellingHousehold](https://docs.onemap.sg/#tenancy-data), [getTypeOfDwellingPop](https://docs.onemap.sg/#dwelling-type-population-data)  
- **Routing Service** (`routingsvc`): [route](https://docs.onemap.sg/#route)

## Usage
### Authentication
In order to query data, most API endpoints in the OneMapSG API require a token. First-time users can register themselves using the [OneMapSG registration form](https://developers.onemap.sg/signup/). Subsequently, they can retrieve their tokens using the `get_token()` function with their email and password, for example:

```{r}
token <- get_token("user@email.com",  "password")
```

The function will also print a message informing users of the token's expiry date and time.

### Themes
Themes in the OneMap SG API refer to types of locations, such as kindergartens, parks, hawker centres etc. This package provides two functions related to querying themes:

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

### Population Query
Population Query API endpoints allow users to pull socio-economic datasets by planning area, which each endpoint representing a dataset (e.g. `getPopulationAgeGroup` provides age group summary statistics by planning area). This package combines querying different Popquery API endpoints into single functions. There are two similar functions for this purpose:

- `get_pop_query()` allows users to query a specific dataset for a specific town, year and gender (optional). It is faster for users who only require a specific value. 

```{r}
# example: return occupation summary data for Bedok town in year 2010
get_pop_query(token, "getOccupation", "Bedok", "2010")
```

- `get_pop_queries()` allows users to query multiple datasets for multiple towns and years. Note that rate-limiting is essential for large queries.

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

- `get_summ_route()` accepts the same parameters as `get_route()`, but only returns total time and total (and start and end points, if requested). Recognising that this API is most valuable for calculating total time travelled (as a improved measure of spatial distance compared to Euclidean distance), this function produces a cleaner output containing only the main variables of interest.

```{r}
# example: return tibble with total time, total distance and start and end points
get_route(token, c(1.319728, 103.8421), c(1.319728905, 103.8421581), "drive")
get_route(token, c(1.319728, 103.8421), c(1.319728905, 103.8421581), "pt",
          mode = "bus", max_dist = 300, n_itineraries = 2)
```

- `compare_routes()` allows the calculation of total time and distance for a tibble of start and end points. Users input a tibble of start and end points (and potentially other variables) and the function returns a tibble with additional columns, `total_time` and `total_dist`.

```{r}
# example: return tibble named df
compare_routes(token, df,
    "start_lat", "start_lon", "end_lat", "end_lon",
    routes = c("cycle", "walk"))
```
