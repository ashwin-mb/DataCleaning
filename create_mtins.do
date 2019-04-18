  /************************************************* 
* Filename: 
* Input: 2a2b dta_files
* Purpose: Creating Mtin only files for DP, Returns and 2a2b
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
** Mtin only files for 2a2b
*--------------------------------------------------------
*2012*
use "H:/Ashwin/dta/final/2a2b_monthly_2012.dta", clear
keep SaleOrPurchase Mtin OriginalTaxPeriod
duplicates drop
save "H:/Ashwin/dta/final/2a2b_monthly_2012_mtins.dta", replace

use "H:/Ashwin/dta/final/2a2b_monthly_2012.dta", clear
keep SaleOrPurchase SellerBuyerTin OriginalTaxPeriod
duplicates drop
save "H:/Ashwin/dta/final/2a2b_monthly_2012_sellerbuyermtins.dta", replace

*2013*
use "H:/Ashwin/dta/final/2a2b_quarterly_2013.dta", clear
keep SaleOrPurchase Mtin OriginalTaxPeriod
duplicates drop
save "H:/Ashwin/dta/final/2a2b_quarterly_2013_mtins.dta", replace

use "H:/Ashwin/dta/final/2a2b_quarterly_2013.dta", clear
keep SaleOrPurchase SellerBuyerTin OriginalTaxPeriod
duplicates drop
save "H:/Ashwin/dta/final/2a2b_quarterly_2013_sellerbuyermtins.dta", replace

*2014*
use "H:/Ashwin/dta/final/2a2b_quarterly_2014.dta", clear
keep SaleOrPurchase Mtin OriginalTaxPeriod
duplicates drop
save "H:/Ashwin/dta/final/2a2b_quarterly_2014_mtins.dta", replace

use "H:/Ashwin/dta/final/2a2b_quarterly_2014.dta", clear
keep SaleOrPurchase SellerBuyerTin OriginalTaxPeriod
duplicates drop
save "H:/Ashwin/dta/final/2a2b_quarterly_2014_sellerbuyermtins.dta", replace

foreach var1 in 2015 2016 { 
foreach var2 in 1 2 3 4 {
use "H:/Ashwin/dta/final/2a2b_`var1'_q`var2'.dta", clear
keep SaleOrPurchase Mtin OriginalTaxPeriod
duplicates drop
save "H:/Ashwin/dta/final/2a2b_`var1'_q`var2'_mtins.dta", replace

use "H:/Ashwin/dta/final/2a2b_`var1'_q`var2'.dta", clear
keep SaleOrPurchase SellerBuyerTin OriginalTaxPeriod
duplicates drop
save "H:/Ashwin/dta/final/2a2b_`var1'_q`var2'_sellerbuyermtins.dta", replace
}
}


foreach var1 in mtins sellerbuyermtins {
use "H:/Ashwin/dta/final/2a2b_monthly_2012_`var1'.dta", clear
append using "H:/Ashwin/dta/final/2a2b_quarterly_2013_`var1'.dta"
append using "H:/Ashwin/dta/final/2a2b_quarterly_2014_`var1'.dta"
append using "H:/Ashwin/dta/final/2a2b_2015_q1_`var1'.dta"
append using "H:/Ashwin/dta/final/2a2b_2015_q2_`var1'.dta"
append using "H:/Ashwin/dta/final/2a2b_2015_q3_`var1'.dta"
append using "H:/Ashwin/dta/final/2a2b_2015_q4_`var1'.dta"
append using "H:/Ashwin/dta/final/2a2b_2016_q1_`var1'.dta"
append using "H:/Ashwin/dta/final/2a2b_2016_q2_`var1'.dta"
append using "H:/Ashwin/dta/final/2a2b_2016_q3_`var1'.dta"
append using "H:/Ashwin/dta/final/2a2b_2016_q4_`var1'.dta"

gen TaxMonth=0
replace TaxMonth=25 if OriginalTaxPeriod=="apr 2012"
replace TaxMonth=26 if OriginalTaxPeriod=="may 2012"
replace TaxMonth=27 if OriginalTaxPeriod=="jun 2012"
replace TaxMonth=28 if OriginalTaxPeriod=="jul 2012"
replace TaxMonth=29 if OriginalTaxPeriod=="aug 2012"
replace TaxMonth=30 if OriginalTaxPeriod=="sep 2012"
replace TaxMonth=31 if OriginalTaxPeriod=="oct 2012"
replace TaxMonth=32 if OriginalTaxPeriod=="nov 2012"
replace TaxMonth=33 if OriginalTaxPeriod=="dec 2012"
replace TaxMonth=34 if OriginalTaxPeriod=="jan 2013"
replace TaxMonth=35 if OriginalTaxPeriod=="feb 2013"
replace TaxMonth=36 if OriginalTaxPeriod=="mar 2013"

gen TaxQuarter=0
replace TaxQuarter=9 if TaxMonth>24&TaxMonth<=27
replace TaxQuarter=10 if TaxMonth>27&TaxMonth<=30
replace TaxQuarter=11 if TaxMonth>30&TaxMonth<=33
replace TaxQuarter=12 if TaxMonth>33&TaxMonth<=36
replace TaxQuarter=13 if OriginalTaxPeriod=="First Quarter-2013"
replace TaxQuarter=14 if OriginalTaxPeriod=="Second Quarter-2013"
replace TaxQuarter=15 if OriginalTaxPeriod=="Third Quarter-2013"
replace TaxQuarter=16 if OriginalTaxPeriod=="Fourth Quarter-2013"
replace TaxQuarter=17 if OriginalTaxPeriod=="First Quarter-2014"
replace TaxQuarter=18 if OriginalTaxPeriod=="Second Quarter-2014"
replace TaxQuarter=19 if OriginalTaxPeriod=="Third Quarter-2014"
replace TaxQuarter=20 if OriginalTaxPeriod=="Fourth Quarter-2014"
replace TaxQuarter=21 if OriginalTaxPeriod=="First Quarter-2015"
replace TaxQuarter=22 if OriginalTaxPeriod=="Second Quarter-2015"
replace TaxQuarter=23 if OriginalTaxPeriod=="Third Quarter-2015"
replace TaxQuarter=24 if OriginalTaxPeriod=="Fourth Quarter-2015"
replace TaxQuarter=25 if OriginalTaxPeriod=="First Quarter-2016"
replace TaxQuarter=26 if OriginalTaxPeriod=="Second Quarter-2016"
replace TaxQuarter=27 if OriginalTaxPeriod=="Third Quarter-2016"
replace TaxQuarter=28 if OriginalTaxPeriod=="Fourth Quarter-2016"

drop TaxMonth OriginalTaxPeriod
save "H:/Ashwin/dta/final/2a2b_`var1'_only.dta", replace
}

** Cleaning mtin values 
use "H:/Ashwin/dta/final/2a2b_mtins_only.dta", clear
drop if Mtin == ""
keep if SaleOrPurchase=="AE" | SaleOrPurchase=="AN" | SaleOrPurchase=="BF" ///
	| SaleOrPurchase=="AB" 
duplicates tag Mtin SaleOrPurchase TaxQuarter, gen(repeat1)
duplicates drop Mtin TaxQuarter SaleOrPurchase, force
save "H:/Ashwin/dta/final/2a2b_mtins_only.dta", replace

use "H:/Ashwin/dta/final/2a2b_sellerbuyermtins_only.dta", clear
drop if SellerBuyerTin == ""
keep if SaleOrPurchase=="AE" | SaleOrPurchase=="AN" | SaleOrPurchase=="BF" ///
	| SaleOrPurchase=="AB" 
duplicates tag SellerBuyerTin SaleOrPurchase TaxQuarter, gen(repeat1)
duplicates drop SellerBuyerTin TaxQuarter SaleOrPurchase, force
drop repeat1
save "H:/Ashwin/dta/final/2a2b_sellerbuyermtins_only.dta", replace

*--------------------------------------------------------
** Mtin only for Form 16
*--------------------------------------------------------

* Adding TaxQuarter instead of TaxPeriod
use "H:/Ashwin/dta/final/unique_mtin_form16.dta", clear 

gen TaxMonth=0
replace TaxMonth=25 if TaxPeriod=="Apr-2012"
replace TaxMonth=26 if TaxPeriod=="May-2012"
replace TaxMonth=27 if TaxPeriod=="Jun-2012"
replace TaxMonth=28 if TaxPeriod=="Jul-2012"
replace TaxMonth=29 if TaxPeriod=="Aug-2012"
replace TaxMonth=30 if TaxPeriod=="Sep-2012"
replace TaxMonth=31 if TaxPeriod=="Oct-2012"
replace TaxMonth=32 if TaxPeriod=="Nov-2012"
replace TaxMonth=33 if TaxPeriod=="Dec-2012"
replace TaxMonth=34 if TaxPeriod=="Jan-2013"
replace TaxMonth=35 if TaxPeriod=="Feb-2013"
replace TaxMonth=36 if TaxPeriod=="Mar-2013"
replace TaxQuarter=9 if TaxPeriod=="First Quarter-2012"
replace TaxQuarter=10 if TaxPeriod=="Second Quarter-2012"
replace TaxQuarter=11 if TaxPeriod=="Third Quarter-2012"
replace TaxQuarter=12 if TaxPeriod=="Fourth Quarter-2012"

gen TaxQuarter=0
replace TaxQuarter=9 if TaxMonth>24&TaxMonth<=27
replace TaxQuarter=10 if TaxMonth>27&TaxMonth<=30
replace TaxQuarter=11 if TaxMonth>30&TaxMonth<=33
replace TaxQuarter=12 if TaxMonth>33&TaxMonth<=36
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
drop TaxPeriod TaxPeriod
duplicates drop Mtin TaxQuarter, force // duplicates found in 2012 data since it is at monthly
save "H:/Ashwin/dta/final/unique_mtin_form16.dta", replace

*--------------------------------------------------------
** Combining files
*--------------------------------------------------------

*Combining Mtin & SellerBuyerMtins - reason - didn't make sense to keep them separate
use "H:/Ashwin/dta/final/2a2b_sellerbuyermtins_only.dta", clear
rename SellerBuyerTin Mtin 
save "H:/Ashwin/dta/final/2a2b_sellerbuyermtins_only.dta", replace

use "H:/Ashwin/dta/final/2a2b_mtins_only.dta", clear // 2a2b Mtin only file
append using "H:/Ashwin/dta/final/2a2b_sellerbuyermtins_only.dta" //2a2b SellerBuyerMtin only file
save "H:/Ashwin/dta/final/2a2b_unique_mtins_only.dta", replace

*Flag outside state Mtins & dropping duplicates
use "H:/Ashwin/dta/final/2a2b_unique_mtins_only.dta", clear
duplicates drop
gen FlagOutsideState =0
destring Mtin, replace
replace FlagOutsideState =1 if Mtin >1000000000
save "H:/Ashwin/dta/final/2a2b_unique_mtins_only.dta", replace

use "H:/Ashwin/dta/final/2a2b_unique_mtins_only.dta", clear
drop SaleOrPurchase
duplicates drop
drop if Mtin == .
save "H:/Ashwin/dta/final/2a2b_unique_mtins_only.dta", replace

*--------------------------------------------------------
* Mtin-TaxQuarter only files
*--------------------------------------------------------
use "H:/Ashwin/dta/final/2a2b_unique_mtins_only.dta", clear // All unique Mtins form 2a2b (including outside state)
use "H:/Ashwin/dta/final/unique_mtin_dp.dta", clear // dp mtin only file
use "H:/Ashwin/dta/final/unique_mtin_form16.dta", clear // form16 mtin only file

*--------------------------------------------------------
* Merging Mtin-Quarter files from DP, Form 16 & 2a2b
*--------------------------------------------------------

use "H:/Ashwin/dta/final/2a2b_unique_mtins_only.dta", clear
//isid Mtin TaxQuarter
tempfile temp1 
save `temp1'

use "H:/Ashwin/dta/final/unique_mtin_form16.dta", clear
//isid Mtin TaxQuarter
destring Mtin, replace
merge 1:1 Mtin TaxQuarter using `temp1'

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                     9,984,649
        from master                 1,018,901  (_merge==1)
        from using                  8,965,748  (_merge==2)

    matched                         4,219,782  (_merge==3)
    -----------------------------------------
*/

gen merge_form16_2a2b = "Only form16" if _merge == 1
replace merge_form16_2a2b = "Only 2a2b" if _merge == 2
replace merge_form16_2a2b = "Both form16-2a2b" if _merge == 3
drop _merge repeat1
save "H:/Ashwin/dta/final/mtin_list_2a2b_form16.dta", replace


* Merge with DP data
use "H:/Ashwin/dta/final/mtin_list_2a2b_form16.dta", clear
tostring Mtin, replace format("%15.0f")
merge m:1 Mtin using "H:/Ashwin/dta/final/unique_mtin_dp.dta", ///
	keepusing(OptComposition RegistrationStatus)
/*     Result                           # of obs.
    -----------------------------------------
    not matched                     8,892,637
        from master                 8,682,155  (_merge==1)
        from using                    210,482  (_merge==2)

    matched                         5,522,276  (_merge==3)
    -----------------------------------------
*/
gen merge_combined_dp = "Only combined (2a2b-form16)" if _merge == 1 
replace merge_combined_dp = "Only DP" if _merge == 2 
replace merge_combined_dp = "Both (DP & 2a2b-form16)" if _merge == 3
drop _merge
save "H:/Ashwin/dta/final/mtin_list_combined.dta", replace




