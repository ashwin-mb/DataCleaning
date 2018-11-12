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
global input_path "H:/Ashwin/dta/intermediate"

*output files*
global output_path "H:/Ashwin/dta/final"

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

