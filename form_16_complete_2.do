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

*--------------------------------------------------------
** Clean Form16_commodityCode 
*--------------------------------------------------------
** Load Form16CommodityCode 
	/* Check for duplicates: No repeats in 1213 */ 

use "${input_path3}\form16_1314_commoditycode.dta", clear

duplicates tag MReturn_ID TaxPeriod ReturnType Mtin Commodity_code ///
			Tax_rate Description_of_Goods Tax_Contribution ///
			DateofReturnFiled, gen(Repetitions)

tab Repetitions

gsort -Repetitions_5 MReturn_ID Commodity_code Tax_rate ///
		Description_of_Goods Tax_Contribution
		
************************ Check the reasons for duplicates *****

