




use "H:/Ashwin_old/output_data/All_return_features_minus_q12.dta", clear
drop bogus_cancellation bogus_any Bogus T312002 _merge_x PhysicalWard OtherLoan
rename (DealerTIN bogus_online _merge) (Mtin bogus_flag _merge_z)
save "H:/Ashwin_old/output_data/All_return_features_minus_q12_old.dta", replace


use "H:/Ashwin/dta/features/All_return_features.dta", replace
drop Ward BalanceBroughtForward 
rename (Ward_Number) Ward
gen salesnetwork_merge_1 = "both" if salesnetwork_merge == 3
replace salesnetwork_merge_1 = "left_only" if salesnetwork_merge == 1 
drop salesnetwork_merge
rename salesnetwork_merge_1 salesnetwork_merge

gen purchasenetwork_merge_1 = "both" if purchasenetwork_merge == 3
replace purchasenetwork_merge_1 = "left_only" if purchasenetwork_merge == 1 
drop purchasenetwork_merge
rename purchasenetwork_merge_1 purchasenetwork_merge

gen purchaseds_merge_1 = "both" if purchaseds_merge == 3
replace purchaseds_merge_1 = "left_only" if purchaseds_merge == 1 
drop purchaseds_merge
rename purchaseds_merge_1 purchaseds_merge
save "H:/Ashwin/dta/features/All_return_features_new.dta", replace

drop if TaxQuarter == 12 
save "H:/Ashwin/dta/features/All_return_features_minus_q12_new.dta", replace

** Seting up the new files to sync with the old files **
** retaining only taxquarters 21 and above **
** this data is to be run using the old trained model **
import delim "H:/Ashwin/dta/features/All_return_features_minus_q12.csv", clear varn(1) case(preserve)
drop if TaxQuarter <=20
drop Ward BalanceBroughtForward 
rename (Ward_Number) Ward
replace salesnetwork_merge = "both" if salesnetwork_merge == "matched (3)"
replace purchasenetwork_merge = "both" if purchasenetwork_merge == "matched (3)"

replace purchaseds_merge = "both" if purchaseds_merge == "matched (3)"
replace purchaseds_merge = "left_only" if purchaseds_merge == "master only (1)" 
replace salesds_merge = "both" if salesds_merge == "matched (3)"
replace salesds_merge = "left_only" if salesds_merge == "master only (1)"
replace profile_merge = "both" if profile_merge == "matched (3)"

gen transaction_merge_1 = 1 if transaction_merge == "0"
replace transaction_merge_1 = 3 if transaction_merge == "master only (1)"
drop transaction_merge
rename transaction_merge_1 transaction_merge
save "H:/Ashwin/dta/features/All_return_features_minus_q20.dta", replace
export delim "H:/Ashwin/dta/features/All_return_features_minus_q20.csv", replace

** Create sample data ** 
gen index = _n
drop if index > 50000
export delim "H:/Ashwin/dta/features/All_return_features_minus_q20_sample.csv", replace
save "H:/Ashwin/dta/features/All_return_features_minus_q20_sample.dta", replace


