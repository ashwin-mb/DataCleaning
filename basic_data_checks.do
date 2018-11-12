/* 
	Author Name: Ashwin MB
	Data - 26/09/2018
	Last Edit - 26/09/2018
	Purpose - Comparing old data with new data
*/

clear all
pause off
set more off

*************** DP info comparison *************

*Loading new files*
use "H:\Ashwin\Dta_files\DP_forms.dta", clear

*Count of registered firms yearwise*
gen temp_year = year(Data_of_original_registration)
tab temp_year
drop temp_year

*Loading old files*
use "D:\data\DealerProfile.dta"

*Count of registered firms yearwise*
gen temp_year = year(dofc(RegistrationDate))
tab temp_year
drop temp_year

*************** Cancelled notices *******************
*Cancelled notices part of DP form*
use "H:\Ashwin\Dta_files\DP_forms.dta", clear

tab Current_status
gen cancellation_year = regexs(0) if regexm(Date_of_cancellation, "([0-9][0-9][0-9][0-9])")
destring cancellation_year, replace
replace cancellation_year = 2006 if cancellation_year < 2007
tostring cancellation_year, replace
replace cancellation_year = "Before 2007" if cancellation_year == "2006"
tab cancellation_year

//Cancellations per year, 283k years included
//Comment: 283k cancelled, 403k Registered

*Loading old files*
use "D:\data\CancellationForm.dta", clear
gen temp_year = year(dofc(CancellationDate))
tab temp_year


****************** Audit Notices *********************
*1. Check Mtin list*
*Load latest data*
use "H:\Ashwin\Dta_files\Audit_notices_1314.dta", clear
tempfile audit_notices
save `audit_notices'

*Merge with UnqiueMtin list* 
use "H:\Ashwin\Dta_files\unique_mtin_list.dta", clear
merge 1:m Mtin using `audit_notices'





*************** Form 16 ****************
*Loading new data*
use "H:\Ashwin\Dta_files\Form16_1314_2.dta", clear
tab Tax_Period



*Loading old files*
use "D:\data\form16_data.dta", clear




*Quarterwise filing of reports*
tab TaxPeriod













