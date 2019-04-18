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
** Identifying Discrepancies
*--------------------------------------------------------

//Creating variables for sale and purchase discrepancies
//Load the purchase side edge list
use "${features_path}/PurchaseTaxAmount_AllQuarters.dta", clear

//Merge the purchase side edge list with Sale side edgelist
rename Mtin x
rename SellerBuyerTin Mtin
rename x SellerBuyerTin

merge 1:1 TaxQuarter Mtin SellerBuyerTin using "${features_path}/SalesTaxAmount_AllQuarters.dta"

//For entries which do not merge, replace the missing to zeroes
replace SalesTaxAmount=0 if SalesTaxAmount==.&_merge==1
replace PurchaseTaxAmount=0 if PurchaseTaxAmount==.&_merge==2

//Calculate the difference and the measures that we had discussed
gen DiffTaxAmount=SalesTaxAmount-PurchaseTaxAmount
gen absDiffTaxAmount=abs(DiffTaxAmount)
gen maxSalesTaxAmount=max(SalesTaxAmount,PurchaseTaxAmount)

save "${features_path}/Intermediate_SalePurchaseDiscrepancy.dta", replace

//For the sales side
use "${features_path}/Intermediate_SalePurchaseDiscrepancy.dta", clear

drop if _merge==1

bys TaxQuarter Mtin: egen diff=sum(DiffTaxAmount)
bys TaxQuarter Mtin: egen absdiff=sum(absDiffTaxAmount)
bys TaxQuarter Mtin: egen maxSalesTax=sum(maxSalesTaxAmount)
bys TaxQuarter Mtin: gen Count=_n

//The two measures that we had discussed on the sale side
gen SaleDiscrepancy=diff/maxSalesTax
gen absSaleDiscrepancy=absdiff/maxSalesTax
keep if Count==1

drop SellerBuyerTin maxSalesTaxAmount absDiffTaxAmount DiffTaxAmount TotalSalesAmount SalesTaxAmount TotalCountSaleTransactions TotalPurchaseAmount PurchaseTaxAmount TotalCountPurchaseTransactions

replace SaleDiscrepancy=0 if SaleDiscrepancy==.
replace absSaleDiscrepancy=0 if absSaleDiscrepancy==.

save "${features_path}/SaleDiscrepancy.dta", replace

//For the Purchase side
use "${features_path}/Intermediate_SalePurchaseDiscrepancy.dta", clear

drop if _merge==2

bys TaxQuarter SellerBuyerTin: egen diff=sum(DiffTaxAmount)
bys TaxQuarter SellerBuyerTin: egen absdiff=sum(absDiffTaxAmount)
bys TaxQuarter SellerBuyerTin: egen maxPurchaseTax=sum(maxSalesTaxAmount)
bys TaxQuarter SellerBuyerTin: gen Count=_n

//The two measures that we had discussed on the purchase side
gen PurchaseDiscrepancy=diff/maxPurchaseTax
gen absPurchaseDiscrepancy=absdiff/maxPurchaseTax
keep if Count==1

drop Count Mtin maxSalesTaxAmount absDiffTaxAmount DiffTaxAmount TotalSalesAmount SalesTaxAmount TotalCountSaleTransactions TotalPurchaseAmount PurchaseTaxAmount TotalCountPurchaseTransactions

replace PurchaseDiscrepancy=0 if PurchaseDiscrepancy==.
replace absPurchaseDiscrepancy=0 if absPurchaseDiscrepancy==.

rename SellerBuyerTin Mtin

save "${features_path}/PurchaseDiscrepancy.dta"

*--------------------------------------------------------
** Calculating Discrepancy Count
*--------------------------------------------------------
use "${features_path}/PurchaseTaxAmount_AllQuarters.dta", clear

rename Mtin x
rename SellerBuyerTin Mtin
rename x SellerBuyerTin

merge 1:1 TaxQuarter Mtin SellerBuyerTin using "${features_path}/SalesTaxAmount_AllQuarters.dta"

rename Mtin x
rename SellerBuyerTin Mtin
rename x SellerBuyerTin

//First we are doing these measures for the purchase side
//Creating counts and measures for different type of merges
bys TaxQuarter Mtin _merge: gen TotalCount=_N
bys TaxQuarter Mtin _merge: gen Count=_n
bys TaxQuarter Mtin _merge: egen TotalPurchaseTaxAmount=sum(PurchaseTaxAmount)
bys TaxQuarter Mtin _merge: egen TotalSalesTaxAmount=sum(SalesTaxAmount)

replace TotalSalesTaxAmount=0 if TotalSalesTaxAmount==.&_merge==1
replace TotalPurchaseTaxAmount=0 if TotalPurchaseTaxAmount==.&_merge==2

keep if Count==1

bys TaxQuarter Mtin: gen OtherDeclarationCount=TotalCount if _merge==2
bys TaxQuarter Mtin: gen MyDeclarationCount=TotalCount if _merge==1
bys TaxQuarter Mtin: gen MatchDeclarationCount=TotalCount if _merge==3

bys TaxQuarter Mtin: gen OtherDeclarationTax=TotalSalesTaxAmount if _merge==2
bys TaxQuarter Mtin: gen MyDeclarationTax=TotalPurchaseTaxAmount if _merge==1
bys TaxQuarter Mtin: gen MatchDeclarationTax=TotalPurchaseTaxAmount if _merge==3

gsort TaxQuarter Mtin _merge
by TaxQuarter Mtin: replace OtherDeclarationCount=OtherDeclarationCount[_n-1] if OtherDeclarationCount>=.
by TaxQuarter Mtin: replace MyDeclarationCount=MyDeclarationCount[_n-1] if MyDeclarationCount>=.
by TaxQuarter Mtin: replace MatchDeclarationCount=MatchDeclarationCount[_n-1] if MatchDeclarationCount>=.
by TaxQuarter Mtin: replace OtherDeclarationTax=OtherDeclarationTax[_n-1] if OtherDeclarationTax>=.
by TaxQuarter Mtin: replace MyDeclarationTax=MyDeclarationTax[_n-1] if MyDeclarationTax>=.
by TaxQuarter Mtin: replace MatchDeclarationTax=MatchDeclarationTax[_n-1] if MatchDeclarationTax>=.


gsort TaxQuarter Mtin -_merge
by TaxQuarter Mtin: replace OtherDeclarationCount=OtherDeclarationCount[_n-1] if OtherDeclarationCount>=.
by TaxQuarter Mtin: replace MyDeclarationCount=MyDeclarationCount[_n-1] if MyDeclarationCount>=.
by TaxQuarter Mtin: replace MatchDeclarationCount=MatchDeclarationCount[_n-1] if MatchDeclarationCount>=.
by TaxQuarter Mtin: replace OtherDeclarationTax=OtherDeclarationTax[_n-1] if OtherDeclarationTax>=.
by TaxQuarter Mtin: replace MyDeclarationTax=MyDeclarationTax[_n-1] if MyDeclarationTax>=.
by TaxQuarter Mtin: replace MatchDeclarationTax=MatchDeclarationTax[_n-1] if MatchDeclarationTax>=.

drop Count

replace OtherDeclarationCount=0 if OtherDeclarationCount==.
replace MyDeclarationCount=0 if MyDeclarationCount==.
replace MatchDeclarationCount=0 if MatchDeclarationCount==.
replace OtherDeclarationTax=0 if OtherDeclarationTax==.
replace MyDeclarationTax=0 if MyDeclarationTax==.
replace MatchDeclarationTax=0 if MatchDeclarationTax==.

by TaxQuarter Mtin: gen Count=_n
by TaxQuarter Mtin: gen Count2=_N

keep if Count==1

gen PurchaseMyCountDiscrepancy=MyDeclarationCount/(OtherDeclarationCount+MyDeclarationCount+MatchDeclarationCount)
gen PurchaseOtherCountDiscrepancy=OtherDeclarationCount/(OtherDeclarationCount+MyDeclarationCount+MatchDeclarationCount)
gen PurchaseMyTaxDiscrepancy=MyDeclarationTax/(MyDeclarationTax+OtherDeclarationTax+MatchDeclarationTax)
gen PurchaseOtherTaxDiscrepancy=OtherDeclarationTax/(MyDeclarationTax+OtherDeclarationTax+MatchDeclarationTax)

isid TaxQuarter Mtin

drop SellerBuyerTin TotalCountPurchaseTransactions PurchaseTaxAmount TotalPurchaseAmount TotalCountSaleTransactions SalesTaxAmount TotalSalesAmount _merge TotalCount TotalPurchaseTaxAmount TotalSalesTaxAmount Count Count2

replace PurchaseMyTaxDiscrepancy=0 if PurchaseMyTaxDiscrepancy==.
replace PurchaseOtherTaxDiscrepancy=0 if PurchaseOtherTaxDiscrepancy==.

save "${features_path}/PurchaseDiscrepancyCounts.dta"


//Now we repeat calculating these measures for the sales side

use "${features_path}/SalesTaxAmount_AllQuarters.dta", clear

rename Mtin x
rename SellerBuyerTin Mtin
rename x SellerBuyerTin

merge 1:1 TaxQuarter Mtin SellerBuyerTin using "${features_path}/PurchaseTaxAmount_AllQuarters.dta"

rename Mtin x
rename SellerBuyerTin Mtin
rename x SellerBuyerTin

bys TaxQuarter Mtin _merge: gen TotalCount=_N
by TaxQuarter Mtin _merge: gen Count=_n
by TaxQuarter Mtin _merge: egen TotalPurchaseTaxAmount=sum(PurchaseTaxAmount)
by TaxQuarter Mtin _merge: egen TotalSalesTaxAmount=sum(SalesTaxAmount)

replace TotalSalesTaxAmount=0 if TotalSalesTaxAmount==.&_merge==2
replace TotalPurchaseTaxAmount=0 if TotalPurchaseTaxAmount==.&_merge==1

keep if Count==1

bys TaxQuarter Mtin: gen OtherDeclarationCount=TotalCount if _merge==2
bys TaxQuarter Mtin: gen MyDeclarationCount=TotalCount if _merge==1
bys TaxQuarter Mtin: gen MatchDeclarationCount=TotalCount if _merge==3

bys TaxQuarter Mtin: gen OtherDeclarationTax=TotalPurchaseTaxAmount if _merge==2
bys TaxQuarter Mtin: gen MyDeclarationTax=TotalSalesTaxAmount if _merge==1
bys TaxQuarter Mtin: gen MatchDeclarationTax=TotalSalesTaxAmount if _merge==3

gsort TaxQuarter Mtin _merge
by TaxQuarter Mtin: replace OtherDeclarationCount=OtherDeclarationCount[_n-1] if OtherDeclarationCount>=.
by TaxQuarter Mtin: replace MyDeclarationCount=MyDeclarationCount[_n-1] if MyDeclarationCount>=.
by TaxQuarter Mtin: replace MatchDeclarationCount=MatchDeclarationCount[_n-1] if MatchDeclarationCount>=.
by TaxQuarter Mtin: replace OtherDeclarationTax=OtherDeclarationTax[_n-1] if OtherDeclarationTax>=.
by TaxQuarter Mtin: replace MyDeclarationTax=MyDeclarationTax[_n-1] if MyDeclarationTax>=.
by TaxQuarter Mtin: replace MatchDeclarationTax=MatchDeclarationTax[_n-1] if MatchDeclarationTax>=.


gsort TaxQuarter Mtin -_merge
by TaxQuarter Mtin: replace OtherDeclarationCount=OtherDeclarationCount[_n-1] if OtherDeclarationCount>=.
by TaxQuarter Mtin: replace MyDeclarationCount=MyDeclarationCount[_n-1] if MyDeclarationCount>=.
by TaxQuarter Mtin: replace MatchDeclarationCount=MatchDeclarationCount[_n-1] if MatchDeclarationCount>=.
by TaxQuarter Mtin: replace OtherDeclarationTax=OtherDeclarationTax[_n-1] if OtherDeclarationTax>=.
by TaxQuarter Mtin: replace MyDeclarationTax=MyDeclarationTax[_n-1] if MyDeclarationTax>=.
by TaxQuarter Mtin: replace MatchDeclarationTax=MatchDeclarationTax[_n-1] if MatchDeclarationTax>=.

drop Count

replace OtherDeclarationCount=0 if OtherDeclarationCount==.
replace MyDeclarationCount=0 if MyDeclarationCount==.
replace MatchDeclarationCount=0 if MatchDeclarationCount==.
replace OtherDeclarationTax=0 if OtherDeclarationTax==.
replace MyDeclarationTax=0 if MyDeclarationTax==.
replace MatchDeclarationTax=0 if MatchDeclarationTax==.

by TaxQuarter Mtin: gen Count=_n
by TaxQuarter Mtin: gen Count2=_N

keep if Count==1

gen SaleMyCountDiscrepancy=MyDeclarationCount/(OtherDeclarationCount+MyDeclarationCount+MatchDeclarationCount)
gen SaleOtherCountDiscrepancy=OtherDeclarationCount/(OtherDeclarationCount+MyDeclarationCount+MatchDeclarationCount)
gen SaleMyTaxDiscrepancy=MyDeclarationTax/(MyDeclarationTax+OtherDeclarationTax+MatchDeclarationTax)
gen SaleOtherTaxDiscrepancy=OtherDeclarationTax/(MyDeclarationTax+OtherDeclarationTax+MatchDeclarationTax)

isid TaxQuarter Mtin

replace SaleMyTaxDiscrepancy=0 if SaleMyTaxDiscrepancy==.
replace SaleOtherTaxDiscrepancy=0 if SaleOtherTaxDiscrepancy==.

drop SellerBuyerTin TotalCountPurchaseTransactions PurchaseTaxAmount TotalPurchaseAmount TotalCountSaleTransactions SalesTaxAmount TotalSalesAmount _merge TotalCount TotalPurchaseTaxAmount TotalSalesTaxAmount Count Count2
save "${features_path}/SaleDiscrepancyCounts.dta"

*--------------------------------------------------------
** Identifying Discrepancies
*--------------------------------------------------------

use "${features_path}/SaleDiscrepancyCounts.dta", clear
merge 1:1 Mtin TaxQuarter using "${features_path}/SaleDiscrepancy.dta", generate(_merge_salediscrepancy)
tab _merge
save "${features_path}/SaleDiscrepancyAll.dta"

use "${features_path}/PurchaseDiscrepancyCounts.dta", clear
merge 1:1 Mtin TaxQuarter using "${features_path}/PurchaseDiscrepancy.dta", generate(_merge_purchasediscrepancy)
tab _merge
save "${features_path}/PurchaseDiscrepancyAll.dta"
