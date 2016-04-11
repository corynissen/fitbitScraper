#' Get sleep data from fitbit.com
#'
#' Get sleep data from fitbit using cookie returned from login function
#' @param cookie Cookie returned after login, specifically the "u" cookie
#' @param start_date Date in YYYY-MM-DD format
#' @param end_date Date in YYYY-MM-DD format
#' @keywords data
#' @export
#' @return A list with two things
#'  \item{summary}{A list of sleep summary values}
#'  \item{df}{A data frame containing various sleep values over time}
#' @examples
#' \dontrun{
#' get_sleep_data(cookie, start_date="2015-01-13", end_date="2015-01-20")
#' }
#' get_sleep_data
get_sleep_data <- function(cookie, start_date="2015-01-13", end_date="2015-01-20"){
  if(!is.character(cookie)){stop("cookie must be a character string")}
  if(!is.character(start_date)){stop("start_date must be a character string")}
  if(!is.character(end_date)){stop("end_date must be a character string")}
  if(!grepl("[0-9]{4}-[0-9]{2}-[0-9]{2}", start_date)){stop('start_date must have format "YYYY-MM-DD"')}
  if(!grepl("[0-9]{4}-[0-9]{2}-[0-9]{2}", end_date)){stop('end_date must have format "YYYY-MM-DD"')}

  url <- "https://www.fitbit.com/ajaxapi"
  request <- paste0('{"template":"/ajaxTemplate.jsp","serviceCalls":[{"name":"activityTileData","args":{"dateFrom":"',
                    start_date,
                    '","dateTo":"',
                    end_date,
                    '"},"method":"getSleepTileData"}]}'
                    )

  csrfToken <- stringr::str_extract(cookie,
    "[A-Z0-9]{8}\\-[A-Z0-9]{4}\\-[A-Z0-9]{4}\\-[A-Z0-9]{4}\\-[0-9A-Z]{12}")
  body <- list(request=request, csrfToken = csrfToken)
  response <- httr::POST(url, body=body, httr::config(cookie=cookie))

  dat_string <- methods::as(response, "character")
  dat_list <- jsonlite::fromJSON(dat_string)
  
  if("hasLoggedSleep" %in% names(dat_list)){
    summary <- list(avgSleepDuration = dat_list$avgSleepDuration,
                    avgSleepTime = dat_list$avgSleepTime,
                    avgSleepScore = dat_list$avgSleepScore,
                    avgGraphicPercent = dat_list$avgGraphicPercent)
    # get individual day data
    df <- dat_list[["entries"]]
  }else{
    stop("No sleep data available")
  }
  return(list(summary=summary, df=df))
}

