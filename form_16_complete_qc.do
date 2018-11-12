/************************************************* 
* Filename: 
* Input: H:/Ashwin/dta/
* Purpose: This code conducts quality checks
* Output: H:/Ashwin/dta/
* Author: Ashwin MB
* Date: 25/09/2018
* Last modified: 22/10/2018 (Ashwin)
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

******** Comparing Mtin of Form16 with original Mtin list *******
*Merge with UnqiueMtin list* 
foreach var in "1213" "1314" "1415" "1516" "1617" {
use "${input_path}/unique_mtin_list.dta", clear
tempfile form16_data
save `form16_data'

* Merge with Mtin original list*
use "${input_path}/form16_1213_complete.dta", clear
merge m:1 Mtin using `form16_data'
}

********* Cancelled firms *****************
	/* Merging cancelled firms data with form16 returns data */
	
foreach var in "1213" "1314" "1415" "1516" "1617" {
use "${input_path}/cancelled_mtin_list.dta", clear
tempfile form16_data
save `form16_data' 

use "${input_path}/form16_`var'_complete.dta", clear
keep Mtin
duplicates drop Mtin, force
merge m:1 Mtin using `form16_data' 

drop if _merge !=3
keep Mtin cancellation_year 
tab cancellation_year
}

* Number of firms, total tax etc. are calculated in another do file *
//dta file "H:\Ashwin\demonetization\dta\output/demonetization_data.dta", replace
// do file "D:/Ashwin/do/demonetization_data.do

*--------------------------------------------------------
** TDS values
*--------------------------------------------------------

** Comparing Form16_consolidated & TDS_consolidated for TDS values

* Aggregating TDS data at Mtin TaxPeriod level
use "${output_path}/form16_tds_consolidated.dta", clear
bys Mtin Tax_Period : egen tds_tin_quarter = sum(TDSAmount)
duplicates drop Mtin Tax_Period, force
save "${qc_path}/form16_tds_tin_period_sum.dta", replace

* Aggregating TDS data at ReturnID level
use "${output_path}/form16_tds_consolidated.dta", clear
bys MReturn_ID: egen tds_returnid = sum(TDSAmount)
duplicates drop MReturn_ID, force
save "${qc_path}/form16_tds_return_sum.dta", replace

** Compare with Form16_consolidated data

* Checking for duplicates at ReturnID level
use "${output_path}/form16_data_consolidated.dta", clear
duplicates tag MReturn_ID, gen(repeat1)
keep if repeat1 != 0 
save "${prob_path}/form16_data_mtin_duplicates.dta", replace

** Compare TDS value at Return ID level with aggregated TDS data
use "${output_path}/form16_data_consolidated.dta", clear
keep MReturn_ID TaxPeriod ReturnType Mtin TDSCertificates DateofReturnFiled

* Compare values that merged
merge m:1 MReturn_ID using "${qc_path}/form16_tds_return_sum.dta"
keep if  _merge ==3 

gen flag = 0 
replace flag = 1 if TDSCertificates != tds_returnid

gen dif = TDSCertificates - tds_returnid
replace flag = 0 if dif <= 1 & dif >= -1
tab flag
 
/*

       flag |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |    100,338       99.46       99.46
          1 |        546        0.54      100.00
------------+-----------------------------------
      Total |    100,884      100.00

*/
keep if flag == 1 
save "${prob_path}/tds_return_merged_diff.dta", replace

** Compare data at quarter level
use "${output_path}/form16_data_consolidated.dta", clear
keep MReturn_ID TaxPeriod ReturnType Mtin TDSCertificates DateofReturnFiled

bysort Mtin TaxPeriod: egen tds_total_quarter = sum(TDSCertificate)
duplicates drop TaxPeriod Mtin, force
drop MReturn_ID ReturnType DateofReturnFiled
save "${qc_path}/form16_data_tds_tin_period_sum.dta", replace

* Rename column names for merging
use "${qc_path}/form16_tds_tin_period_sum.dta", clear
rename Tax_Period TaxPeriod
save "${qc_path}/form16_tds_tin_period_sum.dta", replace

* Merge Form16_data & Form16_tds at Mtin quarter level 
use "${qc_path}/form16_data_tds_tin_period_sum.dta", clear
merge m:1 Mtin TaxPeriod using "${qc_path}/form16_tds_tin_period_sum.dta"
drop TDSCertificates MReturn_ID Date TDSAmount year
keep if _merge ==3

gen flag = 0 
replace flag = 1 if tds_total_quarter != tds_tin_quarter

gen dif = tds_total_quarter - tds_tin_quarter
replace flag = 0 if dif <= 1 & dif >= -1
tab flag

/* 
       flag |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |     58,993       99.11       99.11
          1 |        529        0.89      100.00
------------+-----------------------------------
      Total |     59,522      100.00
*/
keep if flag == 1 
save "${prob_path}/tds_quarter_merged_diff.dta", replace

*--------------------------------------------------------
** Challan data
*--------------------------------------------------------

* Aggregating Challan data at Mtin TaxPeriod level
use "${output_path}/form16_data_consolidated.dta", clear
keep MReturn_ID TaxPeriod ReturnType Mtin AmountDepositedByDealer ///
	DateofReturnFiled

bys Mtin TaxPeriod : egen challan_total_quarter = sum(AmountDepositedByDealer)
save "${prob_path}/form16_data_challan_quarter.dta", replace








