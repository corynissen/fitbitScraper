#' Get daily data from fitbit.com
#'
#' Get daily data from fitbit using cookie returned from login function
#' @param cookie Cookie returned after login, specifically the "u" cookie
#' @param what What data you wish to be returned. Options include "steps", "distance", "floors", "minutesVery", "caloriesBurnedVsIntake"
#' @param start_date Date in YYYY-MM-DD format
#' @param end_date Date in YYYY-MM-DD format
#' @keywords data
#' @export
#' @return A dataframe with two columns:
#'  \item{time}{A POSIXct time value}
#'  \item{data}{The data column corresponding to the choice of "what"}
#' @examples
#' \dontrun{
#' get_daily_data(cookie, what="steps", start_date="2015-01-13", end_date="2015-01-20")
#' }
#' get_daily_data
get_daily_data <- function(cookie, what="steps", start_date, end_date){
  if(!is.character(cookie)){stop("cookie must be a character string")}
  if(!is.character(what)){stop("what must be a character string")}
  if(!is.character(start_date)){stop("start_date must be a character string")}
  if(!is.character(end_date)){stop("end_date must be a character string")}
  if(!grepl("[0-9]{4}-[0-9]{2}-[0-9]{2}", start_date)){stop('start_date must have format "YYYY-MM-DD"')}
  if(!grepl("[0-9]{4}-[0-9]{2}-[0-9]{2}", end_date)){stop('end_date must have format "YYYY-MM-DD"')}
  if(!what %in% c("steps", "distance", "floors", "minutesVery", "caloriesBurnedVsIntake",
                  "getTimeInHeartRateZonesPerDay")){
    stop('what must be one of "steps", "distance", "floors", "minutesVery", "caloriesBurnedVsIntake",
         "getTimeInHeartRateZonesPerDay"')
  }

  url <- "https://www.fitbit.com/graph/getNewGraphData"
  query <- list("type" = what,
                "dateFrom" = start_date,
                "dateTo" = end_date,
                "granularity" = "DAILY",
                "hidePrecreationData" = "false")

  response <- httr::GET(url, query=query, httr::config(cookie=cookie))

  dat_string <- as(response, "character")
  dat_list <- RJSONIO::fromJSON(dat_string, asText=TRUE)
  dat_list <- dat_list[[1]]$dataSets$activity$dataPoints
  dat_list <- sapply(dat_list, "[")
  df <- data.frame(time=as.character(unlist(dat_list[1,])),
                   data=as.numeric(unlist(dat_list[2,])),
                   stringsAsFactors=F)
  names(df) <- c("time", what)
  tz <- Sys.timezone()
  if(is.null(tz)){tz <- format(Sys.time(),"%Z")}
  df$time <- as.POSIXct(df$time, "%Y-%m-%d %H:%M:%S", tz=tz)
  return(df)
}

what <- "getTimeInHeartRateZonesPerDay"
startDate <- "2015-03-01"
endDate <- "2015-03-10"
url <- "https://www.fitbit.com/ajaxapi"
request <- paste0('{"template":"/mgmt/ajaxTemplate.jsp","serviceCalls":[{"name":"activityTileData","args":{"startDate":"',
                  startDate,
                  '","endDate":"',
                  endDate,
                  '"},"method":"',
                  what,
                  '"}]}'
)
csrfToken <- stringr::str_extract(cookie,
                                  "[A-Z0-9]{8}\\-[A-Z0-9]{4}\\-[A-Z0-9]{4}\\-[A-Z0-9]{4}\\-[0-9A-Z]{12}")
body <- list(request=request, csrfToken = csrfToken)
response <- httr::POST(url, body=body, httr::config(cookie=cookie))

