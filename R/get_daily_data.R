#' Get daily data from fitbit.com
#'
#' Get daily data from fitbit using cookie returned from login function
#' @param cookie Cookie returned after login, specifically the "u" cookie
#' @param what What data you wish to be returned. Options include "steps", "distance", "floors", "minutesVery", "caloriesBurnedVsIntake", "getTimeInHeartRateZonesPerDay", "getRestingHeartRateData"
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
                  "getTimeInHeartRateZonesPerDay", "getRestingHeartRateData")){
    stop('what must be one of "steps", "distance", "floors", "minutesVery", "caloriesBurnedVsIntake", "getTimeInHeartRateZonesPerDay", "getRestingHeartRateData"')
  }

  if(what %in% c("getTimeInHeartRateZonesPerDay", "getRestingHeartRateData")){
    url <- "https://www.fitbit.com/ajaxapi"
    request <- paste0('{"template":"/ajaxTemplate.jsp","serviceCalls":[{"name":"activityTileData","args":{"startDate":"',
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

  dat_string <- methods::as(response, "character")
  dat_list <- jsonlite::fromJSON(dat_string)

  if(what=="getTimeInHeartRateZonesPerDay"){
    df <- cbind(dat_list$dateTime, dat_list$value, stringsAsFactors=FALSE)
    names(df)[1:3] <- c("time", "zone1", "zone2", "zone3")
  }else if(what=="getRestingHeartRateData"){
    df <- dat_list$dataPoints
    df <- df[, c("date", "value")]
    names(df)[1:2] <- c("time", "restingHeartRate")
  }else if(what=="caloriesBurnedVsIntake"){
    df_burn <- dat_list[["graph"]][["dataSets"]][["activity"]][["dataPoints"]]
    df_int <- dat_list[["graph"]][["dataSets"]][["caloriesIntake"]][["dataPoints"]]
    names(df_burn)[1:2] <- c("time", "caloriesBurned")
    names(df_int)[1:2] <- c("time", "caloriesIntake")
    df <- merge(df_burn, df_int, by="time")
  }else{
    df <- dat_list[["graph"]][["dataSets"]][["activity"]][["dataPoints"]]
    names(df)[1:2] <- c("time", what)
  }

  if(what=="getRestingHeartRateData"){
    tz <- Sys.timezone()
    if(is.null(tz)){tz <- format(Sys.time(),"%Z")}
    df$time <- as.POSIXct(df$time, "%Y-%m-%d", tz=tz)
  }else{
    tz <- Sys.timezone()
    if(is.null(tz)){tz <- format(Sys.time(),"%Z")}
    df$time <- as.POSIXct(df$time, "%Y-%m-%d %H:%M:%S", tz=tz)
  }
  return(df)
}
