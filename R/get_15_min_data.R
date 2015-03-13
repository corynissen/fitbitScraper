#' Get 15 minute interval data from fitbit.com
#'
#' Get 15 minute interval data from fitbit using cookie returned from login function
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
#' get_15_min_data(cookie, what="steps", date="2015-01-20")
#' }
#' get_15_min_data
get_15_min_data <- function(...){
  .Deprecated("get_intraday_data", package="fitbitScraper")
  get_intraday_data(...)
}

