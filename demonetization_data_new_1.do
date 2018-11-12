 /************************************************* 
* Filename: 
* Input: H:/Ashwin/dta_files/Form16_`year'_2.dta (Form16_2 files)
* Purpose: Identify the impact of demonitization using form 16 data
		- Estimate no. of firms, tax collection, net tax, input credit
		total turnover etc. for each quarter starting 2013-14
* Output: H:/Ashwin/demonetization/dta/output/demonetization_data.dta
* Author: Ashwin MB
* Date: 25/10/2018
* Last modified: 12/10/2018 (Ashwin)
****************************************************/

/****************************************************
Quantities to be estimated

	1. Number of firms filing a return - find unique no. of firms
	2. Number of Firms with zero turnover - count firms with 0 turnover
	3. Total Net Balance collections - Find r8
	4. Total Input Credits claimed - Find r6.6
	5. Total Output tax declared - Find r5.14
	6. Total Net Tax - Find r7.1
	6. Total Turnover - r4.1
	7. Total Central Turnover - r4.2

******************************************************/

** Initializing environment

clear all
pause off
set more off

*--------------------------------------------------------
** Setting directories and files
*--------------------------------------------------------
global output_path "H:/Ashwin/dta/final"

global de_output_path1 "H:\Ashwin\demonetization\dta\input"
global de_output_path2 "H:\Ashwin\demonetization\dta\intermediate"
global de_output_path3 "H:\Ashwin\demonetization\dta\output"
*--------------------------------------------------------
** Cleaning files
*--------------------------------------------------------


*--------------------------------------------------------
** Count no. of firms per quarter
*--------------------------------------------------------

foreach var in "1213"  {
*Load Form 16 information of firms*
use "${output_path}/form16_`var'_complete.dta", clear

** # of unique firms
	/* Count unique no. of firms filling a return in each quarter */	
	
*Every unique combination of Mtin and Tax Period is flagged as 1 (only once)
bysort Tax_Period Mtin : gen nvals = _n == 1 
	gsort Mtin Tax_Period

*Taking sum of all unique combination at Tax period level*
bysort Tax_Period: egen no_firms = sum(nvals)

*Drop duplicates 
	/* except unique combination of Tax Period + sum of firms; others dropped */
duplicates drop Tax_Period no_firms, force
keep Tax_Period no_firms

*Take output
	/* Save the file with no. of firms */
save "${de_output_path1}/No_firms_`var'.dta", replace
}


*--------------------------------------------------------
** Count no of firms with turnover = 0 
*--------------------------------------------------------
foreach var in "1213"  {
qui use "${output_path}/form16_`var'_complete.dta", clear

** Count firms with 0 turnover 

	/* Identify the latest return using last date
	    & remove duplicates and retain last return */
	
gsort Mtin Tax_Period -DateofReturnFiled
duplicates drop Mtin Tax_Period, force

*Retain firms with turnover == 0*
keep if Cross_turnover == 0 | Central_Turnover == 0 | Local_Turnover == 0

*Count no. of firms with gross, central or local turnover == 0*
bysort Tax_Period: gen gturnover_0 = 1 if Cross_turnover == 0
bysort Tax_Period: gen cturnover_0 = 1 if Central_Turnover == 0
bysort Tax_Period: gen lturnover_0 = 1 if Local_Turnover == 0

bysort Tax_Period: egen no_gturnover = sum(gturnover_0)
bysort Tax_Period: egen no_cturnover = sum(cturnover_0)
bysort Tax_Period: egen no_lturnover = sum(lturnover_0)

duplicates drop Tax_Period no_gturnover no_cturnover no_lturnover, force

keep Tax_Period no_*
*Take output
	/* Save the file with no. of firms with 0 turnover */
save "${de_output_path1}/No_turnover_`var'.dta", replace
}



*--------------------------------------------------------
** Total net balance (always negative) per quarter
*--------------------------------------------------------
foreach var in "1213"  {
use "${output_path}/form16_`var'_complete.dta", clear

*Retain relevant columns*
keep MReturn_ID Tax_Period Return_Type Mtin NetBalance Commodity_code DateofReturnFiled

** Dropping duplicates
	/* Since MReturn id repeats, dropping duplicates */
gsort Mtin Tax_Period -DateofReturnFiled
duplicates drop MReturn_ID, force
duplicates drop Mtin Tax_Period, force

** Taking sum of tax for each quarter
bysort Tax_Period: egen total_tax = sum(NetBalance)
duplicates drop Tax_Period total_tax, force

keep Tax_Period total_tax

*Take output
	/* Save the file with net balance */
save "${de_output_path1}/Total_tax_`var'.dta", replace
}


*--------------------------------------------------------
** Total input tax credit per quarter
*--------------------------------------------------------

foreach var in "1213"  {
use "${output_path}/form16_`var'_complete.dta", clear

*Retain relevant columns*
keep MReturn_ID Tax_Period Return_Type Mtin TotalTaxCredit Commodity_code DateofReturnFiled

** Dropping duplicates
	/* Since MReturn id repeats, dropping duplicates */
gsort Mtin Tax_Period -DateofReturnFiled
duplicates drop MReturn_ID, force
duplicates drop Mtin Tax_Period, force

** Taking sum of tax for each quarter
bysort Tax_Period: egen input_tax_credit = sum(TotalTaxCredit)
duplicates drop Tax_Period input_tax_credit, force

keep Tax_Period input_tax_credit

*Take output
	/* Save the file with no. of firms as csv file */
save "${de_output_path1}/Input_tax_credit_`var'.dta", replace
}



*--------------------------------------------------------
** Total output tax per quarter
*--------------------------------------------------------

foreach var in "1213"  {
use "${output_path}/form16_`var'_complete.dta", clear

*Retain relevant columns
keep MReturn_ID Tax_Period Return_Type Mtin TotalOutputTax Commodity_code DateofReturnFiled

** Dropping duplicates
	/* Since MReturn id repeats, dropping duplicates */
gsort Mtin Tax_Period -DateofReturnFiled
duplicates drop MReturn_ID, force
duplicates drop Mtin Tax_Period, force

** Taking sum of tax for each quarter
bysort Tax_Period: egen output_tax = sum(TotalOutputTax)
duplicates drop Tax_Period output_tax, force

keep Tax_Period output_tax

*Take output
	/* Save the file with no. of firms as csv file */
save "${de_output_path1}/Output_tax_`var'.dta", replace
}


*--------------------------------------------------------
** Total net tax per quarter
*--------------------------------------------------------

foreach var in "1213"  {
use "${output_path}/form16_`var'_complete.dta", clear

*Retain relevant columns
keep MReturn_ID Tax_Period Return_Type Mtin NetTax Commodity_code DateofReturnFiled

** Dropping duplicates
	/* Since MReturn id repeats, dropping duplicates */
gsort Mtin Tax_Period -DateofReturnFiled

	/* Dropping duplicate return id keeps only one return per dealer,
	however dealer can have multiple returns:original or revised */

duplicates drop MReturn_ID, force

	/* this command removes all entries except the latest filed at 
	mtin tax-period level */
	
duplicates drop Mtin Tax_Period, force

** Taking sum of tax for each quarter
bysort Tax_Period: egen net_tax = sum(NetTax)

	/* dropping extra rows - retains only tax-period and net tax */
duplicates drop Tax_Period net_tax, force

keep Tax_Period net_tax

*Take output
	/* Save the file with no. of firms as csv file */
save "${de_output_path1}/Net_tax_`var'.dta", replace
}

*--------------------------------------------------------
** Total gross turnover per quarter
*--------------------------------------------------------

foreach var in "1213"  {
use "${output_path}/form16_`var'_complete.dta", clear

*Retain relevant columns
keep MReturn_ID Tax_Period Return_Type Mtin Cross_turnover Commodity_code DateofReturnFiled

** Dropping duplicates
	/* Since MReturn id repeats, dropping duplicates */
gsort Mtin Tax_Period -DateofReturnFiled
duplicates drop MReturn_ID, force
duplicates drop Mtin Tax_Period, force

** Taking sum of tax for each quarter
bysort Tax_Period: egen gross_turnover = sum(Cross_turnover)
duplicates drop Tax_Period gross_turnover, force

keep Tax_Period gross_turnover

*Take output
	/* Save the file with no. of firms as csv file */
save "${de_output_path1}/Gross_turnover_`var'.dta", replace
}


*--------------------------------------------------------
** Total central turnover per quarter
*--------------------------------------------------------

foreach var in "1213"  {
use "${output_path}/form16_`var'_complete.dta", clear

*Retain relevant columns
keep MReturn_ID Tax_Period Return_Type Mtin Central_Turnover Commodity_code DateofReturnFiled

** Dropping duplicates
	/* Since MReturn id repeats, dropping duplicates */
gsort Mtin Tax_Period -DateofReturnFiled
duplicates drop MReturn_ID, force
duplicates drop Mtin Tax_Period, force

** Taking sum of tax for each quarter
bysort Tax_Period: egen central_turnover = sum(Central_Turnover)
duplicates drop Tax_Period central_turnover, force

keep Tax_Period central_turnover

*Take output
	/* Save the file with no. of firms as csv file */
save "${de_output_path1}/Central_turnover_`var'.dta", replace
}



** Append all the files 
	/* Append for each quantity all the data for all the years together */

local quantity No_firms No_turnover Total_tax Input_tax_credit Output_tax ///
	Net_tax Gross_turnover Central_turnover
foreach var in `quantity' {
use "${de_output_path1}/`var'_1213.dta", clear

foreach numlist in 1314 1415 1516 1617 {
append using "${de_output_path1}/`var'_`numlist'.dta"
}

save "${de_output_path2}/`var'_total.dta", replace
}




** Merge all the consolidated data 
	/* All quantities are in consolidated sheet; they will be merged 
	together using quarter information to make master file */ 
	
local quantity No_turnover Total_tax Input_tax_credit Output_tax ///
	Net_tax Gross_turnover Central_turnover

*dropping 1 firm that appears in 1314 but with a Tax Period Mar 2013
use "${de_output_path2}/No_firms_total.dta", clear
drop if Tax_Period == "Mar-2013" & no_firms == 1 
save "${de_output_path2}/No_firms_total.dta", replace

use "${de_output_path2}/No_turnover_total.dta", clear
drop if Tax_Period == "Mar-2013" & no_gturnover == 1 
save "${de_output_path2}/No_turnover_total.dta", replace

use "${de_output_path2}/Total_tax_total.dta", clear
drop if Tax_Period == "Mar-2013" & total_tax == 0 
save "${de_output_path2}/Total_tax_total.dta", replace

use "${de_output_path2}/Input_tax_credit_total.dta", clear
drop if Tax_Period == "Mar-2013" & input_tax_credit == 0
save "${de_output_path2}/Input_tax_credit_total.dta", replace

use "${de_output_path2}/Output_tax_total.dta", clear
drop if Tax_Period == "Mar-2013" & output_tax == 0
save "${de_output_path2}/Output_tax_total.dta", replace

use "${de_output_path2}/Net_tax_total.dta", clear
drop if Tax_Period == "Mar-2013" & net_tax == 0
save "${de_output_path2}/Net_tax_total.dta", replace

use "${de_output_path2}/Gross_turnover_total.dta", clear
drop if Tax_Period == "Mar-2013" & gross_turnover == 0 
save "${de_output_path2}/Gross_turnover_total.dta", replace

use "${de_output_path2}/Central_turnover_total.dta", clear
drop if Tax_Period == "Mar-2013" & central_turnover == 0
save "${de_output_path2}/Central_turnover_total.dta", replace

use "${de_output_path2}/No_firms_total.dta", clear

local quantity No_turnover Total_tax Input_tax_credit Output_tax ///
	Net_tax Gross_turnover Central_turnover
	
foreach var in `quantity' {
merge 1:1 Tax_Period using "${de_output_path2}/`var'_total.dta"
drop _merge
}
 
save "${de_output_path3}/demonetization_data_new.dta", replace








