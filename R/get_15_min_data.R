#' Get 15 minute interval data from fitbit.com
#'
#' Get 15 minute interval data from fitbit using cookie returned from login function
#' @param ... Arguments from get_intraday_data()
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

