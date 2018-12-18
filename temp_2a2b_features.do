
//use "${output_path}/2a2b_2016_`var1'.dta", clear
//use "${output_path}/2a2b_2015_`var1'.dta", clear
//use "annexure_2A2B_quarterly_2014.dta", clear
use "${output_path}/2a2b_2016_q4.dta", clear

tab SaleOrPurchase
tab SalePurchaseType
tab DealerGoodType

//Keep if sales and that too only local
keep if SaleOrPurchase=="BF"&SalePurchaseType=="LS"
keep if DealerGoodType=="RD"|DealerGoodType=="UD"|DealerGoodType =="uD"
replace DealerGoodType ="UD" if DealerGoodType =="uD"
drop if Mtin == ""


//Fix all the transaction type
replace TransactionType=trim(TransactionType)
replace TransactionType="GD" if TransactionType=="    GD"
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
replace Rate="5" if Rate=="05"
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
replace Rate="25" if Rate=="25.00"
replace Rate="16.6" if Rate=="16.60"
replace Rate="27" if Rate=="27.00"
replace Rate="18" if Rate=="18.00"
tab Rate
