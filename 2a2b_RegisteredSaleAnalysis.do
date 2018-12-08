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
global features_path "H:/Ashwin/dta/BogusDealers"
global output_path "H:/Ashwin/dta/final"
global qc_path "H:/Ashwin/dta/qc"
global prob_path "H:/Ashwin/dta/prob"
global sample_path "H:/Ashwin/dta/sample"

*--------------------------------------------------------
** Cleaning variables
*--------------------------------------------------------
foreach var1 in q1 q2 q3 q4{
use "${output_path}/2a2b_2016_`var1'.dta", clear
//use "${output_path}/2a2b_2015_`var1'.dta", clear
//use "annexure_2A2B_quarterly_2014.dta", clear
//use "annexure_2A2B_quarterly_2013.dta", clear

//Keep if sales and that too only local
keep if SaleOrPurchase=="BF"&SalePurchaseType=="LS"
keep if DealerGoodType=="RD"|DealerGoodType=="UD"
drop if Mtin == ""


//Fix all the transaction type
replace TransactionType=trim(TransactionType)
replace TransactionType="GD" if TransactionType=="GD "
replace TransactionType="GD" if TransactionType=="GD  "
replace TransactionType="GD" if TransactionType=="GD    "
replace TransactionType="GD" if TransactionType=="GD     "
replace TransactionType="GD" if TransactionType=="GD             "
replace TransactionType="GD" if TransactionType=="Gd"
replace TransactionType="GD" if TransactionType=="gd"
replace TransactionType="GD" if TransactionType=="gD"
replace TransactionType="GD" if TransactionType=="gd "
replace TransactionType="WC" if TransactionType=="wc"
replace TransactionType="WC" if TransactionType=="Wc"
tab TransactionType
//Clean all the tax rates 
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
replace Rate="4" if Rate=="4.00"
replace Rate="12.5" if Rate=="12.00"
replace Rate="12.5" if Rate=="0.12"
replace Rate="1" if Rate=="0.01"
replace Rate="5" if Rate=="0.05"
replace Rate="20" if Rate=="0.20"
replace Rate="2" if Rate=="0.02"
tab Rate


//bys SourceFile TransactionType Mtin SellerBuyerTIN Rate Amount TaxAmount: gen Count=_n
//keep if Count==1
//drop Count

//Set TaxQuarters in which the transaction was made based on the SourceFile
gen TaxQuarter=0
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

rename NetAmount Amount
rename Tax TaxAmount
rename Total TotalAmount

//isid TaxQuarter Mtin DealerGoodType

bys TaxQuarter Mtin DealerGoodType:gen TransActionCount=_N
by TaxQuarter Mtin DealerGoodType:egen SumAmount=sum(Amount)
by TaxQuarter Mtin DealerGoodType:egen SumTaxAmount=sum(TaxAmount)
by TaxQuarter Mtin DealerGoodType:egen SumTotalAmount=sum(TotalAmount)
by TaxQuarter Mtin DealerGoodType:gen Count=_n
keep if Count==1

bys TaxQuarter Mtin: egen OverallTaxAmount=sum(SumTaxAmount)
gen TaxProp=SumTaxAmount/OverallTaxAmount

gen RegisteredSalesTax=SumTaxAmount if DealerGoodType=="RD"
bys TaxQuarter Mtin: replace RegisteredSalesTax=RegisteredSalesTax[_n-1] if RegisteredSalesTax>=.

gen UnregisteredSalesTax=SumTaxAmount if DealerGoodType=="UD"
gsort TaxQuarter Mtin -DealerGoodType
by TaxQuarter Mtin: replace UnregisteredSalesTax=UnregisteredSalesTax[_n-1] if UnregisteredSalesTax>=.

replace UnregisteredSalesTax=0 if UnregisteredSalesTax==.
replace RegisteredSalesTax=0 if RegisteredSalesTax==.

drop Count
bys TaxQuarter Mtin: gen Count=_n
keep if Count==1

drop SaleOrPurchase SalePurchaseType DealerGoodType TransactionType Rate ///
 Amount TaxAmount TotalAmount SellerBuyerTin TransActionCount SumAmount ///
 SumTaxAmount SumTotalAmount Count var12 var14 TaxPeriod TaxYear Date ///
 Form_Status CommodityName CommodityCode MReturn_ID

save "${features_path}\RegisteredSales_2016_`var1'.dta" //change year
}

use "${features_path}\RegisteredSales_AllQuarters.dta", clear

foreach var1 in 2015 2016{
foreach var2 in q1 q2 q3 q4{
append using "${features_path}\RegisteredSales_`var1'_`var2'.dta"
save "${features_path}\RegisteredSales_AllQuarters.dta", replace
}
}

//Repeating the process for the year 2012

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
replace DealerGoodType="OT" if DealerGoodType=="OTHERS"

replace DealerGoodType="UD" if DealerGoodType=="uD"
replace DealerGoodType="UD" if DealerGoodType=="ud"
replace DealerGoodType="UD" if DealerGoodType=="UNREGISTER DEA"
replace DealerGoodType="UD" if DealerGoodType=="UNREGISTERED D"
replace DealerGoodType="UD" if DealerGoodType=="UNREGISTERED"
replace DealerGoodType="UD" if DealerGoodType=="Unregistered Dea"
replace DealerGoodType="UD" if DealerGoodType=="Unregistered De"
replace DealerGoodType="UD" if DealerGoodType=="Unregister Dea"
replace DealerGoodType="UD" if DealerGoodType=="Unregisterd De"
replace DealerGoodType="UD" if DealerGoodType=="unregistered d"
replace DealerGoodType="UD" if DealerGoodType=="Unregistered D"
replace DealerGoodType="UD" if DealerGoodType=="Unregistered d"

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


replace TransactionType=trim(TransactionType)
replace DealerGoodType=trim(DealerGoodType)

keep if DealerGoodType=="RD"|DealerGoodType=="OT"|DealerGoodType=="CG"|DealerGoodType=="UD"


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

destring Rate, replace
drop if Rate>100
tostring Rate, replace

drop if Rate=="3"
drop if Rate=="2.50"
drop if SellerBuyerTin=="NA"|SellerBuyerTin==""
drop var12 var14 Form_Status
drop if Rate==""
//drop if Rate=="10"&Mtin=="88719"
//drop if Rate=="10"&Mtin=="51456"

//bys SourceFile TransactionType Mtin SellerBuyerTIN Rate Amount TaxAmount: gen Count=_n
//keep if Count==1
//drop Count

**Ask***
drop if Rate!="5"&Rate!="4"&Rate!="12.5"&Rate!="1"&Rate!="0"&Rate!="2"&Rate!="20"&Rate!="0"
**Ask**

replace DealerGoodType="RD" if (DealerGoodType=="OT"|DealerGoodType=="CG")&SellerBuyerTin!=""
replace DealerGoodType="UD" if (DealerGoodType=="OT"|DealerGoodType=="CG")&SellerBuyerTin==""

gen TaxMonth=0
replace TaxMonth=34 if TaxPeriod==1
replace TaxMonth=35 if TaxPeriod==2
replace TaxMonth=36 if TaxPeriod==3
replace TaxMonth=25 if TaxPeriod==4
replace TaxMonth=26 if TaxPeriod==5
replace TaxMonth=27 if TaxPeriod==6
replace TaxMonth=28 if TaxPeriod==7
replace TaxMonth=29 if TaxPeriod==8
replace TaxMonth=30 if TaxPeriod==9
replace TaxMonth=31 if TaxPeriod==10
replace TaxMonth=32 if TaxPeriod==11
replace TaxMonth=33 if TaxPeriod==12

gen TaxQuarter=0
replace TaxQuarter=9 if TaxMonth>24&TaxMonth<=27
replace TaxQuarter=10 if TaxMonth>27&TaxMonth<=30
replace TaxQuarter=11 if TaxMonth>30&TaxMonth<=33
replace TaxQuarter=12 if TaxMonth>33&TaxMonth<=36

rename NetAmount Amount
rename Tax TaxAmount
rename Total TotalAmount

bys TaxQuarter Mtin DealerGoodType:gen TransActionCount=_N
by TaxQuarter Mtin DealerGoodType:egen SumAmount=sum(Amount)
by TaxQuarter Mtin DealerGoodType:egen SumTaxAmount=sum(TaxAmount)
by TaxQuarter Mtin DealerGoodType:egen SumTotalAmount=sum(TotalAmount)
by TaxQuarter Mtin DealerGoodType:gen Count=_n
keep if Count==1

bys TaxQuarter Mtin: egen OverallTaxAmount=sum(SumTaxAmount)

gen RegisteredSalesTax=SumTaxAmount if DealerGoodType=="RD"
bys TaxQuarter Mtin: replace RegisteredSalesTax=RegisteredSalesTax[_n-1] if RegisteredSalesTax>=.

gen UnregisteredSalesTax=SumTaxAmount if DealerGoodType=="UD"
gsort TaxQuarter Mtin -DealerGoodType
by TaxQuarter Mtin: replace UnregisteredSalesTax=UnregisteredSalesTax[_n-1] if UnregisteredSalesTax>=.

replace UnregisteredSalesTax=0 if UnregisteredSalesTax==.
replace RegisteredSalesTax=0 if RegisteredSalesTax==.

drop Count
bys TaxQuarter Mtin: gen Count=_n
keep if Count==1
drop if Mtin ==""

drop SaleOrPurchase SalePurchaseType DealerGoodType TransactionType Rate ///
 Amount TaxAmount TotalAmount SellerBuyerTin TransActionCount SumAmount ///
 SumTaxAmount SumTotalAmount Count TaxPeriod TaxYear Date ///
  CommodityName CommodityCode MReturn_ID TaxMonth
 
save "${features_path}\RegisteredSales_2012.dta", replace

use "${features_path}\RegisteredSales_AllQuarters.dta", clear
append using "${features_path}\RegisteredSales_2012.dta"
save "${features_path}\RegisteredSales_AllQuarters.dta", replace

//keep if TransactionType=="GD"|TransactionType=="WC"|TransactionType==""

merge m:1 Mtin using "E:\data\DataVerification\step3\DealerProfile_uniqueTin.dta", keepusing(Nature Constitution RegistrationType RegistrationDate SubmissionDate Ward BooleanInterState Boolean201011 Boolean201112 Boolean201213 BooleanThirdPartyStorage BooleanSurveyFilled GTONil201213 PhysicalWard BooleanRegisteredIEC BooleanRegisteredCE BooleanServiceTax)
keep if _merge==1|_merge==3

gen DummyRetailer = 0
gen DummyManufacturer = 0
gen DummyWholeSaler = 0 
gen DummyInterStateSeller = 0 
gen DummyInterStatePurchaser = 0
gen DummyWorkContractor = 0
gen DummyImporter = 0
gen DummyExporter = 0 
gen DummyOther = 0
gen DummyHotel=0
gen DummyECommerce=0


replace DummyManufacturer = 1 if(regexm(Nature, "Manufacturer"))
replace DummyManufacturer = 1 if(regexm(Nature, "Manufecturer"))
replace DummyManufacturer = 1 if(regexm(Nature, "Manufacturing"))
replace DummyManufacturer = 1 if(regexm(Nature, "MANUFACTURER"))

replace DummyRetailer = 1 if(regexm(Nature, "Retail Trader"))
replace DummyRetailer = 1 if(regexm(Nature, "Retailer"))
replace DummyRetailer = 1 if(regexm(Nature, "RETAILER"))
replace DummyRetailer = 1 if(regexm(Nature, "RETAIL SALE"))
replace DummyRetailer = 1 if(regexm(Nature, "RETAIL TRADER"))


replace DummyWholeSaler = 1 if(regexm(Nature, "Wholesale Trader"))
replace DummyWholeSaler = 1 if(regexm(Nature, "Wholesaler"))
replace DummyWholeSaler = 1 if(regexm(Nature, "WHOLESALER"))
replace DummyWholeSaler = 1 if(regexm(Nature, "WHOLESALE DEALER"))
replace DummyWholeSaler = 1 if(regexm(Nature, "WHOLESELLER"))
replace DummyWholeSaler = 1 if(regexm(Nature, "wholeseller"))
replace DummyWholeSaler = 1 if(regexm(Nature, "wholesaler"))


replace DummyInterStateSeller = 1 if(regexm(Nature, "Interstate Seller"))
replace DummyInterStateSeller = 1 if(regexm(Nature, "INTERSTATE PURCHASER AND SELLER"))
replace DummyInterStateSeller = 1 if(regexm(Nature, "INTERSTATE SALE/PURCHASE"))
replace DummyInterStateSeller = 1 if(regexm(Nature, "INTERSTATE SELLER AND PURCHASER"))
replace DummyInterStateSeller = 1 if(regexm(Nature, "INTERSTATE SELLER"))
replace DummyInterStateSeller = 1 if(regexm(Nature, "Inter State Seller"))

replace DummyInterStatePurchaser = 1 if(regexm(Nature, "Interstate Purchaser"))
replace DummyInterStatePurchaser = 1 if(regexm(Nature, "INTERSTATE SALE/PURCHASE"))
replace DummyInterStatePurchaser = 1 if(regexm(Nature, "INTERSTATE SELLER AND PURCHASER"))
replace DummyInterStatePurchaser = 1 if(regexm(Nature, "INTERSTATE PURCHASER"))
replace DummyInterStatePurchaser = 1 if(regexm(Nature, "INTERSTATE PURCHASER AND SELLER"))
replace DummyInterStatePurchaser = 1 if(regexm(Nature, "Inter State Purchaser"))



replace DummyWorkContractor = 1 if(regexm(Nature, "Work Contractor"))
replace DummyWorkContractor = 1 if(regexm(Nature, "WORK CONTRACTOR"))
replace DummyWorkContractor = 1 if(regexm(Nature, "WORKCONTRACT"))
replace DummyWorkContractor = 1 if(regexm(Nature, "WORK CONTRACT"))
replace DummyWorkContractor = 1 if(regexm(Nature, "CONTRACTOR"))
replace DummyWorkContractor = 1 if(regexm(Nature, "Contractor"))

replace DummyOther = 1 if(regexm(Nature, "Other"))
replace DummyOther = 1 if(regexm(Nature, "OTHER"))

replace DummyImporter = 1 if(regexm(Nature, "Importer"))
replace DummyImporter = 1 if(regexm(Nature, "IMPORTER/EXPORTER"))
replace DummyImporter = 1 if(regexm(Nature, "IMPORTER"))

replace DummyExporter = 1 if(regexm(Nature, "Exporter"))
replace DummyExporter = 1 if(regexm(Nature, "EXPORTER"))

replace DummyHotel = 1 if(regexm(Nature, "Restaurent"))
replace DummyHotel = 1 if(regexm(Nature, "RESTURANT"))
replace DummyHotel = 1 if(regexm(Nature, "HOTEL"))
replace DummyHotel = 1 if(regexm(Nature, "RESTAURENT"))
replace DummyHotel = 1 if(regexm(Nature, "RESTAURANT"))
replace DummyHotel = 1 if(regexm(Nature, "RESTURENT"))
replace DummyHotel = 1 if(regexm(Nature, "CATERING"))
replace DummyHotel = 1 if(regexm(Nature, "Restaurant"))
replace DummyHotel = 1 if(regexm(Nature, "HOTELS"))
replace DummyHotel = 1 if(regexm(Nature, "CANTEENS"))
replace DummyHotel = 1 if(regexm(Nature, "Banquet"))
replace DummyHotel = 1 if(regexm(Nature, "Catering"))
replace DummyHotel = 1 if(regexm(Nature, "BANQUET"))
replace DummyHotel = 1 if(regexm(Nature, "Banquet"))
replace DummyHotel = 1 if(regexm(Nature, "RESTURAENT"))
replace DummyHotel = 1 if(regexm(Nature, "COFFEE SHOP"))
replace DummyHotel = 1 if(regexm(Nature, "RESTURAENT"))
replace DummyHotel = 1 if(regexm(Nature, "hotel industry"))
replace DummyHotel = 1 if(regexm(Nature, "CATERERS"))

replace DummyECommerce = 1 if(regexm(Nature, "E COMMERCE"))
replace DummyECommerce = 1 if(regexm(Nature, "Online Seller"))
replace DummyECommerce = 1 if(regexm(Nature, "Online Trading"))
replace DummyECommerce = 1 if(regexm(Nature, "ONLINE TRADING"))
replace DummyECommerce = 1 if(regexm(Nature, "E Commerce"))
replace DummyECommerce = 1 if(regexm(Nature, "Ecommerce"))
replace DummyECommerce = 1 if(regexm(Nature, "Website Retailing"))
replace DummyECommerce = 1 if(regexm(Nature, "E Commerece"))
replace DummyECommerce = 1 if(regexm(Nature, "ECOMMERCE"))
replace DummyECommerce = 1 if(regexm(Nature, "ONLINE SHOPPING"))


gen DummyTelecom=0
replace DummyTelecom=1 if (regexm(Nature, "Telecom"))
replace DummyTelecom=1 if (regexm(Nature, "TELECOM"))
replace DummyTelecom=1 if (regexm(Nature, "DTH SERVICE"))
replace DummyTelecom=1 if (regexm(Nature, "Internet Service Provider"))



gen Government=.
replace Government=1 if Constitution=="Government Company"
replace Government=1 if Constitution=="Government Corporation"
replace Government=1 if Constitution=="Government Department"
replace Government=1 if Constitution=="Public Sector UnderTaking"


replace Government=0 if Constitution=="HUF"
replace Government=0 if Constitution=="Partnership"
replace Government=0 if Constitution=="Private Ltd. Company"
replace Government=0 if Constitution=="Proprietorship"

replace Government=2 if Constitution=="Public Ltd. Company"

/*
replace MoneyDeposited =MoneyDeposited/1000000
replace OutputTaxBeforeAdjustment=OutputTaxBeforeAdjustment/1000000
replace TaxCreditBeforeAdjustment=TaxCreditBeforeAdjustment/1000000
replace TurnoverGross=TurnoverGross/1000000
replace TurnoverCentral=TurnoverCentral/1000000
replace TurnoverLocal=TurnoverLocal/1000000
*/

//br if SourceFile=="t9854114"&DummyRetailer==1&DummyManufacturer==0&DummyWholeSaler==0&SaleOrPurchase=="BF"&_merge==3
keep if ((DummyRetailer==1&DummyManufacturer==0&DummyWholeSaler==0)|(DummyRetailer==0&DummyManufacturer==0&DummyWholeSaler==1))


bys TaxQuarter DummyWholeSaler: sum TaxProp if DealerGoodType=="RD", detail
bys TaxQuarter DummyWholeSaler: sum TaxProp if DealerGoodType=="UD", detail
