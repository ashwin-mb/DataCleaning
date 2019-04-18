/************************************************* 
* Filename: 
* Input: H:/Ashwin/dta/intermediate
* Purpose: Split Form 16 into commodity data and rest of the data
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
** Split data
*--------------------------------------------------------
** Spliting data into form16-commoditycode & form16
	/* Dataset contains Commodity Code information. This makes the
	   level of data ReturnID-Commodity Code. But the old data is 
	   at ReturnID level.
	   Checking if there are duplicates at ReturnID-Commodity Code */

* Spliting Form 16 data into commodity code data 

foreach var in "1213" "1314" "1415" "1516" "1617" {
use "${input_path2}\form16_`var'_complete.dta", clear

keep  MReturn_ID TaxPeriod ReturnType Mtin Commodity_code ///
		Description_of_Goods Tax_rate Tax_Contribution DateofReturnFiled

save "${input_path3}/form16_`var'_commoditycode.dta", replace
}

* Spliting remaining Form 16 data 

foreach var in "1213" "1314" "1415" "1516" "1617" {
use "${input_path2}\form16_`var'_complete.dta", clear

drop Commodity_code Description_of_Goods Tax_rate Tax_Contribution

save "${input_path3}/form16_`var'_data.dta", replace
} 

*--------------------------------------------------------
** Clean Form16_data & create consolidated file
*--------------------------------------------------------
** Check for duplicates on Form16_data
	/* Overall the data will have duplicates only at Return_ID level  
	Duplicates for ReturnID and duplicates for all variables should be same
	*/

use "${input_path3}\form16_`var'_data.dta", clear
duplicates tag MReturn_ID, gen(repeat1) 
duplicates tag , gen(repeat2) 

gen flag=0 if repeat1 == repeat2
replace flag=1 if flag !=0
gsort -flag // 1213-1617 all data matches

** Remove all duplicate entries in Form16_data
	/* Drop all entries such that the level of data is at ReturnID */

foreach var in "1213" "1314""1415" "1516" "1617" {
use "${input_path3}\form16_`var'_data.dta", clear
duplicates drop 

save "${input_path3}\form16_`var'_data_noduplicates.dta", replace
}

** Merge Form16_data for all the years in consolidated file

use "${input_path3}\form16_1213_data_noduplicates.dta", clear

foreach var in "1314" "1415" "1516" "1617" {
append using "${input_path3}\form16_`var'_data_noduplicates.dta"
}

save "${output_path}\form16_data_consolidated.dta", replace

**** Rename TaxPeriod
use "${output_path}\form16_data_consolidated.dta", clear

replace TaxPeriod = "Third Quarter-2012" if TaxPeriod == "Third quaterly-2012"
replace TaxPeriod = "Second Quarter-2012" if TaxPeriod == "Second quaterly-2012"
replace TaxPeriod = "First Quarter-2012" if TaxPeriod == "First quaterly-2012"
replace TaxPeriod = "Fourth Quarter-2012" if TaxPeriod == "Forth Quarter-2012"
replace TaxPeriod = "Third Quarter-2012" if TaxPeriod == "Thrid Quater-2012"

save "${output_path}\form16_data_consolidated.dta", replace

**** Remove TaxPeriod before 2012 
use "${output_path}\form16_data_consolidated.dta", clear

drop if TaxPeriod == "99-2012" | TaxPeriod == "Apr-2011" | TaxPeriod == "Aug-2011" ///
	| TaxPeriod == "Dec-2011" | TaxPeriod == "Feb-2012" | TaxPeriod == "First Quarter-2010" ///
	| TaxPeriod == "Fourth Quarter-2010" | TaxPeriod == "Fourth Quarter-2011" ///
	| TaxPeriod == "Jan-2012" | TaxPeriod == "Jul-2011" | TaxPeriod == "Jun-2011" ///
	| TaxPeriod == "Mar-2012" | TaxPeriod == "May-2011" | TaxPeriod == "May-2013" ///
	| TaxPeriod == "Nov-2011" | TaxPeriod == "Oct-2011" | TaxPeriod == "Second Quarter-2010" ///
	| TaxPeriod == "Second Quarter-2011" | TaxPeriod == "Second halfyearly-2010" ///
	| TaxPeriod == "Second halfyearly-2010" | TaxPeriod == "Second halfyearly-2011" ///
	| TaxPeriod == "Sep-2011" | TaxPeriod == "Apr-2013" ///
	| TaxPeriod == "Third Quarter-2009" | TaxPeriod == "Third Quarter-2010"

save "${output_path}\form16_data_consolidated.dta", replace

** Create form16 with latest returns**
use "${output_path}/form16_data_consolidated.dta", clear

duplicates tag MReturn_ID, gen(repeat1)
gsort -repeat1 MReturn_ID //21 entries have same returnIds but different Mtins & Tax Period

* Retain the latest returns
gsort Mtin TaxPeriod -DateofReturnFiled
duplicates drop Mtin TaxPeriod, force
drop if Mtin == ""
drop if TaxPeriod == ""
save "${output_path}/form16_latestreturns_consolidated.dta", replace

** Add TaxQuarter
use "${output_path}/form16_latestreturns_consolidated.dta", clear

*--------------------------------------------------------
** Clean Form16_commodityCode //Need to save in output file
*--------------------------------------------------------
** Load Form16CommodityCode 
	/* Check for duplicates: No repeats in 1213 */ 

use "${input_path3}\form16_1516_commoditycode.dta", clear

duplicates tag MReturn_ID TaxPeriod ReturnType Mtin Commodity_code ///
			Tax_rate Description_of_Goods Tax_Contribution ///
			DateofReturnFiled, gen(Repetitions)

tab Repetitions

gsort -Repetitions_5 MReturn_ID Commodity_code Tax_rate ///
		Description_of_Goods Tax_Contribution
		

** Output Mtins & ReturnIDs
	/* Output unique values from Form16 to QC with 2a2b data */ 

*Unique Mtins
use "${output_path}\form16_data_consolidated.dta", clear
keep Mtin TaxPeriod
duplicates drop
drop if Mtin == "" 
save "${output_path}\unique_mtin_form16.dta", replace

*Unique Returns
use "${output_path}\form16_data_consolidated.dta", clear
keep MReturn_ID TaxPeriod
duplicates drop
save "${output_path}\unique_returnid_form16.dta", replace



