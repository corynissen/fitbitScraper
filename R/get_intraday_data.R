#' Get intraday data from fitbit.com
#'
#' Get intraday data from fitbit using cookie returned from login function
#' @param cookie Cookie returned after login, specifically the "u" cookie
#' @param what What data you wish to be returned. Options include "steps", "distance", "floors", "active-minutes", "calories-burned", "heart-rate"
#' @param date Date in YYYY-MM-DD format
#' @keywords data
#' @export
#' @return A dataframe with two columns:
#'  \item{time}{A POSIXct time value}
#'  \item{data}{The data column corresponding to the choice of "what"}
#' @examples
#' \dontrun{
#' get_intraday_data(cookie, what="steps", date="2015-01-20")
#' }
#' get_intraday_data
get_intraday_data <- function(cookie, what="steps", date){
  if(!is.character(cookie)){stop("cookie must be a character string")}
  if(!is.character(what)){stop("what must be a character string")}
  if(!is.character(date)){stop("date must be a character string")}
  if(!grepl("[0-9]{4}-[0-9]{2}-[0-9]{2}", date)){stop('date must have format "YYYY-MM-DD"')}
  if(!what %in% c("steps", "distance", "floors", "active-minutes", "calories-burned",
                  "heart-rate")){
    stop('what must be one of "steps", "distance", "floors", "active-minutes", "calories-burned",
         "heart-rate"')
  }

  url <- "https://www.fitbit.com/ajaxapi"
  request <- paste0('{"template":"/ajaxTemplate.jsp","serviceCalls":[{"name":"activityTileData","args":{"date":"',
                    date,
                    '","dataTypes":"',
                    what,
                    '"},"method":"getIntradayData"}]}'
  )
  csrfToken <- stringr::str_extract(cookie,
                                    "[A-Z0-9]{8}\\-[A-Z0-9]{4}\\-[A-Z0-9]{4}\\-[A-Z0-9]{4}\\-[0-9A-Z]{12}")
  body <- list(request=request, csrfToken = csrfToken)
  response <- httr::POST(url, body=body, httr::config(cookie=cookie))

  dat_string <- methods::as(response, "character")
  dat_list <- jsonlite::fromJSON(dat_string)
  
  df <- dat_list[["dataSets"]][["activity"]][["dataPoints"]][[1]]
  if(what=="heart-rate"){
    tz <- Sys.timezone()
    if(is.null(tz)){tz <- format(Sys.time(),"%Z")}
    df$time <- as.POSIXct(df$dateTime, "%Y-%m-%d %H:%M:%S", tz=tz)
  }else{
    names(df)[1:2] <- c("time", what)
    tz <- Sys.timezone()
    if(is.null(tz)){tz <- format(Sys.time(),"%Z")}
    df$time <- as.POSIXct(df$time, "%Y-%m-%d %H:%M:%S", tz=tz)
  }
  return(df)
}
