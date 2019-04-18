/************************************************* 
* Filename: 
* Input: H:/Ashwin/dta/Non_existing_firm_year.dta
* Purpose: Creates consolidated list of bogus firms
* Output: H:/Ashwin/dta/Non_existing_firm_consolidated.dta
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

*output files*
global output_path "H:/Ashwin/dta/final"
global analysis_path "H:/Ashwin/dta/analysis"
global qc_path "H:/Ashwin/dta/qc"
global prob_path "H:/Ashwin/dta/prob"


*--------------------------------------------------------
** Combine bogus firms list data for every year
*--------------------------------------------------------
foreach var in "1213" "1314" "1415" "1516" "1617" {
use "${input_path}/bogus_`var'.dta", clear
gen year = `var'
save "${input_path}/bogus_`var'.dta", replace
}

use "${input_path/bogus_1213.dta", clear

foreach var in "1314" "1415" "1516" "1617" {
append using "${input_path}\bogus_`var'.dta"
}

rename Masked_TIN Mtin	
rename year inspection_year	
save "${output_path}/bogus_consolidated.dta", replace







