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
** ashwin - run until line 220
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
//Code to make the files
//Need to run it only once

*--------------------------------------------------------
** Creating other profiles
*--------------------------------------------------------


use "${features_final}/FeatureDealerProfiles.dta", clear
destring Mtin, replace force
drop if Mtin==.
save "${features_final}/NumericFeatureDealerProfiles.dta", replace


use "${features_final}/SaleDiscrepancyAll.dta", clear
drop diff absdiff maxSalesTax OtherDeclarationCount MyDeclarationCount MatchDeclarationCount OtherDeclarationTax MyDeclarationTax MatchDeclarationTax
destring Mtin, replace force
drop if Mtin==.
drop Count
bys Mtin TaxQuarter: gen Count=_N
drop if Count>1
drop Count
save "${features_final}/NumericSaleDiscrepancyAll.dta", replace


use "${features_final}/PurchaseDiscrepancyAll.dta", clear
destring Mtin, replace force
drop OtherDeclarationCount MyDeclarationCount MatchDeclarationCount OtherDeclarationTax MyDeclarationTax MatchDeclarationTax diff absdiff maxPurchaseTax
drop if Mtin==.
bys Mtin TaxQuarter: gen Count=_N
drop if Count>1
drop Count
save "${features_final}/NumericPurchaseDiscrepancyAll.dta", replace

use "${features_final}/FeatureDownStreamnessPurchases.dta", clear
destring Mtin, replace 
save "${features_final}/NumericFeatureDownStreamnessPurchases.dta", replace

use "${features_final}/FeatureDownStreamnessSales.dta", clear
destring Mtin, replace 
save "${features_final}/NumericFeatureDownStreamnessSales.dta", replace

*&E:\data\PreliminaryAnalysis\BogusDealers\
* Creating the code book. 


import delimited "${features_path}/NetworkFeaturesPurchases9.csv", case(preserve) clear
keep __id TaxQuarter pagerank triangle_count in_degree out_degree
rename __id Mtin
rename pagerank Purchases_pagerank
rename triangle_count Purchases_triangle_count
rename in_degree Purchases_in_degree
rename out_degree Purchases_out_degree
replace TaxQuarter=9 if TaxQuarter==. // only outside state mtins have their taxquarter misng
destring Mtin, replace force
save "${features_path}/PurchaseNetworkQuarter.dta", replace

*skip taxquarter 12 since we don't proper values*
forvalues i=10/11{ //should have run it from 1 to 225 but there were errors which needed to be debugged in certain sheets.
*local myend=substr(r(range_`j'),4,1)
import delimited "${features_path}/NetworkFeaturesPurchases`i'.csv", case(preserve) clear
keep __id TaxQuarter pagerank triangle_count in_degree out_degree
rename __id Mtin
rename pagerank Purchases_pagerank
rename triangle_count Purchases_triangle_count
rename in_degree Purchases_in_degree
rename out_degree Purchases_out_degree
replace TaxQuarter=`i' if TaxQuarter==.
destring Mtin, replace force
append using "${features_path}/PurchaseNetworkQuarter.dta", force
save "${features_path}/PurchaseNetworkQuarter.dta", replace
clear
}

forvalues i=13/28{ //should have run it from 1 to 225 but there were errors which needed to be debugged in certain sheets.
*local myend=substr(r(range_`j'),4,1)
import delimited "${features_path}/NetworkFeaturesPurchases`i'.csv", case(preserve) clear
keep __id TaxQuarter pagerank triangle_count in_degree out_degree
rename __id Mtin
rename pagerank Purchases_pagerank
rename triangle_count Purchases_triangle_count
rename in_degree Purchases_in_degree
rename out_degree Purchases_out_degree
replace TaxQuarter=`i' if TaxQuarter==.
destring Mtin, replace force
append using "${features_path}/PurchaseNetworkQuarter.dta", force
save "${features_path}/PurchaseNetworkQuarter.dta", replace
clear
}

use "${features_path}/PurchaseNetworkQuarter.dta", clear
*destring Mtin, replace force
drop if Mtin==.
bys Mtin TaxQuarter: gen Count=_N
drop if Count>1
drop Count
save "${features_path}/PurchaseNetworkQuarter.dta", replace

import delimited "${features_path}/NetworkFeaturesSales9.csv", case(preserve) clear
keep __id TaxQuarter pagerank triangle_count in_degree out_degree
rename __id Mtin
rename pagerank Sales_pagerank
rename triangle_count Sales_triangle_count
rename in_degree Sales_in_degree
rename out_degree Sales_out_degree
replace TaxQuarter=9 if TaxQuarter==.
destring Mtin, replace force
save "${features_path}/SalesNetworkQuarter.dta", replace

*TaxQuarter 12 doesn't exist

forvalues i=10/11{ //should have run it from 1 to 225 but there were errors which needed to be debugged in certain sheets.
*local myend=substr(r(range_`j'),4,1)
import delimited "${features_path}/NetworkFeaturesSales`i'.csv", case(preserve) clear
keep __id TaxQuarter pagerank triangle_count in_degree out_degree
rename __id Mtin
rename pagerank Sales_pagerank
rename triangle_count Sales_triangle_count
rename in_degree Sales_in_degree
rename out_degree Sales_out_degree
replace TaxQuarter=`i' if TaxQuarter==.
destring Mtin, replace force
append using "${features_path}/SalesNetworkQuarter.dta", force
save "${features_path}/SalesNetworkQuarter.dta", replace
clear
}

forvalues i=13/28{ //should have run it from 1 to 225 but there were errors which needed to be debugged in certain sheets.
*local myend=substr(r(range_`j'),4,1)
import delimited "${features_path}/NetworkFeaturesSales`i'.csv", case(preserve) clear
keep __id TaxQuarter pagerank triangle_count in_degree out_degree
rename __id Mtin
rename pagerank Sales_pagerank
rename triangle_count Sales_triangle_count
rename in_degree Sales_in_degree
rename out_degree Sales_out_degree
replace TaxQuarter=`i' if TaxQuarter==.
destring Mtin, replace force
append using "${features_path}/SalesNetworkQuarter.dta", force
save "${features_path}/SalesNetworkQuarter.dta", replace
clear
}

use "${features_path}/SalesNetworkQuarter.dta", clear
drop if Mtin==.
bys Mtin TaxQuarter: gen Count=_N
drop if Count>1
drop Count
save "${features_path}/SalesNetworkQuarter.dta", replace


use "${features_final}/FeatureReturns.dta", clear
//gen RefundClaimedBoolean=RefundClaimed>0

destring Mtin, replace 
destring TaxQuarter, replace

merge m:1 Mtin using "${features_final}/NumericFeatureDealerProfiles.dta", keep(master match) generate(profile_merge)

keep if TaxQuarter>8

merge m:1 Mtin TaxQuarter using "${features_final}/NumericSaleDiscrepancyAll.dta", keep(master match) generate(salesmatch_merge)

merge m:1 Mtin TaxQuarter using "${features_final}/NumericPurchaseDiscrepancyAll.dta", keep(master match) generate(purchasematch_merge)

merge m:1 Mtin TaxQuarter using "${features_path}/SalesNetworkQuarter.dta", keep(master match) generate(salesnetwork_merge)

merge m:1 Mtin TaxQuarter using "${features_path}/PurchaseNetworkQuarter.dta", keep(master match) generate(purchasenetwork_merge)

merge m:1 Mtin TaxQuarter using "${features_final}/NumericFeatureDownStreamnessSales.dta", keep(master match) generate(salesds_merge)

merge m:1 Mtin TaxQuarter using "${features_final}/NumericFeatureDownStreamnessPurchases.dta", keep(master match) generate(purchaseds_merge)


replace GrossTurnover=GrossTurnover/10000000
replace MoneyDeposited=MoneyDeposited/10000000
replace TaxCreditBeforeAdjustment=TaxCreditBeforeAdjustment/10000000
replace OutputTaxBeforeAdjustment=OutputTaxBeforeAdjustment/10000000

replace TaxCreditBeforeAdjustment=TaxCreditBeforeAdjustment*4
replace OutputTaxBeforeAdjustment=OutputTaxBeforeAdjustment*4

** ashwin: need to understand the input file ***
//Creating size of the problem for online bogus data, model 5 and model 7
// Model 5: All features, except the dealer profile related features
// Model 7: All features, including the dealer profile features
{
merge 1:1 TaxQuarter Mtin using "E:\Ofir\BogusFirmCatching\PredictionsBogusOnline.dta", keepusing(BogusOnlineModel* OnlineRankModel* OnlineQuarterlyRankModel*) generate(merge_validation)


label define quarter 1 "Q1, 2010-11" 2 "Q2, 2010-11" 3 "Q3, 2010-11" 4 "Q4, 2010-11" 5 "Q1, 2011-12" 6 "Q2, 2011-12" 7 "Q3, 2011-12" 8 "Q4, 2011-12" 9 "Q1, 2012-13" 10 "Q2, 2012-13" 11 "Q3, 2012-13" 12 "Q4, 2012-13" 13 "Q1, 2013-14" 14 "Q2, 2013-14" 15 "Q3, 2013-14" 16 "Q4, 2013-14" 17 "Q1, 2014-15" 18 "Q2, 2014-15" 19 "Q3, 2014-15" 20 "Q4, 2014-15"
label values TaxQuarter quarter
label define prediction 1 "1-400" 2 "401-800" 3 "801-1200" 4 "1201-1600" 5 "1601-2400" 6 "Rest"


gen dummy=1
gen prediction=0
replace prediction=1 if OnlineQuarterlyRankModel7<=50
replace prediction=2 if OnlineQuarterlyRankModel7<=100&OnlineQuarterlyRankModel7>50
replace prediction=3 if OnlineQuarterlyRankModel7<=150&OnlineQuarterlyRankModel7>100
replace prediction=4 if OnlineQuarterlyRankModel7<=200&OnlineQuarterlyRankModel7>150
replace prediction=5 if OnlineQuarterlyRankModel7<=300&OnlineQuarterlyRankModel7>200

replace prediction=. if OnlineQuarterlyRankModel7==.
replace prediction=6 if prediction==0



label values prediction prediction
*xlabel(, valuelabel)

#delimit ;
preserve;
collapse (mean) UnTaxProp (sum) TaxCreditBeforeAdjustment OutputTaxBeforeAdjustment, by(TaxQuarter prediction);
twoway (connected TaxCreditBeforeAdjustment TaxQuarter)(connected OutputTaxBeforeAdjustment TaxQuarter) 
	   if prediction>0&prediction<6, ylabel(#5) ytitle("Rupees (in crores)") by(, note("Graphs by prediction rankings. Amount in crores. From Q1,2012-13 to Q4, 2014-15")) 
	   legend(order(1 "Tax Credit" 2 "Output Tax") region(lcolor(none))) 
	   by(, title("Bogus firms, online data, all features"))
	   by(, graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))) 
	   by(prediction);
restore;
graph save Graph "E:\data\PreliminaryAnalysis\BogusDealers\TaxCredits_predictions_BogusOnlineModel7.gph"
graph export "E:\data\PreliminaryAnalysis\BogusDealers\TaxCredits_predictions_BogusOnlineModel7.pdf", as(pdf) replace



#delimit ;
graph bar (mean) bogus_online (mean) bogus_cancellation (mean) bogus_any (mean) CancelledDummy 
          if prediction>0&TaxQuarter<17, 
		  over(prediction) graphregion(color(white)) 
		  legend(order(1 "From bogus data" 2 "From cancellation records" 3 "Combined set" 4 "Entire cancellation data" ))
		  title("Definite success rate") blabel(bar)
		  bar(1, fintensity(inten50))
		  bar(2, fintensity(inten10))
		  note("Based on simulation data, if we inspect companies the proportion that is definitely bogus. Lower bound, others could be bogus as well");


merge m:1 Mtin using "E:\data\PreliminaryAnalysis\Cancellation\CancellationData_UniqueMtin.dta", generate(_merge_cancellation)
gen CancelledDummy=0
replace CancelledDummy=1 if _merge_cancellation==3
		  

//The fact that we are not using tax quarter 12's data is taken care of by the if
// condtion that prediction was has to be greater than 0		  
#delimit ;
graph bar (mean) bogus_online (mean) CancelledDummy 
          if prediction>0&TaxQuarter<17, 
		  over(prediction) graphregion(color(white)) 
		  legend(order(1 "From bogus data" 2 "Entire cancellation data" ))
		  title("Definite success rate") blabel(bar)
		  bar(1, fintensity(inten50))
		  bar(2, fintensity(inten10))
		  note("Based on simulation data""If we inspect companies the proportion that is definitely bogus or gets cancelled" "Cancellation can be for any reason");


		  
		  
		  
graph bar (sum) bogus_online (sum) bogus_cancellation (sum) bogus_any (sum) dummy if prediction>0&TaxQuarter<17, over(prediction)



drop prediction

gen prediction=0
replace prediction=1 if OnlineQuarterlyRankModel5<=50
replace prediction=2 if OnlineQuarterlyRankModel5<=100&OnlineQuarterlyRankModel5>50
replace prediction=3 if OnlineQuarterlyRankModel5<=150&OnlineQuarterlyRankModel5>100
replace prediction=4 if OnlineQuarterlyRankModel5<=200&OnlineQuarterlyRankModel5>150
replace prediction=5 if OnlineQuarterlyRankModel5<=300&OnlineQuarterlyRankModel5>200


*gen prediction2=0
*replace prediction2=1 if prediction==0
label values prediction prediction


#delimit ;
preserve;
collapse (mean) UnTaxProp (sum) TaxCreditBeforeAdjustment OutputTaxBeforeAdjustment, by(TaxQuarter prediction);
twoway (connected TaxCreditBeforeAdjustment TaxQuarter)(connected OutputTaxBeforeAdjustment TaxQuarter) 
	   if prediction>0&prediction<6, ylabel(#5) ytitle("Rupees (in crores)") by(, note("Graphs by prediction rankings. Amount in crores. From Q1,2012-13 to Q4, 2014-15")) 
	   legend(order(1 "Tax Credit" 2 "Output Tax") region(lcolor(none))) 
	   by(, title("Bogus firms, online data, no dealer features"))
	   by(, graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))) 
	   by(prediction);
restore;
graph save Graph "E:\data\PreliminaryAnalysis\BogusDealers\TaxCredits_predictions_BogusOnlineModel5.gph"
graph export "E:\data\PreliminaryAnalysis\BogusDealers\TaxCredits_predictions_BogusOnlineModel5.pdf", as(pdf) replace



//Doing expected probability (controlling for size) calculations
keep if merge_validation==3

gen ExpectedProbability=BogusOnlineModel7*TaxCreditBeforeAdjustment
gsort TaxQuarter -ExpectedProbability
by TaxQuarter: gen QuarterlyExpectedRankModel7=_n

gen prediction=0
replace prediction=1 if QuarterlyExpectedRankModel7<=50
replace prediction=2 if QuarterlyExpectedRankModel7<=100&QuarterlyExpectedRankModel7>50
replace prediction=3 if QuarterlyExpectedRankModel7<=150&QuarterlyExpectedRankModel7>100
replace prediction=4 if QuarterlyExpectedRankModel7<=200&QuarterlyExpectedRankModel7>150
replace prediction=5 if QuarterlyExpectedRankModel7<=300&QuarterlyExpectedRankModel7>200


label values prediction prediction

#delimit ;
preserve;
collapse (mean) UnTaxProp (sum) TaxCreditBeforeAdjustment OutputTaxBeforeAdjustment, by(TaxQuarter prediction);
twoway (connected TaxCreditBeforeAdjustment TaxQuarter)(connected OutputTaxBeforeAdjustment TaxQuarter) 
	   if prediction>0&prediction<6, ylabel(#5) ytitle("Rupees (in crores)") by(, note("Ranking=prediction probability*TaxCredit. Amount in crores. From Q1,2012-13 to Q4, 2014-15")) 
	   legend(order(1 "Tax Credit" 2 "Output Tax") region(lcolor(none))) 
	   by(, title("Bogus firms, online data, all features"))
	   by(, graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))) 
	   by(prediction);
restore;
graph save Graph "E:\data\PreliminaryAnalysis\BogusDealers\TaxCredits_predictions_BogusOnlineModel7_ExpectedRanking.gph"
graph export "E:\data\PreliminaryAnalysis\BogusDealers\TaxCredits_predictions_BogusOnlineModel7_ExpectedRanking.pdf", as(pdf) replace


}




//Creating size of the problem for cancellation bogus data, model 7
// Model 5: All features, except the dealer profile related features
// Model 7: All features, including the dealer profile features
{
merge 1:1 TaxQuarter Mtin using "E:\Ofir\BogusFirmCatching\PredictionsBogusCancellation.dta", keepusing(BogusCancellationModel* CancellationRankModel* CancellationQuarterlyRankModel*) generate(merge_validation)


//label define quarter 1 "Q1, 2010-11" 2 "Q2, 2010-11" 3 "Q3, 2010-11" 4 "Q4, 2010-11" 5 "Q1, 2011-12" 6 "Q2, 2011-12" 7 "Q3, 2011-12" 8 "Q4, 2011-12" 9 "Q1, 2012-13" 10 "Q2, 2012-13" 11 "Q3, 2012-13" 12 "Q4, 2012-13" 13 "Q1, 2013-14" 14 "Q2, 2013-14" 15 "Q3, 2013-14" 16 "Q4, 2013-14" 17 "Q1, 2014-15" 18 "Q2, 2014-15" 19 "Q3, 2014-15" 20 "Q4, 2014-15"
label values TaxQuarter quarter
label define prediction 1 "1-400" 2 "401-800" 3 "801-1200" 4 "1201-1600" 5 "1601-2500"


gen prediction=0
replace prediction=1 if CancellationQuarterlyRankModel7<=50
replace prediction=2 if CancellationQuarterlyRankModel7<=100&CancellationQuarterlyRankModel7>50
replace prediction=3 if CancellationQuarterlyRankModel7<=150&CancellationQuarterlyRankModel7>100
replace prediction=4 if CancellationQuarterlyRankModel7<=200&CancellationQuarterlyRankModel7>150
replace prediction=5 if CancellationQuarterlyRankModel7<=300&CancellationQuarterlyRankModel7>200

label values prediction prediction

*xlabel(, valuelabel)

#delimit ;
preserve;
collapse (mean) UnTaxProp (sum) TaxCreditBeforeAdjustment OutputTaxBeforeAdjustment, by(TaxQuarter prediction);
twoway (connected TaxCreditBeforeAdjustment TaxQuarter)(connected OutputTaxBeforeAdjustment TaxQuarter) 
	   if prediction>0&prediction<6, ylabel(#3) ytitle("Rupees (in crores)") by(, note("Graphs by prediction rankings. Amount in crores. From Q1,2012-13 to Q4, 2014-15")) 
	   legend(order(1 "Tax Credit" 2 "Output Tax") region(lcolor(none))) 
	   by(, title("Bogus firms, cancellation data, all features"))
	   by(, graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))) 
	   by(prediction);
restore;
graph save Graph "E:\data\PreliminaryAnalysis\BogusDealers\TaxCredits_predictions_BogusCancellationModel7.gph"
graph export "E:\data\PreliminaryAnalysis\BogusDealers\TaxCredits_predictions_BogusCancellationModel7.pdf", as(pdf) replace
}





//Now merging the weighted models
//Weights: Turnover
//Weights: Output Tax
//Weights: Tax Credit
{

merge 1:1 TaxQuarter Mtin using "E:\Ofir\BogusFirmCatching\PredictionsBogusDifferentModels.dta", keepusing(RFModel* RankModel* QuarterlyRankModel*) generate(merge_validation)


label values TaxQuarter quarter
label define prediction 1 "1-400" 2 "401-800" 3 "801-1200" 4 "1201-1600" 5 "1601-2500"


gen prediction=0
replace prediction=1 if QuarterlyRankModelTurnover<=50
replace prediction=2 if QuarterlyRankModelTurnover<=100&QuarterlyRankModelTurnover>50
replace prediction=3 if QuarterlyRankModelTurnover<=150&QuarterlyRankModelTurnover>100
replace prediction=4 if QuarterlyRankModelTurnover<=200&QuarterlyRankModelTurnover>150
replace prediction=5 if QuarterlyRankModelTurnover<=300&QuarterlyRankModelTurnover>200

label values prediction prediction

*xlabel(, valuelabel)

#delimit ;
preserve;
collapse (mean) UnTaxProp (sum) TaxCreditBeforeAdjustment OutputTaxBeforeAdjustment, by(TaxQuarter prediction);
twoway (connected TaxCreditBeforeAdjustment TaxQuarter)(connected OutputTaxBeforeAdjustment TaxQuarter) 
	   if prediction>0&prediction<6, ylabel(#5) ytitle("Rupees (in crores)") by(, note("Graphs by prediction rankings. Amount in crores. From Q1,2012-13 to Q4, 2014-15")) 
	   legend(order(1 "Tax Credit" 2 "Output Tax") region(lcolor(none))) 
	   by(, title("Bogus firms, online data, all features (weighted by turnover)"))
	   by(, graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))) 
	   by(prediction);
restore;
graph save Graph "E:\data\PreliminaryAnalysis\BogusDealers\TaxCredits_predictions_BogusOnlineTurnoverModel.gph"
graph export "E:\data\PreliminaryAnalysis\BogusDealers\TaxCredits_predictions_BogusOnlineTurnoverModel.pdf", as(pdf) replace


drop prediction

gen prediction=0
replace prediction=1 if QuarterlyRankModelOutputTax<=50
replace prediction=2 if QuarterlyRankModelOutputTax<=100&QuarterlyRankModelOutputTax>50
replace prediction=3 if QuarterlyRankModelOutputTax<=150&QuarterlyRankModelOutputTax>100
replace prediction=4 if QuarterlyRankModelOutputTax<=200&QuarterlyRankModelOutputTax>150
replace prediction=5 if QuarterlyRankModelOutputTax<=300&QuarterlyRankModelOutputTax>200

label values prediction prediction

*xlabel(, valuelabel)

#delimit ;
preserve;
collapse (mean) UnTaxProp (sum) TaxCreditBeforeAdjustment OutputTaxBeforeAdjustment, by(TaxQuarter prediction);
twoway (connected TaxCreditBeforeAdjustment TaxQuarter)(connected OutputTaxBeforeAdjustment TaxQuarter) 
	   if prediction>0&prediction<6, ylabel(#5) ytitle("Rupees (in crores)") by(, note("Graphs by prediction rankings. Amount in crores. From Q1,2012-13 to Q4, 2014-15")) 
	   legend(order(1 "Tax Credit" 2 "Output Tax") region(lcolor(none))) 
	   by(, title("Bogus firms, online data, all features (weighted by output tax)"))
	   by(, graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))) 
	   by(prediction);
restore;
graph save Graph "E:\data\PreliminaryAnalysis\BogusDealers\TaxCredits_predictions_BogusOnlineOutputTaxModel.gph"
graph export "E:\data\PreliminaryAnalysis\BogusDealers\TaxCredits_predictions_BogusOnlineOutputTaxModel.pdf", as(pdf) replace

drop prediction

gen prediction=0
replace prediction=1 if QuarterlyRankModelTaxCredit<=50
replace prediction=2 if QuarterlyRankModelTaxCredit<=100&QuarterlyRankModelTaxCredit>50
replace prediction=3 if QuarterlyRankModelTaxCredit<=150&QuarterlyRankModelTaxCredit>100
replace prediction=4 if QuarterlyRankModelTaxCredit<=200&QuarterlyRankModelTaxCredit>150
replace prediction=5 if QuarterlyRankModelTaxCredit<=300&QuarterlyRankModelTaxCredit>200

label values prediction prediction


#delimit ;
preserve;
collapse (mean) UnTaxProp (sum) TaxCreditBeforeAdjustment OutputTaxBeforeAdjustment, by(TaxQuarter prediction);
twoway (connected TaxCreditBeforeAdjustment TaxQuarter)(connected OutputTaxBeforeAdjustment TaxQuarter) 
	   if prediction>0&prediction<6, ylabel(#5) ytitle("Rupees (in crores)") by(, note("Graphs by prediction rankings. Amount in crores. From Q1,2012-13 to Q4, 2014-15")) 
	   legend(order(1 "Tax Credit" 2 "Output Tax") region(lcolor(none))) 
	   by(, title("Bogus firms, online data, all features (weighted by tax credit)"))
	   by(, graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))) 
	   by(prediction);
restore;
graph save Graph "E:\data\PreliminaryAnalysis\BogusDealers\TaxCredits_predictions_BogusOnlineTaxCreditModel.gph"
graph export "E:\data\PreliminaryAnalysis\BogusDealers\TaxCredits_predictions_BogusOnlineTaxCreditModel.pdf", as(pdf) replace
}




//Bogus Online data minus y5
{
merge 1:1 TaxQuarter Mtin using "E:\Ofir\BogusFirmCatching\PredictionsBogusOnline_MinusY5.dta", keepusing(BogusOnlineModel* OnlineRankModel* OnlineQuarterlyRankModel*) generate(merge_validation)


label define quarter 1 "Q1, 2010-11" 2 "Q2, 2010-11" 3 "Q3, 2010-11" 4 "Q4, 2010-11" 5 "Q1, 2011-12" 6 "Q2, 2011-12" 7 "Q3, 2011-12" 8 "Q4, 2011-12" 9 "Q1, 2012-13" 10 "Q2, 2012-13" 11 "Q3, 2012-13" 12 "Q4, 2012-13" 13 "Q1, 2013-14" 14 "Q2, 2013-14" 15 "Q3, 2013-14" 16 "Q4, 2013-14" 17 "Q1, 2014-15" 18 "Q2, 2014-15" 19 "Q3, 2014-15" 20 "Q4, 2014-15"
label values TaxQuarter quarter
label define prediction 1 "1-400" 2 "401-800" 3 "801-1200" 4 "1201-1600" 5 "1601-2500"


gen prediction=0
replace prediction=1 if OnlineQuarterlyRankModel7<=50
replace prediction=2 if OnlineQuarterlyRankModel7<=100&OnlineQuarterlyRankModel7>50
replace prediction=3 if OnlineQuarterlyRankModel7<=150&OnlineQuarterlyRankModel7>100
replace prediction=4 if OnlineQuarterlyRankModel7<=200&OnlineQuarterlyRankModel7>150
replace prediction=5 if OnlineQuarterlyRankModel7<=300&OnlineQuarterlyRankModel7>200

label values prediction prediction

*xlabel(, valuelabel)

#delimit ;
preserve;
collapse (mean) UnTaxProp (sum) TaxCreditBeforeAdjustment OutputTaxBeforeAdjustment, by(TaxQuarter prediction);
twoway (connected TaxCreditBeforeAdjustment TaxQuarter)(connected OutputTaxBeforeAdjustment TaxQuarter) 
	   if prediction>0&prediction<6, ylabel(#4) ytitle("Rupees (in crores)") by(, note("Graphs by prediction rankings. Amount in crores. From Q1,2012-13 to Q4, 2014-15. Not trained on last year")) 
	   legend(order(1 "Tax Credit" 2 "Output Tax") region(lcolor(none))) 
	   by(, title("Bogus firms, online data, all features"))
	   by(, graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))) 
	   by(prediction);
restore;
graph save Graph "E:\data\PreliminaryAnalysis\BogusDealers\TaxCredits_predictions_BogusOnlineModel7_MinusY5.gph"
graph export "E:\data\PreliminaryAnalysis\BogusDealers\TaxCredits_predictions_BogusOnlineModel7_MinusY5.pdf", as(pdf) replace
}



#delimit ;
preserve;
collapse (mean) UnTaxProp (sum) TaxCreditBeforeAdjustment OutputTaxBeforeAdjustment, by(TaxQuarter prediction);
twoway (connected UnTaxProp TaxQuarter) 
	   if prediction>0&prediction<6, ylabel(#5) ytitle("Rupees (in crores)") by(, note("Graphs by prediction rankings. Amount in crores. From Q1,2012-13 to Q4, 2014-15")) 
	   legend(order(1 "Proportion sales to unregistered firms") region(lcolor(none))) 
	   by(, title("Bogus firms, online data, all features"))
	   by(, graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))) 
	   by(prediction);
restore;

#delimit ;
preserve;
collapse (mean) UnTaxProp (sum) TaxCreditBeforeAdjustment OutputTaxBeforeAdjustment, by(TaxQuarter prediction2);
twoway (connected UnTaxProp TaxQuarter), 
	    ytitle("Rupees (in crores)") by(, note("Graphs by prediction rankings. Amount in crores. From Q1,2012-13 to Q4, 2014-15")) 
	   legend(order(1 "Proportion sales to unregistered firms") region(lcolor(none))) 
	   by(, title("Bogus firms, online data, all features"))
	   by(, graphregion(fcolor(white) lcolor(white) ifcolor(white) ilcolor(white))) 
	   by(prediction2);
restore;


#delimit ;
preserve;
collapse (mean) UnTaxProp (sum) TaxCreditBeforeAdjustment OutputTaxBeforeAdjustment, by(TaxQuarter prediction);
twoway (connected TaxCreditBeforeAdjustment TaxQuarter if prediction==1) 
	(connected OutputTaxBeforeAdjustment TaxQuarter if prediction==1)
	(connected TaxCreditBeforeAdjustment TaxQuarter if prediction==2, lpattern(dash)) 
	(connected OutputTaxBeforeAdjustment TaxQuarter if prediction==2, lpattern(dash))
	(connected TaxCreditBeforeAdjustment TaxQuarter if prediction==3, lpattern(dot)) 
	(connected OutputTaxBeforeAdjustment TaxQuarter if prediction==3, lpattern(dot))
	(connected TaxCreditBeforeAdjustment TaxQuarter if prediction==4, lpattern(dash_dot)) 
	(connected OutputTaxBeforeAdjustment TaxQuarter if prediction==4, lpattern(dash_dot))
	(connected TaxCreditBeforeAdjustment TaxQuarter if prediction==5, lpattern(dash_3dot)) 
	(connected OutputTaxBeforeAdjustment TaxQuarter if prediction==5, lpattern(dash_3dot)),
	ytitle("Input credit and Output Tax") graphregion(color(white)) title("Bogus firms") note("Amounts in crores") 
	legend(order(1 "Tax Credit (1-400)" 2 "Output Tax (1-400)" 3 "Tax Credit (401-800)" 4 "Output Tax (401-800)" 5 
	"Tax Credit (801-1200)" 6 "Output Tax (801-1200)" 7 "Tax Credit (1201-1600)" 8 "Output Tax (1201-1600)" 9 "Tax Credit (1601-2500)" 10 "Output Tax (1601-2500)" ));
restore;

#delimit ;
preserve;
collapse (mean) UnTaxProp (sum) TaxCreditBeforeAdjustment OutputTaxBeforeAdjustment, by(TaxQuarter prediction);
twoway (connected UnTaxProp TaxQuarter if prediction==1) 
	(connected UnTaxProp TaxQuarter if prediction==2, lpattern(dash))
	(connected UnTaxProp TaxQuarter if prediction==3, lpattern(dot)) 
	(connected UnTaxProp TaxQuarter if prediction==4, lpattern(dash_dot))
	(connected UnTaxProp TaxQuarter if prediction==5, lpattern(dash_3dot)) 
	graphregion(color(white)) title("Bogus firms, Proportion sales to unregistered firms")  
	legend(order(1 "Prediction Rank 1-400" 2 "Prediction Rank 401-800" 3 
	"Prediction Rank 801-1200" 4 "Prediction Rank 1201-1600" 5 "Prediction Rank 1601-2500"));
restore;





merge 1:1 TaxQuarter Mtin using "E:\Ofir\BogusFirmCatching\PredictionsBogusCancellation.dta", keepusing(BogusCancellationModel* CancellationRankModel* CancellationQuarterlyRankModel*) generate(merge_validation)

gen prediction=0
replace prediction=1 if CancellationQuarterlyRankModel7<=50
replace prediction=2 if CancellationQuarterlyRankModel7<=100&CancellationQuarterlyRankModel7>50
replace prediction=3 if CancellationQuarterlyRankModel7<=150&CancellationQuarterlyRankModel7>100
replace prediction=4 if CancellationQuarterlyRankModel7<=200&CancellationQuarterlyRankModel7>150
replace prediction=5 if CancellationQuarterlyRankModel7<=300&CancellationQuarterlyRankModel7>200

drop prediction

gen prediction=0
replace prediction=1 if CancellationQuarterlyRankModel5<=50
replace prediction=2 if CancellationQuarterlyRankModel5<=100&CancellationQuarterlyRankModel5>50
replace prediction=3 if CancellationQuarterlyRankModel5<=150&CancellationQuarterlyRankModel5>100
replace prediction=4 if CancellationQuarterlyRankModel5<=200&CancellationQuarterlyRankModel5>150
replace prediction=5 if CancellationQuarterlyRankModel5<=300&CancellationQuarterlyRankModel5>200



#delimit ;
preserve;
collapse (mean) UnTaxProp (sum) TaxCreditBeforeAdjustment OutputTaxBeforeAdjustment, by(TaxQuarter prediction);
twoway (connected TaxCreditBeforeAdjustment TaxQuarter if prediction==1) 
	(connected OutputTaxBeforeAdjustment TaxQuarter if prediction==1)
	(connected TaxCreditBeforeAdjustment TaxQuarter if prediction==2, lpattern(dash)) 
	(connected OutputTaxBeforeAdjustment TaxQuarter if prediction==2, lpattern(dash))
	(connected TaxCreditBeforeAdjustment TaxQuarter if prediction==3, lpattern(dot)) 
	(connected OutputTaxBeforeAdjustment TaxQuarter if prediction==3, lpattern(dot))
	(connected TaxCreditBeforeAdjustment TaxQuarter if prediction==4, lpattern(dash_dot)) 
	(connected OutputTaxBeforeAdjustment TaxQuarter if prediction==4, lpattern(dash_dot))
	(connected TaxCreditBeforeAdjustment TaxQuarter if prediction==5, lpattern(dash_3dot)) 
	(connected OutputTaxBeforeAdjustment TaxQuarter if prediction==5, lpattern(dash_3dot)),
	ytitle("Input credit and Output Tax") graphregion(color(white)) title("Bogus firms") note("Amounts in crores") 
	legend(order(1 "Tax Credit (1-400)" 2 "Output Tax (1-400)" 3 "Tax Credit (401-800)" 4 "Output Tax (401-800)" 5 
	"Tax Credit (801-1200)" 6 "Output Tax (801-1200)" 7 "Tax Credit (1201-1600)" 8 "Output Tax (1201-1600)" 9 "Tax Credit (1601-2500)" 10 "Output Tax (1601-2500)" ));
restore;






#delimit ;
preserve;
collapse (mean) UnTaxProp (sum) TaxCreditBeforeAdjustment OutputTaxBeforeAdjustment, by(TaxQuarter bogus_online);
twoway (connected TaxCreditBeforeAdjustment TaxQuarter, lpattern(dash)) 
	(connected OutputTaxBeforeAdjustment TaxQuarter, lpattern(dash_dot)) 
	(connected UnTaxProp TaxQuarter, lpattern(dash_3dot) yaxis(2)) 
	if bogus_online==1, ytitle("Input credit and Output Tax") graphregion(color(white)) title("Bogus firms (from online data)") note("Amounts in crores") 
	legend(order(1 "Tax Credit" 2 "Output Tax" 3 "Proportion sales made to unregistered firms"));
restore;

#delimit ;
preserve;
collapse (mean) UnTaxProp (sum) TaxCreditBeforeAdjustment OutputTaxBeforeAdjustment MoneyDeposited, by(TaxQuarter bogus_online);
twoway (connected TaxCreditBeforeAdjustment TaxQuarter, lpattern(dash)) 
	(connected OutputTaxBeforeAdjustment TaxQuarter, lpattern(dash_dot)) 
	(connected UnTaxProp TaxQuarter, lpattern(dash_3dot) yaxis(2)) 
	if bogus_online==0, ytitle("Input Credit and Output Tax") graphregion(color(white)) title("Non Bogus firms)") note("Amounts in crores") 
	legend(order(1 "Tax Credit" 2 "Output Tax" 3 "Proportion sales to unregistered firms"));
restore;

#delimit ;
preserve;
collapse (mean) UnTaxProp (sum) TaxCreditBeforeAdjustment OutputTaxBeforeAdjustment, by(TaxQuarter bogus_cancellation);
twoway (connected TaxCreditBeforeAdjustment TaxQuarter, lpattern(dash)) 
	(connected OutputTaxBeforeAdjustment TaxQuarter, lpattern(dash_dot)) 
	if bogus_cancellation==1, ytitle("Input credit and Output Tax") graphregion(color(white)) title("Bogus firms (from cancellation data)") note("Amounts in crores") 
	legend(order(1 "Tax Credit" 2 "Output Tax" ));
restore;





#delimit ;
preserve;
collapse (mean) UnTaxProp (sum) TaxCreditBeforeAdjustment OutputTaxBeforeAdjustment, by(TaxQuarter bogus_online);
twoway (connected TaxCreditBeforeAdjustment TaxQuarter, lpattern(dash)) 
	(connected OutputTaxBeforeAdjustment TaxQuarter, lpattern(dash_dot)) 
	(connected UnTaxProp TaxQuarter, lpattern(dash_3dot) yaxis(2)) 
	if bogus_online==1, ytitle("Input credit and Output Tax") graphregion(color(white)) title("Bogus firms") note("Amounts in crores") 
	legend(order(1 "Tax Credit" 2 "Output Tax" 3 "Proportion sales made to unregistered firms"));
restore;



preserve
collapse (mean) UnTaxProp (sum) TaxCreditBeforeAdjustment OutputTaxBeforeAdjustment, by(TaxQuarter bogus_cancellation)
twoway (connected TaxCreditBeforeAdjustment TaxQuarter, lpattern(dash)) (connected OutputTaxBeforeAdjustment TaxQuarter, lpattern(dash_dot)) (connected UnTaxProp TaxQuarter, lpattern(dash_3dot) yaxis(2)) if bogus_cancellation==1
restore

//Plotting VARIMPs
{


use "FeatureReturns.dta", clear
gen RefundClaimedBoolean=RefundClaimed>0

destring Mtin, replace 
destring TaxQuarter, replace

merge m:1 Mtin using "NumericFeatureDealerProfiles.dta", keep(master match) generate(profile_merge)

keep if TaxQuarter>8

merge m:1 Mtin TaxQuarter using "NumericSaleDiscrepancyAll.dta", keep(master match) generate(salesmatch_merge)

merge m:1 Mtin TaxQuarter using "NumericPurchaseDiscrepancyAll.dta", keep(master match) generate(purchasematch_merge)

merge m:1 Mtin TaxQuarter using "SalesNetworkQuarter.dta", keep(master match) generate(salesnetwork_merge)

merge m:1 Mtin TaxQuarter using "PurchaseNetworkQuarter.dta", keep(master match) generate(purchasenetwork_merge)

merge m:1 Mtin TaxQuarter using "NumericFeatureDownStreamnessSales.dta", keep(master match) generate(salesds_merge)

merge m:1 Mtin TaxQuarter using "NumericFeatureDownStreamnessPurchases.dta", keep(master match) generate(purchaseds_merge)


replace TurnoverGross=TurnoverGross/10000000
replace MoneyDeposited=MoneyDeposited/10000000
replace TaxCreditBeforeAdjustment=TaxCreditBeforeAdjustment/10000000
replace OutputTaxBeforeAdjustment=OutputTaxBeforeAdjustment/10000000


/*
gen sc_disc=((SaleMyCountDiscrepancy>0)+(SaleMyCountDiscrepancy>.05)+(SaleMyCountDiscrepancy>.33)+(SaleMyCountDiscrepancy>.66)+(SaleMyCountDiscrepancy==1))
gen mpp_disc=((MaxPurchaseProp>0.1)+(MaxPurchaseProp>.393)+(MaxPurchaseProp>.594)+(MaxPurchaseProp>.926))
replace pr_disc=((Purchases_pagerank>.16)+(Purchases_pagerank>.319089)+(Purchases_pagerank>.785434)+(Purchases_pagerank>1.43544)+(Purchases_pagerank>4.86127))
replace pr_disc=. if Purchases_pagerank==.
tab pr_disc bogus_online, row
gen pdp_disc=((PurchaseDSUnTaxProp>.0014)+(PurchaseDSUnTaxProp>.0339)+(PurchaseDSUnTaxProp>0.1449898)+(PurchaseDSUnTaxProp>0.34))
*/

drop if TaxQuarter==12
drop if TaxQuarter>16

label define decile 1 "1st decile" 2 "2nd decile" 3 "3rd decile" 4 "4th decile" 5 "5th decile" 6 "6th decile" 7 "7th decile" 8 "8th decile" 9 "9th decile" 10 "10th decile"


xtile decile_SaleMyCountDiscrepancy=SaleMyCountDiscrepancy, nq(10)	
label values decile_SaleMyCountDiscrepancy decile

xtile decile_PurchaseDSUnTaxProp=PurchaseDSUnTaxProp, nq(10)
label values decile_PurchaseDSUnTaxProp decile


#delimit ;
graph bar (mean) bogus_online, over(decile_PurchaseDSUnTaxProp) graphregion(color(white))
               title("Percentage sales made to unregistered firms, by DS Purchase firms") ytitle("Probability of being bogus") 
			   bar(1, fcolor(navy) fintensity(inten50))
               note ("Firms grouped in deciles(10%) of percentage sales made to unregistered firms, by the firms current firm is purchasing from");
graph save Graph "E:\data\PreliminaryAnalysis\BogusDealers\VarImp\PurchaseDSUnTaxProp.gph";
graph export "E:\data\PreliminaryAnalysis\BogusDealers\VarImp\PurchaseDSUnTaxProp.pdf", as(pdf) replace;


#delimit ;
preserve;
bys decile_PurchaseDSUnTaxProp: gen Count=_n;
bys decile_PurchaseDSUnTaxProp: egen Probability= mean(bogus_online);
gen OddsRatio=Probability/(1-Probability);
egen OverallProb=mean(bogus_online);
gen OverallOddsRatio=OverallProb/(1-OverallProb);
gen Likelihood=OddsRatio/OverallOddsRatio;
keep if Count==1;
graph bar (mean) Likelihood, over(decile_PurchaseDSUnTaxProp) graphregion(color(white))
               title("Percentage sales made to unregistered firms, by DS Purchase firms") ytitle("Likelihood of being bogus") 
			   bar(1, fcolor(navy) fintensity(inten50))
               note ("Firms grouped in deciles(10%) of percentage sales made to unregistered firms, by the firms current firm is purchasing from");
graph save Graph "E:\data\PreliminaryAnalysis\BogusDealers\VarImp\Likelihood_PurchaseDSUnTaxProp.gph";
graph export "E:\data\PreliminaryAnalysis\BogusDealers\VarImp\Likelihood_PurchaseDSUnTaxProp.pdf", as(pdf) replace;
restore;


xtile decile_PurchaseDSCreditRatio=PurchaseDSCreditRatio, nq(10)
label values decile_PurchaseDSCreditRatio decile


#delimit ;
graph bar (mean) bogus_online, over(decile_PurchaseDSCreditRatio) graphregion(color(white))
               title("Ratio of credit claimed to turnover, by DS Purchase firms") ytitle("Probability of being bogus") 
			   bar(1, fcolor(navy) fintensity(inten50))
               note ("Firms grouped in deciles(10%) of ratio of credit claimed to turnover, by the firms current firm is purchasing from");
graph save Graph "E:\data\PreliminaryAnalysis\BogusDealers\VarImp\PurchaseDSCreditRatio.gph";
graph export "E:\data\PreliminaryAnalysis\BogusDealers\VarImp\PurchaseDSCreditRatio.pdf", as(pdf) replace;




xtile decile_PurchaseDSVatRatio=PurchaseDSVatRatio, nq(10)
label values decile_PurchaseDSVatRatio decile

#delimit ;
graph bar (mean) bogus_online, over(decile_PurchaseDSVatRatio) graphregion(color(white))
               title("Ratio of VAT deposited to turnover, by DS Purchase firms") ytitle("Probability of being bogus") 
			   bar(1, fcolor(navy) fintensity(inten50))
               note ("Firms grouped in deciles(10%) of ratio of VAT deposited to turnover, by the firms current firm is purchasing from");
graph save Graph "E:\data\PreliminaryAnalysis\BogusDealers\VarImp\PurchaseDSVatRatio.gph";
graph export "E:\data\PreliminaryAnalysis\BogusDealers\VarImp\PurchaseDSVatRatio.pdf", as(pdf) replace;



#delimit ;
preserve;
bys decile_PurchaseDSVatRatio: gen Count=_n;
bys decile_PurchaseDSVatRatio: egen Probability= mean(bogus_online);
gen OddsRatio=Probability/(1-Probability);
egen OverallProb=mean(bogus_online);
gen OverallOddsRatio=OverallProb/(1-OverallProb);
gen Likelihood=OddsRatio/OverallOddsRatio;
keep if Count==1;
graph bar (mean) Likelihood, over(decile_PurchaseDSVatRatio) graphregion(color(white))
               title("Ratio of VAT deposited to turnover, by DS Purchase firms") ytitle("Likelihood of being bogus") 
			   bar(1, fcolor(navy) fintensity(inten50))
               note ("Firms grouped in deciles(10%) of ratio of VAT deposited to turnover, by the firms current firm is purchasing from");
graph save Graph "E:\data\PreliminaryAnalysis\BogusDealers\VarImp\Likelihood_PurchaseDSVatRatio.gph";
graph export "E:\data\PreliminaryAnalysis\BogusDealers\VarImp\Likelihood_PurchaseDSVatRatio.pdf", as(pdf) replace;
restore;



xtile decile_Purchases_pagerank=Purchases_pagerank, nq(10)
label values decile_Purchases_pagerank decile

#delimit ;
graph bar (mean) bogus_online, over(decile_Purchases_pagerank) graphregion(color(white))
               title("Pagerank (purchases)") ytitle("Probability of being bogus") 
			   note ("Firms grouped in deciles(10%) of pagerank from the purchased from data (2A)")
			   bar(1, fcolor(navy) fintensity(inten50));
graph save Graph "E:\data\PreliminaryAnalysis\BogusDealers\VarImp\Purchases_pagerank.gph";
graph export "E:\data\PreliminaryAnalysis\BogusDealers\VarImp\Purchases_pagerank.pdf", as(pdf) replace



#delimit ;
preserve;
bys decile_Purchases_pagerank: gen Count=_n;
bys decile_Purchases_pagerank: egen Probability= mean(bogus_online);
gen OddsRatio=Probability/(1-Probability);
egen OverallProb=mean(bogus_online);
gen OverallOddsRatio=OverallProb/(1-OverallProb);
gen Likelihood=OddsRatio/OverallOddsRatio;
keep if Count==1;
graph bar (mean) Likelihood, over(decile_Purchases_pagerank) graphregion(color(white))
               title("Pagerank (purchases)") ytitle("Likelihood of being bogus") 
			   note ("Firms grouped in deciles(10%) of pagerank from the purchased from data (2A)")
			   bar(1, fcolor(navy) fintensity(inten50));
graph save Graph "E:\data\PreliminaryAnalysis\BogusDealers\VarImp\Likelihood_Purchases_pagerank.gph";
graph export "E:\data\PreliminaryAnalysis\BogusDealers\VarImp\Likelihood_Purchases_pagerank.pdf", as(pdf) replace
restore;


xtile decile_Sales_pagerank=Sales_pagerank, nq(10)
label values decile_Sales_pagerank decile

#delimit ;
graph bar (mean) bogus_online, over(decile_Sales_pagerank) graphregion(color(white))
          title("Pagerank (sales)") ytitle("Probability of being bogus") bar(1, fcolor(navy) fintensity(inten50))
		note ("Firms grouped in deciles(10%) of pagerank from sales data");
graph save Graph "E:\data\PreliminaryAnalysis\BogusDealers\VarImp\Sales_pagerank.gph";
graph export "E:\data\PreliminaryAnalysis\BogusDealers\VarImp\Sales_pagerank.pdf", as(pdf) replace;

xtile decile_VatRatio=VatRatio, nq(10)
label values decile_VatRatio decile

#delimit;
graph bar (mean) bogus_online, over(decile_VatRatio) graphregion(color(white))
               title("Ratio of money deposited to turnover") ytitle("Probability of being bogus") bar(1, fcolor(navy) fintensity(inten50))
			   note ("Firms grouped in deciles(10%) of ratio of money deposited to turnover") ;
graph save Graph "E:\data\PreliminaryAnalysis\BogusDealers\VarImp\VatRatio.gph";
graph export "E:\data\PreliminaryAnalysis\BogusDealers\VarImp\VatRatio.pdf", as(pdf) replace;



#delimit ;
preserve;
bys decile_VatRatio: gen Count=_n;
bys decile_VatRatio: egen Probability= mean(bogus_online);
gen OddsRatio=Probability/(1-Probability);
egen OverallProb=mean(bogus_online);
gen OverallOddsRatio=OverallProb/(1-OverallProb);
gen Likelihood=OddsRatio/OverallOddsRatio;
keep if Count==1;
graph bar (mean) Likelihood, over(decile_VatRatio) graphregion(color(white))
               title("Ratio of money deposited to turnover") ytitle("Likelihood of being bogus") 
			   bar(1, fcolor(navy) fintensity(inten50))
               note ("Firms grouped in deciles(10%) of ratio of money deposited to turnover") ;
graph save Graph "E:\data\PreliminaryAnalysis\BogusDealers\VarImp\Likelihood_VatRatio.gph";
graph export "E:\data\PreliminaryAnalysis\BogusDealers\VarImp\Likelihood_VatRatio.pdf", as(pdf) replace;
restore;


xtile decile_CreditRatio=CreditRatio, nq(10)
label values decile_CreditRatio decile


#delimit ;
graph bar (mean) bogus_online, over(decile_CreditRatio) graphregion(color(white))
               title("Ratio of credit claimed to turnover") ytitle("Probability of being bogus") bar(1, fcolor(navy) fintensity(inten50))
			   note ("Firms grouped in deciles(10%) of ratio of credit claimed to turnover") ;
graph save Graph "E:\data\PreliminaryAnalysis\BogusDealers\VarImp\CreditRatio.gph";
graph export "E:\data\PreliminaryAnalysis\BogusDealers\VarImp\CreditRatio.pdf", as(pdf) replace;


xtile decile_MaxSalesProp=MaxSalesProp, nq(10)
label values decile_MaxSalesProp decile

#delimit ;
graph bar (mean) bogus_online, over(decile_MaxSalesProp) graphregion(color(white))
               title("Ratio of largest sale made to 1 firm") ytitle("Probability of being bogus") bar(1, fcolor(navy) fintensity(inten50))
			   note ("Firms grouped in deciles(10%) of ratio of largest sale made to 1 firm") ;
graph save Graph "E:\data\PreliminaryAnalysis\BogusDealers\VarImp\MaxSalesProp.gph";
graph export "E:\data\PreliminaryAnalysis\BogusDealers\VarImp\MaxSalesProp.pdf", as(pdf) replace;

xtile decile_InterstateRatio=InterstateRatio, nq(10)  
label values decile_InterstateRatio decile

#delimit ;
graph bar (mean) bogus_online, over(decile_InterstateRatio) graphregion(color(white))
               title("Proportion of inter state sales") ytitle("Probability of being bogus") bar(1, fcolor(navy) fintensity(inten50))
			   note ("Firms grouped in deciles(10%) of ratio of central turnover to total turnover") ;
graph save Graph "E:\data\PreliminaryAnalysis\BogusDealers\VarImp\InterstateRatio.gph";
graph export "E:\data\PreliminaryAnalysis\BogusDealers\VarImp\InterstateRatio.pdf", as(pdf) replace;



xtile decile_MaxPurchaseProp=MaxPurchaseProp, nq(10)  
label values decile_MaxPurchaseProp decile


#delimit ;
graph bar (mean) bogus_online, over(decile_MaxPurchaseProp) graphregion(color(white))
               title("Ratio of largest purchase made from 1 firm") ytitle("Probability of being bogus") bar(1, fcolor(navy) fintensity(inten50))
			   note ("Firms grouped in deciles(10%) of ratio of largest purchase made from 1 firm") ;
graph save Graph "E:\data\PreliminaryAnalysis\BogusDealers\VarImp\MaxPurchaseProp.gph";
graph export "E:\data\PreliminaryAnalysis\BogusDealers\VarImp\MaxPurchaseProp.pdf", as(pdf) replace;


xtile decile_TotalBuyers=TotalBuyers, nq(10)
label values decile_TotalBuyers decile

#delimit ;
graph bar (mean) bogus_online, over(decile_TotalBuyers) graphregion(color(white))
               title("Number of firms buying from the current firm") ytitle("Probability of being bogus") bar(1, fcolor(navy) fintensity(inten50))
			   note ("Firms grouped in deciles(10%) of number of buyers") ;
graph save Graph "E:\data\PreliminaryAnalysis\BogusDealers\VarImp\TotalBuyers.gph";
graph export "E:\data\PreliminaryAnalysis\BogusDealers\VarImp\TotalBuyers.pdf", as(pdf) replace;


xtile decile_TotalSellers=TotalSellers, nq(10)  
label values decile_TotalSellers decile


#delimit ;
graph bar (mean) bogus_online, over(decile_TotalSellers) graphregion(color(white))
               title("Number of selling firms") ytitle("Probability of being bogus") bar(1, fcolor(navy) fintensity(inten50))
			   note ("Firms grouped in deciles(10%) of number of sellers to the current firms") ;
graph save Graph "E:\data\PreliminaryAnalysis\BogusDealers\VarImp\TotalSellers.gph";
graph export "E:\data\PreliminaryAnalysis\BogusDealers\VarImp\TotalSellers.pdf", as(pdf) replace;



xtile decile_SalesDSVatRatio=SalesDSVatRatio, nq(10)
label values decile_SalesDSVatRatio decile

#delimit ;
graph bar (mean) bogus_online, over(decile_SalesDSVatRatio) graphregion(color(white))
               title("VAT deposited over turnover, by DS Sales firms") ytitle("Probability of being bogus") 
			   bar(1, fcolor(navy) fintensity(inten50))
			   note ("Firms grouped in deciles(10%) of ratio of VAT deposited to turnover, by the firms current firm is selling to");
graph save Graph "E:\data\PreliminaryAnalysis\BogusDealers\VarImp\SalesDSVatRatio.gph";
graph export "E:\data\PreliminaryAnalysis\BogusDealers\VarImp\SalesDSVatRatio.pdf", as(pdf) replace;


#delimit ;
preserve;
bys decile_SalesDSVatRatio: gen Count=_n;
bys decile_SalesDSVatRatio: egen Probability= mean(bogus_online);
gen OddsRatio=Probability/(1-Probability);
egen OverallProb=mean(bogus_online);
gen OverallOddsRatio=OverallProb/(1-OverallProb);
gen Likelihood=OddsRatio/OverallOddsRatio;
keep if Count==1;
graph bar (mean) Likelihood, over(decile_SalesDSVatRatio) graphregion(color(white))
               title("VAT deposited over turnover, by DS Sales firms") ytitle("Likelihood of being bogus") 
			   bar(1, fcolor(navy) fintensity(inten50))
			   note ("Firms grouped in deciles(10%) of ratio of VAT deposited to turnover, by the firms current firm is selling to");
graph save Graph "E:\data\PreliminaryAnalysis\BogusDealers\VarImp\Likelhihood_SalesDSVatRatio.gph";
graph export "E:\data\PreliminaryAnalysis\BogusDealers\VarImp\Likelihood_SalesDSVatRatio.pdf", as(pdf) replace;
restore;



xtile decile_SalesDSCreditRatio=SalesDSCreditRatio, nq(10)
label values decile_SalesDSCreditRatio decile

#delimit ;
graph bar (mean) bogus_online, over(decile_SalesDSCreditRatio) graphregion(color(white))
               title("Credit claimed over turnover, by DS Sales firms") ytitle("Probability of being bogus") 
			   bar(1, fcolor(navy) fintensity(inten50))
			   note ("Firms grouped in deciles(10%) of ratio of credit to turnover, by the firms current firm is selling to");
graph save Graph "E:\data\PreliminaryAnalysis\BogusDealers\VarImp\SalesDSCreditRatio.gph";
graph export "E:\data\PreliminaryAnalysis\BogusDealers\VarImp\SalesDSCreditRatio.pdf", as(pdf) replace;



xtile decile_SalesDSUnTaxProp=SalesDSUnTaxProp, nq(10)
label values decile_SalesDSUnTaxProp decile

#delimit ;
graph bar (mean) bogus_online, over(decile_SalesDSUnTaxProp) graphregion(color(white))
               title("Percentage sales made to unregistered firms, by DS Sales firms") ytitle("Probability of being bogus") 
			   bar(1, fcolor(navy) fintensity(inten50))
			   note ("Firms grouped in deciles(10%) of sales made to unregistered firms, by the firms current firm is selling to");
graph save Graph "E:\data\PreliminaryAnalysis\BogusDealers\VarImp\SalesDSUnTaxProp.gph";
graph export "E:\data\PreliminaryAnalysis\BogusDealers\VarImp\SalesDSUnTaxProp.pdf", as(pdf) replace;



xtile decile_UnTaxProp=UnTaxProp, nq(10)
label values decile_UnTaxProp decile

#delimit ;
graph bar (mean) bogus_online, over(decile_UnTaxProp) graphregion(color(white))
               title("Percentage sales made to unregistered firms") ytitle("Probability of being bogus") bar(1, fcolor(navy) fintensity(inten50))
			   note ("Firms grouped in deciles(10%) of sales made to unregistered firms") ;
graph save Graph "E:\data\PreliminaryAnalysis\BogusDealers\VarImp\UnTaxProp.gph";
graph export "E:\data\PreliminaryAnalysis\BogusDealers\VarImp\UnTaxProp.pdf", as(pdf) replace



#delimit ;
preserve;
bys decile_UnTaxProp: gen Count=_n;
bys decile_UnTaxProp: egen Probability= mean(bogus_online);
gen OddsRatio=Probability/(1-Probability);
egen OverallProb=mean(bogus_online);
gen OverallOddsRatio=OverallProb/(1-OverallProb);
gen Likelihood=OddsRatio/OverallOddsRatio;
keep if Count==1;
graph bar (mean) Likelihood, over(decile_UnTaxProp) graphregion(color(white))
               title("Percentage sales made to unregistered firms") ytitle("Likelihood of being bogus") bar(1, fcolor(navy) fintensity(inten50))
			   note ("Firms grouped in deciles(10%) of sales made to unregistered firms") ;
graph save Graph "E:\data\PreliminaryAnalysis\BogusDealers\VarImp\Likelihood_UnTaxProp.gph";
graph export "E:\data\PreliminaryAnalysis\BogusDealers\VarImp\Likelihood_UnTaxProp.pdf", as(pdf) replace;
restore;


xtile decile_TotalReturnCount=TotalReturnCount, nq(10)
label values decile_TotalReturnCount decile

#delimit ;
graph bar (mean) bogus_online, over(decile_TotalReturnCount) graphregion(color(white))
               title("Return Revision") ytitle("Probability of being bogus") bar(1, fcolor(navy) fintensity(inten50))
			   note ("Firms grouped in deciles(10%) of revising returns") ;
graph save Graph "E:\data\PreliminaryAnalysis\BogusDealers\VarImp\TotalReturnCount.gph";
graph export "E:\data\PreliminaryAnalysis\BogusDealers\VarImp\TotalReturnCount.pdf", as(pdf) replace;
