/************************************************* 
* Filename: 
* Input: H:/Ashwin/dta/
* Purpose: Mapping old return id with new return ids
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

global old_input_path1 "D:/data"

*output files*
global output_path "H:/Ashwin/dta/final"
global qc_path "H:/Ashwin/dta/qc"
global prob_path "H:/Ashwin/dta/prob"

*--------------------------------------------------------
** Return Ids from old dataset
*--------------------------------------------------------

use "${old_input_path1}/form16_data.dta", clear
duplicates tag TaxPeriod TurnoverGross TurnoverCentral TurnoverLocal ///
	TotalOutputTax TotalTaxCredit NetTax NetBalance, gen(repeat2)

rename (TurnoverGross TurnoverCentral TurnoverLocal) ///
		(GrossTurnover CentralTurnover LocalTurnover)

drop if repeat2 !=0

keep id TaxPeriod DealerTIN GrossTurnover CentralTurnover LocalTurnover ///
	TotalOutputTax TotalTaxCredit NetTax NetBalance 
	
merge 1:m TaxPeriod GrossTurnover CentralTurnover LocalTurnover ///
	TotalOutputTax TotalTaxCredit NetTax NetBalance ///
	using "${output_path}/form16_data_consolidated.dta"
	
keep if _merge==3
keep id TaxPeriod DealerTIN MReturn_ID Mtin
order MReturn_ID, before(TaxPeriod)

save "${output_path}/returnid_old_new_mapping.dta", replace



	




