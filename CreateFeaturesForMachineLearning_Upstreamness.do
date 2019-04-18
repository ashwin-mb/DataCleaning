/************************************************* 
* Filename: 
* Input: H:/Ashwin/dta/DP_forms.dta
* Purpose: Creates input files for Network features  
* Output: 
			
* Author: Ashwin MB
* Date: 28/11/2018
* Last modified: 10/12/2018 (Ashwin)
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
** Creates downstream purchases
*--------------------------------------------------------
use "${features_path}/PurchaseTaxAmount_AllQuarters.dta", clear
drop TotalCountPurchaseTransactions TotalPurchaseAmount

rename Mtin x
rename SellerBuyerTin Mtin
rename x SellerBuyerTin

merge m:1 TaxQuarter Mtin  using "${features_path}/FeatureReturns.dta", keepusing(UnTaxProp CreditRatio VatRatio) generate(returns_merge)  keep(master match) 

rename Mtin x
rename SellerBuyerTin Mtin
rename x SellerBuyerTin

replace UnTaxProp=0 if UnTaxProp==.
replace CreditRatio=0 if CreditRatio==.
replace VatRatio=0 if VatRatio==.

gen WUnTaxProp=PurchaseTaxAmount*UnTaxProp
gen WCreditRatio=PurchaseTaxAmount*CreditRatio
gen WVatRatio=PurchaseTaxAmount*VatRatio

gsort TaxQuarter Mtin
by TaxQuarter Mtin: gen TotalSellers=_N
by TaxQuarter Mtin: egen MaxPurchaseTaxAmount=max(PurchaseTaxAmount)
by TaxQuarter Mtin: egen TotalPurchaseTaxAmount=sum(PurchaseTaxAmount)
by TaxQuarter Mtin: egen SumWUnTaxProp=sum(WUnTaxProp)
by TaxQuarter Mtin: egen SumWCreditRatio=sum(WCreditRatio)
by TaxQuarter Mtin: egen SumWVatRatio=sum(WVatRatio)
by TaxQuarter Mtin: gen Count=_n

keep if Count==1

gen MaxPurchaseProp=MaxPurchaseTaxAmount/TotalPurchaseTaxAmount
gen PurchaseDSUnTaxProp=SumWUnTaxProp/TotalPurchaseTaxAmount
gen PurchaseDSCreditRatio=SumWCreditRatio/TotalPurchaseTaxAmount
gen PurchaseDSVatRatio=SumWVatRatio/TotalPurchaseTaxAmount

gen Missing_PurchaseDSUnTaxProp=0
gen Missing_PurchaseDSCreditRatio=0
gen Missing_PurchaseDSVatRatio=0
gen Missing_MaxPurchaseProp=0

replace Missing_PurchaseDSUnTaxProp=1 if PurchaseDSUnTaxProp==.
replace Missing_PurchaseDSCreditRatio=1 if PurchaseDSCreditRatio==.
replace Missing_PurchaseDSVatRatio=1 if PurchaseDSVatRatio==.
replace Missing_MaxPurchaseProp=1 if MaxPurchaseProp==.

replace PurchaseDSUnTaxProp=0 if PurchaseDSUnTaxProp==.
replace PurchaseDSCreditRatio=0 if PurchaseDSCreditRatio==.
replace PurchaseDSVatRatio=0 if PurchaseDSVatRatio==.
replace MaxPurchaseProp=0 if MaxPurchaseProp==.

drop VatRatio CreditRatio SellerBuyerTin UnTaxProp returns_merge WUnTaxProp WCreditRatio WVatRatio SumWUnTaxProp TotalPurchaseTaxAmount SumWCreditRatio SumWVatRatio Count PurchaseTaxAmount MaxPurchaseTaxAmount
save "${features_path}/FeatureDownStreamnessPurchases.dta", replace

*--------------------------------------------------------
** Creates downstream sales
*--------------------------------------------------------

use "${features_path}/SalesTaxAmount_AllQuarters.dta", clear

drop TotalCountSaleTransactions TotalSalesAmount

rename Mtin x
rename SellerBuyerTin Mtin
rename x SellerBuyerTin

merge m:1 TaxQuarter Mtin  using "${features_path}/FeatureReturns.dta", keepusing(UnTaxProp CreditRatio VatRatio) generate(returns_merge)  keep(master match) 

rename Mtin x
rename SellerBuyerTin Mtin
rename x SellerBuyerTin

replace UnTaxProp=0 if UnTaxProp==.
replace CreditRatio=0 if CreditRatio==.
replace VatRatio=0 if VatRatio==.

gen WUnTaxProp=SalesTaxAmount*UnTaxProp
gen WCreditRatio=SalesTaxAmount*CreditRatio
gen WVatRatio=SalesTaxAmount*VatRatio

gsort TaxQuarter Mtin
by TaxQuarter Mtin: gen TotalBuyers=_N
by TaxQuarter Mtin: egen TotalSalesTaxAmount=sum(SalesTaxAmount)
by TaxQuarter Mtin: egen MaxSalesTaxAmount=max(SalesTaxAmount)
by TaxQuarter Mtin: egen SumWUnTaxProp=sum(WUnTaxProp)
by TaxQuarter Mtin: egen SumWCreditRatio=sum(WCreditRatio)
by TaxQuarter Mtin: egen SumWVatRatio=sum(WVatRatio)
by TaxQuarter Mtin: gen Count=_n


keep if Count==1

gen MaxSalesProp=MaxSalesTaxAmount/TotalSalesTaxAmount
gen SalesDSUnTaxProp=SumWUnTaxProp/TotalSalesTaxAmount
gen SalesDSCreditRatio=SumWCreditRatio/TotalSalesTaxAmount
gen SalesDSVatRatio=SumWVatRatio/TotalSalesTaxAmount

gen Missing_SalesDSUnTaxProp=0
gen Missing_SalesDSCreditRatio=0
gen Missing_SalesDSVatRatio=0
gen Missing_MaxSalesProp=0

replace Missing_SalesDSUnTaxProp=1 if SalesDSUnTaxProp==.
replace Missing_SalesDSCreditRatio=1 if SalesDSCreditRatio==.
replace Missing_SalesDSVatRatio=1 if SalesDSVatRatio==.
replace Missing_MaxSalesProp=1 if MaxSalesProp==.

replace SalesDSUnTaxProp=0 if SalesDSUnTaxProp==.
replace SalesDSCreditRatio=0 if SalesDSCreditRatio==.
replace SalesDSVatRatio=0 if SalesDSVatRatio==.
replace MaxSalesProp=0 if MaxSalesProp==.

drop VatRatio CreditRatio SellerBuyerTin UnTaxProp returns_merge WUnTaxProp WCreditRatio WVatRatio SumWUnTaxProp TotalSalesTaxAmount SumWCreditRatio SumWVatRatio Count SalesTaxAmount MaxSalesTaxAmount

save "${features_path}/FeatureDownStreamnessSales.dta", replace

