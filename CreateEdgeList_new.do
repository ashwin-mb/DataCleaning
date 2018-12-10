/************************************************* 
* Filename: 
* Input: H:/Ashwin/dta/DP_forms.dta
* Purpose: Creates input files for Network features  
* Output: 
			
* Author: Ashwin MB
* Date: 28/11/2018
* Last modified: 28/11/2018 (Ashwin)
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
global features_path "H:/Ashwin/dta/bogusdealers"
global output_path "H:/Ashwin/dta/final"
global qc_path "H:/Ashwin/dta/qc"
global prob_path "H:/Ashwin/dta/prob"
global sample_path "H:/Ashwin/dta/sample"

*--------------------------------------------------------
** Monthly 2a2b Sale form
*--------------------------------------------------------
*use "E:\data\annexure_2A2B_monthly_201213.dta", clear
use "${output_path}/2a2b_monthly_2012.dta", clear

keep if SaleOrPurchase=="BF"
keep if SalePurchaseType=="LS"|SalePurchaseType==""

replace DealerGoodType="OT" if DealerGoodType==" OT"
replace DealerGoodType="OT" if DealerGoodType=="OT             "
replace DealerGoodType="OT" if DealerGoodType=="OT     "
replace DealerGoodType="OT" if DealerGoodType=="OT "
replace DealerGoodType="OT" if DealerGoodType=="OT  "
replace DealerGoodType="OT" if DealerGoodType=="Ot"
replace DealerGoodType="OT" if DealerGoodType=="ot"
replace DealerGoodType="OT" if DealerGoodType=="ot "
replace DealerGoodType="OT" if DealerGoodType=="OT  "

replace DealerGoodType="UD" if DealerGoodType=="uD"
replace DealerGoodType="UD" if DealerGoodType=="ud"

replace TransactionType="GD" if TransactionType=="GD "
replace TransactionType="GD" if TransactionType=="GD  "
replace TransactionType="GD" if TransactionType=="GD    "
replace TransactionType="GD" if TransactionType=="GD     "
replace TransactionType="GD" if TransactionType=="GD             "
replace TransactionType="GD" if TransactionType=="Gd"
replace TransactionType="GD" if TransactionType=="gd"
replace TransactionType="GD" if TransactionType=="gd "
replace TransactionType="GD" if TransactionType==" GD"

replace TransactionType="WC" if TransactionType=="wc"
replace TransactionType="WC" if TransactionType=="Wc"

replace TransactionType=trim(TransactionType)
replace DealerGoodType=trim(DealerGoodType)

keep if DealerGoodType=="RD"|DealerGoodType=="OT"|DealerGoodType=="CG"

keep if TransactionType=="GD"|TransactionType=="WC"
drop if SellerBuyerTin==""

replace Rate=trim(Rate)

replace Rate="0" if Rate=="0.0"
replace Rate="0" if Rate=="0.00"
replace Rate="0" if Rate=="00.00"
replace Rate="1" if Rate=="0.99"
replace Rate="1" if Rate=="1.00"
replace Rate="1" if Rate=="0.01"
replace Rate="1" if Rate=="1.000"
replace Rate="2" if Rate=="2.00"
replace Rate="2" if Rate=="0.02"
replace Rate="12.5" if Rate=="12.49"
replace Rate="12.5" if Rate=="12.00"
replace Rate="12.5" if Rate=="12.50"
replace Rate="12.5" if Rate=="12.500"
replace Rate="12.5" if Rate=="12.5000"
replace Rate="12.5" if Rate=="125.00"
replace Rate="20" if Rate=="20.00"
replace Rate="20" if Rate=="20.0"
replace Rate="5" if Rate=="0.05"
replace Rate="5" if Rate=="5.0"
replace Rate="5" if Rate=="5.00"
replace Rate="5" if Rate=="5.000"
replace Rate="5" if Rate=="5.0000"
replace Rate="5" if Rate=="05.00"
replace Rate="5" if Rate=="4.99"
replace Rate="4" if Rate=="4.00"
replace Rate="4" if Rate=="0.04"
replace Rate="10" if Rate=="0.10"
replace Rate="10" if Rate=="10.00"
replace Rate="12.5" if Rate=="0.12"

drop if Rate=="3.00"
drop if Rate=="2.50"
drop if SellerBuyerTin=="NA"|SellerBuyerTin=="0"
drop Form_Status
*drop T985DF5 T985DF6 T985DF7 T985DF8 FormsStatus T985DF4
drop if Rate==""
drop if SellerBuyerTin==""
drop if Mtin == ""

*Cleaning 2a2b files
drop TaxPeriod
rename OriginalTaxPeriod TaxPeriod
rename Tax TaxAmount
rename Total TotalAmount

bys TaxPeriod Mtin SellerBuyerTin: gen TotalCount=_N
by TaxPeriod Mtin SellerBuyerTin: egen TotalTaxAmount= sum(TaxAmount)
by TaxPeriod Mtin SellerBuyerTin: egen SumTotalAmount= sum(TotalAmount)
by TaxPeriod Mtin SellerBuyerTin: gen Count2=_n
keep if Count2==1

isid TaxPeriod Mtin SellerBuyerTin 

***** temp ******
save "${temp_path1}/networkfeatures_2a2b.dta", replace
use "${temp_path1}/networkfeatures_2a2b.dta", clear
***** temp ******


drop TransactionType DealerGoodType SalePurchaseType Count2 Date var12 var14  TaxYear CommodityName CommodityCode TotalAmount TaxAmount NetAmount 

rename TotalTaxAmount SalesTaxAmount
rename SumTotalAmount TotalSalesAmount

gen TaxMonth=25 if TaxPeriod=="apr 2012"
replace TaxMonth=26 if TaxPeriod=="may 2012"
replace TaxMonth=27 if TaxPeriod=="jun 2012"
replace TaxMonth=28 if TaxPeriod=="jul 2012"
replace TaxMonth=29 if TaxPeriod=="aug 2012"
replace TaxMonth=30 if TaxPeriod=="sep 2012"
replace TaxMonth=31 if TaxPeriod=="oct 2012"
replace TaxMonth=32 if TaxPeriod=="nov 2012"
replace TaxMonth=33 if TaxPeriod=="dec 2012"
replace TaxMonth=34 if TaxPeriod=="jan 2013"
replace TaxMonth=35 if TaxPeriod=="feb 2013"
replace TaxMonth=36 if TaxPeriod=="mar 2013"

gen TaxQuarter=0
replace TaxQuarter=9 if TaxMonth>24&TaxMonth<=27
replace TaxQuarter=10 if TaxMonth>27&TaxMonth<=30
replace TaxQuarter=11 if TaxMonth>30&TaxMonth<=33
replace TaxQuarter=12 if TaxMonth>33&TaxMonth<=36

gsort TaxQuarter Mtin SellerBuyerTin TaxMonth
bys TaxQuarter Mtin SellerBuyerTin: egen Count=sum(TotalCount)
by TaxQuarter Mtin SellerBuyerTin: egen TotalTaxAmount= sum(SalesTaxAmount)
by TaxQuarter Mtin SellerBuyerTin: egen SumTotalAmount= sum(TotalSalesAmount)
by TaxQuarter Mtin SellerBuyerTin: gen Count2=_n
keep if Count2==1

isid TaxQuarter Mtin SellerBuyerTin 

drop TotalCount SalesTaxAmount TotalSalesAmount TaxMonth TaxPeriod Count2 Rate SaleOrPurchase MReturn_ID 
rename TotalTaxAmount SalesTaxAmount
rename SumTotalAmount TotalSalesAmount
rename Count TotalCountSaleTransactions

save "${features_path}\SalesTaxAmount2012.dta", replace


*--------------------------------------------------------
** Monthly 2a2b Purchase form
*--------------------------------------------------------

*use "E:\data\annexure_2A2B_monthly_201213.dta", clear
use "${output_path}/2a2b_monthly_2012.dta", clear
keep if SaleOrPurchase=="AE"
replace SalePurchaseType="OT" if SalePurchaseType=="ot"
keep if SalePurchaseType=="CG"|SalePurchaseType=="OT"|SalePurchaseType==""

keep if DealerGoodType==""|DealerGoodType=="OT"|DealerGoodType=="CG"

drop if SellerBuyerTin==""

replace Rate=trim(Rate)
replace Rate="0" if Rate=="0.0"
replace Rate="0" if Rate=="0.00"
replace Rate="0" if Rate=="00.00"
replace Rate="1" if Rate=="0.99"
replace Rate="1" if Rate=="1.00"
replace Rate="1" if Rate=="0.01"
replace Rate="1" if Rate=="1.000"
replace Rate="2" if Rate=="2.00"
replace Rate="2" if Rate=="0.02"
replace Rate="12.5" if Rate=="12.49"
replace Rate="12.5" if Rate=="12.00"
replace Rate="12.5" if Rate=="12.50"
replace Rate="12.5" if Rate=="12.500"
replace Rate="12.5" if Rate=="12.5000"
replace Rate="12.5" if Rate=="125.00"
replace Rate="12.5" if Rate==".12"
replace Rate="20" if Rate=="20.00"
replace Rate="20" if Rate=="20.0"
replace Rate="5" if Rate=="0.05"
replace Rate="5" if Rate==".05"
replace Rate="5" if Rate=="5.0"
replace Rate="5" if Rate=="5.00"
replace Rate="5" if Rate=="5.000"
replace Rate="5" if Rate=="5.0000"
replace Rate="5" if Rate=="05.00"
replace Rate="5" if Rate=="4.99"
replace Rate="4" if Rate=="4.00"
replace Rate="4" if Rate=="0.04"
replace Rate="10" if Rate=="0.10"
replace Rate="10" if Rate=="10.00"
replace Rate="12.5" if Rate=="0.12"

gen dRate=Rate
destring dRate, replace
replace dRate=NetAmount if Rate!="5"&Rate!="4"&Rate!="12.5"&Rate!="1"&Rate!="0"&Rate!="2"&Rate!="20"&Rate!="0"&Rate!=""

gen d2Rate=Rate
destring d2Rate, replace
replace NetAmount=d2Rate if Rate!="5"&Rate!="4"&Rate!="12.5"&Rate!="1"&Rate!="0"&Rate!="2"&Rate!="20"&Rate!="0"&Rate!=""

tostring dRate, replace
replace Rate=dRate if Rate!="5"&Rate!="4"&Rate!="12.5"&Rate!="1"&Rate!="0"&Rate!="2"&Rate!="20"&Rate!="0"&Rate!=""

drop if Rate==""
drop dRate d2Rate

replace Rate="0" if Rate=="0.0"
replace Rate="0" if Rate=="0.00"
replace Rate="0" if Rate=="00.00"
replace Rate="1" if Rate=="0.99"
replace Rate="1" if Rate=="1.00"
replace Rate="1" if Rate=="0.01"
replace Rate="1" if Rate=="1.000"
replace Rate="2" if Rate=="2.00"
replace Rate="2" if Rate=="0.02"
replace Rate="12.5" if Rate=="12.49"
replace Rate="12.5" if Rate=="12.00"
replace Rate="12.5" if Rate=="12.50"
replace Rate="12.5" if Rate=="12.500"
replace Rate="12.5" if Rate=="12.5000"
replace Rate="12.5" if Rate=="125.00"
replace Rate="12.5" if Rate==".12"
replace Rate="20" if Rate=="20.00"
replace Rate="20" if Rate=="20.0"
replace Rate="5" if Rate=="0.05"
replace Rate="5" if Rate==".05"
replace Rate="5" if Rate=="5.0"
replace Rate="5" if Rate=="5.00"
replace Rate="5" if Rate=="5.000"
replace Rate="5" if Rate=="5.0000"
replace Rate="5" if Rate=="05.00"
replace Rate="5" if Rate=="4.99"
replace Rate="4" if Rate=="4.00"
replace Rate="4" if Rate=="0.04"
replace Rate="10" if Rate=="0.10"
replace Rate="10" if Rate=="10.00"
replace Rate="12.5" if Rate=="0.12"

keep if Rate=="5"|Rate=="4"|Rate=="12.5"|Rate=="1"|Rate=="0"|Rate=="2"|Rate=="20"|Rate=="0"

replace TransactionType="GD" if TransactionType=="GD "
replace TransactionType="GD" if TransactionType=="GD  "
replace TransactionType="GD" if TransactionType=="GD    "
replace TransactionType="GD" if TransactionType=="GD     "
replace TransactionType="GD" if TransactionType=="GD             "
replace TransactionType="GD" if TransactionType=="Gd"
replace TransactionType="GD" if TransactionType=="gd"
replace TransactionType="GD" if TransactionType=="gd "
replace TransactionType="GD" if TransactionType==" GD"

replace TransactionType="WC" if TransactionType=="wc"
replace TransactionType="WC" if TransactionType=="Wc"

***** temp ******
save "${temp_path1}/networkfeatures_2a2b.dta", replace
use "${temp_path1}/networkfeatures_2a2b.dta", clear
***** temp ******
replace TransactionType=trim(TransactionType)

drop if TransactionType==""
drop if Mtin == ""

*Cleaning 2a2b files
drop TaxPeriod
rename OriginalTaxPeriod TaxPeriod
rename Tax TaxAmount
rename Total TotalAmount

bys TaxPeriod Mtin SellerBuyerTin: gen TotalCount=_N
by TaxPeriod Mtin SellerBuyerTin: egen TotalTaxAmount= sum(TaxAmount)
by TaxPeriod Mtin SellerBuyerTin: egen SumTotalAmount= sum(TotalAmount)
by TaxPeriod Mtin SellerBuyerTin: gen Count2=_n
keep if Count2==1

isid TaxPeriod Mtin SellerBuyerTin

rename TotalTaxAmount PurchaseTaxAmount
rename SumTotalAmount TotalPurchaseAmount

*drop TransactionType DealerGoodType SalePurchaseType  Count2 T985DF3 T985DF2 T985DF1 AEBoolean TaxRate Date ReceiptId DateTime Year DealerName TotalAmount TaxAmount Month Amount
*drop FormsStatus T985DF4 T985DF5 T985DF6 T985DF7 T985DF8 Rate SaleOrPurchase
drop TransactionType DealerGoodType SalePurchaseType Count2 Date var12 var14  TaxYear CommodityName CommodityCode TotalAmount TaxAmount NetAmount Form_Status 
	
gen TaxMonth=25 if TaxPeriod=="apr 2012"
replace TaxMonth=26 if TaxPeriod=="may 2012"
replace TaxMonth=27 if TaxPeriod=="jun 2012"
replace TaxMonth=28 if TaxPeriod=="jul 2012"
replace TaxMonth=29 if TaxPeriod=="aug 2012"
replace TaxMonth=30 if TaxPeriod=="sep 2012"
replace TaxMonth=31 if TaxPeriod=="oct 2012"
replace TaxMonth=32 if TaxPeriod=="nov 2012"
replace TaxMonth=33 if TaxPeriod=="dec 2012"
replace TaxMonth=34 if TaxPeriod=="jan 2013"
replace TaxMonth=35 if TaxPeriod=="feb 2013"
replace TaxMonth=36 if TaxPeriod=="mar 2013"

gen TaxQuarter=0
replace TaxQuarter=9 if TaxMonth>24&TaxMonth<=27
replace TaxQuarter=10 if TaxMonth>27&TaxMonth<=30
replace TaxQuarter=11 if TaxMonth>30&TaxMonth<=33
replace TaxQuarter=12 if TaxMonth>33&TaxMonth<=36

gsort TaxQuarter Mtin SellerBuyerTin TaxMonth
bys TaxQuarter Mtin SellerBuyerTin: egen Count=sum(TotalCount)
by TaxQuarter Mtin SellerBuyerTin: egen TotalTaxAmount= sum(PurchaseTaxAmount)
by TaxQuarter Mtin SellerBuyerTin: egen SumTotalAmount= sum(TotalPurchaseAmount)
by TaxQuarter Mtin SellerBuyerTin: gen Count2=_n
keep if Count2==1

isid TaxQuarter Mtin SellerBuyerTin 

drop PurchaseTaxAmount TotalPurchaseAmount TotalCount Count2 TaxMonth TaxPeriod
drop SaleOrPurchase Rate MReturn_ID 
rename TotalTaxAmount PurchaseTaxAmount
rename SumTotalAmount TotalPurchaseAmount
rename Count TotalCountPurchaseTransactions

save "${features_path}\PurchaseTaxAmount_2012.dta", replace

*--------------------------------------------------------
** Quarterly 2a2b Sale form for 2013, 2014, 2015, 2016
*--------------------------------------------------------

foreach var1 in 2015 2016{
foreach var2 in q1 q2 q3 q4{

use "${output_path}/2a2b_`var1'_`var2'.dta", clear


//use "annexure_2A2B_quarterly_2013.dta", clear
//use "annexure_2A2B_quarterly_2014.dta", clear
*use "${output_path}/2a2b_quarterly_2013.dta", clear
*use "${output_path}/2a2b_quarterly_2014.dta", clear

keep if SaleOrPurchase=="BF"
keep if SalePurchaseType=="LS"


replace DealerGoodType="OT" if DealerGoodType==" OT"
replace DealerGoodType="OT" if DealerGoodType=="OT             "
replace DealerGoodType="OT" if DealerGoodType=="OT     "
replace DealerGoodType="OT" if DealerGoodType=="OT "
replace DealerGoodType="OT" if DealerGoodType=="OT  "
replace DealerGoodType="OT" if DealerGoodType=="Ot"
replace DealerGoodType="OT" if DealerGoodType=="ot"
replace DealerGoodType="OT" if DealerGoodType=="ot "
replace DealerGoodType="OT" if DealerGoodType=="OT  "

replace DealerGoodType="UD" if DealerGoodType=="uD"
replace DealerGoodType="UD" if DealerGoodType=="ud"
tab DealerGoodType

replace TransactionType=trim(TransactionType)
replace TransactionType="GD" if TransactionType=="GD "
replace TransactionType="GD" if TransactionType=="GD  "
replace TransactionType="GD" if TransactionType=="GD    "
replace TransactionType="GD" if TransactionType=="GD     "
replace TransactionType="GD" if TransactionType=="GD             "
replace TransactionType="GD" if TransactionType=="Gd"
replace TransactionType="GD" if TransactionType=="gd"
replace TransactionType="GD" if TransactionType=="gd "

replace TransactionType="WC" if TransactionType=="wc"
replace TransactionType="WC" if TransactionType=="Wc"
tab TransactionType

replace TransactionType=trim(TransactionType)
keep if DealerGoodType=="RD"

replace Rate=trim(Rate)

replace Rate="0" if Rate=="0.0"
replace Rate="0" if Rate=="0.00"
replace Rate="0" if Rate=="00.00"
replace Rate="1" if Rate=="1.00"
replace Rate="1" if Rate=="1.000"
replace Rate="2" if Rate=="2.00"
replace Rate="12.5" if Rate=="12.50"
replace Rate="12.5" if Rate=="12.500"
replace Rate="12.5" if Rate=="12.5000"
replace Rate="20" if Rate=="20.00"
replace Rate="20" if Rate=="20.0"
replace Rate="5" if Rate=="5.0"
replace Rate="5" if Rate=="5.00"
replace Rate="5" if Rate=="5.000"
replace Rate="5" if Rate=="05.00"
replace Rate="5" if Rate=="4.99"
replace Rate="4" if Rate=="4.00"
tab Rate

drop if Mtin ==""
drop if SellerBuyerTin==""

rename NetAmount Amount
rename Tax TaxAmount
rename Total TotalAmount

bys TaxPeriod Mtin SellerBuyerTin: gen TotalCount=_N
by TaxPeriod Mtin SellerBuyerTin: egen TotalTaxAmount= sum(TaxAmount)
by TaxPeriod Mtin SellerBuyerTin: gen Count=_n
by TaxPeriod Mtin SellerBuyerTin: egen SumTotalAmount= sum(TotalAmount)

keep if Count==1

isid TaxPeriod Mtin SellerBuyerTin 
drop TransactionType DealerGoodType SalePurchaseType CommodityName CommodityCode ///
 Count Rate Date MReturn_ID SaleOrPurchase var12 var14 Form_Status

rename TotalTaxAmount SalesTaxAmount
rename SumTotalAmount TotalSalesAmount
rename TotalCount TotalCountSaleTransactions

gen TaxQuarter =0
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
tab TaxQuarter

drop TaxPeriod OriginalTaxPeriod

//save "${features_path}\SalesTaxAmount2013.dta", replace
//save "${features_path}\SalesTaxAmount2014.dta", replace
save "${features_path}\SalesTaxAmount_`var1'_`var2'.dta", replace
}
}


use "${features_path}/SalesTaxAmount_2012.dta", clear
append using "${features_path}/SalesTaxAmount_2013.dta"
append using "${features_path}/SalesTaxAmount_2014.dta"
append using "${features_path}/SalesTaxAmount_2015_q1.dta"
append using "${features_path}/SalesTaxAmount_2015_q2.dta"
append using "${features_path}/SalesTaxAmount_2015_q3.dta"
append using "${features_path}/SalesTaxAmount_2015_q4.dta"
append using "${features_path}/SalesTaxAmount_2016_q1.dta"
append using "${features_path}/SalesTaxAmount_2016_q2.dta"
append using "${features_path}/SalesTaxAmount_2016_q3.dta"
append using "${features_path}/SalesTaxAmount_2016_q4.dta"

save "${features_path}/SalesTaxAmount_AllQuarters.dta", replace

*Dropping unnecessary variables 
use "${features_path}/SalesTaxAmount_AllQuarters.dta", clear
drop Amount TaxAmount TotalAmount TaxYear
save "${features_path}/SalesTaxAmount_AllQuarters.dta", replace

*Dropping repetitions from the dataset 
duplicates tag TaxQuarter Mtin SellerBuyerTin, gen(repeat1)

/*
    repeat1 |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 | 28,120,759      100.00      100.00
          1 |          2        0.00      100.00
------------+-----------------------------------
      Total | 28,120,761      100.00
*/

drop if repeat1 == 1 
drop repeat1
save "${features_path}/SalesTaxAmount_AllQuarters.dta", replace

*--------------------------------------------------------
** Quarterly 2a2b Purchase form
*--------------------------------------------------------

foreach var1 in 2015 2016{
foreach var2 in q1 q2 q3 q4{

use "${output_path}/2a2b_`var1'_`var2'.dta", clear

*use "${output_path}/2a2b_quarterly_2013.dta", clear
*use "${output_path}/2a2b_quarterly_2014.dta", clear

keep if SaleOrPurchase=="AE"
keep if SalePurchaseType=="CG"|SalePurchaseType=="OT"|DealerGoodType=="CG"|DealerGoodType=="OT"

replace TransactionType=trim(TransactionType)
replace TransactionType="GD" if TransactionType=="GD "
replace TransactionType="GD" if TransactionType=="GD  "
replace TransactionType="GD" if TransactionType=="GD    "
replace TransactionType="GD" if TransactionType=="GD     "
replace TransactionType="GD" if TransactionType=="GD             "
replace TransactionType="GD" if TransactionType=="Gd"
replace TransactionType="GD" if TransactionType=="gd"
replace TransactionType="GD" if TransactionType=="gd "
replace TransactionType="GD" if TransactionType=="gD"

replace TransactionType="WC" if TransactionType=="wc"
replace TransactionType="WC" if TransactionType=="Wc"
tab TransactionType

replace Rate=trim(Rate)
replace Rate="0" if Rate=="0.0"
replace Rate="0" if Rate=="0.00"
replace Rate="0" if Rate=="00.00"
replace Rate="1" if Rate=="1.00"
replace Rate="1" if Rate=="1.000"
replace Rate="2" if Rate=="2.00"
replace Rate="12.5" if Rate=="12.50"
replace Rate="12.5" if Rate=="12.500"
replace Rate="12.5" if Rate=="12.5000"
replace Rate="20" if Rate=="20.00"
replace Rate="20" if Rate=="20.0"
replace Rate="5" if Rate=="5.0"
replace Rate="5" if Rate=="5.00"
replace Rate="5" if Rate=="5.000"
replace Rate="5" if Rate=="5.0000"
replace Rate="5" if Rate=="05.00"
replace Rate="4" if Rate=="4.00"
tab Rate

drop if Rate=="13.13"|Rate=="14"
drop if SellerBuyerTin==""
drop if Mtin ==""

rename NetAmount Amount
rename Tax TaxAmount
rename Total TotalAmount

bys TaxPeriod Mtin SellerBuyerTin:gen TransActionCount=_N
*by TaxPeriod Mtin SellerBuyerTin:egen SumAmount=sum(Amount)
by TaxPeriod Mtin SellerBuyerTin:egen TotalTaxAmount=sum(TaxAmount)
by TaxPeriod Mtin SellerBuyerTin:egen SumTotalAmount=sum(TotalAmount)
by TaxPeriod Mtin SellerBuyerTin:gen Count2=_n

keep if Count2==1

isid TaxPeriod Mtin SellerBuyerTin 
drop TransactionType DealerGoodType SalePurchaseType Count2 Date var12 var14  TaxYear CommodityName CommodityCode TotalAmount TaxAmount Amount Form_Status 

rename TotalTaxAmount PurchaseTaxAmount
rename SumTotalAmount TotalPurchaseAmount
rename TransActionCount TotalCountPurchaseTransactions

gen TaxQuarter =0
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
tab TaxQuarter

drop TaxPeriod Rate SaleOrPurchase
drop MReturn_ID OriginalTaxPeriod

*save "${features_path}\PurchaseTaxAmount_2013.dta", replace
*save "${features_path}\PurchaseTaxAmount_2014.dta", replace

save "${features_path}\PurchaseTaxAmount_`var1'_`var2'.dta", replace
}
}

use "${features_path}/PurchaseTaxAmount_2012.dta", clear
append using "${features_path}/PurchaseTaxAmount_2013.dta"
append using "${features_path}/PurchaseTaxAmount_2014.dta"
append using "${features_path}/PurchaseTaxAmount_2015_q1.dta"
append using "${features_path}/PurchaseTaxAmount_2015_q2.dta"
append using "${features_path}/PurchaseTaxAmount_2015_q3.dta"
append using "${features_path}/PurchaseTaxAmount_2015_q4.dta"
append using "${features_path}/PurchaseTaxAmount_2016_q1.dta"
append using "${features_path}/PurchaseTaxAmount_2016_q2.dta"
append using "${features_path}/PurchaseTaxAmount_2016_q3.dta"
append using "${features_path}/PurchaseTaxAmount_2016_q4.dta"

save "${features_path}/PurchaseTaxAmount_AllQuarters.dta", replace






