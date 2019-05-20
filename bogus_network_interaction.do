/************************************************* 
* Filename: 
* Input: 
* Purpose: Create network analysis chain for predicted top bogus firms
* Output: 
* Author: Ashwin MB
* Date: 26/04/2019
* Last modified: 26/04/2019(Ashwin)
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
global input_path4 "H:/Ashwin/dta"
global input_path5 "H:/Ashwin"
global analysis_path1 "H:/Ashwin/analysis"


*output files*
global output_path "H:/Ashwin/dta/final"
global analysis_path "H:/Ashwin/dta/analysis"
global qc_path "H:/Ashwin/dta/qc"
global prob_path "H:/Ashwin/dta/prob"
global features_path "H:/Ashwin/dta/bogusdealers"
global features_final "H:/Ashwin/dta/features"
global temp_path2 "Z:/features"
global final_list "H:/Ashwin/finallist"

*--------------------------------------------------------
** Identify top 10 predicted bogus firms 
*--------------------------------------------------------
*Applying necessary filters*
use "${final_list}/final/FinalSelectedFirms.dta", clear 
keep if TotalTaxCreditBeforeAdjustment > 5000000 & RegistrationStatus == "Registered" & bogus_flag == 0 
gsort -p_allfeatures
gen index1 = _n
drop if index1 > 10
keep Mtin p_allfeatures 
save "${analysis_path1}/network_analysis/top10_bogus_firms.dta", replace

/*
Mtin		p_allfeatures
1610388		.5053056
1127545		.4286655
1173226		.3988543
1718237		.3478473
1190660		.3072143
1208461		.2774938
1685024		.2645907
1690594		.25386
1186492		.2524704
1398890		.2462479
*/

*--------------------------------------------------------
** Create a network of firms for the top 10 bogus firms 
*--------------------------------------------------------

* Identify the most active quarters for the top 10 bogus_flag == 1 
use "${analysis_path1}/network_analysis/top10_bogus_firms.dta", clear
merge 1:m Mtin using "${features_final}/All_return_features_minus_q12.dta"
keep if _merge == 3 
bysort Mtin: egen min_quarter = min(TaxQuarter)
bysort Mtin: egen max_quarter = max(TaxQuarter)
keep Mtin TaxQuarter min_quarter max_quarter TotalReturnCount p_allfeatures
gsort Mtin -TotalReturnCount
duplicates drop Mtin, force
gsort -p_allfeatures

/*
Mtin		p_allfeatures	TaxQuarter	TotalReturnCount	min_quarter		max_quarter
1610388		.5053056			28			5					22				28
1127545		.4286655			25			2					23				26
1173226		.3988543			23			7					23				28
1718237		.3478473			23			11					21				28
1190660		.3072143			22			2					22				27
1208461		.2774938			22			3					21				28
1685024		.2645907			25			2					21				28
1690594		.25386				28			3					23				28
1186492		.2524704			23			6					23				28
1398890		.2462479			24			7					23				28


*/

*--------------------------------------------------------
** Firm 1
*--------------------------------------------------------
* mtin == 1610388 taxquarter == 28 (2016-17, q4)
use "${output_path}/2a2b_2016_q4.dta", clear
keep if Mtin == "1610388" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop

/*SaleOrPurchase	Mtin	SellerBuyerTin
		AE			1610388		1799211
		AE			1610388		1579980
		AE			1610388		1104634	*/

*check if reverse is true
use "${output_path}/2a2b_2016_q4.dta", clear
keep if (Mtin == "1799211" | Mtin == "1579980" | Mtin == "1104634" )& ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1610388"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches

/* EXPLORE each 1nd degree seller/purchaser firms */ 
** Seller 2 
use "${output_path}/2a2b_2016_q4.dta", clear
keep if Mtin == "1799211" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

** Seller 3 
use "${output_path}/2a2b_2016_q4.dta", clear
keep if Mtin == "1579980" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

*check if reverse is true
use "${output_path}/2a2b_2016_q4.dta", clear
keep if (Mtin == "1858904" | Mtin == "1003627") & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1579980"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches

** Seller 4
use "${output_path}/2a2b_2016_q4.dta", clear
keep if Mtin == "1104634" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

*check if reverse is true
use "${output_path}/2a2b_2016_q4.dta", clear
keep if (Mtin == "1398890" | Mtin == "1799211") & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1104634"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches


/* EXPLORE each 2nd degree seller/purchaser firms */ 
** Seller 5 
use "${output_path}/2a2b_2016_q4.dta", clear
keep if Mtin == "1858904" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

*check if reverse is true
use "${output_path}/2a2b_2016_q4.dta", clear
keep if (Mtin == "1610388" | Mtin == "1799211") & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1858904"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches


** Seller 6
use "${output_path}/2a2b_2016_q4.dta", clear
keep if Mtin == "1003627" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

*check if reverse is true
use "${output_path}/2a2b_2016_q4.dta", clear
keep if Mtin == "1305777" & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1003627"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches

** Seller 7
use "${output_path}/2a2b_2016_q4.dta", clear
keep if Mtin == "1398890" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

*check if reverse is true
use "${output_path}/2a2b_2016_q4.dta", clear
keep if (Mtin == "1002671" | Mtin == "1579980" | Mtin == "1084582") & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1398890"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches

/* EXPLORE each 3rd degree seller/purchaser firms */ 
** Seller 8 
use "${output_path}/2a2b_2016_q4.dta", clear
keep if Mtin == "1305777" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

*check if reverse is true
use "${output_path}/2a2b_2016_q4.dta", clear
keep if (Mtin == "1002671" | Mtin == "1123786" | Mtin == "1610388") & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1305777"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches

** Seller 9 
use "${output_path}/2a2b_2016_q4.dta", clear
keep if Mtin == "1002671" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

*check if reverse is true
use "${output_path}/2a2b_2016_q4.dta", clear
keep if (Mtin == "1104634" | Mtin == "1708638") & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1002671"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches

** Seller 10
use "${output_path}/2a2b_2016_q4.dta", clear
keep if Mtin == "1084582" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

*check if reverse is true
use "${output_path}/2a2b_2016_q4.dta", clear
keep if (Mtin == "1104634" | Mtin == "1123786" | Mtin == "1398890" | Mtin == "1610388") & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1084582"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches


/* EXPLORE each 4th degree seller/purchaser firms */ 
** Seller 11 
use "${output_path}/2a2b_2016_q4.dta", clear
keep if Mtin == "1123786" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

** Seller 12 
use "${output_path}/2a2b_2016_q4.dta", clear
keep if Mtin == "1708638" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

*check if reverse is true
use "${output_path}/2a2b_2016_q4.dta", clear
keep if (Mtin == "1610388" | Mtin == "1799211" | Mtin == "1398890" | Mtin == "1796835") & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1708638"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches

/* EXPLORE each 5th degree seller/purchaser firms */ 
** Seller 13
use "${output_path}/2a2b_2016_q4.dta", clear
keep if Mtin == "1796835" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

*check if reverse is true
use "${output_path}/2a2b_2016_q4.dta", clear
keep if (Mtin == "1883616" | Mtin == "1538310" | Mtin == "1263261" | Mtin == "1106402") & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1796835"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches

/* EXPLORE each 6th degree seller/purchaser firms */ 
** Seller 14
use "${output_path}/2a2b_2016_q4.dta", clear
keep if Mtin == "1883616" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

** Seller 15
use "${output_path}/2a2b_2016_q4.dta", clear
keep if Mtin == "1538310" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

** Seller 16
use "${output_path}/2a2b_2016_q4.dta", clear
keep if Mtin == "1263261" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

** Seller 17
use "${output_path}/2a2b_2016_q4.dta", clear
keep if Mtin == "1106402" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

// Firms 14-17 interact with Firms 18-33 (all unique). Stopped going further in purchase side

/* Sales side of Master Bogus Firm */
use "${output_path}/2a2b_2016_q4.dta", clear
keep if Mtin == "1610388" & SaleOrPurchase == "BF"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

/*check interaction between purchase and sales firm*/
** sales side firms and 2a
use "${output_path}/2a2b_2016_q4.dta", clear
keep if (Mtin == "1207339" | Mtin == "1741141" | Mtin == "1848324" ///
	| Mtin == "1861317" | Mtin == "1391990") & SaleOrPurchase == "AE"
keep if (SellerBuyerTin == "1579980" | SellerBuyerTin == "1799211"  ///
	| SellerBuyerTin == "1610388" | SellerBuyerTin == "1104634" ///
	| SellerBuyerTin == "1858904" | SellerBuyerTin == "1003627"  ///
	| SellerBuyerTin == "1398890" | SellerBuyerTin == "1305777" ///
	| SellerBuyerTin == "1002671" | SellerBuyerTin == "1084582"  ///
	| SellerBuyerTin == "1123786" | SellerBuyerTin == "1708638" ///
	| SellerBuyerTin == "1796835") // interacts with only master bogus firm
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 
	
** sales side firms and 2b
use "${output_path}/2a2b_2016_q4.dta", clear
keep if (Mtin == "1207339" | Mtin == "1741141" | Mtin == "1848324" ///
	| Mtin == "1861317" | Mtin == "1391990") & SaleOrPurchase == "BF"
keep if (SellerBuyerTin == "1610388" | SellerBuyerTin == "1799211"  ///
	| SellerBuyerTin == "1579980" | SellerBuyerTin == "1104634" ///
	| SellerBuyerTin == "1858904" | SellerBuyerTin == "1003627"  ///
	| SellerBuyerTin == "1398890" | SellerBuyerTin == "1305777" ///
	| SellerBuyerTin == "1002671" | SellerBuyerTin == "1084582"  ///
	| SellerBuyerTin == "1123786" | SellerBuyerTin == "1708638" ///
	| SellerBuyerTin == "1796835") // no observations
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

** purchase side firms and 2a
use "${output_path}/2a2b_2016_q4.dta", clear
keep if (Mtin == "1610388" | Mtin == "1799211"  ///
	| Mtin == "1579980" | Mtin == "1104634" ///
	| Mtin == "1858904" | Mtin == "1003627"  ///
	| Mtin == "1398890" | Mtin == "1305777" ///
	| Mtin == "1002671" | Mtin == "1084582"  ///
	| Mtin == "1123786" | Mtin == "1708638" ///
	| Mtin == "1796835") & SaleOrPurchase == "AE"
keep if (SellerBuyerTin == "1207339" | SellerBuyerTin == "1741141" | SellerBuyerTin == "1848324" ///
	| SellerBuyerTin == "1861317" | SellerBuyerTin == "1391990")
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

** purchase side firms and 2b (don't include Master Bogus firm)
use "${output_path}/2a2b_2016_q4.dta", clear
keep if (Mtin == "1610388" | Mtin == "1799211"  ///
	| Mtin == "1579980" | Mtin == "1104634" ///
	| Mtin == "1858904" | Mtin == "1003627"  ///
	| Mtin == "1398890" | Mtin == "1305777" ///
	| Mtin == "1002671" | Mtin == "1084582"  ///
	| Mtin == "1123786" | Mtin == "1708638" ///
	| Mtin == "1796835") & SaleOrPurchase == "BF"
keep if (SellerBuyerTin == "1207339" | SellerBuyerTin == "1741141" | SellerBuyerTin == "1848324" ///
	| SellerBuyerTin == "1861317" | SellerBuyerTin == "1391990")
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

/* Import registration status, bogus_flag, p_hat about firms interacting with Firm 1 */
*import the file (created manually)
import delim "${analysis_path1}/network_analysis/PredictedFirm1_list.csv", varn(1) clear case(preserve)
merge 1:m Mtin using "${features_final}/All_return_features_minus_q12.dta"
keep if _merge == 3
keep Mtin Rename bogus_flag RegistrationStatus
duplicates drop
merge 1:1 Mtin using "${final_list}/final/FinalSelectedFirms.dta", keepusing(p_allfeatures) 
keep if _merge == 3
drop _merge
gsort Rename

*--------------------------------------------------------
** Firm 2
*--------------------------------------------------------
* mtin == 1127545 taxquarter == 25 (2016-17, q1)
use "${output_path}/2a2b_2016_q1.dta", clear
keep if Mtin == "1127545" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop

/*SaleOrPurchase	Mtin		SellerBuyerTin
		AE			1127545		1376737		*/

*check if reverse is true
use "${output_path}/2a2b_2016_q1.dta", clear
keep if Mtin == "1376737" & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1127545"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop 

/* EXPLORE each 1nd degree seller/purchaser firms */ 
** Seller 2 
use "${output_path}/2a2b_2016_q1.dta", clear
keep if Mtin == "1376737" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

*check if reverse is true
use "${output_path}/2a2b_2016_q1.dta", clear
keep if Mtin == "1846984" & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1376737"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop 

/* EXPLORE each 1nd degree seller/purchaser firms */ 
** Seller 3
use "${output_path}/2a2b_2016_q1.dta", clear
keep if Mtin == "1846984" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

** Purchaser from bogus firm
use "${output_path}/2a2b_2016_q1.dta", clear
keep if Mtin == "1127545" & SaleOrPurchase == "BF"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

/*check interaction between purchase and sales firm*/
** sales side firms and 2a
use "${output_path}/2a2b_2016_q1.dta", clear
keep if (Mtin == "1392665" | Mtin == "1307856") & SaleOrPurchase == "AE"
keep if (SellerBuyerTin == "1127545" | SellerBuyerTin == "1376737"  ///
	| SellerBuyerTin == "1846984") 
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

** sales side firms and 2b
use "${output_path}/2a2b_2016_q1.dta", clear
keep if (Mtin == "1392665" | Mtin == "1307856") & SaleOrPurchase == "BF"
keep if (SellerBuyerTin == "1127545" | SellerBuyerTin == "1376737"  ///
	| SellerBuyerTin == "1846984") 
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

** purchase side firms and 2a
use "${output_path}/2a2b_2016_q1.dta", clear
keep if ( Mtin == "1127545" | Mtin == "1376737" | Mtin == "1846984") ///
		& SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
keep if SellerBuyerTin == "1392665" | SellerBuyerTin == "1307856"

** purchase side firms and 2b (don't include Master bogus firm)
use "${output_path}/2a2b_2016_q1.dta", clear
keep if ( Mtin == "1376737" | Mtin == "1846984") ///
		& SaleOrPurchase == "BF"
keep SaleOrPurchase Mtin SellerBuyerTin
keep if SellerBuyerTin == "1392665" | SellerBuyerTin == "1307856"
duplicates drop 

/* Import more information about firms interacting with Firm 1 */
*import the file (created manually)
import delim "${analysis_path1}/network_analysis/PredictedFirm2_list.csv", varn(1) clear case(preserve)
merge 1:m Mtin using "${features_final}/All_return_features_minus_q12.dta"
keep if _merge == 3 | _merge == 1 
keep Mtin Rename bogus_flag RegistrationStatus
duplicates drop
tostring Mtin,replace
rename RegistrationStatus Status
merge 1:1 Mtin using "${output_path}/dp_form.dta", keepusing(RegistrationStatus)
keep if _merge == 3
drop Status _merge
destring Mtin, replace
merge 1:1 Mtin using "${final_list}/final/FinalSelectedFirms.dta", keepusing(p_allfeatures) 
keep if _merge == 3 | _merge == 1 
drop _merge
gsort Rename


