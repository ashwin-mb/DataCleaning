  /************************************************* 
* Filename: 
* Input: 
* Purpose: This do files creates sample data sets for all forms
			* DP form
			* Form 16
			* Audit notices
			* Bogus firms
			* 2a 2b
			
* Output:
* Author: Ashwin MB
* Date: 17/10/2018
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

*output files*
global output_path "H:/Ashwin/dta/final"
global qc_path "H:/Ashwin/dta/qc"
global prob_path "H:/Ashwin/dta/prob"

*--------------------------------------------------------
** DP1 - Create sample data
*--------------------------------------------------------

*Create sample data
	/*Extract top 10000 firms for each year between 2000-2018 
		to create sample data*/
		
use "${output_path}/dp_form.dta", clear 
gen reg_year = year(original_registration_date)

bysort reg_year: gen number= _n
keep if number <=10000 & (reg_year >1999 & reg_year <2019)
drop number

save "${sample_output_path}/sample_dp.dta", replace

*--------------------------------------------------------
** Form 16 - Create sample data
*--------------------------------------------------------

*Creating a consolidated list for Form 16 is become an enormous file*
	/*Extract top 20000 rows for each year to create sample data*/

foreach var in "1213" "1314" "1415" "1516" "1617" {
use "${output_path}\Form16_`var'_2.dta", clear
gsort Mtin Tax_Period
gen number= _n
keep if number <= 20000
drop number

save "${sample_output_path}\sample_form16_`var'_consolidated.dta", replace
}


** Merge the sample data from every year

use "${output_path}\sample_form16_1213_consolidated.dta", clear

foreach var in  "1314" "1415" "1516" "1617" {
append using "${output_path}\sample_form16_`var'_consolidated.dta"
}

save "${sample_output_path}\sample_form16", replace

** Later: Manually delete consolidated file for every year from the location

*--------------------------------------------------------
** Form 16 Challan - Create sample data
*--------------------------------------------------------
** Create sample data
	/* Extract top 10000 rows for each year to create sample data */

use "${output_path}\Form16_challan_consolidated.dta", clear

bysort year: gen number= _n
keep if number <=10000
drop number

save "${sample_output_path}\sample_form16_challan.dta", replace

*--------------------------------------------------------
** Form 16 TDS - Create sample data
*--------------------------------------------------------
*Create sample data: Extract top 1000 rows for each year to create sample data*

use "${output_path}\Form16_tds_consolidated.dta", clear

bysort year: gen number= _n
keep if number <=10000
drop number

save "${sample_output_path}\sample_form16_tds.dta", replace






