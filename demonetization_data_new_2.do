 /************************************************* 
* Filename: 
* Input: ${output_path3}/demonetization_data.dta
* Purpose: Rename all the variables demonetization data
* Output: ${output_path3}/demonetization_data.dta
* Author: Ashwin MB
* Date: 09/10/2018
* Last modified: 10/10/2018 (Ashwin)
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
global de_output_path3 "H:\Ashwin\demonetization\dta\output"

*--------------------------------------------------------
** Clean data
*--------------------------------------------------------
use "${de_output_path3}/demonetization_data_new.dta", clear

label variable no_firms "Total no. of firms"
label variable no_gturnover "Firms with no gross turnover"
label variable no_cturnover "Firms with no central turnover"
label variable no_lturnover "Firms with no local turnover"
label variable total_tax "Net balance: it is negative, amt to be deposited"

label variable input_tax_credit "Total tax credit"
label variable output_tax "Total output tax"
label variable net_tax "Total tax collection (Output tax - tax credit)"
label variable gross_turnover "Total gross turnover"
label variable central_turnover "Total central turnover"

save "${de_output_path3}/demonetization_data_new.dta", replace

export delim "${de_output_path3}/demonetization_data_new.csv", replace


