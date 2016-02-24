
### fitbitScraper 0.1.5
* added <> around URLs in DESCRIPTION
* added methods and utils to imports in DESCRIPTION
* added corresponding methods:: and utils:: in code
* changed get_activity_data() function to have a working end_date.
* pull request #7 calories burned vs intake
* pull request #5 Add check.names=T for creating data.frames
* pull request #4 slight changes to sleep variable names
* pull request #3 Update login.R

### fitbitScraper 0.1.4
* added get_activity_data() function
* added "getRestingHeartRateData" to get_daily_data() function
* added rememberMe parameter to login function
* merged pull request #2, a change to the login function

### fitbitScraper 0.1.3
* Changed the API calls to match changes on fitbit end of things.

### fitbitScraper 0.1.2
* Added get_sleep_data()
* Added get_premium_export()
* Changed output column of get_daily_data(), get_15_min_data(), and get_weight_data() to correspond to the data type requested... for example: "weight" instead of "data"", "steps" instead of "data"
* Added heart-rate for get_15_min_data() and get_daily_data()
* added get_intraday_data()
* Deprecated get_15_min_data(), use get_intraday_data() instead

### fitbitScraper 0.1.1
* Basic checks included for arguments
* tz added to the return dataframes as.POSIXct date field
* documentation cleanup

### fitbitScraper 0.1  
* No error checking
* Three functions: login, get_daily_data, get_15_min_data 
