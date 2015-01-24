#' Get 15 minute interval data from fitbit using cookie returned from login function
#'
#' Get 15 minute interval data from fitbit.com
#' @param cookie Cookie returned after login, specifically the "u" cookie
#' @param what What data you wish to be returned. Options include "steps", "distance", "floors", "active-minutes", "calories-burned"
#' @param date Date in YYYY-MM-DD format
#' @keywords data
#' @export
#' @examples
#' \dontrun{
#' get_15_min_data(cookie, what="steps", date="2015-01-20")
#' }
#' get_15_min_data
get_15_min_data <- function(cookie, what="steps", date){
  if(!is.character(cookie)){stop("cookie must be a character string")}
  if(!is.character(what)){stop("what must be a character string")}
  if(!is.character(date)){stop("date must be a character string")}
  if(!grepl("[0-9]{4}-[0-9]{2}-[0-9]{2}", date)){stop('date must have format "YYYY-MM-DD"')}
  if(!what %in% c("steps", "distance", "floors", "active-minutes", "calories-burned")){
    stop('what must be one of "steps", "distance", "floors", "active-minutes", "calories-burned"')
  }

  url <- "https://www.fitbit.com/ajaxapi"
  request <- paste0('{"template":"/mgmt/ajaxTemplate.jsp","serviceCalls":[{"name":"activityTileData","args":{"date":"',
                    date,
                    '","dataTypes":"',
                    what,
                    '"},"method":"getIntradayData"}]}'
  )
  csrfToken <- stringr::str_extract(cookie,
                           "[A-Z0-9]{8}\\-[A-Z0-9]{4}\\-[A-Z0-9]{4}\\-[A-Z0-9]{4}\\-[0-9A-Z]{12}")
  body <- list(request=request, csrfToken = csrfToken)
  response <- httr::POST(url, body=body, httr::config(cookie=cookie))

  dat_string <- as(response, "character")
  dat_list <- RJSONIO::fromJSON(dat_string, asText=TRUE)
  dat_list <- dat_list[[1]]$dataSets$activity$dataPoints
  dat_list <- sapply(dat_list, "[")
  df <- data.frame(time=as.character(unlist(dat_list[1,])),
                   data=as.numeric(unlist(dat_list[2,])),
                   stringsAsFactors=F)
  tz <- Sys.timezone()
  if(is.null(tz)){tz <- format(Sys.time(),"%Z")}
  df$time <- as.POSIXct(df$time, "%Y-%m-%d %H:%M:%S", tz=tz)
  return(df)
}
