  /************************************************* 
* Filename: 
* Input: 2a2b dta_files
* Purpose: Clean 2a2b files by changing variable names and 
			appending all the files yearwise
* Output:
* Author: Ashwin MB
* Date: 09/10/2018
* Last modified: 09/10/2018 (Ashwin)
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
global old_path "D:/data"

*output files*
global output_path "H:/Ashwin/dta/final"
global qc_path "H:/Ashwin/dta/qc"
global prob_path "H:/Ashwin/dta/prob"
global sample_path "H:/Ashwin/dta/sample"


*--------------------------------------------------------
** Clean files
*--------------------------------------------------------

** Inserting quarterly information
	/* TaxPeriod (41) = 1st quarter, 42 = 2nd quarter, 43 = 3rd, 44 = 4th
	In original data, 41 is present in 2nd quarter data as well.
	Retaining the original TaxPeriod information */

foreach var in 2013 2014 2015 {	
use "${input_path1}/2a2b_1q_`var'.dta", clear 
gen OriginalTaxPeriod = "First Quarter `var'"
save "${input_path1}/2a2b_1q_`var'.dta", replace 
}

foreach var in 2013 2014 2015 {	
use "${input_path1}/2a2b_2q_`var'.dta", clear 
gen OriginalTaxPeriod = "Second Quarter `var'"
save "${input_path1}/2a2b_2q_`var'.dta", replace 
}

foreach var in 2013 2014 2015 {	
use "${input_path1}/2a2b_3q_`var'.dta", clear 
gen OriginalTaxPeriod = "Third Quarter `var'"
save "${input_path1}/2a2b_3q_`var'.dta", replace 
}

foreach var in 2013 2014 2015 {	
use "${input_path1}/2a2b_4q_`var'.dta", clear 
gen OriginalTaxPeriod = "Fourth Quarter `var'"
save "${input_path1}/2a2b_4q_`var'.dta", replace 
}

** Append data
	/* Adding all the data together for each year */
	
foreach var in 2013 2014 2015 {
use "${input_path1}/2a2b_1q_`var'.dta", clear
append using "${input_path1}/2a2b_2q_`var'.dta" 
append using "${input_path1}/2a2b_3q_`var'.dta" 
append using "${input_path1}/2a2b_4q_`var'.dta" 

save "${output_path}/2a2b_quarterly_`var'.dta", replace 
}

foreach var in 2013 2014 2015 {
use "${output_path}/2a2b_quarterly_`var'.dta", clear
*Renaming files 
rename Type_1 SaleOrPurchase
rename Type_2 SalePurchaseType
rename Type_3 DealerGoodType
rename Type_4 TransactionType
rename MTIn Mtin
rename MPartyTIN SellerBuyerTin
rename MReceiptID MReturn_ID

label variable SaleOrPurchase "AN-Purchase not eligible/AE- Purchase Eligible/BF - 2B Sales"
label variable SalePurchaseType "IOI/HSP/PEU/PUC/PTEG/CG/ISPC/ISPH/ISPN/E1E2/SBT/SCT/OT/ISBCT/EOI/HSS/ISS/LS"
label variable DealerGoodType "CG/OT/RD/UD"
label variable TransactionType "None/Exempted/H/I/E1E2/C/J/GD/WC"
label variable Mtin "Tin number of the current dealer"
label variable SellerBuyerTin "Tin of the dealer whom the current dealer sold to or bought from"
//label variable MReturn_ID "Unique identifier"

save "${output_path}/2a2b_quarterly_`var'.dta", replace
}

** Clean and append monthly values 
	/* Generating the original tax period */
foreach var in apr may jun jul aug sep oct nov dec {
use "${input_path1}/2a2b_`var'_2012.dta", clear
gen OriginalTaxPeriod = "`var' 2012"

save "${input_path1}/2a2b_`var'_2012.dta", replace
}

* Cleaning April 2012 data
	/* April 2012 has one missing column. 
		Adding the column for ease in appending later */
	
use "${input_path1}/2a2b_apr_2012.dta", clear
rename var13 var14
gen Form_Status = ""
label variable var12 "Date/Month"
save "${input_path1}/2a2b_apr_2012.dta", replace



foreach var in jan feb mar {
use "${input_path1}/2a2b_`var'_2013.dta", clear
gen OriginalTaxPeriod = "`var' 2013"

save "${input_path1}/2a2b_`var'_2013.dta", replace
}


use "${input_path1}/2a2b_apr_2012.dta", clear 

** Append all the values 
foreach var in may jun jul aug sep oct nov dec {
append using "${input_path1}/2a2b_`var'_2012.dta", force
}
save "${output_path}/2a2b_monthly_2012.dta", replace

use "${output_path}/2a2b_monthly_2012.dta", clear 
foreach var in jan feb mar {
append using "${input_path1}/2a2b_`var'_2013.dta", force
}
save "${output_path}/2a2b_monthly_2012.dta", replace

* Renaming variables for consolidated monthly 2a2b data
use "${output_path}/2a2b_monthly_2012.dta", clear
*Renaming files 
rename Type_1 SaleOrPurchase
rename Type_2 SalePurchaseType
rename Type_3 DealerGoodType
rename Type_4 TransactionType
rename MTIn Mtin
rename MPartyTIN SellerBuyerTin
rename MReceiptID MReturn_ID

label variable SaleOrPurchase "AN-Purchase not eligible/AE- Purchase Eligible/BF - 2B Sales"
label variable SalePurchaseType "IOI/HSP/PEU/PUC/PTEG/CG/ISPC/ISPH/ISPN/E1E2/SBT/SCT/OT/ISBCT/EOI/HSS/ISS/LS"
label variable DealerGoodType "CG/OT/RD/UD"
label variable TransactionType "None/Exempted/H/I/E1E2/C/J/GD/WC"
label variable Mtin "Tin number of the current dealer"
label variable SellerBuyerTin "Tin of the dealer whom the current dealer sold to or bought from"
//label variable MReturn_ID "Unique identifier"

save "${output_path}/2a2b_monthly_2012.dta", replace

** Output sample data ** 

** New data
use "${output_path}/2a2b_monthly_2012.dta", clear 
gen number = _n
keep if number <10000 
export excel "${sample_path}/sample2a2b.xlsx", ///
			firstrow(variables) she("New_2012_monthly") sheetmodify

use "${output_path}/2a2b_quarterly_2013.dta", clear 
gen number = _n
keep if number <10000 
export excel "${sample_path}/sample2a2b.xlsx", ///
			firstrow(variables) she("New_2013_quarterly") sheetmodify
			
use "${output_path}/2a2b_quarterly_2014.dta", clear 
gen number = _n
keep if number <10000 
export excel "${sample_path}/sample2a2b.xlsx", ///
			firstrow(variables) she("New_2014_quarterly") sheetmodify
			
use "${output_path}/2a2b_quarterly_2015.dta", clear 
gen number = _n
keep if number <10000 
export excel "${sample_path}/sample2a2b.xlsx", ///
			firstrow(variables) she("New_2015_quarterly") sheetmodify

** Old data
use "${old_path}/annexure_2A2B_monthly_201213.dta", clear
gen number = _n
keep if number <10000 
export excel "${sample_path}/sample2a2b.xlsx", ///
			firstrow(variables) she("Old_2012_monthly") sheetmodify

use "${old_path}/annexure_2A2B_quarterly_2013.dta", clear
gen number = _n
keep if number <10000 
export excel "${sample_path}/sample2a2b.xlsx", ///
			firstrow(variables) she("Old_2013_quarterly") sheetmodify
			
use "${old_path}/annexure_2A2B_quarterly_2014.dta", clear
gen number = _n
keep if number <10000 
export excel "${sample_path}/sample2a2b.xlsx", ///
			firstrow(variables) she("Old_2014_quarterly") sheetmodify


