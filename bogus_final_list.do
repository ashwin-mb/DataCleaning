/************************************************* 
* Filename: 
* Input: H:/Ashwin/dta/Non_existing_firm_year.dta
* Purpose: Creates final master list of firms according to their ranks 
			from different models
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
** Setting directories and files
*--------------------------------------------------------

*input files*
global input_path1 "H:/Ashwin/dta/original"
global input_path2 "H:/Ashwin/dta/intermediate"
global input_path3 "H:/Ashwin/dta/intermediate2"
global temp_path1 "H:/Ashwin/dta/temp"
global input_path4 "H:/Ashwin/dta"
global input_path5 "H:/Ashwin"

*output files*
global output_path "H:/Ashwin/dta/final"
global analysis_path "H:/Ashwin/dta/analysis"
global qc_path "H:/Ashwin/dta/qc"
global prob_path "H:/Ashwin/dta/prob"
global features_path "H:/Ashwin/dta/bogusdealers"
global features_final "H:/Ashwin/dta/features"
global temp_path2 "Z:/features"
global final_list "H:/Ashwin/finallist"

*--------------------------------------------------------
** Generating final list 
*--------------------------------------------------------
*Creating a master list of features
use "${features_final}/All_return_features_minus_q12.dta", clear
gen TotalTaxCreditBeforeAdjustment = TaxCreditBeforeAdjustment
collapse (sum)TotalTaxCreditBeforeAdjustment (mean) TaxCreditBeforeAdjustment (mean) TotalReturnCount (mean)VatRatio ///
		(mean) MoneyGroup, by(Mtin)
rename (TaxCreditBeforeAdjustment TotalReturnCount) (AvgTaxCreditBeforeAdjustment AvgRevisedReturns)
tostring Mtin, replace
merge 1:1 Mtin using "${output_path}/dp_form.dta", keepusing(CancellationReason RegistrationStatus CancellationDate)
keep if _merge == 3
drop _merge
save "${final_list}/intermediate/master_file_new.dta", replace

use "${features_final}/All_return_features_minus_q12.dta", clear
*calculate how long where the firms active (no of quarters)
keep Mtin TaxQuarter bogus_flag StartYear Ward
bysort Mtin TaxQuarter: gen ActiveQuarters = _n
isid Mtin TaxQuarter
bysort Mtin: replace ActiveQuarters = sum(ActiveQuarters)
gsort Mtin -ActiveQuarters
duplicates drop Mtin, force
drop TaxQuarter
tostring Mtin, replace

merge 1:1 Mtin using "${final_list}/intermediate/master_file_new.dta"
drop _merge
isid Mtin
save "${final_list}/intermediate/master_file_new.dta", replace

** Merge the master file with prediction file ** 

*1. performance * 
import delim "${input_path5}/BogusFirmCatching_minus_glm/output_data/avg_predictions20190419.csv", ///
		clear varn(1) case(preserve)
tempfile temp1
save `temp1'
		
use "${final_list}/intermediate/master_file_new.dta", clear
destring Mtin, replace
merge 1:1 Mtin using `temp1'
drop _merge 
rename model_score_bogus_flag p1
gsort -p1 
gen Ranking_Performance = _n
save "${final_list}/intermediate/master_file_new.dta", replace

*2. Performance without ward*
import delim "${input_path5}/BogusFirmCatching_minus_glm_ward/output_data/avg_predictions20190419.csv", ///
		clear varn(1) case(preserve)
tempfile temp1
save `temp1'
		
use "${final_list}/intermediate/master_file_new.dta", clear
destring Mtin, replace
merge 1:1 Mtin using `temp1'
drop _merge 
rename model_score_bogus_flag p2
gsort -p2
gen Ranking_Performance_Noward = _n
save "${final_list}/intermediate/master_file_new.dta", replace

*3. Revenue Optimized*
gen p3 = p1*TotalTaxCreditBeforeAdjustment
gsort -p3
gen Ranking_RevenueOptimized = _n

*4. Revenue Optimized without Ward
gen p4 = p2*TotalTaxCreditBeforeAdjustment
gsort -p4
gen Ranking_RevenueOptimized_Noward = _n
save "${final_list}/intermediate/master_file_new.dta", replace

*5. Performance without DP (feature set 4 has network features + return features)
import delim "${input_path5}/BogusFirmCatching_minus_glm/models/diff_feature_sets/20190419/feature_set_4/firm_period_predictions20190419.csv", ///
		clear varn(1) case(preserve)
collapse (mean) model_score_bogus_flag, by(Mtin)
tempfile temp1
save `temp1'

use "${final_list}/intermediate/master_file_new.dta", clear
destring Mtin, replace
merge 1:1 Mtin using `temp1'
drop _merge 
rename model_score_bogus_flag p5
gsort -p5
gen Ranking_Performance_NoDP = _n
save "${final_list}/intermediate/master_file_new.dta", replace

*6. Revenue Optimized without DP
gen p6 = p5*TotalTaxCreditBeforeAdjustment
gsort -p6
gen Ranking_RevenueOptimized_NoDP = _n
save "${final_list}/final/master_file_new.dta", replace
export excel "${final_list}/final/master_file_new.xlsx", replace firstrow(var)

/* Needs modification to the input file
*7. Keeping firms with StartYear >= 2013
import delim "${input_path5}/BogusFirmCatching_minus_glm_2013/output_data/firm_period_predictions20190227.csv", ///
		clear varn(1) case(preserve)
collapse (mean) model_score_bogus_flag, by(Mtin)
tempfile temp1
save `temp1'

use "${final_list}/final/master_file_new.dta", clear
destring Mtin, replace
merge 1:1 Mtin using `temp1'
drop _merge 
rename model_score_bogus_flag p7
gsort -p7
gen Ranking_Performance_after_2013 = _n
save "${final_list}/final/master_file_new.dta", replace

*8. Adding revenue optimized to firms wtih StartYear >= 2013
gen p8 = p7*TotalTaxCreditBeforeAdjustment
gsort -p8
gen Ranking_RevenueOptimized_2013 = _n
save "${final_list}/final/master_file_new.dta", replace
export excel "${final_list}/final/master_file_new.xlsx", replace firstrow(var)
*/




 


*--------------------------------------------------------
** /* Basic stats */
*--------------------------------------------------------

*list of firms that are registered/ cancelled
/*
Firms 		  Registered	  % 	  Cancelled 	  % 
Top 500 		269 		53.80% 		231 		46.20% 
Top 1000 		582 		58.20% 		418 		41.80% 
Top 1500 		933 		62.20% 		567 		37.80%
Top 2500 		1668 		66.72% 		832 		33.28%
Top 5000 		3460 		69.20% 		1540 		30.80% 
*/

*find overlap of rankings (write a more efficient code)
use "${final_list}/final/all_ranking.dta", clear

foreach var1 in 500 1000 1500 2500 5000{
foreach var2 in 1 2 3 4{
gen top_`var1'_`var2' = 0
}
}

foreach var1 in 500 1000 1500 2500 5000 {
replace top_`var1'_1 = 1 if rank_performance <=`var1'
replace top_`var1'_2 = 1 if rank_performance_noward <=`var1'
replace top_`var1'_3 = 1 if rank_revenueoptimized <=`var1'
replace top_`var1'_4 = 1 if rank_revenueoptimized_noward <=`var1'
egen top_`var1' = rowtotal(top_`var1'_1 top_`var1'_2 top_`var1'_3 top_`var1'_4)
}


foreach var1 in 500 1000 1500 2500 5000{
foreach var2 in 1 2 3 4{
drop top_`var1'_`var2'
}
}

export excel "${final_list}/final/all_ranking.xlsx", replace firstrow(var)
drop _merge
save "${final_list}/final/all_ranking.dta", replace 

*Dropping firms before 2013 (act as an input for the python to create the model)
use "${features_final}/All_return_features_minus_q12.dta", clear
keep if StartYear>= 2013
save "${features_final}/All_return_features_after_2013.dta", replace
export delim "${features_final}/All_return_features_after_2013.csv", replace

/******* Recreating Table 2 *******/ 
import delim "H:\Ashwin\BogusFirmCatching_minus_glm\models\cv_predictions\20190227\point_in_time_revenue.csv", clear
rename (mean sum) (avg_revenue total_revenue)
save "H:\Ashwin\BogusFirmCatching_minus_glm\models\cv_predictions\20190227\point_in_time_revenue.dta", replace

import delim "H:\Ashwin\BogusFirmCatching_minus_glm\models\cv_predictions\20190227\point_in_time_performance.csv", clear
rename (mean sum) (avg_performance total_performance)
save "H:\Ashwin\BogusFirmCatching_minus_glm\models\cv_predictions\20190227\point_in_time_performance.dta", replace

merge 1:1 inspection_group t using "H:\Ashwin\BogusFirmCatching_minus_glm\models\cv_predictions\20190227\point_in_time_revenue.dta"
drop if inspection_group != "1-400"
replace t = t-8
gen bogus_identified = total_performance/size
drop size _merge avg_performance inspection_group
rename (t total_performance avg_revenue total_revenue bogus_identified) ///
		(T BogusFirmsCaught RevenueGainedPerInspection RevenueGainedTotal BogusCaughtInspection)
order BogusCaughtInspection, after(BogusFirmsCaught)
order RevenueGainedTotal, after(BogusCaughtInspection)
save "${final_list}/final/table_2.dta", replace



