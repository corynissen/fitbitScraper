#' Get daily data from fitbit using cookie returned from login function
#'
#' Get daily data from fitbit.com
#' @param cookie Cookie returned after login, specifically the "u" cookie
#' @param what What data you wish to be returned. Options include "steps", "distance", "floors", "minutesVery", "caloriesBurnedVsIntake"
#' @param start_date Date in YYYY-MM-DD format
#' @param end_date Date in YYYY-MM-DD format
#' @keywords data
#' @export
#' @examples
#' \dontrun{
#' get_daily_data(cookie, what="steps", start_date="2015-01-13", end_date="2015-01-20")
#' }
#' get_daily_data
get_daily_data <- function(cookie, what="steps", start_date, end_date){
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
  df$time <- as.POSIXct(df$time, "%Y-%m-%d %H:%M:%S")
  return(df)
}
