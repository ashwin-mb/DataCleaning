 /************************************************* 
* Filename: 
* Input: ${output_path3}/demonetization_data.dta
* Purpose: Get summary stats of Form 16 old data and compare new data
* Output: ${output_path3}/demonetization_data.dta
* Author: Ashwin MB
* Date: 11/10/2018
* Last modified: 11/10/2018 (Ashwin)
****************************************************/

/****************************************************

Timeline 2013 onwards
Quarterly updates
1. Number of firms filing a return - find unique no. of firms
Number of Firms with zero turnover - count firms with 0 turnover
Total Tax collections - Find r8
Total Input Credits claimed - Find r6.6
Total Output tax declared - Find r5.14
Total Turnover - r4.1
Total Central Turnover - r4.2

******************************************************/

** Initializing environment

clear all
version 1
set more off
qui cap log c
set mem 100m

*--------------------------------------------------------
** Setting directories and files
*--------------------------------------------------------

global old_input_path "D:\data"

global de_output_path_old "H:\Ashwin\demonetization\dta\output"

*--------------------------------------------------------
** Conduct basic stats
*--------------------------------------------------------

use "${old_input_path}\form16_data.dta", clear

	/*sorting with descending approval date to get the latest return 
	per quarter at top*/

gsort DealerTIN TaxPeriod -ApprovalDate

* Having only 1 return (the latest) per firm for each quarter
duplicates drop DealerTIN TaxPeriod, force

*count firms with turnover zero*

gen g_turnover = 0 
gen c_turnover = 0
gen l_turnover = 0
replace g_turnover = 1 if TurnoverGross == 0  
replace c_turnover = 1 if TurnoverCentral == 0 
replace l_turnover = 1 if TurnoverLocal == 0 

****** Total Tax collection ****************

bysort TaxPeriod: egen no_firms = count(DealerTIN)
bysort TaxPeriod: egen g0 = sum(g_turnover)
bysort TaxPeriod: egen c0 = sum(c_turnover)
bysort TaxPeriod: egen l0 = sum(l_turnover)
bysort TaxPeriod: egen output_tax = sum(TotalOutputTax)
bysort TaxPeriod: egen input_credit = sum(TotalTaxCredit)
bysort TaxPeriod: egen net_tax = sum(NetTax)
bysort TaxPeriod: egen net_balance = sum(NetBalance)
bysort TaxPeriod: egen gross_turnover = sum(TurnoverGross)
bysort TaxPeriod: egen central_turnover = sum(TurnoverCentral)

*Retaining only relevant columns*
keep TaxPeriod output_tax input_credit net_tax net_balance gross_turnover ///
	central_turnover no_firms g0 c0 l0
	
duplicates drop TaxPeriod output_tax input_credit net_tax net_balance gross_turnover ///
	central_turnover, force

save "${de_output_path_old}\demonetization_data_old.dta", replace


