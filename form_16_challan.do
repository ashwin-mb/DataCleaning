/************************************************* 
* Filename: 
* Input: 
* Purpose: Form 16 Challan data: Created consolidated list of Challan data 
	          of 5 years and renamed variables;
* Output:
* Author: Ashwin MB
* Date: 25/09/2018
* Last modified: 17/10/2018 (Ashwin)
****************************************************/

** Initializing environment

clear all
version 1
set more off
qui cap log c
set mem 100m

*--------------------------------------------------------
** Setting directories and files
*--------------------------------------------------------

*input files*
global input_path1 "H:/Ashwin/dta/original"
global input_path2 "H:/Ashwin/dta/intermediate"
global input_path3 "H:/Ashwin/dta/intermediate2"
global temp_path1 "H:/Ashwin/dta/temp"
global old_path "D:/data"

*output files*
global output_path "H:/Ashwin/dta/final"
global qc_path "H:/Ashwin/dta/qc"
global prob_path "H:/Ashwin/dta/prob"
global sample_path "H:/Ashwin/dta/sample"

*--------------------------------------------------------
** Merging all challan form 16 data (12-13 data got deleted - fix it)
*--------------------------------------------------------
foreach var in "1213" "1314" "1415" "1516" "1617" {
use "${input_path}/form16_`var'_challan.dta", clear
replace year = `var'
save "${input_path}/form16_`var'_challan.dta", replace
}

use "${input_path}/form16_1213_challan.dta", clear

foreach var in "1314" "1415" "1516" "1617" {
append using "${input_path}\form16_`var'_challan.dta"
}

rename (From_Date To_Date Deposit_Date Amount) ///
		(from_date to_date deposit_date amount)
		
save "${output_path}/form16_challan_consolidated.dta", replace

*--------------------------------------------------------
** Add TaxPeriod to challan form16 data
*-------------------------------------------------------

use "${output_path}/form16_challan_consolidated.dta", clear

//order from_date, before(to_date)
gen from_month = month(dofc(from_date))
gen to_month   = month(dofc(to_date))
gen flag_month = 1 if from_month !=to_month
tostring from_month, replace
tostring to_month, replace
gen flag_quarter = from_month + to_month
tab flag_quarter if flag_month ==1

gen from_year = year(dofc(from_date))
gen to_year   = year(dofc(to_date))
gen flag_year = 1 if from_year !=to_year

drop TaxPeriod
gen TaxPeriod = ""
foreach var in 2013 2014 2015 2016 {
replace TaxPeriod = "First Quarter - `var'" if flag_quarter == "13" ///
				& from_year == `var' & to_year == `var'
}

foreach var in 2013 2014 2015 2016 {
replace TaxPeriod = "Second Quarter - `var'" if flag_quarter == "46" ///
				& from_year == `var' & to_year == `var'
}

foreach var in 2013 2014 2015 2016 {
replace TaxPeriod = "Third Quarter - `var'" if flag_quarter == "79" ///
				& from_year == `var' & to_year == `var'
}

foreach var in 2013 2014 2015 2016 {
replace TaxPeriod = "Fourth Quarter - `var'" if flag_quarter == "1012" ///
				& from_year == `var' & to_year == `var'
}
