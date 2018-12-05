******** temp *****************
use "${output_path}/2a2b_quarterly_2014.dta", clear

** create sample data
	/* Identify the most recurring Mtins */ 
duplicates tag Mtin TaxPeriod, gen(repetitions)
keep Mtin TaxPeriod repetitions
duplicates drop
gsort -repetitions

* create sample data with selected Mtin 
use "${output_path}/2a2b_quarterly_2014.dta", clear
	
keep if Mtin == "1055762" | Mtin == "1055762" | Mtin == "1021291" ///
	| Mtin == "1374116" | Mtin == "1680787" | Mtin == "1889507" ///
	| Mtin == "1801326" | Mtin == "1585502" | Mtin == "1216752"
	
save "${temp_path}/2a2b_2014_sample.dta", replace

*edit 2a2b sample data
use "${temp_path}/2a2b_2014_sample.dta", clear
gen Combination = SaleOrPurchase + SalePurchaseType
bysort Mtin Combination TaxPeriod: egen NetAmount_1 = sum(NetAmount)
bysort Mtin Combination TaxPeriod: egen Tax_1 = sum(Tax)
bysort Mtin Combination TaxPeriod: egen Total_1 = sum(Total)
tostring TaxPeriod, replace
gen Unique_identifier = Mtin + TaxPeriod

duplicates drop Unique_identifier Combination, force
drop Sale* DealerG* TransactionT* Rate NetAmount Tax Total TaxYear Date var12 ///
	Form_Status var14 SellerBuyerTin MReturn_ID Commodity*

reshape wide NetAmount_1 Tax_1 Total_1, i(Unique_identifier) j(Combination) string

label variable NetAmount_1AECG "NetAmount = R6.1(PurchaseCapitalGoods)"
label variable Tax_1AEOT "Tax = R6.2(CreditOtherGoods)" 
label variable NetAmount_1ANISPC "NetAmount = R11.15(InterStatePurchaseCD)" 
label variable NetAmount_1ANISPN "NetAmount = R11.15(TotalInterStatePurchase)"
label variable NetAmount_1ANPUC "NetAmount = R6.3(PurchaseUnregisteredDealer)"
label variable NetAmount_1ANSBT "NetAmount = R11.3(InwardStockTransferBranchF)"

label variable NetAmount_1BFEOI "NetAmount = R11.10(ExportFromIndia"
//label variable NetAmount_1BFHSS "NetAmount = R11.12(HighSeaSale)"
label variable NetAmount_1BFISBCT "NetAmount = R11.4(OutwardStockTransferBranch"
label variable NetAmount_1BFISS "NetAmount = R11.15(TotalInterStateSale)"
label variable Tax_1BFLS "Tax = R5.14(TotalOutputTax)"

/*
//replace label variable combination  if combination == "AE/EXG"
//replace label variable combination  if combination == "AE/PAT"
//replace label variable combination  if combination == "AE/PUC"
//replace label variable combination  if combination == "AE/SCPT"
//replace label variable combination  if combination == "AE/SCUC"

//replace label variable combination  if combination == "AN/CG"
//replace label variable combination  if combination == "AN/E1E2"
//replace label variable combination  if combination == "AN/EXG"
//replace label variable combination  if combination == "AN/GRBF"
//replace label variable combination  if combination == "AN/HSP"
//replace label variable combination  if combination == "AN/IOI"
//replace label variable combination  if combination == "AN/ISPH"
replace label variable combination  if combination == "AN/ODRF"
replace label variable combination  if combination == "AN/OT"
replace label variable combination  if combination == "AN/PAC"
replace label variable combination  if combination == "AN/PAT"
replace label variable combination  if combination == "AN/PEU"
replace label variable combination  if combination == "AN/PTEG"
replace label variable combination  if combination == "AN/PUC"
replace label variable combination  if combination == "AN/SBT"
replace label variable combination  if combination == "AN/SCT"
replace label variable combination  if combination == "AN/SCUC"

replace label variable combination  if combination == "BF/DCTW"
replace label variable combination  if combination == "BF/EOI"
replace label variable combination  if combination == "BF/HSS"
replace label variable combination  if combination == "BF/ISBCT"
replace label variable combination  if combination == "BF/ISS"
replace label variable combination  if combination == "BF/LS"
replace label variable combination  if combination == "BF/LSSC"
*/

order (Mtin TaxPeriod OriginalTaxPeriod), before(Unique_identifier)
drop Unique_identifier TaxPeriod
rename OriginalTaxPeriod TaxPeriod
save "${temp_path}/2a2b_2014_sample_1.dta", replace

use "${output_path}\form16_data_consolidated.dta", clear
keep if Mtin == "1055762" | Mtin == "1055762" | Mtin == "1021291" ///
	| Mtin == "1374116" | Mtin == "1680787" | Mtin == "1889507" ///
	| Mtin == "1801326" | Mtin == "1585502" | Mtin == "1216752"

keep if TaxPeriod == "First Quarter-2014" | TaxPeriod == "Second Quarter-2014" | TaxPeriod == "Third Quarter-2014" | TaxPeriod == "Fourth Quarter-2014"
gsort Mtin TaxPeriod -DateofReturnFiled
duplicates drop Mtin TaxPeriod, force

merge 1:1 Mtin TaxPeriod using "${temp_path}/2a2b_2014_sample_1.dta"

gsort Mtin TaxPeriod
save "${temp_path}/2a2b_2014_sample_2.dta", replace

use "${temp_path}/2a2b_2014_sample_2.dta", clear
export excel "${delim_path}/temp_2a2b_comparison_mtins.xlsx", ///
			firstrow(variables) she("form16_2a2b_complete") sheetmodify

			
keep TaxPeriod Mtin ///
	PurchaseCapitalGoods CreditOtherGoods InterStatePurchaseOther ///
	PurchaseUnregisteredDealer InwardStockTransferBranchF ExportFromIndia ///
	HighSeaSale  TotalInterStateSale TotalOutputTax InterStatePurchaseCD ///
	NetAmount_1AECG Tax_1AEOT NetAmount_1ANISPC NetAmount_1ANISPN ///
	NetAmount_1ANPUC NetAmount_1ANSBT NetAmount_1BFEOI NetAmount_1BFISBCT ///
	NetAmount_1BFISS Tax_1BFLS 

/* Mapping between 2a2b & Form 16 
TotalOutputTax 				Tax_1BFLS
PurchaseCapitalGoods 		NetAmount_1AECG
CreditOtherGoods			Tax_1AEOT
PurchaseUnregisteredDealer	NetAmount_1ANPUC
InwardStockTransferBranchF	NetAmount_1ANSBT
ExportFromIndia				NetAmount_1BFEOI
//HighSeaSale				NetAmount_1BFHSS
TotalInterStateSale			NetAmount_1BFISS
TotalInterStatePurchase		NetAmount_1ANISPN
InterStatePurchaseCD		NetAmount_1ANISPC
*/

gen r5_14_error = ((TotalOutputTax - Tax_1BFLS)*100)/Tax_1BFLS
gen r6_1_error = ((PurchaseCapitalGoods - NetAmount_1AECG)*100)/NetAmount_1AECG
gen r6_2_error = ((CreditOtherGoods - Tax_1AEOT)*100)/Tax_1AEOT
gen r11_3_error = ((InwardStockTransferBranchF - NetAmount_1ANSBT)*100)/NetAmount_1ANSBT
gen r11_10_error = ((ExportFromIndia - NetAmount_1BFEOI)*100)/NetAmount_1BFEOI
gen r11_15s_error = ((TotalInterStateSale - NetAmount_1BFISS)*100)/NetAmount_1BFISS
gen r11_1_error = ((InterStatePurchaseCD - NetAmount_1ANISPC)*100)/NetAmount_1ANISPC

*Problems in numbers
gen r6_3_1_error = ((PurchaseUnregisteredDealer - NetAmount_1ANPUC)*100)/NetAmount_1ANPUC
gen r11_15p_error = ((InterStatePurchaseOther - NetAmount_1ANISPN)*100)/NetAmount_1ANISPN

export excel "${delim_path}/temp_2a2b_comparison_mtins.xlsx", ///
			firstrow(variables) she("form16_2a2b_quarterly_mtins") sheetmodify
