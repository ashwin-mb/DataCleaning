 /* 
	Author Name: Ashwin MB
	Data - 02/08/2018
	Last Edit - 02/08/2018
	Purpose - Do Sanity checks for Form 16 data
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

* Merge with master DP file * 
use "H:\Ashwin\Raw_dta_files\Form16_1213.dta", clear
gsort Mtin



keep Mtin

duplicates tag, gen(repeats)
gsort -repeats
duplicates drop Mtin, force

rename Mtin mtin

tempfile intermediate
save `intermediate'

use "H:\Ashwin\Processed_dta_files\DP_mtin_list.dta", clear

merge m:1 mtin using `intermediate'

* Old data *

use "D:\Data\form16_data.dta", clear


* Check no. of returning filed in each quarter *
tab TaxPeriod

gsort DealerTIN
keep DealerTIN

duplicates tag, gen(repeats)
gsort -repeats
duplicates drop DealerTin, force
keep DealerTin

* Tabulate different values *
tab TDSDetails
tab Status
sort Tin



