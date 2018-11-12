/* 
	Author Name: Ashwin MB
	Data - 02/08/2018
	Last Edit - 02/08/2018
	Purpose - Do Sanity checks for cancelled data
*/

/*
New Data 
Load new data 
Append the new data to create consolidated list
Compare this data to DP1 firms list information
Tabulate basic variables

Old Data
Compare column names and values
Compare basic variables
*/


* Append the new data to create consolidated list * 
use "H:\Ashwin\Raw_dta_files\Form37_1314.dta", clear
gen fy = "13-14"

append using "H:\Ashwin\Raw_dta_files\Form37_1415.dta"
replace fy = "14-15" if fy == ""

append using "H:\Ashwin\Raw_dta_files\Form37_1516.dta"
replace fy = "15-16" if fy == ""

append using "H:\Ashwin\Raw_dta_files\Form37_1617.dta"
replace fy = "16-17" if fy == ""

*Consolidated list of form 37 information*
save "H:\Ashwin\Processed_dta_files\Form37_consolidated.dta", replace

** Compare this data to DP1 firms list information **
use "H:\Ashwin\Processed_dta_files\Form37_consolidated.dta", clear

*Drop duplicate MTin values*
duplicates tag, gen(repeats)
gsort -repeats
duplicates drop MTin, force
keep MTin
rename MTin mtin
tempfile intermediate
save `intermediate'

use "H:\Ashwin\Processed_dta_files\DP_mtin_list.dta", clear

merge m:1 mtin using `intermediate'

** Compare old data **

use "D:\Data\form37_data_auditnotice.dta", clear 
gsort DateActualNotice


duplicates tag, gen(repeats)
gsort -repeats
duplicates drop DealerTin, force
keep DealerTin










