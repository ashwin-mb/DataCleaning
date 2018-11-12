/* 
	Author Name: Ashwin MB
	Data - 02/08/2018
	Last Edit - 02/08/2018
	Purpose - Do Sanity checks for 2A 2B data
*/

/*
New Data 
Load 1 year data 
Understand the variables, compare the variables asked in the MoU
Append the new data to create consolidated list
Compare this data to DP1 firms list information
Tabulate basic variables

Old Data
Compare column names and values
Compare basic variables
*/

* Append the new 2A data to create consolidated list * 
use "H:\Ashwin\Raw_dta_files\2A_1314.dta", clear
gen fy = "13-14"

append using "H:\Ashwin\Raw_dta_files\2A_1415.dta"
replace fy = "14-15" if fy == ""

append using "H:\Ashwin\Raw_dta_files\2A_1516.dta"
replace fy = "15-16" if fy == ""

append using "H:\Ashwin\Raw_dta_files\2A_1617.dta"
replace fy = "16-17" if fy == ""

**Consolidated list of 2A forms**
save "H:\Ashwin\Processed_dta_files\2A_consolidated.dta", replace

* Append the new 2B data to create consolidated list * 
use "H:\Ashwin\Raw_dta_files\2B_1314.dta", clear
gen fy = "13-14"

append using "H:\Ashwin\Raw_dta_files\2B_1415.dta"
replace fy = "14-15" if fy == ""

append using "H:\Ashwin\Raw_dta_files\2B_1516.dta"
replace fy = "15-16" if fy == ""

append using "H:\Ashwin\Raw_dta_files\2B_1617.dta"
replace fy = "16-17" if fy == ""

*Consolidated list of 2B forms*
save "H:\Ashwin\Processed_dta_files\2B_consolidated.dta", replace

** Analyse 2A forms **
use "H:\Ashwin\Processed_dta_files\2A_consolidated.dta", clear

* Remove duplicates and check with master DP files * 
use "H:\Ashwin\Processed_dta_files\2A_consolidated.dta", clear
keep Mtin

duplicates tag, gen(repeats)
gsort -repeats
duplicates drop Mtin, force

rename Mtin mtin

tempfile intermediate
save `intermediate'

use "H:\Ashwin\Processed_dta_files\DP_mtin_list.dta", clear

merge m:1 mtin using `intermediate'

* tabulate variables of 2A *
use "H:\Ashwin\Processed_dta_files\2A_consolidated.dta", clear
tab fy

use "H:\Ashwin\Processed_dta_files\2A_consolidated.dta", clear
tab fy

* Old data *

use "D:\Data\annexure_2A2B_monthly_201213.dta", clear

use "D:\Data\annexure_2A2B_quarterly_2013.dta", clear

use "D:\Data\annexure_2A2B_quarterly_2014.dta", clear








