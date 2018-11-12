/************************************************* 
* Filename: 
* Input: H:/Ashwin/dta/Form16_year_3.dta
* Purpose: Creates a consolidated data of form 16 challan data
			and cleans all the variables
* Output: H:/Ashwin/dta/Form16_tds_consolidated.dta
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
global input_path "H:/Ashwin/dta/final"
global input_path2 "H:/Ashwin/dta/intermediate"

*output files*


*--------------------------------------------------------
** Combine Form 16 TDS data for every year
*--------------------------------------------------------
foreach var in "1314" "1415" "1516" "1617" {
use "${input_path2}/form16_`var'_tds.dta", clear
gen year = `var'
save "${input_path2}/form16_`var'_tds.dta", replace
}

use "${input_path2}/Form16_1314_3.dta", clear

foreach var in "1415" "1516" "1617" {
append using "${input_path2}\form16_`var'_tds.dta"
}
		
save "${input_path}/form16_tds_consolidated.dta", replace

*--------------------------------------------------------
** Identify and insert tax quarter 
*--------------------------------------------------------
** Merge tds consolidated with returnid-taxperiod table
	/* Inserting tax quarter information with tds details */
use "${input_path}/form16_tds_consolidated.dta", clear

merge m:1 MReturn_ID using ///
	"${input_path}/returnid_taxperiod_consolidated.dta"

keep if _merge==3
drop _merge

save "${input_path}/form16_tds_consolidated.dta", replace

*****Tempt*****
use "${input_path2}/form16_1415_tds.dta", clear
keep if Mtin == "1779386"

****TEmpt*****

