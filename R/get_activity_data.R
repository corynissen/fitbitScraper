#' Get activity data from fitbit.com
#'
#' Get activity data from fitbit using cookie returned from login function
#' @param cookie Cookie returned after login, specifically the "u" cookie
#' @param start_date Date in YYYY-MM-DD format
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
#'  \item{duration_hours}{Duration in hours of the activity}
#'  \item{duration_minutes}{Duration in minutes of the activity}
#'  \item{duration_seconds}{Duration in seconds of the activity}
#'  \item{calories}{Calories burned during the activity}
#'  \item{steps}{Steps taken the activity}
#'  \item{start_datetime}{A POSIXct encoded start time for the activity}
#'  \item{end_datetime}{A POSIXct encoded end time for the activity}
#' @examples
#' \dontrun{
#' get_activity_data(cookie, start_date="2015-01-13", end_date="2015-01-20")
#' }
#' get_activity_data
get_activity_data <- function(cookie, start_date, end_date){
  if(!is.character(cookie)){stop("cookie must be a character string")}
  if(!is.character(start_date)){stop("start_date must be a character string")}
  if(!is.character(end_date)){stop("end_date must be a character string")}
  if(!grepl("[0-9]{4}-[0-9]{2}-[0-9]{2}", start_date)){stop('start_date must have format "YYYY-MM-DD"')}
  if(!grepl("[0-9]{4}-[0-9]{2}-[0-9]{2}", end_date)){stop('end_date must have format "YYYY-MM-DD"')}

  url <- "https://www.fitbit.com/ajaxapi"

  request <- paste0('{"serviceCalls":[{"id":"GET /api/2/user/activities/logs","name":"user","method":"getActivitiesLogs","args":{"fromDate":"',
                    start_date,
                    '","toDate":"',
                    end_date,
                    '","period":"day","offset":0,"limit":20}},{"id":"GET /api/2/user/activities/logs/summary","name":"user","method":"getActivitiesLogsSummary","args":{"fromDate":"',
                    start_date,
                    '","toDate":"',
                    end_date,
                    '","period":"day","offset":0,"limit":20}}],"template":"activities/modules/models/ajax.response.json.jsp"}'
  )

  csrfToken <- stringr::str_extract(cookie,
                                    "[A-Z0-9]{8}\\-[A-Z0-9]{4}\\-[A-Z0-9]{4}\\-[A-Z0-9]{4}\\-[0-9A-Z]{12}")
  body <- list(request=request, csrfToken = csrfToken)
  response <- httr::POST(url, body=body, httr::config(cookie=cookie))

  dat_string <- as(response, "character")
  dat_list <- RJSONIO::fromJSON(dat_string, asText=TRUE)

  df <- data.frame(id=sapply(dat_list[[2]]$result, "[[", "id"),
                   name=sapply(dat_list[[2]]$result, "[[", "name"),
                   date=sapply(dat_list[[2]]$result, "[[", "formattedDate"),
                   start_time=sapply(dat_list[[2]]$result, "[[", "formattedStartTime"),
                   distance=sapply(dat_list[[2]]$result, "[[", "formattedDistance"),
                   duration=sapply(dat_list[[2]]$result, "[[", "formattedDuration"),
                   duration_hours=sapply(dat_list[[2]]$result, "[[", "durationHours"),
                   duration_minutes=sapply(dat_list[[2]]$result, "[[", "durationMinutes"),
                   duration_seconds=sapply(dat_list[[2]]$result, "[[", "durationSeconds"),
                   calories=sapply(dat_list[[2]]$result, "[[", "calories"),
                   steps=sapply(dat_list[[2]]$result, "[[", "steps"),
                   stringsAsFactors=FALSE
  )
  df$duration_hours <- as.numeric(df$duration_hours)
  df$duration_minutes <- as.numeric(df$duration_minutes)
  df$duration_seconds <- as.numeric(df$duration_seconds)
  df$duration_hours[is.na(df$duration_hours)] <- 0
  df$duration_minutes[is.na(df$duration_minutes)] <- 0
  df$duration_seconds[is.na(df$duration_seconds)] <- 0
  tz <- Sys.timezone()
  if(is.null(tz) | is.na(tz)){tz <- format(Sys.time(),"%Z")}
  df$start_datetime <- as.POSIXct(paste0(df$date, " ", df$start_time),
                                  format="%Y-%m-%d %H:%M", tz=tz)
  df$end_datetime <- df$start_datetime + (df$duration_hours * 60 * 60) +
                     (df$duration_minutes * 60) + df$duration_seconds

  return(df)
}
