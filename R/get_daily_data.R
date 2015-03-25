#' Get daily data from fitbit.com
#'
#' Get daily data from fitbit using cookie returned from login function
#' @param cookie Cookie returned after login, specifically the "u" cookie
#' @param what What data you wish to be returned. Options include "steps", "distance", "floors", "minutesVery", "caloriesBurnedVsIntake", "getTimeInHeartRateZonesPerDay"
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

  if(what=="getTimeInHeartRateZonesPerDay"){
    url <- "https://www.fitbit.com/ajaxapi"
    request <- paste0('{"template":"/mgmt/ajaxTemplate.jsp","serviceCalls":[{"name":"activityTileData","args":{"startDate":"',
                      start_date,
                      '","endDate":"',
                      end_date,
                      '"},"method":"',
                      what,
                      '"}]}'
    )
    csrfToken <- stringr::str_extract(cookie,
                                      "[A-Z0-9]{8}\\-[A-Z0-9]{4}\\-[A-Z0-9]{4}\\-[A-Z0-9]{4}\\-[0-9A-Z]{12}")
    body <- list(request=request, csrfToken = csrfToken)
    response <- httr::POST(url, body=body, httr::config(cookie=cookie))
  }else{
    url <- "https://www.fitbit.com/graph/getNewGraphData"
    query <- list("type" = what,
                  "dateFrom" = start_date,
                  "dateTo" = end_date,
                  "granularity" = "DAILY",
                  "hidePrecreationData" = "false")

    response <- httr::GET(url, query=query, httr::config(cookie=cookie))
  }

  dat_string <- as(response, "character")
  dat_list <- RJSONIO::fromJSON(dat_string, asText=TRUE)

  if(what=="getTimeInHeartRateZonesPerDay"){
    zones <- sapply(dat_list, "[", "value")
    times <- as.character(unlist(sapply(dat_list, "[", "dateTime")))
    if(is.null(unlist(sapply(zones, "[", "IN_DEFAULT_ZONE_1")))){
      zone1 <- rep(0, length(times))
    }else{
      zone1 <- sapply(zones, "[", "IN_DEFAULT_ZONE_1")
      zone1 <- unname(sapply(zone1, function(x)ifelse(is.null(x), 0, x)))
    }
    if(is.null(unlist(sapply(zones, "[", "IN_DEFAULT_ZONE_2")))){
      zone2 <- rep(0, length(times))
    }else{
      zone2 <- sapply(zones, "[", "IN_DEFAULT_ZONE_2")
      zone2 <- unname(sapply(zone2, function(x)ifelse(is.null(x), 0, x)))
    }
    if(is.null(unlist(sapply(zones, "[", "IN_DEFAULT_ZONE_3")))){
      zone3 <- rep(0, length(times))
    }else{
      zone3 <- sapply(zones, "[", "IN_DEFAULT_ZONE_3")
      zone3 <- unname(sapply(zone3, function(x)ifelse(is.null(x), 0, x)))
    }
    df <- data.frame(time=times,
                     zone1=zone1,
                     zone2=zone2,
                     zone3=zone3,
                     stringsAsFactors=F)
  }else{
    dat_list <- dat_list[[1]]$dataSets$activity$dataPoints
    df <- data.frame(time=as.character(unlist(sapply(dat_list, "[", "dateTime"))),
                     data=as.numeric(unlist(sapply(dat_list, "[", 2))),
                     stringsAsFactors=F)
    names(df) <- c("time", what)
  }

  tz <- Sys.timezone()
  if(is.null(tz)){tz <- format(Sys.time(),"%Z")}
  df$time <- as.POSIXct(df$time, "%Y-%m-%d %H:%M:%S", tz=tz)
  return(df)
}
