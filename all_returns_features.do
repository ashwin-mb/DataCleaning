/************************************************* 
* Filename: 
* Input: H:/Ashwin/dta/Non_existing_firm_year.dta
* Purpose: Creates summary stats for bogus firms and firms linked to bogus
* Output: H:/Ashwin/dta/Non_existing_firm_consolidated.dta
* Author: Ashwin MB
* Date: 25/09/2018
* Last modified: 17/10/2018 (Ashwin)
****************************************************/

** Initializing environment

clear all
version 1
set more off
qui cap log c
set mem 100m

*--------------------------------------------------------
** 1. Setting directories and files
*--------------------------------------------------------

*input files*
global input_path1 "H:/Ashwin/dta/original"
global input_path2 "H:/Ashwin/dta/intermediate"
global input_path3 "H:/Ashwin/dta/intermediate2"
global temp_path1 "H:/Ashwin/dta/temp"
global input_path4 "H:/Ashwin/dta"

*output files*
global output_path "H:/Ashwin/dta/final"
global analysis_path "H:/Ashwin/dta/analysis"
global qc_path "H:/Ashwin/dta/qc"
global prob_path "H:/Ashwin/dta/prob"
global features_path "H:/Ashwin/dta/bogusdealers"
global features_final "H:/Ashwin/dta/features"
global temp_path2 "Z:/features"

*--------------------------------------------------------
** Merging all the columns
*--------------------------------------------------------
* Append all the network features from sales side
forval var = 9/11{
import delim "${features_path}/NetworkFeaturesSales`var'.csv", varn() clear
keep __id taxquarter pagerank triangle_count in_degree out_degree
rename (pagerank triangle_count in_degree out_degree) ///
 (Sales_pagerank Sales_triangle_count Sales_in_degree Sales_out_degree)
save "${features_path}/NetworkFeaturesSales`var'.dta", replace
}

forval var = 13/28{
import delim "${features_path}/NetworkFeaturesSales`var'.csv", varn() clear
keep __id taxquarter pagerank triangle_count in_degree out_degree
rename (pagerank triangle_count in_degree out_degree) ///
 (Sales_pagerank Sales_triangle_count Sales_in_degree Sales_out_degree)
save "${features_path}/NetworkFeaturesSales`var'.dta", replace
}

use "${features_path}/NetworkFeaturesSales9.dta", clear 
append using "${features_path}/NetworkFeaturesSales10.dta" 
append using "${features_path}/NetworkFeaturesSales11.dta"

forval var =13/28{
append using "${features_path}/NetworkFeaturesSales`var'.dta"
}
rename (taxquarter __id) (TaxQuarter Mtin)
tostring Mtin, replace format("%13.0f")
save "${features_path}/NetworkFeaturesSalesAll.dta", replace

** Append all the network features from purchase side
forval var = 9/11{
import delim "${features_path}/NetworkFeaturesPurchases`var'.csv", varn() clear
keep __id taxquarter pagerank triangle_count in_degree out_degree
rename (pagerank triangle_count in_degree out_degree) ///
 (Purchases_pagerank Purchases_triangle_count Purchases_in_degree Purchases_out_degree)
save "${features_path}/NetworkFeaturesPurchases`var'.dta", replace
}

forval var = 13/28{
import delim "${features_path}/NetworkFeaturesPurchases`var'.csv", varn() clear
keep __id taxquarter pagerank triangle_count in_degree out_degree
rename (pagerank triangle_count in_degree out_degree) ///
 (Purchases_pagerank Purchases_triangle_count Purchases_in_degree Purchases_out_degree)
save "${features_path}/NetworkFeaturesPurchases`var'.dta", replace
}

use "${features_path}/NetworkFeaturesPurchases9.dta", clear 
append using "${features_path}/NetworkFeaturesPurchases10.dta" 
append using "${features_path}/NetworkFeaturesPurchases11.dta"

forval var =13/28{
append using "${features_path}/NetworkFeaturesPurchases`var'.dta"
}
rename (taxquarter __id) (TaxQuarter Mtin)
tostring Mtin, replace format("%13.0f")
save "${features_path}/NetworkFeaturesPurchasesAll.dta", replace

*--------------------------------------------------------
** Testing merge all the columns (Need to debug the problems)
*--------------------------------------------------------
use "${features_path}/FeatureReturns_TIN_hash_byte.dta", clear // created from init_new.py code
isid Mtin TaxQuarter
gen TaxQuarter1 =0
replace TaxQuarter1=9 if TaxQuarter==0
replace TaxQuarter1=10 if TaxQuarter==1
replace TaxQuarter1=11 if TaxQuarter==2
replace TaxQuarter1=12 if TaxQuarter==3
replace TaxQuarter1=13 if TaxQuarter==4
replace TaxQuarter1=14 if TaxQuarter==5
replace TaxQuarter1=15 if TaxQuarter==6
replace TaxQuarter1=16 if TaxQuarter==7
replace TaxQuarter1=17 if TaxQuarter==8
replace TaxQuarter1=18 if TaxQuarter==9
replace TaxQuarter1=19 if TaxQuarter==10
replace TaxQuarter1=20 if TaxQuarter==11
replace TaxQuarter1=21 if TaxQuarter==12
replace TaxQuarter1=22 if TaxQuarter==13
replace TaxQuarter1=23 if TaxQuarter==14
replace TaxQuarter1=24 if TaxQuarter==15
replace TaxQuarter1=25 if TaxQuarter==16
replace TaxQuarter1=26 if TaxQuarter==17
replace TaxQuarter1=27 if TaxQuarter==18
replace TaxQuarter1=28 if TaxQuarter==19
drop TaxQuarter
rename TaxQuarter1 TaxQuarter

label define year 1 "2010-11" 2 "2011-12" 3 "2012-13" 4 "2013-14" 5 "2014-15" 6 "2015-16" 7 "2016-17"
label define quarter 1 "Q1, 2010-11" 2 "Q2, 2010-11" 3 "Q3, 2010-11" 4 "Q4, 2010-11" ///
5 "Q1, 2011-12" 6 "Q2, 2011-12" 7 "Q3, 2011-12" 8 "Q4, 2011-12" ///
9 "Q1, 2012-13" 10 "Q2, 2012-13" 11 "Q3, 2012-13" 12 "Q4, 2012-13" ///
13 "Q1, 2013-14" 14 "Q2, 2013-14" 15 "Q3, 2013-14" 16 "Q4, 2013-14" ///
17 "Q1, 2014-15" 18 "Q2, 2014-15" 19 "Q3, 2014-15" 20 "Q4, 2014-15" ///
21 "Q1, 2015-16" 22 "Q2, 2015-16" 23 "Q3, 2015-16" 24 "Q4, 2015-16" ///
25 "Q1, 2016-17" 26 "Q2, 2016-17" 27 "Q3, 2016-17" 28 "Q4, 2016-17"

label values TaxQuarter quarter

merge m:1 Mtin using "${features_path}/FeatureDealerProfiles.dta", gen(_merge_profile)
/*  Result                           # of obs.
    -----------------------------------------
    not matched                       239,298
        from master                         0  (_merge_profile==1)
        from using                    239,298  (_merge_profile==2)
    matched                         5,238,280  (_merge_profile==3)
    -----------------------------------------
*/

drop if TaxQuarter == . // all _merge == 2 is deleted
isid Mtin TaxQuarter
//save "${features_final}/All_return_features_v1.dta", replace


merge 1:1 Mtin TaxQuarter using "${features_path}/SaleDiscrepancyCounts.dta", ///
		keepusing(SaleMyCountDiscrepancy SaleOtherCountDiscrepancy ///
		SaleMyTaxDiscrepancy SaleOtherTaxDiscrepancy) gen(Merge_16_SDC)
/*  Result                           # of obs.
    -----------------------------------------
    not matched                     2,647,845
        from master                 2,586,573  (Merge_16_SDC==1)
        from using                     61,272  (Merge_16_SDC==2)

    matched                         2,651,707  (Merge_16_SDC==3)
    -----------------------------------------
*/
		
isid Mtin TaxQuarter
//save "${features_final}/All_return_features_v2.dta", replace
	
	
merge 1:1 Mtin TaxQuarter using "${features_path}/SaleDiscrepancyAll.dta", ///
		keepusing(SaleDiscrepancy absSaleDiscrepancy) gen(_merge_16_SDA)
/* Result                           # of obs.
    -----------------------------------------
    not matched                     2,586,573
        from master                 2,586,573  (_merge_16_SDA==1)
        from using                          0  (_merge_16_SDA==2)

    matched                         2,712,979  (_merge_16_SDA==3)
    -----------------------------------------
*/

isid Mtin TaxQuarter
//save "${features_final}/All_return_features_v3.dta", replace
	
//use "${features_final}/All_return_features_v3.dta", clear	
merge 1:1 Mtin TaxQuarter using "${features_path}/PurchaseDiscrepancyCounts.dta", ///
		keepusing(PurchaseMyCountDiscrepancy PurchaseOtherCountDiscrepancy ///
		PurchaseMyTaxDiscrepancy PurchaseOtherTaxDiscrepancy) gen(_merge_16_PDC)
/* Result                           # of obs.
    -----------------------------------------
    not matched                     2,178,817
        from master                 1,788,028  (_merge_16_PDC==1)
        from using                    390,789  (_merge_16_PDC==2)

    matched                         3,511,524  (_merge_16_PDC==3)
    -----------------------------------------
*/

isid Mtin TaxQuarter
//save "${features_final}/All_return_features_v4.dta", replace
				
merge 1:1 Mtin TaxQuarter using "${features_path}/PurchaseDiscrepancyAll.dta", ///
		keepusing(PurchaseDiscrepancy absPurchaseDiscrepancy) gen(_merge_16_PDA)
/* Result                           # of obs.
    -----------------------------------------
    not matched                     1,787,819
        from master                 1,787,773  (_merge_16_PDA==1)
        from using                         46  (_merge_16_PDA==2)
    matched                         3,902,568  (_merge_16_PDA==3)
    -----------------------------------------
*/

isid Mtin TaxQuarter
//save "${features_final}/All_return_features_v5.dta", replace

*dropping Mtins with no tax quarter
//use "${features_path}/NetworkFeaturesSalesAll.dta", clear
//drop if TaxQuarter == . 
//save "${features_path}/NetworkFeaturesSalesAll_minus_taxquarter.dta", replace

//use "${features_final}/All_return_features_v5.dta", clear	
merge 1:1 Mtin TaxQuarter using "${features_path}/NetworkFeaturesSalesAll_minus_taxquarter.dta", ///
	keepusing(Sales_pagerank Sales_triangle_count Sales_in_degree Sales_out_degree) gen(_merge_NFS) 
/* Result                           # of obs.
    -----------------------------------------
    not matched                       692,205
        from master                   692,205  (_merge_NFS==1)
        from using                          0  (_merge_NFS==2)
    matched                         4,998,182  (_merge_NFS==3)
    -----------------------------------------
*/

isid Mtin TaxQuarter
//save "${features_final}/All_return_features_v6.dta", replace

*dropping Mtins with no tax quarter	
//use "${features_path}/NetworkFeaturesPurchasesAll.dta", clear
//drop if TaxQuarter == . 
//save "${features_path}/NetworkFeaturesPurchasesAll_minus_taxquarter.dta", clear

//use "${features_final}/All_return_features_v6.dta", clear	
merge 1:1 Mtin TaxQuarter using "${features_path}/NetworkFeaturesPurchasesAll_minus_taxquarter.dta", ///
		keepusing(Purchases_pagerank Purchases_triangle_count Purchases_in_degree Purchases_out_degree) gen(_merge_NPF)
/*     Result                           # of obs.
    -----------------------------------------
    not matched                       692,205
        from master                   692,205  (_merge_NPF==1)
        from using                          0  (_merge_NPF==2)

    matched                         4,998,182  (_merge_NPF==3)
    -----------------------------------------
*/

isid Mtin TaxQuarter
//save "${features_final}/All_return_features_v7.dta", replace
	
//use "${features_final}/All_return_features_v7.dta", clear
merge 1:1 Mtin TaxQuarter using "${features_path}/FeatureDownStreamnessPurchases.dta", ///
		keepusing(TotalSellers MaxPurchaseProp PurchaseDSUnTaxProp PurchaseDSCreditRatio ///
		PurchaseDSVatRatio Missing_PurchaseDSUnTaxProp Missing_PurchaseDSCreditRatio ///
		Missing_PurchaseDSVatRatio Missing_MaxPurchaseProp) gen(_merge_FDSP)
/* 
    Result                           # of obs.
    -----------------------------------------
    not matched                     2,523,438
        from master                 2,523,438  (_merge_FDSP==1)
        from using                          0  (_merge_FDSP==2)

    matched                         3,166,949  (_merge_FDSP==3)
    -----------------------------------------
*/

isid Mtin TaxQuarter
save "${features_final}/All_return_features_v8.dta", replace
		
use "${features_final}/All_return_features_v8.dta", clear		
merge m:1 Mtin TaxQuarter using "${features_path}/FeatureDownStreamnessSales.dta", ///
		keepusing(TotalBuyers MaxSalesProp SalesDSUnTaxProp SalesDSCreditRatio ///
		SalesDSVatRatio Missing_SalesDSUnTaxProp Missing_SalesDSCreditRatio ///
		Missing_SalesDSVatRatio Missing_MaxSalesProp) gen(_merge_FDSS)

/* Result                           # of obs.
    -----------------------------------------
    not matched                     3,106,833
        from master                 3,106,833  (_merge_FDSS==1)
        from using                          0  (_merge_FDSS==2)

    matched                         2,583,554  (_merge_FDSS==3)
    -----------------------------------------
*/
isid Mtin TaxQuarter
save "${features_final}/All_return_features.dta", replace

*dropping Outside state Mtins
use "${features_final}/All_return_features.dta", clear
destring Mtin, replace
drop if Mtin>1000000000
drop index
save "${features_final}/All_return_features.dta", replace
export delim H:/Ashwin/dta/features/All_return_features.csv, replace


*renaming and ordering variables
use "${features_final}/All_return_features.dta", clear
rename (_merge_profile Merge_16_SDC _merge_16_SDA) (profile_merge _merge_y _merge_salediscrepancy)
rename (_merge_16_PDC _merge_16_PDA) (_merge_z _merge_purchasediscrepancy) 
rename (_merge_NFS _merge_NPF) (salesnetwork_merge purchasenetwork_merge)
rename (_merge_FDSP _merge_FDSS) (purchaseds_merge salesds_merge)
//rename _merge transaction_merge
rename (LocalTurnover CentralTurnover GrossTurnover) (TurnoverLocal TurnoverCentral TurnoverGross) 
order TIN_hash_byte, before(RefundClaimedBoolean)
order TaxQuarter, before(RefundClaimed)
order CarryForwardTaxCredit, after(RefundClaimed)
order ZeroTaxCredit, before(RegisteredSalesTax)

* Create salesmatch & purchasematch (since old file has these variables)
gen salesmatch_merge = "left_only"
replace salesmatch_merge = "both" if _merge_salediscrepancy == 1 
order salesmatch_merge, after(_merge_salediscrepancy)

gen purchasematch_merge = "left_only"
replace purchasematch_merge = "both" if _merge_purchasediscrepancy == 1 
order purchasematch_merge, after(_merge_purchasediscrepancy)

* Retaining rows with only Returns columns 
tab TaxQuarter if RefundClaimed != .
drop if RefundClaimed == .

*Drop variables not present in the old dataset 
drop Top5Items TDSCertificates NetTax TotalOutputTax TotalTaxCredit ExemptedSales LocalTaxRatio TaxProp OriginalRegistrationDate OriginalTaxPeriod OverallTaxAmount

*changing values of few variables to make it comparable with old data
gen RefundClaimedBoolean_1 = "nan"
replace RefundClaimedBoolean_1 = "True" if RefundClaimedBoolean == 1
replace RefundClaimedBoolean_1 = "False" if RefundClaimedBoolean == 0
drop RefundClaimedBoolean
rename RefundClaimedBoolean_1 RefundClaimedBoolean

*drop label for TaxQuarter
label drop quarter
save "${features_final}/All_return_features.dta", replace
export delim H:/Ashwin/dta/features/All_return_features.csv, replace

*Dropping Q4 of 2012-13 
drop if TaxQuarter == 12
save "${features_final}/All_return_features_minus_q12.dta", replace

**Dropping CancellationReason column 
	/* This creates a problem when converting to csv file
	Need to understand why */
use "${features_final}/All_return_features_minus_q12.dta", clear
drop CancellationReason
*Save as csv file
save "${features_final}/All_return_features_minus_q12.dta", replace
export delim H:/Ashwin/dta/features/All_return_features_minus_q12.csv, replace



****** create sample data
use "${features_final}/All_return_features_minus_q12.dta", clear
gen index = _n
drop if index >50000
drop index
save "${features_final}/All_return_features_minus_q12_sample.dta", replace
//gen CancellationReason_1 = substr(CancellationReason, 1, 50)
export delim H:/Ashwin/dta/features/All_return_features_minus_q12_sample.csv, replace
