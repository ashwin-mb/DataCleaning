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

foreach var in /*2013 2014 2015*/ 2016 {	
use "${input_path1}/2a2b_1q_`var'.dta", clear 
gen OriginalTaxPeriod = "First Quarter-`var'"
save "${input_path1}/2a2b_1q_`var'.dta", replace 
}

foreach var in /*2013 2014 2015*/ 2016 {	
use "${input_path1}/2a2b_2q_`var'.dta", clear 
gen OriginalTaxPeriod = "Second Quarter-`var'"
save "${input_path1}/2a2b_2q_`var'.dta", replace 
}

foreach var in /*2013 2014 2015*/ 2016 {	
use "${input_path1}/2a2b_3q_`var'.dta", clear 
gen OriginalTaxPeriod = "Third Quarter-`var'"
save "${input_path1}/2a2b_3q_`var'.dta", replace 
}

foreach var in /*2013 2014 2015*/ 2016 {	
use "${input_path1}/2a2b_4q_`var'.dta", clear 
gen OriginalTaxPeriod = "Fourth Quarter-`var'"
save "${input_path1}/2a2b_4q_`var'.dta", replace 
}

** Append data
	/* Adding all the data together for each year */
	
foreach var in 2013 2014 {
use "${input_path1}/2a2b_1q_`var'.dta", clear
append using "${input_path1}/2a2b_2q_`var'.dta" 
append using "${input_path1}/2a2b_3q_`var'.dta" 
append using "${input_path1}/2a2b_4q_`var'.dta" 

save "${output_path}/2a2b_quarterly_`var'.dta", replace 
}

foreach var in 2013 2014  {
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

* Renaming 2a2b for 2015, 2016 (not appended due to large size)
foreach var in 2 3 4 {
use "${input_path1}/2a2b_`var'q_2016.dta", clear
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

save "${output_path}/2a2b_2016_q`var'.dta", replace
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

*Rename QuarterNames
use "${output_path}/2a2b_monthly_2012.dta", clear

replace TaxPeriod = "Jan-2012" if TaxPeriod == "jan 2012"
replace TaxPeriod = "Feb-2012" if TaxPeriod == "feb 2012"
replace TaxPeriod = "Mar-2012" if TaxPeriod == "mar 2012"
replace TaxPeriod = "Apr-2012" if TaxPeriod == "apr 2012"
replace TaxPeriod = "May-2012" if TaxPeriod == "may 2012"
replace TaxPeriod = "Jun-2012" if TaxPeriod == "jun 2012"
replace TaxPeriod = "Jul-2012" if TaxPeriod == "jul 2012"
replace TaxPeriod = "Aug-2012" if TaxPeriod == "aug 2012"
replace TaxPeriod = "Sep-2012" if TaxPeriod == "sep 2012"
replace TaxPeriod = "Oct-2012" if TaxPeriod == "oct 2012"
replace TaxPeriod = "Nov-2012" if TaxPeriod == "nov 2012"
replace TaxPeriod = "Dec-2012" if TaxPeriod == "dec 2012"
replace TaxPeriod = "Jan-2013" if TaxPeriod == "jan 2013"
replace TaxPeriod = "Feb-2013" if TaxPeriod == "feb 2013"
replace TaxPeriod = "Mar-2013" if TaxPeriod == "mar 2013"

save "${output_path}/2a2b_monthly_2012.dta", replace


** Cleaning data ** 
use "${output_path}/2a2b_quarterly_2014.dta", clear

tab TaxPeriod

/*

  TaxPeriod |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |          2        0.00        0.00
          5 |          9        0.00        0.00
          9 |         60        0.00        0.00
         41 |  6,033,869       24.73       24.73
         42 |  6,159,508       25.25       49.98
         43 |  6,071,148       24.89       74.87
         44 |  6,131,654       25.13      100.00
------------+-----------------------------------
      Total | 24,396,250      100.00
*/

drop if TaxPeriod == 1 | TaxPeriod == 5 | TaxPeriod == 9
tab TaxYear

/*    TaxYear |      Freq.     Percent        Cum.
------------+-----------------------------------
       2013 |         99        0.00        0.00
       2014 | 24,396,080      100.00      100.00
------------+-----------------------------------
      Total | 24,396,179      100.00
*/

drop if TaxYear!=2014
save "${output_path}/2a2b_quarterly_2014.dta", replace

