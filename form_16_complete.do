/************************************************* 
* Filename: 
* Input: H:/Ashwin/dta/
* Purpose: Rename variables in form16
* Output: H:/Ashwin/dta/
* Author: Ashwin MB
* Date: 25/09/2018
* Last modified: 22/10/2018 (Ashwin)
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

*output files*
global output_path "H:/Ashwin/dta/final"
global qc_path "H:/Ashwin/dta/qc"
global prob_path "H:/Ashwin/dta/prob"

****************** Load Form 16 information of firms *************
/*Creating a consolidated list will make it a huge file; 
use for loop instead*/

foreach var in "1213" "1314" "1415" "1516" "1617" {
use "${input_path1}\form16_`var'_complete.dta", clear

* Renaming the variables appropriately * 
rename  var1	ReturnType
rename  var2	TaxPeriod
rename  var3 	ReturnType
rename  var5 	TurnoverGross
rename  var6 	TurnoverCentral
rename  var7 	TurnoverLocal
rename	var8	TurnoverAt1
rename	var9	OutputTaxAt1
rename	var10	TurnoverAt5
rename	var11	OutputTaxAt5
rename	var12	TurnoverAt125
rename	var13	OutputTaxAt125
rename	var14	TurnoverAt20
rename	var15	OutputTaxAt20
rename	var16	WCTurnoverAt5
rename	var17	WCOutputTaxAt5
rename	var18	WCTurnoverAt125
rename	var19	WCOutputTaxAt125
rename	var20	ExemptedSales
rename	var21	LaborCharges
rename	var22	LandCharges
rename	var23	DieselSale
rename	var24	SaleDelhiFormH
rename	var25	OutputTaxBeforeAdjustment
rename	var26	AdjustmentOutputTax
rename	var27	TotalOutputTax
rename	var28	PurchaseCapitalGoods
rename	var29	CreditCapitalGoods
rename	var30	PurchaseOtherGoods
rename	var31	CreditOtherGoods
rename	var32	PurchaseGoodsAt1
rename	var33	CreditGoodsAt1
rename	var34	PurchaseGoodsAt5
rename	var35	CreditGoodsAt5
rename	var36	PurchaseGoodsAt125
rename	var37	CreditGoodsAt125
rename	var38	PurchaseGoodsAt20
rename	var39	CreditGoodsAt20
rename	var40	WCPurchaseAt5
rename	var41	WCCreditAt5
rename	var42	WCPurchaseAt125
rename	var43	WCCreditAt125
rename	var44	PurchaseUnregisteredDealer
rename	var45	PurchaseCompositionDealer
rename	var46	PurchaseNonCreditableGoods
rename	var47	PurchaseTaxFreeGoods
rename	var48	WCLabourPurchase 
rename	var49	PurchaseIneligibleForITC
rename	var50	PurchaseRetailInvoice
rename	var51	DieselPurchase
rename	var52	PurchaseDelhiFormH
rename	var53	PurchaseCapitalNonCreditGood
rename	var54	TaxCreditBeforeAdjustment
rename	var55	AdjustmentTaxCredit
rename	var56	TotalTaxCredit
rename	var57	NetTax
rename	var58	InterestPayable
rename	var59	PenaltyPayable
rename	var60	TDSCertificates
rename	var61	CarryForwardTaxCredit
rename	var62	CSTAdjustmentVAT
rename	var63	BalancePayable
rename	var64	AmountDepositedByDealer
rename	var65	AggregateAmountPaid
rename	var66	NetBalance
rename	var67	BalanceBroughtForward
rename	var68	AdjustCSTLiability
rename	var69	RefundClaimed
rename	var70	BalanceCarriedNextTaxPeriod
rename	var71	InterStateSaleCD
rename	var72	InterStatePurchaseCD
rename	var73	InterStateSaleCE1E2
rename	var74	InterStatePurchaseCE1E2
rename	var75	OutwardStockTransferBranchF //Need to verify this is correct
rename	var76	InwardStockTransferBranchF //Need to verify this is correct
rename	var77	OutwardStockTransferConsignmentF //Need to verify this is correct
rename	var78	InwardStockTransferConsignmentF //Need to verify this is correct
rename	var79	OwnGoodsTransferredAfterJobF //Need to verify this is correct
rename	var80	OwnGoodsReceivedAfterJobF //Need to verify this is correct
rename	var81	OtherDealersGoodsTrJobF //Need to verify this is correct
rename	var82	OtherDealersGoodsReJobF //Need to verify this is correct
rename	var83	InterStateExportsAgainstH
rename	var84	InterStateImportsAgainstH
rename	var85	InterStateExportsAgainstI
rename	var86	InterStateImportsAgainstI
rename	var87	InterStateExportsAgainstJ
rename	var88	InterStateImportsAgainstJ
rename	var89	ExportFromIndia //Need to verifty
rename	var90	ImportToIndia //Need to verify
rename	var91	SaleExemptedGoodsSchedule //Need to verify
rename	var92	PurchaseExemptedGoodsSchedule //Need to verify
rename	var93	SaleExemptedGoodsCST //Need to verify
rename	var94	PurchaseExemptedGoodsCST //Need to verify
rename	var95	HighSeaSale //Need to verify
rename	var96	HighSeaPurchase //Need to verify
rename	var97	InterStateSaleOther
rename	var98	InterStatePurchaseOther
rename	var99	InterStateSaleCapital
rename	var100	InterStatePurchaseCapital
rename	var101	TotalInterStateSale
rename	var102	TotalInterStatePurchase

save "${input_path2}\form16_`var'_complete.dta", replace
}

** Tax Period
	/* Cleaning Tax Period names */

foreach var in "1213" "1314" "1415" "1516" "1617" {
use "${input_path2}\form16_`var'_complete.dta", clear
tab TaxPeriod
}

** Renaming tax periods 
	/* Problem in 2012-13 with names */
use "${input_path2}\form16_1213_complete.dta", clear
replace TaxPeriod = "Fourth Quarter-2012" if TaxPeriod == "Forth Quarter-2012"
replace TaxPeriod = "First Quarter-2012" if TaxPeriod == "First quaterly-2012"
replace TaxPeriod = "Second Quarter-2012" if TaxPeriod == "Second quaterly-2012"
replace TaxPeriod = "Third Quarter-2012" if TaxPeriod == "Third quaterly-2012"
replace TaxPeriod = "Third Quarter-2012" if TaxPeriod == "Thrid Quater-2012"

** Wrong Mtin Tax Period combination
	/* There exists 1 return in FY 1314 for Tax Period = Mar-2013 */
use "${input_path2}\form16_1314_complete.dta", clear
bro if ///
TaxPeriod == "Mar-2013" // All values are 0, MReturn_ID 11181345, Mtin 1773142

drop if TaxPeriod == "Mar-2013"

** Rename variables labels
	/* Renaming as the old form16 dataset */ 

foreach var in "1213" "1314" "1415" "1516" "1617" {
use "${input_path2}\form16_`var'_complete.dta", clear

//label variable id "This is the internal id. I think this is the primary key"
label variable MReturn_ID "Unique Identifier for Form 16"
label variable TaxPeriod "The tax period for which the returns has been filed"
label variable GrossTurnover "R4.1 GrossTurnover (G) G = C + L"
label variable CentralTurnover "R4.2 CentralTurnover (C) G = C + L"
label variable LocalTurnover "R4.3 LocalTurnover (L) G = C + L"
label variable WCTurnoverAt5 "R5.5 Work contract taxable at 5%  - Turnover(Rs.)"
label variable WCOutputTaxAt5 "R5.5 Work contract taxable at 5%  - Output Tax(Rs.)"
label variable WCTurnoverAt125 "R5.6 Work contract taxable at 12.5%  - Turnover(Rs.)"
label variable WCOutputTaxAt125 "R5.6 Work contract taxable at 12.5%  - Output Tax(Rs)"
label variable ExemptedSales "R5.7 Exempted sales"
label variable LaborCharges "R5.8 Charges towards labour, services and other like charges"
label variable LandCharges "R5.9 Charges towards cost of land, if any, in civil works contracts"
label variable DieselSale "R5.10Sale of Diesel & Petrol as have suffered tax in the hands of various Oil Marketing Companies in Delhi"
label variable SaleDelhiFormH "R5.11 sales within Delhi against Form 'H'"
label variable OutputTaxBeforeAdjustment "R5.12 Output Tax before Adjustment - SubTotal (A)"
label variable AdjustmentOutputTax "R5.13 Adjustment to Output Tax(Complete Annexure and enter Total A2 here) - (B)"
label variable TotalOutputTax "R5.14 Total OutPut Tax (A+B)"
label variable PurchaseCapitalGoods "R6.1 Capital Goods - Purchases(Rs.)"
label variable CreditCapitalGoods "R6.1 Capital Goods - Tax Credit(Rs.)"
label variable PurchaseOtherGoods "R6.2 Other Goods - Purchases(Rs.)"
label variable CreditOtherGoods "R6.2 Other Goods - Tax Credit(Rs.)"
label variable PurchaseGoodsAt1 "R6.2(1) Goods taxable at 1% - Purchases(Rs.)"
label variable CreditGoodsAt1 "R6.2(1) Goods taxable at 1% - Tax Credit(Rs.)"
label variable PurchaseGoodsAt5 "R6.2(2) Goods taxable at 5% - Purchases(Rs.)"
label variable CreditGoodsAt5 "R6.2(2) Goods taxable at 5% - Tax Credit(Rs.)"
label variable PurchaseGoodsAt125 "R6.2(3) Goods taxable at 12.5% - Purchases(Rs.)"
label variable CreditGoodsAt125 "R6.2(3) Goods taxable at 12.5% - Tax Credit(Rs.)"
label variable PurchaseGoodsAt20 "R6.2(4) Goods taxable at 20% - Purchases(Rs.)"
label variable CreditGoodsAt20 "R6.2(4) Goods taxable at 20% - Tax Credit(Rs.)"
label variable WCPurchaseAt5 "R6.2(5) Work contract taxable at 5% - Purchases(Rs.)"
label variable WCCreditAt5 "R6.2(5) Work contract taxable at 5% - Tax Credit(Rs.)"
label variable WCPurchaseAt125 "R6.2(6) Work contract taxable at 12.5% - Purchases(Rs.)"
label variable WCCreditAt125 "R6.2(6) Work contract taxable at 12.5% - Tax Credit(Rs.)"
label variable PurchaseUnregisteredDealer "R 6.3(1)  PURCHASE FROM UNREGISTERED DEALER"
label variable PurchaseCompositionDealer "R 6.3(2) Purchase from composition Dealer "
label variable PurchaseNonCreditableGoods "R 6.3(3) Purchase from Non Creditable Goods"
label variable PurchaseTaxFreeGoods "R6.3(4) Purchase from Tax free Goods"
label variable WCLabourPurchase "R6.3(5) Purchase of labour and services related to works contract"
label variable PurchaseIneligibleForITC "R6.3(6) Purchase againsttax Invoices not eligible for ITC"
label variable PurchaseRetailInvoice "R6.3(7) Purchase against Retail Invoices"
label variable DieselPurchase "R6.3(8) Purchase of Diesel & petrol as have suffered tax in the hands of various Oil Marketing Companies in Delhi"
label variable PurchaseDelhiFormH "R6.3(9) Purchase from delhi dealers against Form 'H'"
label variable PurchaseCapitalNonCreditGood "R6.3(10) Purchase of Capital Goods (Used for manufacturing of non-creditable goods)"
label variable TaxCreditBeforeAdjustment "R6.4 Tax Credit before Adjustment - Sub Total (A) amount"
label variable AdjustmentTaxCredit "R6.5 Adjustment of Tax credits(Complete Annexure and enter Total A4 here) - (B)"
label variable TotalTaxCredit "R6.6 Total Tax Credit (A + B)"
label variable NetTax "R7.1 Net Tax  (R5.14 - R6.6)"
label variable InterestPayable "R7.2 Add: Interest,If Payable"
label variable PenaltyPayable "R7.3 Add: Penalty,If Payable"
label variable TDSCertificates "R7.4 Tax Deducted at source (Attach  No of TDS Certificates in Original)"
label variable CarryForwardTaxCredit "R7.5 Tax Credit carried forward from previous tax period"
label variable CSTAdjustmentVAT "R7.6 Adjustment of excess balance under CST towards DVAT liability"
label variable BalancePayable "R7.7 Balance Payable ((R7.1 + R7.2 + R7.3 )-( R7.4+R7.5+R7.6))"
label variable AmountDepositedByDealer "R7.8  Amount Deposited by the Dealer (attach proof of payment)"
label variable AggregateAmountPaid "Aggregate Amount Paid(Sum total of Challan)"
label variable NetBalance "R8. Net Balance * (R7.7 - R7.8)"
label variable BalanceBroughtForward "R9.0 Balance Brought forward from line (positive value)"
label variable AdjustCSTLiability "R9.1 Adjust against laibility under Central Sales Tax"
label variable RefundClaimed "R9.2 Refund Claimed"
label variable BalanceCarriedNextTaxPeriod "R9.3 Balance Carried forward to Next Tax Period"
label variable InterStateSaleCD "R11.1 Againts C/D Forms Inter - State Sales Exports"
label variable InterStatePurchaseCD "R11.1 Againts C/D Forms Inter - State Purchase/Imports"
label variable InterStateSaleCE1E2 "R11.2 Against C+ E1/E2 Forms - Inter State Sales Exports"
label variable InterStatePurchaseCE1E2 "R11.2 Against C+ E1/E2 Forms - Inter-State Purchase/Imports"
label variable OutwardStockTransferBranchF "R11.3 Inward/outward Stock Transfer(Branch) against F Forms"
label variable InwardStockTransferBranchF "R11.3 Inward/outward Stock Transfer(Branch) against F Forms"
label variable OutwardStockTransferConsignmentF "R11.4 Inward/outward Stock Transfer(Consignment) against F Forms"
label variable InwardStockTransferConsignmentF "R11.4 Inward/outward Stock Transfer(Consignment) against F Forms"
label variable OwnGoodsTransferredAfterJobF "R11.5 Own goods received/tranferered after job work against F Forms"
label variable OwnGoodsReceivedAfterJobF "R11.5 Own goods received/tranferered after job work against F Forms"
label variable OtherDealersGoodsTrJobF "R11.6 Other Dealers goods received/returned after job work against F Forms"
label variable OtherDealersGoodsReJobF "R11.6 Other Dealers goods received/returned after job work against F Forms"
label variable InterStateExportsAgainstH "R11.7 Against H Forms - Inter State Sales Exports"
label variable InterStateImportsAgainstH "R11.7 Against H Forms - Inter-State Purchase/Imports"
label variable InterStateExportsAgainstI "R11.8 Against I Forms - Inter State Sales Exports"
label variable InterStateImportsAgainstI "R11.8 Against I Forms - Inter-State Purchase/Imports"
label variable InterStateExportsAgainstJ "R11.9 Against J Forms - Inter State Sales Exports"
label variable InterStateImportsAgainstJ "R11.9 Against J Forms - Inter State Purchase/Imports"
label variable ExportFromIndia "R11.10 Export to/Import from outside India - Inter State Sales Exports"
label variable ImportToIndia "R11.10 Export to/Import from outside India - Inter-State Purchase/Imports"
label variable SaleExemptedGoodsSchedule "R11.11 Sae of Exempted Goods(Schedule 1)"
label variable PurchaseExemptedGoodsSchedule "R11.11 Sae of Exempted Goods(Schedule 1)"
label variable SaleExemptedGoodsCST "R11.12 Purchase of Exempted Goods (Section 8(5) ) of CST Act)"
label variable PurchaseExemptedGoodsCST "R11.12 Purchase of Exempted Goods (Section 8(5) ) of CST Act)"
label variable HighSeaSale "R11.13 High Sea Sales/Purchases"
label variable HighSeaPurchase "R11.13 High Sea Sales/Purchases"
label variable InterStateSaleOther "R11.14 Other(Not Supported by any form)- Inter State Sales Exports"
label variable InterStatePurchaseOther "R11.14 Other(Not Supported by any form)- Inter-State Purchase/Imports"
label variable InterStateSaleCapital "R11.15 Capital Goods- Inter State Sales Exports"
label variable InterStatePurchaseCapital "R11.15 Capital Goods- Inter-State Purchase/Imports"
label variable TotalInterStateSale "R11.16 Total Inter State Sales Exports"
label variable TotalInterStatePurchase "R11.16 Total  Inter-State Purchase/Imports"
//label variable WardName "Ward Name"
label variable ReturnType "Original or Revised"

save "${input_path2}\form16_`var'_complete.dta", replace
}




