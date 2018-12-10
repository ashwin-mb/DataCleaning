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
** 1. Flow of the code 
** 2. Setting directories and files
** 3. Naming TaxPeriods
** 4. Sum of Summary stats
** 5. Finding Ratios
** 6.a Total Purchases, PercValueAdded
** 6.b TotalReturnCount
** 7. Bogus flags
** 8. Bogus more details
** 9. Registered/ unregistered values
** 10. UntaxProp
*--------------------------------------------------------

*--------------------------------------------------------
** 1. Setting directories and files
*--------------------------------------------------------

*input files*
global input_path1 "H:/Ashwin/dta/original"
global input_path2 "H:/Ashwin/dta/intermediate"
global input_path3 "H:/Ashwin/dta/intermediate2"
global temp_path1 "H:/Ashwin/dta/temp"

*output files*
global output_path "H:/Ashwin/dta/final"
global analysis_path "H:/Ashwin/dta/analysis"
global qc_path "H:/Ashwin/dta/qc"
global prob_path "H:/Ashwin/dta/prob"

*--------------------------------------------------------
** 2. Naming TaxPeriods
*--------------------------------------------------------

use "${output_path}/form16_latestreturns_consolidated.dta", clear

replace TaxPeriod = "Third Quarter-2012" if TaxPeriod == "Third quaterly-2012"
replace TaxPeriod = "Second Quarter-2012" if TaxPeriod == "Second quaterly-2012"
replace TaxPeriod = "First Quarter-2012" if TaxPeriod == "First quaterly-2012"
replace TaxPeriod = "Fourth Quarter-2012" if TaxPeriod == "Forth Quarter-2012"
replace TaxPeriod = "Third Quarter-2012" if TaxPeriod == "Thrid Quater-2012"

drop if TaxPeriod=="Annual-2012"|TaxPeriod=="First Halfyear-2012"|TaxPeriod=="Second Halfyear-2012"|TaxPeriod=="Apr-2013"|TaxPeriod=="May-2013"

gen TaxYear=0
replace TaxYear=1 if TaxPeriod=="Annual-2010"
replace TaxYear=2 if TaxPeriod=="Annual-2011"
replace TaxYear=3 if TaxPeriod=="Annual-2012"

gen TaxHalfyear=0
replace TaxHalfyear=1 if TaxPeriod=="First halfyearly-2010"
replace TaxHalfyear=2 if TaxPeriod=="Second halfyearly-2010"
replace TaxHalfyear=3 if TaxPeriod=="First halfyearly-2011"
replace TaxHalfyear=4 if TaxPeriod=="Second halfyearly-2011"
replace TaxHalfyear=5 if TaxPeriod=="First halfyearly-2012"
replace TaxHalfyear=6 if TaxPeriod=="Second halfyearly-2012"

replace TaxYear=1 if TaxPeriod=="First halfyearly-2010"|TaxPeriod=="Second halfyearly-2010"
replace TaxYear=2 if TaxPeriod=="First halfyearly-2011"|TaxPeriod=="Second halfyearly-2011"
replace TaxYear=3 if TaxPeriod=="First halfyearly-2012"|TaxPeriod=="Second halfyearly-2012"


gen TaxQuarter=0
replace TaxQuarter=1 if TaxPeriod=="First Quarter-2010"
replace TaxQuarter=2 if TaxPeriod=="Second Quarter-2010"
replace TaxQuarter=3 if TaxPeriod=="Third Quarter-2010"
replace TaxQuarter=4 if TaxPeriod=="Fourth Quarter-2010"
replace TaxQuarter=5 if TaxPeriod=="First Quarter-2011"
replace TaxQuarter=6 if TaxPeriod=="Second Quarter-2011"
replace TaxQuarter=7 if TaxPeriod=="Third Quarter-2011"
replace TaxQuarter=8 if TaxPeriod=="Fourth Quarter-2011"
replace TaxQuarter=9 if TaxPeriod=="First Quarter-2012"
replace TaxQuarter=10 if TaxPeriod=="Second Quarter-2012"
replace TaxQuarter=11 if TaxPeriod=="Third Quarter-2012"
replace TaxQuarter=12 if TaxPeriod=="Fourth Quarter-2012"
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


replace TaxYear=1 if TaxQuarter>0&TaxQuarter<=4
replace TaxYear=2 if TaxQuarter>4&TaxQuarter<=8
replace TaxYear=3 if TaxQuarter>8&TaxQuarter<=12
replace TaxYear=4 if TaxQuarter>12&TaxQuarter<=16
replace TaxYear=5 if TaxQuarter>16&TaxQuarter<=20
replace TaxYear=6 if TaxQuarter>20&TaxQuarter<=24
replace TaxYear=7 if TaxQuarter>24&TaxQuarter<=28

gen TaxMonth=0
replace TaxMonth=1 if TaxPeriod=="Apr-2010"
replace TaxMonth=2 if TaxPeriod=="May-2010"
replace TaxMonth=3 if TaxPeriod=="Jun-2010"
replace TaxMonth=4 if TaxPeriod=="Jul-2010"
replace TaxMonth=5 if TaxPeriod=="Aug-2010"
replace TaxMonth=6 if TaxPeriod=="Sep-2010"
replace TaxMonth=7 if TaxPeriod=="Oct-2010"
replace TaxMonth=8 if TaxPeriod=="Nov-2010"
replace TaxMonth=9 if TaxPeriod=="Dec-2010"
replace TaxMonth=10 if TaxPeriod=="Jan-2011"
replace TaxMonth=11 if TaxPeriod=="Feb-2011"
replace TaxMonth=12 if TaxPeriod=="Mar-2011"
replace TaxMonth=13 if TaxPeriod=="Apr-2011"
replace TaxMonth=14 if TaxPeriod=="May-2011"
replace TaxMonth=15 if TaxPeriod=="Jun-2011"
replace TaxMonth=16 if TaxPeriod=="Jul-2011"
replace TaxMonth=17 if TaxPeriod=="Aug-2011"
replace TaxMonth=18 if TaxPeriod=="Sep-2011"
replace TaxMonth=19 if TaxPeriod=="Oct-2011"
replace TaxMonth=20 if TaxPeriod=="Nov-2011"
replace TaxMonth=21 if TaxPeriod=="Dec-2011"
replace TaxMonth=22 if TaxPeriod=="Jan-2012"
replace TaxMonth=23 if TaxPeriod=="Feb-2012"
replace TaxMonth=24 if TaxPeriod=="Mar-2012"
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
replace TaxMonth=37 if TaxPeriod=="Apr-2013"
replace TaxMonth=38 if TaxPeriod=="May-2013"


replace TaxYear=1 if TaxMonth>0&TaxMonth<=12
replace TaxYear=2 if TaxMonth>12&TaxMonth<=24
replace TaxYear=3 if TaxMonth>24&TaxMonth<=36
replace TaxYear=4 if TaxMonth>36

replace TaxQuarter=1 if TaxMonth>0&TaxMonth<=3
replace TaxQuarter=2 if TaxMonth>3&TaxMonth<=6
replace TaxQuarter=3 if TaxMonth>6&TaxMonth<=9
replace TaxQuarter=4 if TaxMonth>9&TaxMonth<=12
replace TaxQuarter=5 if TaxMonth>12&TaxMonth<=15
replace TaxQuarter=6 if TaxMonth>15&TaxMonth<=18
replace TaxQuarter=7 if TaxMonth>18&TaxMonth<=21
replace TaxQuarter=8 if TaxMonth>21&TaxMonth<=24
replace TaxQuarter=9 if TaxMonth>24&TaxMonth<=27
replace TaxQuarter=10 if TaxMonth>27&TaxMonth<=30
replace TaxQuarter=11 if TaxMonth>30&TaxMonth<=33
replace TaxQuarter=12 if TaxMonth>33&TaxMonth<=36
replace TaxQuarter=13 if TaxMonth>36&TaxMonth<=39

label define year 1 "2010-11" 2 "2011-12" 3 "2012-13" 4 "2013-14" 5 "2014-15" 6 "2015-16" 7 "2016-17"
label define quarter 1 "Q1, 2010-11" 2 "Q2, 2010-11" 3 "Q3, 2010-11" 4 "Q4, 2010-11" ///
5 "Q1, 2011-12" 6 "Q2, 2011-12" 7 "Q3, 2011-12" 8 "Q4, 2011-12" ///
9 "Q1, 2012-13" 10 "Q2, 2012-13" 11 "Q3, 2012-13" 12 "Q4, 2012-13" ///
13 "Q1, 2013-14" 14 "Q2, 2013-14" 15 "Q3, 2013-14" 16 "Q4, 2013-14" ///
17 "Q1, 2014-15" 18 "Q2, 2014-15" 19 "Q3, 2014-15" 20 "Q4, 2014-15" ///
21 "Q1, 2015-16" 22 "Q2, 2015-16" 23 "Q3, 2015-16" 24 "Q4, 2015-16" ///
25 "Q1, 2016-17" 26 "Q2, 2016-17" 27 "Q3, 2016-17" 28 "Q4, 2016-17"

label values TaxQuarter quarter
label values TaxYear year	

gsort Mtin TaxYear TaxHalfyear TaxQuarter TaxMonth

*--------------------------------------------------------
** 6.a Total Purchases, PercValueAdded
*--------------------------------------------------------

gen MoneyDeposited=max(AggregateAmountPaid, AmountDepositedByDealer)
gen TotalPurchases=PurchaseCapitalGoods+PurchaseOtherGoods+PurchaseUnregisteredDealer
gen PercValueAdded=(GrossTurnover-TotalPurchases)/(TotalPurchases)
gen TotalValueAdded=(GrossTurnover-TotalPurchases)
gen PercPurchaseUnregisteredDealer=PurchaseUnregisteredDealer/(TotalPurchases)
*label variable PurchaseNoCredit "R6.3 Total local purchases that are no eligible for credit of input tax"
label variable PercValueAdded "A measure of fraction of value added, definition is (TurnoverGross-PurchaseCapitalGoods-PurchaseOtherGoods-PurchaseUnregisteredDealer)/(PurchaseCapitalGoods+PurchaseOtherGoods+PurchaseNoCredit)"
label variable PercPurchaseUnregisteredDealer "A measure of amount purchased from unregistered dealers:PurchaseUnregisteredDealer/(PurchaseCapitalGoods+PurchaseOtherGoods+PurchaseUnregisterdDealer)"
label variable TotalValueAdded "Total value added, (TurnoverGross-TotalPurchases)"
label variable TotalPurchases "Total purchases made: PurchaseCapitalGoods+PurchaseOtherGoods+PurchaseUnregisteredDealer"

gsort Mtin TaxYear TaxHalfyear TaxQuarter TaxMonth
gen AnnualDummy=1 if TaxPeriod=="Annual-2010"|TaxPeriod=="Annual-2011"
gen SemiAnnualDummy=1 if TaxPeriod=="First Halfyear-2010"|TaxPeriod=="First Halfyear-2011"|TaxPeriod=="Second Halfyear-2010"|TaxPeriod=="Second Halfyear-2011"
gen QuarterlyDummy=1 if TaxPeriod=="First Quarter-2010"|TaxPeriod=="First Quarter-2011"|TaxPeriod=="Second Quarter-2010"|TaxPeriod=="Second Quarter-2011"|TaxPeriod=="Third Quarter-2010"|TaxPeriod=="Third Quarter-2011"|TaxPeriod=="Fourth Quarter-2010"|TaxPeriod=="Fourth Quarter-2011"
gen MonthlyDummy=1 if TaxPeriod=="Apr-2010"|TaxPeriod=="Apr-2011"|TaxPeriod=="Apr-2012"|TaxPeriod=="Aug-2010"|TaxPeriod=="Aug-2011"|TaxPeriod=="Aug-2012"|TaxPeriod=="Dec-2010"|TaxPeriod=="Dec-2011"|TaxPeriod=="Dec-2012"|TaxPeriod=="Feb-2011"|TaxPeriod=="Feb-2012"|TaxPeriod=="Feb-2013"|TaxPeriod=="Jan-2011"|TaxPeriod=="Jan-2012"|TaxPeriod=="Jan-2013"|TaxPeriod=="Jul-2010"|TaxPeriod=="Jul-2011"|TaxPeriod=="Jul-2012"|TaxPeriod=="Jun-2010"|TaxPeriod=="Jun-2011"|TaxPeriod=="Jun-2012"|TaxPeriod=="Mar-2011"|TaxPeriod=="Mar-2012"|TaxPeriod=="Mar-2013"|TaxPeriod=="May-2010"|TaxPeriod=="May-2011"|TaxPeriod=="May-2012"|TaxPeriod=="Nov-2010"|TaxPeriod=="Nov-2011"|TaxPeriod=="Nov-2012"|TaxPeriod=="Oct-2010"|TaxPeriod=="Oct-2011"|TaxPeriod=="Oct-2012"|TaxPeriod=="Sep-2010"|TaxPeriod=="Sep-2011"|TaxPeriod=="Sep-2012"

by Mtin: replace AnnualDummy=AnnualDummy[_n-1] if AnnualDummy>=.
by Mtin: replace SemiAnnualDummy=SemiAnnualDummy[_n-1] if SemiAnnualDummy>=.
by Mtin: replace QuarterlyDummy=QuarterlyDummy[_n-1] if QuarterlyDummy>=.
by Mtin: replace MonthlyDummy=MonthlyDummy[_n-1] if MonthlyDummy>=.


drop if AnnualDummy==1&SemiAnnualDummy==1&TaxYear==1
drop if AnnualDummy==1&QuarterlyDummy==1&TaxYear==1
drop if AnnualDummy==1&MonthlyDummy==1&TaxYear==1
drop if SemiAnnualDummy==1&QuarterlyDummy==1&TaxYear==1
drop if SemiAnnualDummy==1&MonthlyDummy==1&TaxYear==1
drop if QuarterlyDummy==1&MonthlyDummy==1&TaxYear==1
drop AnnualDummy SemiAnnualDummy MonthlyDummy QuarterlyDummy


gsort Mtin TaxYear TaxHalfyear TaxQuarter TaxMonth
gen AnnualDummy=1 if TaxPeriod=="Annual-2011"
gen SemiAnnualDummy=1 if TaxPeriod=="First Halfyear-2011"|TaxPeriod=="Second Halfyear-2011"
gen QuarterlyDummy=1 if TaxPeriod=="First Quarter-2011"|TaxPeriod=="Second Quarter-2011"|TaxPeriod=="Third Quarter-2011"|TaxPeriod=="Fourth Quarter-2011"
gen MonthlyDummy=1 if TaxPeriod=="Apr-2011"|TaxPeriod=="Aug-2011"|TaxPeriod=="Dec-2011"|TaxPeriod=="Feb-2012"|TaxPeriod=="Jan-2012"|TaxPeriod=="Jul-2011"|TaxPeriod=="Jun-2011"|TaxPeriod=="Mar-2012"|TaxPeriod=="May-2011"|TaxPeriod=="Nov-2011"|TaxPeriod=="Oct-2011"|TaxPeriod=="Sep-2011"

by Mtin: replace AnnualDummy=AnnualDummy[_n-1] if AnnualDummy>=.
by Mtin: replace SemiAnnualDummy=SemiAnnualDummy[_n-1] if SemiAnnualDummy>=.
by Mtin: replace QuarterlyDummy=QuarterlyDummy[_n-1] if QuarterlyDummy>=.
by Mtin: replace MonthlyDummy=MonthlyDummy[_n-1] if MonthlyDummy>=.

drop if AnnualDummy==1&SemiAnnualDummy==1&TaxYear==2
drop if AnnualDummy==1&QuarterlyDummy==1&TaxYear==2
drop if AnnualDummy==1&MonthlyDummy==1&TaxYear==2
drop if SemiAnnualDummy==1&QuarterlyDummy==1&TaxYear==2
drop if SemiAnnualDummy==1&MonthlyDummy==1&TaxYear==2
drop if QuarterlyDummy==1&MonthlyDummy==1&TaxYear==2
drop AnnualDummy SemiAnnualDummy MonthlyDummy QuarterlyDummy

gsort Mtin TaxYear TaxHalfyear TaxQuarter TaxMonth
gen QuarterlyDummy=1 if TaxPeriod=="First Quarter-2012"|TaxPeriod=="Second Quarter-2012"|TaxPeriod=="Third Quarter-2012"|TaxPeriod=="Fourth Quarter-2012"
gen MonthlyDummy=1 if TaxPeriod=="Apr-2012"|TaxPeriod=="Aug-2012"|TaxPeriod=="Dec-2012"|TaxPeriod=="Feb-2013"|TaxPeriod=="Jan-2013"|TaxPeriod=="Jul-2012"|TaxPeriod=="Jun-2012"|TaxPeriod=="Mar-2013"|TaxPeriod=="May-2012"|TaxPeriod=="Nov-2012"|TaxPeriod=="Oct-2012"|TaxPeriod=="Sep-2012"


by Mtin: replace QuarterlyDummy=QuarterlyDummy[_n-1] if QuarterlyDummy>=.
by Mtin: replace MonthlyDummy=MonthlyDummy[_n-1] if MonthlyDummy>=.
drop if QuarterlyDummy==1&MonthlyDummy==1&TaxYear==3

//drop if TaxQuarter==0
//collapse (sum) RefundClaimed TDSCertificates NetTax BalanceBroughtForward CarryForwardTaxCredit BalanceCarriedNextTaxPeriod MoneyDeposited TurnoverGross TurnoverCentral TurnoverLocal TotalOutputTax PurchaseUnregisteredDealer TotalTaxCredit ExemptedSales TaxCreditBeforeAdjustment OutputTaxBeforeAdjustment, by(DealerTIN TaxYear)

*--------------------------------------------------------
** 4. Sum of Summary stats
*--------------------------------------------------------

collapse (sum) RefundClaimed TDSCertificates NetTax BalanceBroughtForward ///
	CarryForwardTaxCredit BalanceCarriedNextTaxPeriod MoneyDeposited ///
	GrossTurnover CentralTurnover LocalTurnover TotalOutputTax ///
	PurchaseUnregisteredDealer TotalTaxCredit ExemptedSales ///
	TaxCreditBeforeAdjustment OutputTaxBeforeAdjustment, ///
	by(Mtin TaxQuarter)

*--------------------------------------------------------
** 5. Ratio
*--------------------------------------------------------

gen ZeroTurnover=0
replace ZeroTurnover=1 if GrossTurnover==0

gen PositiveContribution=0
replace PositiveContribution=1 if MoneyDeposited>0

gen AllCentral=0
replace AllCentral=1 if GrossTurnover==CentralTurnover&GrossTurnover!=0

gen AllLocal=0
replace AllLocal=1 if CentralTurnover==0&GrossTurnover!=0

gen ZeroTax=(ExemptedSales==LocalTurnover)&LocalTurnover!=0
gen VatRatio=MoneyDeposited/GrossTurnover
gen CreditRatio=TaxCreditBeforeAdjustment/GrossTurnover
gen TaxRatio=OutputTaxBeforeAdjustment/GrossTurnover
gen InterstateRatio=CentralTurnover/GrossTurnover
gen LocalVatRatio=MoneyDeposited/LocalTurnover
gen LocalCreditRatio=TaxCreditBeforeAdjustment/LocalTurnover
gen LocalTaxRatio=OutputTaxBeforeAdjustment/LocalTurnover

/*xtile group1=MoneyDeposited if TaxQuarter==1 , nq(100) 
xtile group2=MoneyDeposited if TaxQuarter==2 , nq(100)  
xtile group3=MoneyDeposited if TaxQuarter==3 , nq(100)  
xtile group4=MoneyDeposited if TaxQuarter==4 , nq(100) 
xtile group5=MoneyDeposited if TaxQuarter==5 , nq(100)  
xtile group6=MoneyDeposited if TaxQuarter==6 , nq(100)  
xtile group7=MoneyDeposited if TaxQuarter==7 , nq(100)  
xtile group8=MoneyDeposited if TaxQuarter==8 , nq(100) */ 
xtile group9=MoneyDeposited if TaxQuarter==9 , nq(100) 
xtile group10=MoneyDeposited if TaxQuarter==10 , nq(100) 
xtile group11=MoneyDeposited if TaxQuarter==11 , nq(100) 
xtile group12=MoneyDeposited if TaxQuarter==12 , nq(100) 
xtile group13=MoneyDeposited if TaxQuarter==13 , nq(100) 
xtile group14=MoneyDeposited if TaxQuarter==14 , nq(100) 
xtile group15=MoneyDeposited if TaxQuarter==15 , nq(100) 
xtile group16=MoneyDeposited if TaxQuarter==16 , nq(100) 
xtile group17=MoneyDeposited if TaxQuarter==17 , nq(100) 
xtile group18=MoneyDeposited if TaxQuarter==18 , nq(100) 
xtile group19=MoneyDeposited if TaxQuarter==19 , nq(100) 
xtile group20=MoneyDeposited if TaxQuarter==20 , nq(100) 
xtile group21=MoneyDeposited if TaxQuarter==21 , nq(100) 
xtile group22=MoneyDeposited if TaxQuarter==22 , nq(100) 
xtile group23=MoneyDeposited if TaxQuarter==23 , nq(100) 
xtile group24=MoneyDeposited if TaxQuarter==24 , nq(100) 
xtile group25=MoneyDeposited if TaxQuarter==25 , nq(100) 
xtile group26=MoneyDeposited if TaxQuarter==26 , nq(100) 
xtile group27=MoneyDeposited if TaxQuarter==27 , nq(100) 
xtile group28=MoneyDeposited if TaxQuarter==28 , nq(100) 

gen MoneyGroup=group1
replace MoneyGroup=group2 if MoneyGroup==.
replace MoneyGroup=group3 if MoneyGroup==.
replace MoneyGroup=group4 if MoneyGroup==.
replace MoneyGroup=group5 if MoneyGroup==.
replace MoneyGroup=group6 if MoneyGroup==.
replace MoneyGroup=group7 if MoneyGroup==.
replace MoneyGroup=group8 if MoneyGroup==.
replace MoneyGroup=group9 if MoneyGroup==.
replace MoneyGroup=group10 if MoneyGroup==.
replace MoneyGroup=group11 if MoneyGroup==.
replace MoneyGroup=group12 if MoneyGroup==.
replace MoneyGroup=group13 if MoneyGroup==.
replace MoneyGroup=group14 if MoneyGroup==.
replace MoneyGroup=group15 if MoneyGroup==.
replace MoneyGroup=group16 if MoneyGroup==.
replace MoneyGroup=group17 if MoneyGroup==.
replace MoneyGroup=group18 if MoneyGroup==.
replace MoneyGroup=group19 if MoneyGroup==.
replace MoneyGroup=group20 if MoneyGroup==.
replace MoneyGroup=group21 if MoneyGroup==.
replace MoneyGroup=group22 if MoneyGroup==.
replace MoneyGroup=group23 if MoneyGroup==.
replace MoneyGroup=group24 if MoneyGroup==.
replace MoneyGroup=group25 if MoneyGroup==.
replace MoneyGroup=group26 if MoneyGroup==.
replace MoneyGroup=group27 if MoneyGroup==.
replace MoneyGroup=group28 if MoneyGroup==.
drop group*

*merge 1:1 Mtin TaxQuarter using "${features_path}/form16_v5.dta", keepusing(TotalReturnCount TotalPurchases PercValueAdded TotalValueAdded PercPurchaseUnregisteredDealer)
gen ZeroTaxCredit=0
replace ZeroTaxCredit=1 if TaxCreditBeforeAdjustment==0
drop if Mtin == ""
isid Mtin TaxQuarter
save "${features_path}/FeatureReturns_new.dta", replace

*Add mean return count
use "${features_path}/form16_v5.dta", clear
bysort Mtin TaxQuarter: egen MeanReturnCount = mean(TotalReturnCount)
bysort Mtin TaxQuarter: gen Count=_n
keep if Count==1
replace TotalReturnCount=MeanReturnCount
keep Mtin TaxQuarter TotalReturnCount TotalPurchases PercValueAdded ///
	PercPurchaseUnregisteredDealer TotalValueAdded
isid Mtin TaxQuarter
save "${features_path}/form16_v5_ReturnCount.dta", replace

use "${features_path}/FeatureReturns_new.dta", clear
merge 1:1 Mtin TaxQuarter using "${features_path}/form16_v5_ReturnCount.dta", keepusing(TotalReturnCount TotalPurchases PercValueAdded PercPurchaseUnregisteredDealer TotalValueAdded)
save "${features_path}/FeatureReturns_new.dta", replace

* Merging bogus dealers information
use "${features_path}/FeatureReturns_new.dta", clear
drop _merge
destring Mtin, replace
merge m:1 Mtin using "${output_path}\bogus_consolidated.dta"
gen bogus_flag = 0 
replace bogus_flag = 1 if _merge == 3 
drop if _merge == 2 
drop Reason inspection_year _merge
save "${features_path}/FeatureReturns_new_v2.dta", replace

*Merge with status of bogus firms
use "${output_path}/dp_form.dta", clear
keep Mtin RegistrationStatus
drop if Mtin == ""
tempfile temp3
save temp3, replace

use "${features_path}/FeatureReturns_new_v2.dta", clear
tostring Mtin, replace
merge m:1 Mtin using temp3
drop if _merge==2
drop _merge
save "${features_path}/FeatureReturns_new_v3.dta", replace

use "${features_path}/FeatureReturns_new_v3.dta", clear
merge 1:1 Mtin TaxQuarter using "${features_path}/RegisteredSales_AllQuarters.dta"
drop if _merge==2

gen UnTaxProp=UnregisteredSalesTax/OutputTaxBeforeAdjustment
replace UnTaxProp=0 if UnTaxProp==.

save "${features_path}/FeatureReturns.dta", replace

use "${features_path}/FeatureReturns.dta"
merge 1:1 Mtin TaxQuarter using "${features_path}/FeatureDownStreamnessSales.dta", keep(master match) generate(salesds_merge)
merge 1:1 Mtin TaxQuarter using "${features_path}/FeatureDownStreamnessPurchases.dta", keep(master match) generate(purchaseds_merge)
save "${features_path}/FeatureReturnsWithDS.dta", replace
