#' Get activity data from fitbit.com
#'
#' Get activity data from fitbit using cookie returned from login function
#' @param cookie Cookie returned after login, specifically the "u" cookie
#' @param end_date Date in YYYY-MM-DD format
#' @keywords data
#' @export
#' @return A dataframe with thirteen columns:
#'  \item{id}{The fitbit ID of the activity}
#'  \item{name}{Name for the type of activity}
#'  \item{date}{Date of the activity}
#'  \item{start_time}{Start time for the activity}
#'  \item{distance}{Distance travelled during the activity}
#'  \item{duration}{Duration in hours:minutes:seconds of the activity}
#'  \item{calories}{Calories burned during the activity}
#'  \item{steps}{Steps taken the activity}
#'  \item{start_datetime}{A POSIXct encoded start time for the activity}
#'  \item{end_datetime}{A POSIXct encoded end time for the activity}
#' @examples
#' \dontrun{
#' get_activity_data(cookie, end_date="2015-01-20")
#' }
#' get_activity_data
get_activity_data <- function(cookie, end_date){
  if(!is.character(cookie)){stop("cookie must be a character string")}
  if(!is.character(end_date)){stop("end_date must be a character string")}
  if(!grepl("[0-9]{4}-[0-9]{2}-[0-9]{2}", end_date)){stop('end_date must have format "YYYY-MM-DD"')}

  url <- "https://www.fitbit.com/ajaxapi"
 
  request <- paste0('{"serviceCalls":[{"id":"GET /api/2/user/activities/logs","name":"user","method":"getActivitiesLogs","args":{',
                    '"beforeDate":"',
                    end_date,
                    'T00:00:00",',
                    '"period":"day","offset":0,"limit":100}},{"id":"GET /api/2/user/activities/logs/summary","name":"user","method":"getActivitiesLogsSummary","args":{"fromDate":"',
                    end_date,
                    '","toDate":"',
                    end_date, 
                    '","period":"day","offset":0,"limit":10}}],"template":"activities/modules/models/ajax.response.json.jsp"}'
  )
  
  csrfToken <- stringr::str_extract(cookie,
                                    "[A-Z0-9]{8}\\-[A-Z0-9]{4}\\-[A-Z0-9]{4}\\-[A-Z0-9]{4}\\-[0-9A-Z]{12}")
  body <- list(request=request, csrfToken = csrfToken)
  response <- httr::POST(url, body=body, httr::config(cookie=cookie))

  dat_string <- methods::as(response, "character")
  dat_list <- jsonlite::fromJSON(dat_string)
  
  if("GET /api/2/user/activities/logs" %in% names(dat_list)){
    df <- dat_list[["GET /api/2/user/activities/logs"]]["result"][[1]]
  }else{
    df <- NULL
    print("unable to retrieve activities data")
  }
  
  tz <- Sys.timezone()
  if(is.null(tz) | is.na(tz)){tz <- format(Sys.time(),"%Z")}
  df$start_datetime <- as.POSIXct(paste0(df$date, " ", df$formattedStartTime),
                                  format="%Y-%m-%d %H:%M", tz=tz)
  df$end_datetime <- as.POSIXct(paste0(df$date, " ", df$formattedEndTime),
                                  format="%Y-%m-%d %H:%M", tz=tz)
  
  return(df)
}
