/************************************************* 
* Filename: 
* Input: H:/Ashwin/dta/intermediate
* Purpose: Create trends for challan deposits
* Output: H:/Ashwin/dta/final
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
global temp_path1 "H:/Ashwin/dta/temp"

*output files*
global output_path "H:/Ashwin/dta/final"
global qc_path "H:/Ashwin/dta/qc"
global prob_path "H:/Ashwin/dta/prob"

*--------------------------------------------------------
** Initializing form 16 consolidated data
*--------------------------------------------------------

use "${output_path}\form16_data_consolidated.dta", clear
bys TaxPeriod: egen ChallanAmount = sum(AmountDepositedByDealer)
duplicates drop TaxPeriod ChallanAmount ChallanAmount_2, force
keep TaxPeriod ChallanAmount ChallanAmount_2

gen TaxQuarter = 0 
replace TaxQuarter=9 if TaxPeriod=="First Quarter-2012"
replace TaxQuarter=10 if TaxPeriod=="Second Quarter-2012"
replace TaxQuarter=11 if TaxPeriod=="Third Quarter-2012"
replace TaxQuarter=12 if TaxPeriod=="Fourth Quarter-2012"
replace TaxQuarter=13 if TaxPeriod=="First Quarter-2013"
replace TaxQuarter=14 if TaxPeriod=="Second Quarter-2013"
replace TaxQuarter=15 if TaxPeriod=="Third Quarter-2013"
replace TaxQuarter=16 if TaxPeriod=="Fourth Quarter-2013"
replace TaxQuarter=17 if TaxPeriod=="First Quarter-2014"
replace TaxQuarter=18 if TaxPeriod=="Second Quarter-2014"
replace TaxQuarter=19 if TaxPeriod=="Third Quarter-2014"
replace TaxQuarter=20 if TaxPeriod=="Fourth Quarter-2014"
replace TaxQuarter=21 if TaxPeriod=="First Quarter-2015"
replace TaxQuarter=22 if TaxPeriod=="Second Quarter-2015"
replace TaxQuarter=23 if TaxPeriod=="Third Quarter-2015"
replace TaxQuarter=24 if TaxPeriod=="Fourth Quarter-2015"
replace TaxQuarter=25 if TaxPeriod=="First Quarter-2016"
replace TaxQuarter=26 if TaxPeriod=="Second Quarter-2016"
replace TaxQuarter=27 if TaxPeriod=="Third Quarter-2016"
replace TaxQuarter=28 if TaxPeriod=="Fourth Quarter-2016"
drop if TaxQuarter == 0
gsort TaxQuarter

two bar ChallanAmount TaxQuarter

*--------------------------------------------------------
** Initializing challan data in disaggregated form
*--------------------------------------------------------

use "${output_path}/form16_challan_consolidated.dta", clear
//bys TaxMonth: egen monthly_challan = sum(amount)
duplicates drop TaxMonth monthly_challan, force
keep TaxMonth monthly_challan
keep if TaxMonth>0

*total data
two bar monthly_challan TaxMonth
*if month > 60
two bar monthly_challan TaxMonth if TaxMonth >60
*if month >72
two bar monthly_challan TaxMonth if TaxMonth >74



