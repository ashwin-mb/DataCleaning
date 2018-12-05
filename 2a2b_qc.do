  /************************************************* 
* Filename: 
* Input: 2a2b dta_files
* Purpose: Compare new and old 2a2b data
* Output:
* Author: Ashwin MB
* Date: 09/10/2018
* Last modified: 19/11/2018 (Ashwin)
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
global delim_path "H:/Ashwin/output"

*--------------------------------------------------------
** Comparing new 2a2b data with old 2a2b data
*--------------------------------------------------------

****************** 2012-13 Monthly data *****************

** Loading old 2a2b dataset
use "${old_path}/annexure_2A2B_monthly_201213.dta", clear
/*
. tab Month Year

           |               Year
     Month |      2011       2012       2013 |     Total
-----------+---------------------------------+----------
         1 |         0 14,446,310  3,015,728 |17,462,038 
         2 |         0 11,544,660  2,935,327 |14,479,987 
         3 |         0 11,366,778  3,143,788 |14,510,566 
         4 |         0  2,847,322          0 | 2,847,322 
         5 |         0  3,001,472          0 | 3,001,472 
         6 |         0  2,942,949          0 | 2,942,949 
         7 |         0  3,021,751          0 | 3,021,751 
         8 |         0  2,989,978          0 | 2,989,978 
         9 |         0  3,098,230          0 | 3,098,230 
        10 |         0  3,242,476          0 | 3,242,476 
        11 |         0  3,015,173          1 | 3,015,174 
        12 |        17  3,248,914          0 | 3,248,931 
-----------+---------------------------------+----------
     Total |        17 64,766,013  9,094,844 |73,860,874 
*/

	/* Loading new dataset */ 
use "${output_path}/2a2b_monthly_2012.dta", clear
tab TaxPeriod TaxYear

/* 
 TaxPeriod |      2011       2012       2013 |     Total
-----------+---------------------------------+----------
         1 |     1,458     17,996        155 |    19,609 
         2 |     1,730     23,754         46 |    25,530 
         3 |     6,188     34,621        119 |    40,928 
         4 |         0  2,840,353          0 | 2,840,353 
         5 |         0  2,994,700          0 | 2,994,700 
         6 |         0  2,936,299          0 | 2,936,299 
         7 |         0  3,016,582          0 | 3,016,582 
         8 |         0  2,984,651          0 | 2,984,651 
         9 |         0  3,092,614          0 | 3,092,614 
        10 |         0  3,239,521          0 | 3,239,521 
        11 |         0  3,007,976          1 | 3,007,977 
        12 |         0  3,244,408          0 | 3,244,408 
-----------+---------------------------------+----------
     Total |     9,376 27,433,475        321 |27,443,172 
*/

****************** 2013-14 Quarterly data *****************

** 2013 2a2b data
	/* Loading old dataset */ 
use "${old_path}/annexure_2A2B_quarterly_2013.dta", clear
tab Month
* Tabulate no. of entries every quarter
/* 
      Month |      Freq.     Percent        Cum.
------------+-----------------------------------
         41 |  6,261,404       25.30       25.30
         42 |  6,225,620       25.15       50.45
         43 |  6,114,606       24.70       75.15
         44 |  6,150,091       24.85      100.00
------------+-----------------------------------
      Total | 24,751,721      100.00
*/

	/* Loading new dataset */ 
use "${output_path}/2a2b_quarterly_2013.dta", clear
tab TaxPeriod 
*Tabulate no. of entries every quarter 
/* 
  TaxPeriod |      Freq.     Percent        Cum.
------------+-----------------------------------
         41 |  6,263,658       25.30       25.30
         42 |  6,227,668       25.15       50.45
         43 |  6,117,659       24.71       75.17
         44 |  6,148,474       24.83      100.00
------------+-----------------------------------
      Total | 24,757,459      100.00

*/

****************** 2013-14 Quarterly data *****************

	/* Loading old dataset */
use "${old_path}/annexure_2A2B_quarterly_2014.dta", clear
tab Month
*Tabulate no. of entries every quarter
/*
      Month |      Freq.     Percent        Cum.
------------+-----------------------------------
          9 |         60        0.00        0.00
         41 |  6,013,150       24.82       24.82
         42 |  6,134,286       25.32       50.14
         43 |  6,033,836       24.90       75.04
         44 |  6,046,717       24.96      100.00
------------+-----------------------------------
      Total | 24,228,049      100.00
*/

	/* Loading new dataset */ 
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

*--------------------------------------------------------
** Check missing values & values in 2a2b data
*--------------------------------------------------------

** Monthly 2012 values
use "${output_path}/2a2b_monthly_2012.dta", clear

tab SaleOrPurchase // AB, AE, AN, BF
tab SalePurchaseType // Childnode
tab DealerGoodType // UD RD OT (other values present)
tab TransactionType // C, Exempted, E1/E2,GD, H, I, J, None, WC (other values present)
tab Rate // Rates other than 0-5-12-18 (some in thousands)
tab TaxYear // 2011, 2012, 2013

* Missing Return ID, Mtin, PartyTin
bro if  MReturn_ID == "" // 41.8% don't have return Ids
bro if Mtin == "" //99.99% data present
bro if SellerBuyerTin == "" // 99.9% data present

** Quarterly 2013-14 data
use "${output_path}/2a2b_quarterly_2013.dta", clear

tab SaleOrPurchase // AB, AE, AN, BF
tab SalePurchaseType // Childnode
tab DealerGoodType // UD RD OT (other values present)
tab TransactionType // C, Exempted, E1/E2,GD, H, I, J, None, WC 
tab Rate // Rates proper
tab TaxYear // 2013

* Missing Return ID, Mtin, PartyTin
bro if  MReturn_ID == "" // 84.3% don't have return Ids
bro if Mtin == "" //99.99% data present
bro if SellerBuyerTin == "" // 99.99% data present

** Quarterly 2014-15 data
use "${output_path}/2a2b_quarterly_2014.dta", clear

tab SaleOrPurchase // AE, AN, BF
tab SalePurchaseType // Childnode
tab DealerGoodType // UD RD OT (other values present)
tab TransactionType // C, Exempted, E1/E2,GD, H, I, J, None, WC 
tab Rate // Rates proper
tab TaxYear // 2012, 2013, 2014

* Missing Return ID, Mtin, PartyTin
bro if  MReturn_ID == "" // 99.5% don't have return Ids
bro if Mtin == "" //99.99% data present
bro if SellerBuyerTin == "" // 99.99% data present

*--------------------------------------------------------
** Aggregating Type 1 & 2 values of 2a2b & checking with Form 16
*--------------------------------------------------------

** Quarterly 2014-15 data
	/* Summing values for different catergories */
use "${output_path}/2a2b_quarterly_2014.dta", clear

bysort SaleOrPurchase SalePurchaseType DealerGoodType TransactionType ///
							TaxPeriod: gen NetAmount_1 = sum(NetAmount)
bysort SaleOrPurchase SalePurchaseType DealerGoodType TransactionType ///
							TaxPeriod: gen Tax_1 = sum(Tax)
bysort SaleOrPurchase SalePurchaseType DealerGoodType TransactionType ///
							TaxPeriod: gen Total_1 = sum(Total)

keep SaleOrPurchase SalePurchaseType DealerGoodType TransactionType ///
							TaxPeriod NetAmount_1 Tax_1 Total_1							
duplicates drop SaleOrPurchase SalePurchaseType TaxPeriod, force

save "${temp_path1}/2a2b_aggregated.dta", replace
export excel "${delim_path}/2a2b_comparison_data.xlsx", ///
			firstrow(variables) she("2a2b_2014_quarterly") sheetmodify

** Form 16 data
	/* Summing all the variables of form16 at quarterly level */
use "${output_path}\form16_data_consolidated.dta", clear

*Retaining the latest return per dealer
gsort TaxPeriod Mtin -DateofReturnFiled
duplicates drop TaxPeriod Mtin, force

collapse (sum) *Turnover* *OutputTax* *Labor* *Land* *Purchase* *Sale* Credit* *Credit WCCredit*, by(TaxPeriod)
save "${temp_path1}/form16_data_aggregated.dta" ,replace
export excel "${delim_path}/2a2b_comparison_data.xlsx", ///
			firstrow(variables) she("form16_aggregated") sheetmodify

// Numbers don't match Location- H:/Ashwin/dta/temp/2a2b_comparison_data.xlsx

*--------------------------------------------------------
** Comparing Mtin values 
*--------------------------------------------------------

** Extract Mtin from 2a2b information

use "${output_path}/2a2b_monthly_2012.dta", clear
keep Mtin MReturn_ID SellerBuyerTin OriginalTaxPeriod
duplicates drop
save "${temp_path1}/2a2b_tin.dta", replace

foreach var in 2013 2014 2015 {
use "${output_path}/2a2b_quarterly_`var'.dta", clear
keep Mtin MReturn_ID SellerBuyerTin OriginalTaxPeriod
duplicates drop
append using "${temp_path1}/2a2b_tin.dta"
save "${temp_path1}/2a2b_tin.dta", replace 
}

** Compare Mtin & Return_Ids from 2a2b and Tin
* Load Tin values from 2a2b
use "${temp_path1}/2a2b_tin.dta", clear //2a2b at Mtin-TaxPeriod-ReturnID level

*rename TaxPeriod for merging
rename OriginalTaxPeriod TaxPeriod
label variable TaxPeriod "OriginalTaxPeriod"

save "${temp_path1}/2a2b_tin.dta", replace //2a2b at Mtin-TaxPeriod-ReturnID level

* To merge Mtins, bring the data to Mtin Taxperiod level
duplicates drop Mtin TaxPeriod, force
save "${temp_path1}/2a2b_tin_temp.dta", replace //2a2b at Mtin-TaxPeriod level

use "${output_path}/unique_mtin_form16.dta", clear
merge 1:1 Mtin TaxPeriod using "${temp_path1}/2a2b_tin_temp.dta"
/*

    Result                           # of obs.
    -----------------------------------------
    not matched                     4,120,597
        from master                 2,672,656  (_merge==1)
        from using                  1,447,941  (_merge==2)

    matched                         2,703,311  (_merge==3)
    -----------------------------------------

*/
// Not perfect mapping when merged at Mtin-TaxPeriod

* Create unique Mtins from 2a2b  data
use "${temp_path1}/2a2b_tin.dta", clear
duplicates drop Mtin, force
save "${temp_path1}/2a2b_tin_temp.dta", replace

* Merge at Mtin level

use "${output_path}/unique_mtin_form16.dta", clear
merge m:1 Mtin using "${temp_path1}/2a2b_tin_temp.dta"

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                       455,183
        from master                   444,375  (_merge==1)
        from using                     10,808  (_merge==2)

    matched                         4,931,592  (_merge==3)
    -----------------------------------------
*/

// Not perfect mapping when merged at Mtin level. 
// Missing values within state transactions as well
keep if _merge == 2 
keep Mtin
save "${output_path}/2a2b_mtins_only.dta", replace

** Understand Types of dealers that are present only in 2a2b
	/* Merge mtins from 2a2b (that are not present in form16) with DP */

use "${output_path}/2a2b_mtins_only.dta", clear 
tempfile temp1
save `temp1'

use "${output_path}/dp_form.dta", clear
merge m:1 Mtin using `temp1'

keep if _merge == 3 // retaing only merged data; total firms = 10,808
tab OptComposition // 98.65 (8.3k) are composition, 115 firms regular, others cancelled

** Merge ReturnIds, bring the data to Mtin Taxperiod level
use "${temp_path1}/2a2b_tin.dta", clear
duplicates drop MReturn_ID, force
save "${temp_path1}/2a2b_tin_temp.dta", replace // 2a2b data at Mtin-Period level

use "${output_path}/unique_returnid_form16.dta", clear
merge m:1 MReturn_ID using "${temp_path1}/2a2b_tin_temp.dta"

/*

    Result                           # of obs.
    -----------------------------------------
    not matched                     8,915,569
        from master                 7,533,063  (_merge==1)
        from using                  1,382,506  (_merge==2)

    matched                                 0  (_merge==3)
    -----------------------------------------
*/

// Return IDs don't match at all. They haven't deidentified the data. 

** Merge Mtins from 2a2b and DP
	/* Check dealer from 2a2b are present in DP forms */
use "${temp_path1}/2a2b_tin.dta", clear 
duplicates drop Mtin, force
save "${temp_path1}/2a2b_tin_temp.dta", replace // 2a2b data at Mtin level

use "${output_path}/unique_mtin_dp.dta", clear
merge m:1 Mtin using "${temp_path1}/2a2b_tin_temp.dta"

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                       355,048
        from master                   355,048  (_merge==1)
        from using                          0  (_merge==2)

    matched                           331,517  (_merge==3)
    -----------------------------------------
*/

// Mtins from 2a2b and DP perfectly match



*--------------------------------------------------------
** 5.1 Aggregating 2a2b and Form16 at firm level for 2014-15
*--------------------------------------------------------
**** Aggregating 2a2b and Form16 data at firm level **** 
foreach var in 2013 2015 {
use "${output_path}/2a2b_quarterly_`var'.dta", clear
gen Combination = SaleOrPurchase + SalePurchaseType
//tab Combination
drop if Combination == "Swank-Jodhpur" | Combination == `"""'
bysort Mtin Combination TaxPeriod: egen NetAmount_1 = sum(NetAmount)
bysort Mtin Combination TaxPeriod: egen Tax_1 = sum(Tax)
bysort Mtin Combination TaxPeriod: egen Total_1 = sum(Total)
tostring TaxPeriod, replace
gen Unique_identifier = Mtin + TaxPeriod
duplicates drop Unique_identifier Combination, force

drop Sale* DealerG* TransactionT* Rate NetAmount Tax Total TaxYear Date var12 ///
	Form_Status var14 SellerBuyerTin MReturn_ID OriginalTaxPeriod Commodity* 
drop if Combination == "'" | Combination == "(41)" | Combination == "(64)" ///
	| Combination == "(77)" | Combination == "+" | Combination == "88" ///
	| Combination == "]" 
	
reshape wide NetAmount_1 Tax_1 Total_1, i(Unique_identifier) j(Combination) string

label variable NetAmount_1AECG "NetAmount = R6.1(PurchaseCapitalGoods)"
label variable Tax_1AEOT "Tax = R6.2(CreditOtherGoods)" 
label variable NetAmount_1ANISPC "NetAmount = R11.15(InterStatePurchaseCD)" 
label variable NetAmount_1ANISPN "NetAmount = R11.15(TotalInterStatePurchase)"
label variable NetAmount_1ANPUC "NetAmount = R6.3(PurchaseUnregisteredDealer)"
label variable NetAmount_1ANSBT "NetAmount = R11.3(InwardStockTransferBranchF)"
label variable NetAmount_1BFEOI "NetAmount = R11.10(ExportFromIndia"
label variable NetAmount_1BFHSS "NetAmount = R11.12(HighSeaSale)"
label variable NetAmount_1BFISBCT "NetAmount = R11.4(OutwardStockTransferBranch"
label variable NetAmount_1BFISS "NetAmount = R11.15(TotalInterStateSale)"
label variable Tax_1BFLS "Tax = R5.14(TotalOutputTax)"

order (Mtin TaxPeriod), before(Unique_identifier)
replace TaxPeriod = "First Quarter-`var'" if TaxPeriod == "41"
replace TaxPeriod = "Second Quarter-`var'" if TaxPeriod == "42"
replace TaxPeriod = "Third Quarter-`var'" if TaxPeriod == "43"
replace TaxPeriod = "Fourth Quarter-`var'" if TaxPeriod == "44"
tempfile temp1
save "`temp1'" 

use "${output_path}\form16_data_consolidated.dta", clear
keep if TaxPeriod == "First Quarter-`var'" | TaxPeriod == "Second Quarter-`var'" ///
| TaxPeriod == "Third Quarter-`var'" | TaxPeriod == "Fourth Quarter-`var'"
gsort Mtin TaxPeriod -DateofReturnFiled
duplicates drop Mtin TaxPeriod, force

merge 1:1 Mtin TaxPeriod using `temp1'

/* 2013-14
    Result                           # of obs.
    -----------------------------------------
    not matched                       179,380
        from master                   148,965  (_merge==1)
        from using                     30,415  (_merge==2)

    matched                           821,567  (_merge==3)
    -----------------------------------------
*/

/* 2014-15
Master = Form16; Using = 2a2b
    Result                           # of obs.
    -----------------------------------------
    not matched                       197,098
        from master                   165,823  (_merge==1)
        from using                     31,275  (_merge==2)

    matched                           844,944  (_merge==3)
    -----------------------------------------
*/

/* 2015-16
    Result                           # of obs.
    -----------------------------------------
    not matched                       241,995
        from master                   211,146  (_merge==1)
        from using                     30,849  (_merge==2)

    matched                           896,993  (_merge==3)
    -----------------------------------------
*/
save "${input_path2}\2a2b_form16_`var'.dta", replace
}

** 5.1.a Merged data from 2a2b and Form 16 for 2014-15
foreach var in 2013 2014 2015{
use "${input_path2}\2a2b_form16_`var'.dta", clear
keep if _merge == 3 			
keep TaxPeriod Mtin ///
	PurchaseCapitalGoods CreditOtherGoods InterStatePurchaseOther ///
	PurchaseUnregisteredDealer InwardStockTransferBranchF ExportFromIndia ///
	HighSeaSale  TotalInterStateSale TotalOutputTax InterStatePurchaseCD ///
	HighSeaPurchase InwardStockTransferConsignment ///
	NetAmount_1AECG Tax_1AEOT NetAmount_1ANISPC NetAmount_1ANISPN ///
	NetAmount_1ANPUC NetAmount_1ANSBT NetAmount_1BFEOI NetAmount_1BFISBCT ///
	NetAmount_1BFISS Tax_1BFLS  NetAmount_1ANHSP OutwardStockTransferBranchF ///
	NetAmount_1ANIOI NetAmount_1BFHSS ImportToIndia NetAmount_1ANSCT

/* Mapping between 2a2b & Form 16 
TotalOutputTax 					Tax_1BFLS
PurchaseCapitalGoods 			NetAmount_1AECG
CreditOtherGoods				Tax_1AEOT
PurchaseUnregisteredDealer		NetAmount_1ANPUC
InwardStockTransferBranchF		NetAmount_1ANSBT
ExportFromIndia					NetAmount_1BFEOI
ImportToIndia					Tax_1AEOT
OutwardStockTransferBranchF 	NetAmount_1BFISBCT
HighSeaSale						NetAmount_1BFHSS
HighSeaPurchase					NetAmount_1ANHSP
TotalInterStateSale				NetAmount_1BFISS
TotalInterStatePurchase			NetAmount_1ANISPN
InterStatePurchaseCD			NetAmount_1ANISPC
InwardStockTransferConsignment	NetAmount_1ANSCT
*/

gen r5_14_error = ((TotalOutputTax - Tax_1BFLS)*100)/Tax_1BFLS
//gen r6_1_error = ((PurchaseCapitalGoods - NetAmount_1AECG)*100)/NetAmount_1AECG
gen r6_2_error = ((CreditOtherGoods - Tax_1AEOT)*100)/Tax_1AEOT
//gen r11_10p_error = ((ImportToIndia - NetAmount_1ANIOI)*100)/NetAmount_1ANIOI
//gen r11_3p_error = ((InwardStockTransferBranchF - NetAmount_1ANSBT)*100)/NetAmount_1ANSBT
//gen r11_4_error = ((InwardStockTransferConsignment - NetAmount_1ANSCT)*100)/NetAmount_1ANSCT
//gen r11_3s_error = ((OutwardStockTransferBranchF - NetAmount_1BFISBCT)*100)/NetAmount_1BFISBCT 
//gen r11_10s_error = ((ExportFromIndia - NetAmount_1BFEOI)*100)/NetAmount_1BFEOI
//gen r11_12p_error = ((HighSeaPurchase - NetAmount_1ANHSP)*100)/NetAmount_1ANHSP
//gen r11_12s_error = ((HighSeaSale - NetAmount_1BFHSS)*100)/NetAmount_1BFHSS
gen r11_15s_error = ((TotalInterStateSale - NetAmount_1BFISS)*100)/NetAmount_1BFISS
gen r11_1_error = ((InterStatePurchaseCD - NetAmount_1ANISPC)*100)/NetAmount_1ANISPC
//gen r11_13p_error = ((InterStatePurchaseOther - NetAmount_1ANISPN)*100)/NetAmount_1ANISPN
//gen r6_3_1_error = ((PurchaseUnregisteredDealer - NetAmount_1ANPUC)*100)/NetAmount_1ANPUC


label variable r5_14_error "TotalOutputTax" 
//label variable r6_1_error "PurchaseCapitalGoods" 
label variable r6_2_error "CreditOtherGoods" 
//label variable r11_10p_error "ImportToIndia" 
//label variable r11_3p_error "InwardStockTransferBranchF"
//label variable r11_4_error "InwardStockTransferConsignment" 
//label variable r11_3s_error "OutwardStockTransferBranchF" 
//label variable r11_10s_error "ExportFromIndia"
//label variable r11_12p_error "HighSeaPurchase"
//label variable r11_12s_error "HighSeaSale"
label variable r11_15s_error "TotalInterStateSale" 
label variable r11_1_error "InterStatePurchaseCD"
//label variable r11_13p_error "InterStatePurchaseOther" 
//label variable r6_3_1_error "PurchaseUnregisteredDealer"

save "${input_path3}\2a2b_form16_`var'_2.dta", replace
}
**Deep dive on the reasons for high Error Rate

foreach var1 in 2013 2014 2015 { 
use "${input_path3}\2a2b_form16_`var1'_2.dta", clear

foreach var in r5_14 r6_2 r11_15s r11_1 {
gen `var'_error_flag = 0 
replace `var'_error_flag = 1 if r5_14_error > -5 & r5_14_error < 5
replace `var'_error_flag = 2 if r5_14_error < -5 | r5_14_error > 5
replace `var'_error_flag = 0 if  r5_14_error == . 
tab `var'_error_flag 
}
}
/*  All 4 variables show same error rates
	0=Missing; 1=Between -5 & 5; 2=more than -5 & 5
				2013-14
r5_14_error |
      _flag |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |    150,762       18.35       18.35
          1 |    662,745       80.67       99.02
          2 |      8,060        0.98      100.00
------------+-----------------------------------
      Total |    821,567      100.00

				2014-15
r5_14_error |
      _flag |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |    159,444       18.87       18.87
          1 |    676,879       80.11       98.98
          2 |      8,621        1.02      100.00
------------+-----------------------------------
      Total |    844,944      100.00

				2015-16
r5_14_error |
      _flag |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |    172,755       19.26       19.26
          1 |    714,394       79.64       98.90
          2 |      9,844        1.10      100.00
------------+-----------------------------------
      Total |    896,993      100.00

*/


** Not merged = Only from Form 16 
	/* Understand the type of firms that are in Form 16 but not in 2a2b */

foreach var in 2013 2014 2015 {
use "${input_path2}\2a2b_form16_`var'.dta", clear

keep if _merge == 1
tab GrossTurnover // Average 99.5 firms have 0 Gross-turnover
}
** Not merged = Only from 2a2b
	/* Understand the type of firms that are in 2a2b but not in Form16 */

** Check how many are composition dealers
foreach var in 2013 2014 2015 {
use "${input_path2}\2a2b_form16_`var'.dta", clear
keep if _merge == 2 	
keep Mtin
duplicates drop
tempfile temp1
save `temp1'
	
* Merge 2a2b unmerged data with dp
use "${output_path}\dp_form.dta", clear
merge m:1 Mtin using `temp1'
tab OptComposition if _merge == 3 // Average 91% are Composition dealers

/*
    Result                           # of obs.
    -----------------------------------------
    not matched                       676,705
        from master                   676,705  (_merge==1)
        from using                          0  (_merge==2)

    matched                             9,860  (_merge==3)
*/
}
