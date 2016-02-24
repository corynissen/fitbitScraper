#' Get weight data from fitbit.com
#'
#' Get weight data from fitbit using cookie returned from login function
#' @param cookie Cookie returned after login, specifically the "u" cookie
#' @param start_date Date in YYYY-MM-DD format
#' @param end_date Date in YYYY-MM-DD format
#' @keywords data
#' @export
#' @return A dataframe with two columns:
#'  \item{time}{A POSIXct time value}
#'  \item{weight}{The data column corresponding to weight}
#' @examples
#' \dontrun{
#' get_weight_data(cookie, start_date="2015-01-13", end_date="2015-01-20")
#' }
#' get_weight_data
get_weight_data <- function(cookie, start_date, end_date){
  if(!is.character(cookie)){stop("cookie must be a character string")}
  if(!is.character(start_date)){stop("start_date must be a character string")}
  if(!is.character(end_date)){stop("end_date must be a character string")}
  if(!grepl("[0-9]{4}-[0-9]{2}-[0-9]{2}", start_date)){stop('start_date must have format "YYYY-MM-DD"')}
  if(!grepl("[0-9]{4}-[0-9]{2}-[0-9]{2}", end_date)){stop('end_date must have format "YYYY-MM-DD"')}

  url <- "https://www.fitbit.com/graph/getNewGraphData"
  query <- list("type" = "weight",
                "dateFrom" = start_date,
                "dateTo" = end_date)

  response <- httr::GET(url, query=query, httr::config(cookie=cookie))

  dat_string <- methods::as(response, "character")
  dat_list <- RJSONIO::fromJSON(dat_string, asText=TRUE)
  dat_list <- dat_list[[1]]$dataSets$weight$dataPoints
  dat_list <- sapply(dat_list, "[")
  df <- data.frame(time=as.character(unlist(dat_list[1,])),
                   weight=as.numeric(unlist(dat_list[2,])),
                   stringsAsFactors=F)
  tz <- Sys.timezone()
  if(is.null(tz)){tz <- format(Sys.time(),"%Z")}
  df$time <- as.POSIXct(df$time, "%Y-%m-%d %H:%M:%S", tz=tz)
  return(df)
}
