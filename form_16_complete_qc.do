/************************************************* 
* Filename: 
* Input: H:/Ashwin/dta/
* Purpose: This code conducts quality checks
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
global old_input_path "D:\data"

*output files*
global output_path "H:/Ashwin/dta/final"
global qc_path "H:/Ashwin/dta/qc"
global prob_path "H:/Ashwin/dta/prob"

******** Comparing Mtin of Form16 with original Mtin list *******
*Merge with UnqiueMtin list* 
foreach var in "1213" "1314" "1415" "1516" "1617" {
use "${input_path}/unique_mtin_list.dta", clear
tempfile form16_data
save `form16_data'

* Merge with Mtin original list*
use "${input_path}/form16_1213_complete.dta", clear
merge m:1 Mtin using `form16_data'
}

********* Cancelled firms *****************
	/* Merging cancelled firms data with form16 returns data */
	
foreach var in "1213" "1314" "1415" "1516" "1617" {
use "${input_path}/cancelled_mtin_list.dta", clear
tempfile form16_data
save `form16_data' 

use "${input_path}/form16_`var'_complete.dta", clear
keep Mtin
duplicates drop Mtin, force
merge m:1 Mtin using `form16_data' 

drop if _merge !=3
keep Mtin cancellation_year 
tab cancellation_year
}

* Number of firms, total tax etc. are calculated in another do file *
//dta file "H:\Ashwin\demonetization\dta\output/demonetization_data.dta", replace
// do file "D:/Ashwin/do/demonetization_data.do

*--------------------------------------------------------
** Refund Status
*--------------------------------------------------------
** Plot a histogram of Refund Status
	/* For each quarter, plot a histogram of refund at firm level */
use "${output_path}/form16_latestreturns_consolidated.dta", clear

local quarter "First Quarter-2012" "Second Quarter-2012" ///
	"Third Quarter-2012" "Fourth Quarter-2012" "First Quarter-2013" ///
	"Second Quarter-2013" "Third Quarter-2013" "Fourth Quarter-2013" ///
	"First Quarter-2014" 

use "${output_path}/form16_latestreturns_consolidated.dta", clear
keep if TaxPeriod == "Fourth Quarter-2015"
keep if RefundClaimed >20000 & RefundClaimed < 2000000
hist RefundClaimed, frequency bin(100)
graph export "H:\Ashwin\output\graph\graphrefund_q4_1516_histogram.pdf", replace


*--------------------------------------------------------
** TDS values
*--------------------------------------------------------

** Comparing Form16_consolidated & TDS_consolidated for TDS values

** Comparing Form16_consolidated & TDS_consolidated at Mtin-Quarter Level

* Aggregating TDS data at Mtin TaxPeriod level
use "${output_path}/form16_tds_consolidated.dta", clear
bys Mtin TaxPeriod : egen tds_tin_quarter = sum(TDSAmount)
duplicates drop Mtin TaxPeriod, force
save "${qc_path}/form16_tds_tin_period_sum.dta", replace

* Retaining the latest returns in form16 for TDS data
use "${output_path}/form16_data_consolidated.dta", clear
gsort Mtin TaxPeriod -DateofReturnFiled
drop if Mtin == ""
duplicates drop Mtin TaxPeriod, force
keep MReturn_ID TaxPeriod ReturnType Mtin TDSCertificates DateofReturnFiled
merge 1:1 Mtin TaxPeriod using "${qc_path}/form16_tds_tin_period_sum.dta"
save "${qc_path}/form16_tds_merged.dta", replace

/*     Result                           # of obs.
    -----------------------------------------
    not matched                     5,316,440
        from master                 5,316,432  (_merge==1)
        from using                          8  (_merge==2)

    matched                            59,521  (_merge==3)
    -----------------------------------------
*/

** Data that is completely merged
	/* Merged data should have equal values */ 
use "${qc_path}/form16_tds_merged.dta", clear

keep if _merge == 3
gen flag = 0 
replace flag = 1 if TDSCertificates != tds_tin_quarter

gen dif = TDSCertificates - tds_tin_quarter
replace flag = 0 if dif <= 1 & dif >= -1
tab flag

/* 44% of data doesn't match at MTin-Quarter level
       flag |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |     32,940       55.34       55.34
          1 |     26,581       44.66      100.00
------------+-----------------------------------
      Total |     59,521      100.00
*/
 
** Data that is present in Form 16 
	/* Data should be zero */ 
use "${qc_path}/form16_tds_merged.dta", clear

keep if _merge == 1
gsort -TDSCertificates
keep if TDSCertificates !=0 //Removing zero values
tab TaxPeriod

/* Most TDS values don't match from 12-13 & 13-14

 The tax period for |
 which the returns has |
            been filed |      Freq.     Percent        Cum.
-----------------------+-----------------------------------
           Annual-2012 |          4        0.02        0.02
              Apr-2012 |        196        0.99        1.01
              Apr-2013 |         11        0.06        1.07
              Aug-2012 |        265        1.34        2.41
              Dec-2012 |        286        1.45        3.86
              Feb-2013 |        286        1.45        5.31
    First Quarter-2012 |      2,075       10.52       15.83
    First Quarter-2013 |      2,869       14.54       30.37
    First Quarter-2014 |          4        0.02       30.39
    First Quarter-2015 |          2        0.01       30.40
   Fourth Quarter-2012 |      3,003       15.22       45.62
   Fourth Quarter-2013 |          3        0.02       45.63
   Fourth Quarter-2014 |          2        0.01       45.64
              Jan-2013 |        294        1.49       47.13
              Jul-2012 |        265        1.34       48.48
              Jun-2012 |        253        1.28       49.76
              Mar-2013 |        395        2.00       51.76
              May-2012 |        241        1.22       52.98
              Nov-2012 |        285        1.44       54.43
              Oct-2012 |        274        1.39       55.82
   Second Quarter-2012 |      2,387       12.10       67.91
   Second Quarter-2013 |      3,491       17.69       85.61
   Second Quarter-2014 |          3        0.02       85.62
   Second Quarter-2015 |          4        0.02       85.64
              Sep-2012 |        266        1.35       86.99
    Third Quarter-2012 |      2,548       12.91       99.90
    Third Quarter-2013 |         11        0.06       99.96
    Third Quarter-2014 |          5        0.03       99.98
    Third Quarter-2015 |          3        0.02      100.00
-----------------------+-----------------------------------
                 Total |     19,731      100.00
*/

** Data that is present in Form 16_tds
	/* Data should be zero */ 
use "${qc_path}/form16_tds_merged.dta", clear

keep if _merge == 2

replace flag = 1 if TDSCertificates != tds_tin_quarter

gen dif = TDSCertificates - tds_tin_quarter
replace flag = 0 if dif <= 1 & dif >= -1
tab flag

/* 44% of data doesn't match at MTin-Quarter level
       flag |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |     32,940       55.34       55.34
          1 |     26,581       44.66      100.00
------------+-----------------------------------
      Total |     59,521      100.00
*/


* From Form16_consolidated 

* From Form16_tds

* Aggregating TDS data at ReturnID level
use "${output_path}/form16_tds_consolidated.dta", clear
bys MReturn_ID: egen tds_returnid = sum(TDSAmount)
duplicates drop MReturn_ID, force
save "${qc_path}/form16_tds_return_sum.dta", replace

** Compare with Form16_consolidated data

* Checking for duplicates at ReturnID level
use "${output_path}/form16_data_consolidated.dta", clear
duplicates tag MReturn_ID, gen(repeat1)
keep if repeat1 != 0 
save "${prob_path}/form16_data_mtin_duplicates.dta", replace

** Compare TDS value at Return ID level with aggregated TDS data
use "${output_path}/form16_data_consolidated.dta", clear
keep MReturn_ID TaxPeriod ReturnType Mtin TDSCertificates DateofReturnFiled

* Compare values that merged
merge m:1 MReturn_ID using "${qc_path}/form16_tds_return_sum.dta"
keep if  _merge ==3 


 
/*

       flag |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |    100,338       99.46       99.46
          1 |        546        0.54      100.00
------------+-----------------------------------
      Total |    100,884      100.00

*/
keep if flag == 1 
save "${prob_path}/tds_return_merged_diff.dta", replace

** Compare data at quarter level
use "${output_path}/form16_data_consolidated.dta", clear
keep MReturn_ID TaxPeriod ReturnType Mtin TDSCertificates DateofReturnFiled

bysort Mtin TaxPeriod: egen tds_total_quarter = sum(TDSCertificate)
duplicates drop TaxPeriod Mtin, force
drop MReturn_ID ReturnType DateofReturnFiled
save "${qc_path}/form16_data_tds_tin_period_sum.dta", replace

* Rename column names for merging
use "${qc_path}/form16_tds_tin_period_sum.dta", clear
rename Tax_Period TaxPeriod
save "${qc_path}/form16_tds_tin_period_sum.dta", replace

* Merge Form16_data & Form16_tds at Mtin quarter level 
use "${qc_path}/form16_data_tds_tin_period_sum.dta", clear
merge m:1 Mtin TaxPeriod using "${qc_path}/form16_tds_tin_period_sum.dta"
drop TDSCertificates MReturn_ID Date TDSAmount year
keep if _merge ==3

gen flag = 0 
replace flag = 1 if tds_total_quarter != tds_tin_quarter

gen dif = tds_total_quarter - tds_tin_quarter
replace flag = 0 if dif <= 1 & dif >= -1
tab flag

/* 
       flag |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |     58,993       99.11       99.11
          1 |        529        0.89      100.00
------------+-----------------------------------
      Total |     59,522      100.00
*/
keep if flag == 1 
save "${prob_path}/tds_quarter_merged_diff.dta", replace

*--------------------------------------------------------
** Challan data
*--------------------------------------------------------

* Aggregating Challan data at Mtin TaxPeriod level
use "${output_path}/form16_data_consolidated.dta", clear
keep MReturn_ID TaxPeriod ReturnType Mtin AmountDepositedByDealer ///
	DateofReturnFiled

bys Mtin TaxPeriod : egen challan_total_quarter = sum(AmountDepositedByDealer)
save "${prob_path}/form16_data_challan_quarter.dta", replace

*--------------------------------------------------------
** Match top 10000 firms by comparing old and the new data
*--------------------------------------------------------
use "${output_path}/form16_latestreturns_consolidated.dta", clear
keep if TaxPeriod == "Fourth Quarter-2013" //Keep changing TaxPeriod

gsort -GrossTurnover
gen top_firms = _n 
keep if top_firms <= 1000
duplicates tag TaxPeriod GrossTurnover CentralTurnover LocalTurnover TotalOutputTax TotalTaxCredit NetTax AggregateAmountPaid NetBalance, gen(repeat3)
gsort -repeat3
tempfile temp2
save "`temp2'"

use "${old_input_path}\form16_data.dta", clear 

*retain the latest returns* 
gsort DealerTIN TaxPeriod -ApprovalDate
*duplicates drop DealerTIN TaxPeriod, force
rename (TurnoverGross TurnoverCentral TurnoverLocal) (GrossTurnover CentralTurnover LocalTurnover)
keep if TaxPeriod == "Fourth Quarter-2013"
*keep if GrossTurnover> 0 

merge m:m TaxPeriod GrossTurnover CentralTurnover LocalTurnover TotalOutputTax TotalTaxCredit NetTax AggregateAmountPaid NetBalance using `temp2'

/* Fourth Quarter-2013 
    Result                           # of obs.
    -----------------------------------------
    not matched                       324,800
        from master                   324,799  (_merge==1)
        from using                          1  (_merge==2)

    matched                             1,406  (_merge==3)
    -----------------------------------------


*/
















