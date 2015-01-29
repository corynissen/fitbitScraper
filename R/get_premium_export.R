#' Get official data export from fitbit.com premium
#'
#' Get official data export from fitbit premium using cookie returned from login function. This should be used over individual calls to get_daily_data(), etc. if you subscribe to premium and data export is allowed. I'm not subscribed to premium, but it works for me...
#' @param cookie Cookie returned after login, specifically the "u" cookie
#' @param what What data you wish to be returned. Options include "BODY", "FOODS", "ACTIVITIES", "SLEEP"
#' @param start_date Date in YYYY-MM-DD format
#' @param end_date Date in YYYY-MM-DD format
#' @keywords data
#' @export
#' @return A list with two things
#'  \item{summary}{A list of sleep summary values}
#'  \item{df}{A data frame containing various sleep values over time}
#' @examples
#' \dontrun{
#' get_premium_export(cookie, what="ACTIVITIES", start_date="2015-01-13", end_date="2015-01-20")
#' }
#' get_premium_export
get_premium_export <- function(cookie, what="ACTIVITIES", start_date="2015-01-13", end_date="2015-01-20"){
  if(!is.character(cookie)){stop("cookie must be a character string")}
  if(!is.character(what)){stop("what must be a character string")}
  if(!is.character(start_date)){stop("start_date must be a character string")}
  if(!is.character(end_date)){stop("end_date must be a character string")}
  if(!grepl("[0-9]{4}-[0-9]{2}-[0-9]{2}", start_date)){stop('start_date must have format "YYYY-MM-DD"')}
  if(!grepl("[0-9]{4}-[0-9]{2}-[0-9]{2}", end_date)){stop('end_date must have format "YYYY-MM-DD"')}
  if(!what %in% c("BODY", "FOODS", "ACTIVITIES", "SLEEP")){
    stop('what must be one of "BODY", "FOODS", "ACTIVITIES", "SLEEP"')
  }

  url <- "https://www.fitbit.com/export/user/data"
  header <- list("Content-Type"="application/x-www-form-urlencoded",
                 "u"=cookie,
                 "Host"="www.fitbit.com",
                 "Origin"="https://www.fitbit.com",
                 "Referer"="https://www.fitbit.com/export/user/data",
                 "User-Agent"="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/40.0.2214.93 Safari/537.36",
                 "X-Requested-With"="XMLHttpRequest")
  body <- list("export"="true",
                  "dataPeriod.periodType"="CUSTOM",
                  "startDate"=start_date,
                  "endDate"=end_date,
                "dataExportType"=what,
                  "fileFormat"="CSV")

  response <- httr::POST(url, header=header, body=body,
                         httr::config(cookie=cookie))
  if(response$status_code!=200){
    stop("problem with request, this may be available only for premium subscribers")
  }
  file_id <- as(response, "character")
  file_id <- RJSONIO::fromJSON(file_id, asText=TRUE)
  file_id <- file_id["fileIdentifier"]

  # see if file ready for download
  get_file_status <- function(file_id){
    is_ready <- httr::GET(paste0("https://www.fitbit.com/premium/export?isExportedFileReady=true&fileIdentifier=",
                                 file_id))
    if("fileIsReady" %in% names(httr::content(is_ready))){
      is_ready <- httr::content(is_ready)$fileIsReady
    }else{
      stop("file_id not found while retrieving file status")
    }
    return(is_ready)
  }

  start <- Sys.time()
  is_ready <- get_file_status(file_id)
  while(!is_ready){
    if(Sys.time() - start > 10){
      stop("timeout waiting for file to generate")
    }
    Sys.sleep(.5)
    is_ready <- get_file_status(file_id)
  }

  a <- httr::GET(paste0("https://www.fitbit.com/premium/export/download/",
                      file_id))
  df <- read.csv(text=as(a, "character"), skip=1, stringsAsFactors=F)

  return(df)
}
