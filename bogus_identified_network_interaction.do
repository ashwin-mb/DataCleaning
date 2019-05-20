/************************************************* 
* Filename: 
* Input: 
* Purpose: Conduct network analysis of bogus firms 
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
** Identify top 10 predicted bogus firms with bogus_flag == 1 
*--------------------------------------------------------
*Applying necessary filters*
use "${final_list}/final/FinalSelectedFirms.dta", clear 
keep if bogus_flag == 1 & RegistrationStatus == "Cancelled" & TotalTaxCreditBeforeAdjustment > 5000000
gsort -p_allfeatures
gen index1 = _n
drop if index1 > 10
keep Mtin p_allfeatures 
save "${analysis_path1}/network_analysis/top10_bogus_identified.dta", replace

/*
 Mtin		p_allfeatures
1841320		.9166667
1032951		.7393162
1207611		.7307692
1380115		.7161369
1871200		.6776661
1394065		.6623475
1910917		.6526126
1570028		.6354893
1553644		.6272201
1333851		.5966924
*/

*--------------------------------------------------------
** Create a network of firms for the top 10 bogus firms 
*--------------------------------------------------------

* Identify the most active quarters for the top 10 bogus_flag == 1 
use "${analysis_path1}/network_analysis/top10_bogus_identified.dta", clear
merge 1:m Mtin using "${features_final}/All_return_features_minus_q12.dta"
keep if _merge == 3 
bysort Mtin: egen min_quarter = min(TaxQuarter)
bysort Mtin: egen max_quarter = max(TaxQuarter)
keep Mtin TaxQuarter min_quarter max_quarter TotalReturnCount
duplicates drop

/*
Mtin		min_quarter	  max_quarter 	ActiveQuarter
 1032951			23			23				23
 1207611			22			23				22
 1333851			20			20				20
 1380115			22			22				22
 1394065			17			20				Any
 1553644			21			23				22
 1570028			17			20				Any
 1841320			20			20				20
 1871200			17			20				Any
 1910917			20			21				20
*/

* choose any taxquarter 
*--------------------------------------------------------
** Firm 1 
*--------------------------------------------------------
* mtin == 1032951 taxquarter == 23 (2015-16, q3)
use "${output_path}/2a2b_2015_q3.dta", clear
keep if Mtin == "1032951" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop

*check if reverse is true
use "${output_path}/2a2b_2015_q3.dta", clear
keep if (Mtin == "1207611" | Mtin == "1893402" | Mtin == "1363724" )& ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1032951"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches

/* explore each 1st degree seller/purchaser firms */
	**Seller 2
use "${output_path}/2a2b_2015_q3.dta", clear
keep if Mtin == "1207611" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop

*check if reverse is true
use "${output_path}/2a2b_2015_q3.dta", clear
keep if (Mtin == "1045974" | Mtin == "1032951" | Mtin == "1387381" )& ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1207611"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches
		
*Seller 3
use "${output_path}/2a2b_2015_q3.dta", clear
keep if Mtin == "1893402" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop
	
*check if reverse is true
use "${output_path}/2a2b_2015_q3.dta", clear
keep if (Mtin == "1363724" | Mtin == "1068698" | Mtin == "1773123" | Mtin == "1045974" | Mtin == "1380115" | Mtin == "1834911" )& ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1893402"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // one match

*Seller 4
use "${output_path}/2a2b_2015_q3.dta", clear
keep if Mtin == "1363724" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop
	
*check if reverse is true
use "${output_path}/2a2b_2015_q3.dta", clear
keep if (Mtin == "1032951" | Mtin == "1045974")& ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1363724"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches

/* explore each 2nd degree seller firms */ 
*Seller 5
use "${output_path}/2a2b_2015_q3.dta", clear
keep if Mtin == "1045974" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop

*check if reverse is true
use "${output_path}/2a2b_2015_q3.dta", clear
keep if (Mtin == "1363724" | Mtin == "1068698" | Mtin == "1380115")& ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1045974"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches

* Seller 6
use "${output_path}/2a2b_2015_q3.dta", clear
keep if Mtin == "1387381" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop
		
*check if reverse is true
use "${output_path}/2a2b_2015_q3.dta", clear
keep if Mtin == "1762575" & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1387381"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches		
		
* Seller 7
use "${output_path}/2a2b_2015_q3.dta", clear
keep if Mtin == "1773123" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop
		
*check if reverse is true
use "${output_path}/2a2b_2015_q3.dta", clear
keep if (Mtin == "1407847" | Mtin == "1207611" | Mtin == "1045974") & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1773123"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches		

* Seller 8
use "${output_path}/2a2b_2015_q3.dta", clear
keep if Mtin == "1068698" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop
		
*check if reverse is true
use "${output_path}/2a2b_2015_q3.dta", clear
keep if (Mtin == "1773123" | Mtin == "1676450" | Mtin == "1893402") & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1068698"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches		

* Seller 9
use "${output_path}/2a2b_2015_q3.dta", clear
keep if Mtin == "1834911" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop
		
*check if reverse is true
use "${output_path}/2a2b_2015_q3.dta", clear
keep if Mtin == "1207611" & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1834911"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop 

* Seller 10
use "${output_path}/2a2b_2015_q3.dta", clear
keep if Mtin == "1380115" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop
		
*check if reverse is true
use "${output_path}/2a2b_2015_q3.dta", clear
keep if Mtin == "1207611" & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1834911"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches	

/* EXPLORE 3rd degree seller/purchaser firms */ 
* Seller 11
use "${output_path}/2a2b_2015_q3.dta", clear
keep if Mtin == "1762575" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop

*check if reverse is true
use "${output_path}/2a2b_2015_q3.dta", clear
keep if Mtin == "1835680" & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1762575"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches	

* Seller 12
use "${output_path}/2a2b_2015_q3.dta", clear
keep if Mtin == "1407847" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop

*check if reverse is true
use "${output_path}/2a2b_2015_q3.dta", clear
keep if (Mtin == "1363724" | Mtin == "1045974" | Mtin == "1605508" | Mtin == "1421476" | Mtin == "1119549")& ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1407847"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches	

* Seller 13
use "${output_path}/2a2b_2015_q3.dta", clear
keep if Mtin == "1676450" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop	

*check if reverse is true
use "${output_path}/2a2b_2015_q3.dta", clear
keep if (Mtin == "1178098" | Mtin == "1407847" | Mtin == "1838660" | Mtin == "1068698")& ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1676450"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches	

/* explore each 4th degree seller/purchaser firms */
*Seller 14 
use "${output_path}/2a2b_2015_q3.dta", clear
keep if Mtin == "1835680" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop

*check if reverse is true
use "${output_path}/2a2b_2015_q3.dta", clear
keep if Mtin == "1745062" & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1835680"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches	
		
*Seller 15		
use "${output_path}/2a2b_2015_q3.dta", clear
keep if Mtin == "1605508" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop // No values

*Seller 16
use "${output_path}/2a2b_2015_q3.dta", clear
keep if Mtin == "1421476" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop // No values

*Seller 17
use "${output_path}/2a2b_2015_q3.dta", clear
keep if Mtin == "1119549" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop

*check if reverse is true
use "${output_path}/2a2b_2015_q3.dta", clear
keep if (Mtin == "1745062" | Mtin == "1032951") & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1119549"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches		
		
*Seller 18
use "${output_path}/2a2b_2015_q3.dta", clear
keep if Mtin == "1178098" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop
	
*check if reverse is true
use "${output_path}/2a2b_2015_q3.dta", clear
keep if Mtin == "1205348" & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1178098"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches		

*Seller 19
use "${output_path}/2a2b_2015_q3.dta", clear
keep if Mtin == "1838660" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop

*check if reverse is true
use "${output_path}/2a2b_2015_q3.dta", clear
keep if Mtin == "1594811" & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1838660"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches	

/* EXPLORE each 5th degree seller firms */ 
*Seller 20
use "${output_path}/2a2b_2015_q3.dta", clear
keep if Mtin == "1745062" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop
		
*check if reverse is true
use "${output_path}/2a2b_2015_q3.dta", clear
keep if (Mtin == "1946173" | Mtin == "1199215" | Mtin == "1634334" | Mtin == "1810567" | Mtin == "1066393")& ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1745062"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches

*Seller 21
use "${output_path}/2a2b_2015_q3.dta", clear
keep if Mtin == "1896970" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop

*check if reverse is true
use "${output_path}/2a2b_2015_q3.dta", clear
keep if (Mtin == "1363724" | Mtin == "1068698" | Mtin == "1032951" | Mtin == "1893402" | Mtin == "1045974" | Mtin == "1380115" | Mtin == "1207611")& ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1896970"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches	

*Seller 22
use "${output_path}/2a2b_2015_q3.dta", clear
keep if Mtin == "1205348" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop

*Seller 23
use "${output_path}/2a2b_2015_q3.dta", clear
keep if Mtin == "1594811" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop

/* Sales side of Master Bogus Firm */
use "${output_path}/2a2b_2015_q3.dta", clear
keep if Mtin == "1032951" & SaleOrPurchase == "BF"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

/*check interaction between purchase and sales firm*/
** sales side firms and 2a
use "${output_path}/2a2b_2015_q3.dta", clear
keep if (Mtin == "1404230" |	Mtin == "1592994" |	Mtin == "1470153" ///
	|	Mtin == "1698794" |	Mtin == "1294778" |	Mtin == "1280698" ///
	|	Mtin == "1780570" |	Mtin == "1635613" |	Mtin == "1197844" ///
	|	Mtin == "1028056" |	Mtin == "1313894" |	Mtin == "1700387" ///
	|	Mtin == "1916849" |	Mtin == "1828310" |	Mtin == "1888547" ///
	|	Mtin == "1190151" |	Mtin == "1019491" |	Mtin == "1903279" ///
	|	Mtin == "1028048" |	Mtin == "1415657" |	Mtin == "1123216" ///
	|	Mtin == "1337842" |	Mtin == "1480028" |	Mtin == "1951643" ///
	|	Mtin == "1639760") & SaleOrPurchase == "AE"
keep if (SellerBuyerTin == "1032951" |	SellerBuyerTin == "1207611" ///
	|	SellerBuyerTin == "1893402" |	SellerBuyerTin == "1363724" |	SellerBuyerTin == "1045974" ///
	|	SellerBuyerTin == "1387381" |	SellerBuyerTin == "1773123" |	SellerBuyerTin == "1068698" ///
	|	SellerBuyerTin == "1834911" |	SellerBuyerTin == "1380115" |	SellerBuyerTin == "1762575" ///
	|	SellerBuyerTin == "1407847" |	SellerBuyerTin == "1676450" |	SellerBuyerTin == "1835680" ///
	|	SellerBuyerTin == "1605508" |	SellerBuyerTin == "1421476" |	SellerBuyerTin == "1119549" ///
	|	SellerBuyerTin == "1178098" |	SellerBuyerTin == "1838660" |	SellerBuyerTin == "1745062" ///
	|	SellerBuyerTin == "1896970" |	SellerBuyerTin == "1205348" |	SellerBuyerTin == "1594811" ///
	|	SellerBuyerTin == "1946173" |	SellerBuyerTin == "1199215" |	SellerBuyerTin == "1634334" ///
	|	SellerBuyerTin == "1810567" |	SellerBuyerTin == "1066393")  
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 
	
** sales side firms and 2b
use "${output_path}/2a2b_2015_q3.dta", clear
keep if (Mtin == "1404230" |	Mtin == "1592994" |	Mtin == "1470153" ///
	|	Mtin == "1698794" |	Mtin == "1294778" |	Mtin == "1280698" ///
	|	Mtin == "1780570" |	Mtin == "1635613" |	Mtin == "1197844" ///
	|	Mtin == "1028056" |	Mtin == "1313894" |	Mtin == "1700387" ///
	|	Mtin == "1916849" |	Mtin == "1828310" |	Mtin == "1888547" ///
	|	Mtin == "1190151" |	Mtin == "1019491" |	Mtin == "1903279" ///
	|	Mtin == "1028048" |	Mtin == "1415657" |	Mtin == "1123216" ///
	|	Mtin == "1337842" |	Mtin == "1480028" |	Mtin == "1951643" ///
	|	Mtin == "1639760") & SaleOrPurchase == "BF"
keep if (SellerBuyerTin == "1032951" |	SellerBuyerTin == "1207611" ///
	|	SellerBuyerTin == "1893402" |	SellerBuyerTin == "1363724" |	SellerBuyerTin == "1045974" ///
	|	SellerBuyerTin == "1387381" |	SellerBuyerTin == "1773123" |	SellerBuyerTin == "1068698" ///
	|	SellerBuyerTin == "1834911" |	SellerBuyerTin == "1380115" |	SellerBuyerTin == "1762575" ///
	|	SellerBuyerTin == "1407847" |	SellerBuyerTin == "1676450" |	SellerBuyerTin == "1835680" ///
	|	SellerBuyerTin == "1605508" |	SellerBuyerTin == "1421476" |	SellerBuyerTin == "1119549" ///
	|	SellerBuyerTin == "1178098" |	SellerBuyerTin == "1838660" |	SellerBuyerTin == "1745062" ///
	|	SellerBuyerTin == "1896970" |	SellerBuyerTin == "1205348" |	SellerBuyerTin == "1594811" ///
	|	SellerBuyerTin == "1946173" |	SellerBuyerTin == "1199215" |	SellerBuyerTin == "1634334" ///
	|	SellerBuyerTin == "1810567" |	SellerBuyerTin == "1066393") 
keep SaleOrPurchase Mtin SellerBuyerTin // no observations
duplicates drop 

** purchase side firms and 2a
use "${output_path}/2a2b_2015_q3.dta", clear
keep if (Mtin == "1032951" |	Mtin == "1207611" ///
	|	Mtin == "1893402" |	Mtin == "1363724" |	Mtin == "1045974" ///
	|	Mtin == "1387381" |	Mtin == "1773123" |	Mtin == "1068698" ///
	|	Mtin == "1834911" |	Mtin == "1380115" |	Mtin == "1762575" ///
	|	Mtin == "1407847" |	Mtin == "1676450" |	Mtin == "1835680" ///
	|	Mtin == "1605508" |	Mtin == "1421476" |	Mtin == "1119549" ///
	|	Mtin == "1178098" |	Mtin == "1838660" |	Mtin == "1745062" ///
	|	Mtin == "1896970" |	Mtin == "1205348" |	Mtin == "1594811" ///
	|	Mtin == "1946173" |	Mtin == "1199215" |	Mtin == "1634334" ///
	|	Mtin == "1810567" |	Mtin == "1066393") & SaleOrPurchase == "AE"
keep if (SellerBuyerTin == "1404230" |	SellerBuyerTin == "1592994" |	SellerBuyerTin == "1470153" ///
	|	SellerBuyerTin == "1698794" |	SellerBuyerTin == "1294778" |	SellerBuyerTin == "1280698" ///
	|	SellerBuyerTin == "1780570" |	SellerBuyerTin == "1635613" |	SellerBuyerTin == "1197844" ///
	|	SellerBuyerTin == "1028056" |	SellerBuyerTin == "1313894" |	SellerBuyerTin == "1700387" ///
	|	SellerBuyerTin == "1916849" |	SellerBuyerTin == "1828310" |	SellerBuyerTin == "1888547" ///
	|	SellerBuyerTin == "1190151" |	SellerBuyerTin == "1019491" |	SellerBuyerTin == "1903279" ///
	|	SellerBuyerTin == "1028048" |	SellerBuyerTin == "1415657" |	SellerBuyerTin == "1123216" ///
	|	SellerBuyerTin == "1337842" |	SellerBuyerTin == "1480028" |	SellerBuyerTin == "1951643" ///
	|	SellerBuyerTin == "1639760") 
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

** purchase side firms and 2b (don't include Master Bogus firm)
use "${output_path}/2a2b_2015_q3.dta", clear
keep if (Mtin == "1032951" |	Mtin == "1207611" ///
	|	Mtin == "1893402" |	Mtin == "1363724" |	Mtin == "1045974" ///
	|	Mtin == "1387381" |	Mtin == "1773123" |	Mtin == "1068698" ///
	|	Mtin == "1834911" |	Mtin == "1380115" |	Mtin == "1762575" ///
	|	Mtin == "1407847" |	Mtin == "1676450" |	Mtin == "1835680" ///
	|	Mtin == "1605508" |	Mtin == "1421476" |	Mtin == "1119549" ///
	|	Mtin == "1178098" |	Mtin == "1838660" |	Mtin == "1745062" ///
	|	Mtin == "1896970" |	Mtin == "1205348" |	Mtin == "1594811" ///
	|	Mtin == "1946173" |	Mtin == "1199215" |	Mtin == "1634334" ///
	|	Mtin == "1810567" |	Mtin == "1066393") & SaleOrPurchase == "BF"
keep if (SellerBuyerTin == "1404230" |	SellerBuyerTin == "1592994" |	SellerBuyerTin == "1470153" ///
	|	SellerBuyerTin == "1698794" |	SellerBuyerTin == "1294778" |	SellerBuyerTin == "1280698" ///
	|	SellerBuyerTin == "1780570" |	SellerBuyerTin == "1635613" |	SellerBuyerTin == "1197844" ///
	|	SellerBuyerTin == "1028056" |	SellerBuyerTin == "1313894" |	SellerBuyerTin == "1700387" ///
	|	SellerBuyerTin == "1916849" |	SellerBuyerTin == "1828310" |	SellerBuyerTin == "1888547" ///
	|	SellerBuyerTin == "1190151" |	SellerBuyerTin == "1019491" |	SellerBuyerTin == "1903279" ///
	|	SellerBuyerTin == "1028048" |	SellerBuyerTin == "1415657" |	SellerBuyerTin == "1123216" ///
	|	SellerBuyerTin == "1337842" |	SellerBuyerTin == "1480028" |	SellerBuyerTin == "1951643" ///
	|	SellerBuyerTin == "1639760") 
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

/* Import more information about firms interacting with Firm 1 */
*import the file (created manually)
import delim "${analysis_path1}/network_analysis/Firm1_list.csv", varn(1) clear case(preserve)
merge 1:m Mtin using "${features_final}/All_return_features_minus_q12.dta"
keep if _merge == 3
keep Mtin Rename bogus_flag RegistrationStatus
duplicates drop
merge 1:1 Mtin using "${final_list}/final/FinalSelectedFirms.dta", keepusing(p_allfeatures) 
keep if _merge == 3
drop _merge
gsort Rename

**********************************************************
/* Firm 2 */
**********************************************************
* mtin == 1207611 taxquarter == 22 (2015-16, q2)
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1207611" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop

*check if reverse is true
use "${output_path}/2a2b_2015_q2.dta", clear
keep if (Mtin == "1407938" | Mtin == "1380115" | Mtin == "1046135" | Mtin == "1363724" | Mtin == "1068698" | Mtin == "1910917")& ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1207611"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches

/* EXPLORE each 1st degree seller/purchaser firms */ 
** Seller 2 
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1046135" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop // no observations

** Seller 3
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1380115" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop

*check if reverse is true
use "${output_path}/2a2b_2015_q2.dta", clear
keep if (Mtin == "1046135" | Mtin == "1910917" | Mtin == "1553644" | Mtin == "1896970" | Mtin == "1908789" | Mtin == "1205498")& ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1380115"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches

** Seller 4 
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1910917" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop // no observations

** Seller 5 
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1068698" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 
		
*check if reverse is true
use "${output_path}/2a2b_2015_q2.dta", clear
keep if (Mtin == "1908789" | Mtin == "1045974" | Mtin == "1694906" | Mtin == "1896970" | Mtin == "1893402")& ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1068698"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches

** Seller 6
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1363724" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

*check if reverse is true
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1915931" & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1363724"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches		
		
** Seller 7
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1407938" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop

*check if reverse is true
use "${output_path}/2a2b_2015_q2.dta", clear
keep if (Mtin == "1046135" | Mtin == "1553644" | Mtin == "1068698" | Mtin == "1910917")& ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1407938"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches

/* EXPLORE each 2nd degree seller/purchaser firms */ 
* Seller 8
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1553644" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop

*check if reverse is true
use "${output_path}/2a2b_2015_q2.dta", clear
keep if (Mtin == "1893402" | Mtin == "1032951" | Mtin == "1896970" | Mtin == "1045974" | Mtin == "1260243" | Mtin == "1407938")& ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1553644"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches

** Seller 9 
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1896970" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop

use "${output_path}/2a2b_2015_q2.dta", clear
keep if (Mtin == "1045974" | Mtin == "1068698" | Mtin == "1380115")& ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1896970"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // one match

** Seller 10
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1908789" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop

use "${output_path}/2a2b_2015_q2.dta", clear
keep if (Mtin == "1207611" | Mtin == "1097713" | Mtin == "1380115")& ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1908789"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // one match

** Seller 11
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1205498" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop

use "${output_path}/2a2b_2015_q2.dta", clear
keep if (Mtin == "1380115" | Mtin == "1207611")& ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1205498"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // two match

** Seller 12
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1045974" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop

use "${output_path}/2a2b_2015_q2.dta", clear
keep if (Mtin == "1068698" | Mtin == "1207611")& ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1045974"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // no match

** Seller 13
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1694906" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop

** Seller 14
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1893402" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop

use "${output_path}/2a2b_2015_q2.dta", clear
keep if (Mtin == "1380115" | Mtin == "1207611" | Mtin == "1363724")& ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1893402"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // no match

** Seller 15
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1915931" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop // no match

/* EXPLORE each 2nd degree seller/purchaser firms */ 
* Seller 16
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1032951" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop // no match

* Seller 17 
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1260243" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop // no match

* Seller 18
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1097713" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop // no match

/*check interaction between purchase and sales firm*/
** sales side firms and 2a
use "${output_path}/2a2b_2015_q2.dta", clear
keep if (Mtin == "1280698"|	Mtin == "1149793" ///
|	Mtin == "1592994"|	Mtin == "1781440"|	Mtin == "1560137" ///
|	Mtin == "1835029"|	Mtin == "1677120"|	Mtin == "1557335" ///
|	Mtin == "1834911"|	Mtin == "1951643"|	Mtin == "1638239" ///
|	Mtin == "1528632"|	Mtin == "1635613"|	Mtin == "1496951" ///
|	Mtin == "1039162"|	Mtin == "1736155"|	Mtin == "1384917" ///
|	Mtin == "1102506"|	Mtin == "1404230"|	Mtin == "1029405" ///
|	Mtin == "1442956"|	Mtin == "1887710"|	Mtin == "1484280" ///
|	Mtin == "1073349"|	Mtin == "1160571"|	Mtin == "1639760" ///
|	Mtin == "1123980"|	Mtin == "1328204"|	Mtin == "1294778" ///
|	Mtin == "1385788"|	Mtin == "1446102"|	Mtin == "1531098" ///
|	Mtin == "1502871"|	Mtin == "1106734"|	Mtin == "1235261" ///
|	Mtin == "1637553"|	Mtin == "1265483"|	Mtin == "1057588" ///
|	Mtin == "1190151"|	Mtin == "1780570"|	Mtin == "1480028" ///
|	Mtin == "1698794") & SaleOrPurchase == "AE"
keep if (SellerBuyerTin == "1207611"|	SellerBuyerTin == "1046135"|	SellerBuyerTin == "1380115" ///
|	SellerBuyerTin == "1910917"|	SellerBuyerTin == "1068698"|	SellerBuyerTin == "1363724" ///
|	SellerBuyerTin == "1407938"|	SellerBuyerTin == "1553644"|	SellerBuyerTin == "1896970" ///
|	SellerBuyerTin == "1908789"|	SellerBuyerTin == "1205498"|	SellerBuyerTin == "1045974" ///
|	SellerBuyerTin == "1694906"|	SellerBuyerTin == "1893402"|	SellerBuyerTin == "1915931" ///
|	SellerBuyerTin == "1032951"|	SellerBuyerTin == "1260243"|	SellerBuyerTin == "1097713")  
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 
	
** sales side firms and 2b
use "${output_path}/2a2b_2015_q2.dta", clear
keep if (Mtin == "1280698"|	Mtin == "1149793" ///
|	Mtin == "1592994"|	Mtin == "1781440"|	Mtin == "1560137" ///
|	Mtin == "1835029"|	Mtin == "1677120"|	Mtin == "1557335" ///
|	Mtin == "1834911"|	Mtin == "1951643"|	Mtin == "1638239" ///
|	Mtin == "1528632"|	Mtin == "1635613"|	Mtin == "1496951" ///
|	Mtin == "1039162"|	Mtin == "1736155"|	Mtin == "1384917" ///
|	Mtin == "1102506"|	Mtin == "1404230"|	Mtin == "1029405" ///
|	Mtin == "1442956"|	Mtin == "1887710"|	Mtin == "1484280" ///
|	Mtin == "1073349"|	Mtin == "1160571"|	Mtin == "1639760" ///
|	Mtin == "1123980"|	Mtin == "1328204"|	Mtin == "1294778" ///
|	Mtin == "1385788"|	Mtin == "1446102"|	Mtin == "1531098" ///
|	Mtin == "1502871"|	Mtin == "1106734"|	Mtin == "1235261" ///
|	Mtin == "1637553"|	Mtin == "1265483"|	Mtin == "1057588" ///
|	Mtin == "1190151"|	Mtin == "1780570"|	Mtin == "1480028" ///
|	Mtin == "1698794") & SaleOrPurchase == "BF"
keep if (SellerBuyerTin == "1207611"|	SellerBuyerTin == "1046135"|	SellerBuyerTin == "1380115" ///
|	SellerBuyerTin == "1910917"|	SellerBuyerTin == "1068698"|	SellerBuyerTin == "1363724" ///
|	SellerBuyerTin == "1407938"|	SellerBuyerTin == "1553644"|	SellerBuyerTin == "1896970" ///
|	SellerBuyerTin == "1908789"|	SellerBuyerTin == "1205498"|	SellerBuyerTin == "1045974" ///
|	SellerBuyerTin == "1694906"|	SellerBuyerTin == "1893402"|	SellerBuyerTin == "1915931" ///
|	SellerBuyerTin == "1032951"|	SellerBuyerTin == "1260243"|	SellerBuyerTin == "1097713")  
keep SaleOrPurchase Mtin SellerBuyerTin // no observations
duplicates drop 

** purchase side firms and 2a
use "${output_path}/2a2b_2015_q2.dta", clear
keep if (Mtin == "1207611"|	Mtin == "1046135"|	Mtin == "1380115" ///
|	Mtin == "1910917"|	Mtin == "1068698"|	Mtin == "1363724" ///
|	Mtin == "1407938"|	Mtin == "1553644"|	Mtin == "1896970" ///
|	Mtin == "1908789"|	Mtin == "1205498"|	Mtin == "1045974" ///
|	Mtin == "1694906"|	Mtin == "1893402"|	Mtin == "1915931" ///
|	Mtin == "1032951"|	Mtin == "1260243"|	Mtin == "1097713") & SaleOrPurchase == "AE" 
keep if (SellerBuyerTin == "1280698"|	SellerBuyerTin == "1149793" ///
|	SellerBuyerTin == "1592994"|	SellerBuyerTin == "1781440"|	SellerBuyerTin == "1560137" ///
|	SellerBuyerTin == "1835029"|	SellerBuyerTin == "1677120"|	SellerBuyerTin == "1557335" ///
|	SellerBuyerTin == "1834911"|	SellerBuyerTin == "1951643"|	SellerBuyerTin == "1638239" ///
|	SellerBuyerTin == "1528632"|	SellerBuyerTin == "1635613"|	SellerBuyerTin == "1496951" ///
|	SellerBuyerTin == "1039162"|	SellerBuyerTin == "1736155"|	SellerBuyerTin == "1384917" ///
|	SellerBuyerTin == "1102506"|	SellerBuyerTin == "1404230"|	SellerBuyerTin == "1029405" ///
|	SellerBuyerTin == "1442956"|	SellerBuyerTin == "1887710"|	SellerBuyerTin == "1484280" ///
|	SellerBuyerTin == "1073349"|	SellerBuyerTin == "1160571"|	SellerBuyerTin == "1639760" ///
|	SellerBuyerTin == "1123980"|	SellerBuyerTin == "1328204"|	SellerBuyerTin == "1294778" ///
|	SellerBuyerTin == "1385788"|	SellerBuyerTin == "1446102"|	SellerBuyerTin == "1531098" ///
|	SellerBuyerTin == "1502871"|	SellerBuyerTin == "1106734"|	SellerBuyerTin == "1235261" ///
|	SellerBuyerTin == "1637553"|	SellerBuyerTin == "1265483"|	SellerBuyerTin == "1057588" ///
|	SellerBuyerTin == "1190151"|	SellerBuyerTin == "1780570"|	SellerBuyerTin == "1480028" ///
|	SellerBuyerTin == "1698794") 
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

** purchase side firms and 2b (don't include Master Bogus firm)
use "${output_path}/2a2b_2015_q2.dta", clear
keep if (Mtin == "1207611"|	Mtin == "1046135"|	Mtin == "1380115" ///
|	Mtin == "1910917"|	Mtin == "1068698"|	Mtin == "1363724" ///
|	Mtin == "1407938"|	Mtin == "1553644"|	Mtin == "1896970" ///
|	Mtin == "1908789"|	Mtin == "1205498"|	Mtin == "1045974" ///
|	Mtin == "1694906"|	Mtin == "1893402"|	Mtin == "1915931" ///
|	Mtin == "1032951"|	Mtin == "1260243"|	Mtin == "1097713") & SaleOrPurchase == "BF" 
keep if (SellerBuyerTin == "1280698"|	SellerBuyerTin == "1149793" ///
|	SellerBuyerTin == "1592994"|	SellerBuyerTin == "1781440"|	SellerBuyerTin == "1560137" ///
|	SellerBuyerTin == "1835029"|	SellerBuyerTin == "1677120"|	SellerBuyerTin == "1557335" ///
|	SellerBuyerTin == "1834911"|	SellerBuyerTin == "1951643"|	SellerBuyerTin == "1638239" ///
|	SellerBuyerTin == "1528632"|	SellerBuyerTin == "1635613"|	SellerBuyerTin == "1496951" ///
|	SellerBuyerTin == "1039162"|	SellerBuyerTin == "1736155"|	SellerBuyerTin == "1384917" ///
|	SellerBuyerTin == "1102506"|	SellerBuyerTin == "1404230"|	SellerBuyerTin == "1029405" ///
|	SellerBuyerTin == "1442956"|	SellerBuyerTin == "1887710"|	SellerBuyerTin == "1484280" ///
|	SellerBuyerTin == "1073349"|	SellerBuyerTin == "1160571"|	SellerBuyerTin == "1639760" ///
|	SellerBuyerTin == "1123980"|	SellerBuyerTin == "1328204"|	SellerBuyerTin == "1294778" ///
|	SellerBuyerTin == "1385788"|	SellerBuyerTin == "1446102"|	SellerBuyerTin == "1531098" ///
|	SellerBuyerTin == "1502871"|	SellerBuyerTin == "1106734"|	SellerBuyerTin == "1235261" ///
|	SellerBuyerTin == "1637553"|	SellerBuyerTin == "1265483"|	SellerBuyerTin == "1057588" ///
|	SellerBuyerTin == "1190151"|	SellerBuyerTin == "1780570"|	SellerBuyerTin == "1480028" ///
|	SellerBuyerTin == "1698794") 
keep SaleOrPurchase Mtin SellerBuyerTin // no observations
duplicates drop 

/* Import more information about firms interacting with Firm 1 */
*import the file (created manually)
import delim "${analysis_path1}/network_analysis/Firm2_list.csv", varn(1) clear case(preserve)
merge 1:m Mtin using "${features_final}/All_return_features_minus_q12.dta"
keep if _merge == 3
keep Mtin Rename bogus_flag RegistrationStatus
duplicates drop
merge 1:1 Mtin using "${final_list}/final/FinalSelectedFirms.dta", keepusing(p_allfeatures) 
keep if _merge == 3
drop _merge
gsort Rename

**********************************************************
/* Firm 3 */
**********************************************************
* mtin == 1333851 taxquarter == 20 (2014-15, q4)
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if Mtin == "1333851" & SaleOrPurchase == "AE"
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop
			
*check if reverse is true
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if (Mtin == "1522818" | Mtin == "1333851" )& ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1333851"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches


/* EXPLORE each 1st degree seller/purchaser firms */ 
** Seller 2
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if Mtin == "1522818" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop // no observations

*check if reverse is true
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if (Mtin == "1688488" | Mtin == "1123946" | Mtin == "1192516" | Mtin == "1522670" | Mtin == "1310032" | Mtin == "1633967")& ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1522818"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches

** Seller 3 
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if Mtin == "1988853" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop // no observations

*check if reverse is true
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if (Mtin == "1878281" | Mtin == "1538287" | Mtin == "1693629" | Mtin == "1651612" )& ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1988853"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop 


/* EXPLORE each 2nd degree seller/purchaser firms */ 
** Seller 4 
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if Mtin == "1688488" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

** Seller 5
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if Mtin == "1123946" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

** Seller 6 
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if Mtin == "1192516" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

** Seller 7 
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if Mtin == "1522670" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

** Seller 8
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if Mtin == "1310032" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

** Seller 9
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if Mtin == "1633967" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

** Seller 10
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if Mtin == "1878281" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

** Seller 11
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if Mtin == "1538287" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

** Seller 12
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if Mtin == "1693629" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

** Seller 13
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if Mtin == "1651612" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

** Purchaser from bogus firm
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if Mtin == "1333851" & SaleOrPurchase == "BF"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

/*check interaction between purchase and sales firm*/
** sales side firms and 2a
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if (Mtin == "1998350"|	Mtin == "1310673"	///
|	Mtin == "1834078"|	Mtin == "1330695" ///
|	Mtin == "1315918"|	Mtin == "1557945" ///
|	Mtin == "1073598"|	Mtin == "1501770" ///
|	Mtin == "1903813"|	Mtin == "1510170" ///
|	Mtin == "1561766"|	Mtin == "1076063" ///
|	Mtin == "1188788"|	Mtin == "1568153" ///
|	Mtin == "1950138"|	Mtin == "1851228") & SaleOrPurchase == "AE"
keep if (SellerBuyerTin == "1333851"|	SellerBuyerTin == "1522818" ///
|	SellerBuyerTin == "1988853"|	SellerBuyerTin == "1688488" ///
|	SellerBuyerTin == "1123946"|	SellerBuyerTin == "1192516" ///
|	SellerBuyerTin == "1522670"|	SellerBuyerTin == "1310032" ///
|	SellerBuyerTin == "1633967"|	SellerBuyerTin == "1878281" ///
|	SellerBuyerTin == "1538287"|	SellerBuyerTin == "1693629" ///
|	SellerBuyerTin == "1651612")  
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 
	
** sales side firms and 2b
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if (Mtin == "1998350"|	Mtin == "1310673"	///
|	Mtin == "1834078"|	Mtin == "1330695" ///
|	Mtin == "1315918"|	Mtin == "1557945" ///
|	Mtin == "1073598"|	Mtin == "1501770" ///
|	Mtin == "1903813"|	Mtin == "1510170" ///
|	Mtin == "1561766"|	Mtin == "1076063" ///
|	Mtin == "1188788"|	Mtin == "1568153" ///
|	Mtin == "1950138"|	Mtin == "1851228") & SaleOrPurchase == "BF"
keep if (SellerBuyerTin == "1333851"|	SellerBuyerTin == "1522818" ///
|	SellerBuyerTin == "1988853" |	SellerBuyerTin == "1688488" ///
|	SellerBuyerTin == "1123946"|	SellerBuyerTin == "1192516" ///
|	SellerBuyerTin == "1522670"|	SellerBuyerTin == "1310032" ///
|	SellerBuyerTin == "1633967"|	SellerBuyerTin == "1878281" ///
|	SellerBuyerTin == "1538287"|	SellerBuyerTin == "1693629" ///
|	SellerBuyerTin == "1651612") 
keep SaleOrPurchase Mtin SellerBuyerTin // no observations
duplicates drop 

** purchase side firms and 2a
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if (Mtin == "1333851"|	Mtin == "1522818" ///
|	Mtin == "1988853"|	Mtin == "1688488" ///
|	Mtin == "1123946"|	Mtin == "1192516" ///
|	Mtin == "1522670"|	Mtin == "1310032" ///
|	Mtin == "1633967"|	Mtin == "1878281" ///
|	Mtin == "1538287"|	Mtin == "1693629" ///
|	Mtin == "1651612") & SaleOrPurchase == "AE"
keep if (SellerBuyerTin == "1998350"|	SellerBuyerTin == "1310673"	///
|	SellerBuyerTin == "1834078"|	SellerBuyerTin == "1330695" ///
|	SellerBuyerTin == "1315918"|	SellerBuyerTin == "1557945" ///
|	SellerBuyerTin == "1073598"|	SellerBuyerTin == "1501770" ///
|	SellerBuyerTin == "1903813"|	SellerBuyerTin == "1510170" ///
|	SellerBuyerTin == "1561766"|	SellerBuyerTin == "1076063" ///
|	SellerBuyerTin == "1188788"|	SellerBuyerTin == "1568153" ///
|	SellerBuyerTin == "1950138"|	SellerBuyerTin == "1851228") 
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

** purchase side firms and 2b (don't include Master Bogus firm)
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if (Mtin == "1333851"|	Mtin == "1522818" ///
|	Mtin == "1988853"|	Mtin == "1688488" ///
|	Mtin == "1123946"|	Mtin == "1192516" ///
|	Mtin == "1522670"|	Mtin == "1310032" ///
|	Mtin == "1633967"|	Mtin == "1878281" ///
|	Mtin == "1538287"|	Mtin == "1693629" ///
|	Mtin == "1651612") & SaleOrPurchase == "BF"
keep if (SellerBuyerTin == "1998350"|	SellerBuyerTin == "1310673"	///
|	SellerBuyerTin == "1834078"|	SellerBuyerTin == "1330695" ///
|	SellerBuyerTin == "1315918"|	SellerBuyerTin == "1557945" ///
|	SellerBuyerTin == "1073598"|	SellerBuyerTin == "1501770" ///
|	SellerBuyerTin == "1903813"|	SellerBuyerTin == "1510170" ///
|	SellerBuyerTin == "1561766"|	SellerBuyerTin == "1076063" ///
|	SellerBuyerTin == "1188788"|	SellerBuyerTin == "1568153" ///
|	SellerBuyerTin == "1950138"|	SellerBuyerTin == "1851228") 
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

/* Import more information about firms interacting with Firm 1 */
*import the file (created manually)
import delim "${analysis_path1}/network_analysis/Firm3_list.csv", varn(1) clear case(preserve)
merge 1:m Mtin using "${features_final}/All_return_features_minus_q12.dta"
keep if _merge == 3
keep Mtin Rename bogus_flag RegistrationStatus
duplicates drop
merge 1:1 Mtin using "${final_list}/final/FinalSelectedFirms.dta", keepusing(p_allfeatures) 
keep if _merge == 3
drop _merge
gsort Rename


**********************************************************
/* Firm 4 (same as Firm 3) */
**********************************************************
* mtin == 1841320 taxquarter == 20 (2014-15, q4)
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if Mtin == "1841320" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop
			
*check if reverse is true
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if (Mtin == "1522818" | Mtin == "1988853" )& ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1841320"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches

** Purchaser from bogus firm
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if Mtin == "1841320" & SaleOrPurchase == "BF"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

/*check interaction between purchase and sales firm*/
** sales side firms and 2a
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if (Mtin == "1903813"|	Mtin == "1510170" ///
|	Mtin == "1561766"|	Mtin == "1950138" ///
|	Mtin == "1568153"|	Mtin == "1310673" ///
|	Mtin == "1188788"|	Mtin == "1851228" ///
|	Mtin == "1982886"|	Mtin == "1104274" ///
|	Mtin == "1787317"|	Mtin == "1183874" ///
|	Mtin == "1700585") & SaleOrPurchase == "AE"
keep if (SellerBuyerTin == "1841320"|	SellerBuyerTin == "1522818" ///
|	SellerBuyerTin == "1988853"|	SellerBuyerTin == "1688488" ///
|	SellerBuyerTin == "1123946"|	SellerBuyerTin == "1192516" ///
|	SellerBuyerTin == "1522670"|	SellerBuyerTin == "1310032" ///
|	SellerBuyerTin == "1633967"|	SellerBuyerTin == "1878281" ///
|	SellerBuyerTin == "1538287"|	SellerBuyerTin == "1693629" ///
|	SellerBuyerTin == "1651612")  
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 
	
** sales side firms and 2b
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if (Mtin == "1903813"|	Mtin == "1510170" ///
|	Mtin == "1561766"|	Mtin == "1950138" ///
|	Mtin == "1568153"|	Mtin == "1310673" ///
|	Mtin == "1188788"|	Mtin == "1851228" ///
|	Mtin == "1982886"|	Mtin == "1104274" ///
|	Mtin == "1787317"|	Mtin == "1183874" ///
|	Mtin == "1700585") & SaleOrPurchase == "BF"
keep if (SellerBuyerTin == "1841320"|	SellerBuyerTin == "1522818" ///
|	SellerBuyerTin == "1988853"|	SellerBuyerTin == "1688488" ///
|	SellerBuyerTin == "1123946"|	SellerBuyerTin == "1192516" ///
|	SellerBuyerTin == "1522670"|	SellerBuyerTin == "1310032" ///
|	SellerBuyerTin == "1633967"|	SellerBuyerTin == "1878281" ///
|	SellerBuyerTin == "1538287"|	SellerBuyerTin == "1693629" ///
|	SellerBuyerTin == "1651612")  
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

** purchase side firms and 2a
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if (Mtin == "1841320"|	Mtin == "1522818" ///
|	Mtin == "1988853"|	Mtin == "1688488" ///
|	Mtin == "1123946"|	Mtin == "1192516" ///
|	Mtin == "1522670"|	Mtin == "1310032" ///
|	Mtin == "1633967"|	Mtin == "1878281" ///
|	Mtin == "1538287"|	Mtin == "1693629" ///
|	Mtin == "1651612") & SaleOrPurchase == "AE" 
keep if (SellerBuyerTin == "1903813"|	SellerBuyerTin == "1510170" ///
|	SellerBuyerTin == "1561766"|	SellerBuyerTin == "1950138" ///
|	SellerBuyerTin == "1568153"|	SellerBuyerTin == "1310673" ///
|	SellerBuyerTin == "1188788"|	SellerBuyerTin == "1851228" ///
|	SellerBuyerTin == "1982886"|	SellerBuyerTin == "1104274" ///
|	SellerBuyerTin == "1787317"|	SellerBuyerTin == "1183874" ///
|	SellerBuyerTin == "1700585") 
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

** purchase side firms and 2b (don't include Master Bogus firm)
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if (Mtin == "1841320"|	Mtin == "1522818" ///
|	Mtin == "1988853"|	Mtin == "1688488" ///
|	Mtin == "1123946"|	Mtin == "1192516" ///
|	Mtin == "1522670"|	Mtin == "1310032" ///
|	Mtin == "1633967"|	Mtin == "1878281" ///
|	Mtin == "1538287"|	Mtin == "1693629" ///
|	Mtin == "1651612") & SaleOrPurchase == "BF" 
keep if (SellerBuyerTin == "1903813"|	SellerBuyerTin == "1510170" ///
|	SellerBuyerTin == "1561766"|	SellerBuyerTin == "1950138" ///
|	SellerBuyerTin == "1568153"|	SellerBuyerTin == "1310673" ///
|	SellerBuyerTin == "1188788"|	SellerBuyerTin == "1851228" ///
|	SellerBuyerTin == "1982886"|	SellerBuyerTin == "1104274" ///
|	SellerBuyerTin == "1787317"|	SellerBuyerTin == "1183874" ///
|	SellerBuyerTin == "1700585") 
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

/* Import more information about firms interacting with Firm 4 */
*import the file (created manually)
import delim "${analysis_path1}/network_analysis/Firm4_list.csv", varn(1) clear case(preserve)
merge 1:m Mtin using "${features_final}/All_return_features_minus_q12.dta"
keep if _merge == 3
keep Mtin Rename bogus_flag RegistrationStatus
duplicates drop
merge 1:1 Mtin using "${final_list}/final/FinalSelectedFirms.dta", keepusing(p_allfeatures) 
keep if _merge == 3
drop _merge
gsort Rename


**********************************************************
/* Firm 5 */
**********************************************************
* mtin == 1910917 taxquarter == 20 (2014-15, q4)
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if Mtin == "1910917" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop
			
*check if reverse is true
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if (Mtin == "1046135" | Mtin == "1407938" | Mtin == "1260243" )& ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1910917"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches

/* EXPLORE each 1nd degree seller/purchaser firms */ 
** Seller 2
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if Mtin == "1046135" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

*check if reverse is true
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if (Mtin == "1910917" | Mtin == "1407938" | Mtin == "1260243" )& ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1046135"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches

** Seller 3 
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if Mtin == "1407938" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

*check if reverse is true
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if (Mtin == "1585403" | Mtin == "1046135" | Mtin == "1913662" )& ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1407938"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches

* Seller 4 
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if Mtin == "1260243" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

*check if reverse is true
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if (Mtin == "1913662" | Mtin == "1585403")& ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1260243"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches

/* EXPLORE each 2nd degree seller/purchaser firms */ 
** Seller 5
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if Mtin == "1585403" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop // no values

** Seller 6
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if Mtin == "1913662" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop // no values

/* Sales side of Master Bogus Firm */
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if Mtin == "1910917" & SaleOrPurchase == "BF"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

/*check interaction between purchase and sales firm*/
** sales side firms and 2a
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if (Mtin == "1635613"|	Mtin == "1461527" ///
|	Mtin == "1328204"|	Mtin == "1294778" ///
|	Mtin == "1592994"|	Mtin == "1339067" ///
|	Mtin == "1651268"|	Mtin == "1698794" ///
|	Mtin == "1362430"|	Mtin == "1776452" ///
|	Mtin == "1638239"|	Mtin == "1377606" ///
|	Mtin == "1385788"|	Mtin == "1248727" ///
|	Mtin == "1548770"|	Mtin == "1379214" ///
|	Mtin == "1947969"|	Mtin == "1442956" ///
|	Mtin == "1637524"|	Mtin == "1757731" ///
|	Mtin == "1566841"|	Mtin == "1704506" ///
|	Mtin == "1073349"|	Mtin == "1834911" ///
|	Mtin == "1190151"|	Mtin == "1924738" ///
|	Mtin == "1639760"|	Mtin == "1677120") & SaleOrPurchase == "AE"
keep if (SellerBuyerTin == "1910917"|	SellerBuyerTin == "1046135" ///
|	SellerBuyerTin == "1407938"|	SellerBuyerTin == "1260243" ///
|	SellerBuyerTin == "1585403"|	SellerBuyerTin == "1913662")  
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 
	
** sales side firms and 2b
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if (Mtin == "1635613"|	Mtin == "1461527" ///
|	Mtin == "1328204"|	Mtin == "1294778" ///
|	Mtin == "1592994"|	Mtin == "1339067" ///
|	Mtin == "1651268"|	Mtin == "1698794" ///
|	Mtin == "1362430"|	Mtin == "1776452" ///
|	Mtin == "1638239"|	Mtin == "1377606" ///
|	Mtin == "1385788"|	Mtin == "1248727" ///
|	Mtin == "1548770"|	Mtin == "1379214" ///
|	Mtin == "1947969"|	Mtin == "1442956" ///
|	Mtin == "1637524"|	Mtin == "1757731" ///
|	Mtin == "1566841"|	Mtin == "1704506" ///
|	Mtin == "1073349"|	Mtin == "1834911" ///
|	Mtin == "1190151"|	Mtin == "1924738" ///
|	Mtin == "1639760"|	Mtin == "1677120") & SaleOrPurchase == "BF"
keep if (SellerBuyerTin == "1910917"|	SellerBuyerTin == "1046135" ///
|	SellerBuyerTin == "1407938"|	SellerBuyerTin == "1260243" ///
|	SellerBuyerTin == "1585403"|	SellerBuyerTin == "1913662")  
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop // no observations

** purchase side firms and 2a
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if (Mtin == "1910917"|	Mtin == "1046135" ///
|	Mtin == "1407938"|	Mtin == "1260243" ///
|	Mtin == "1585403"|	Mtin == "1913662")  & SaleOrPurchase == "AE"
keep if (SellerBuyerTin == "1635613"|	SellerBuyerTin == "1461527" ///
|	SellerBuyerTin == "1328204"|	SellerBuyerTin == "1294778" ///
|	SellerBuyerTin == "1592994"|	SellerBuyerTin == "1339067" ///
|	SellerBuyerTin == "1651268"|	SellerBuyerTin == "1698794" ///
|	SellerBuyerTin == "1362430"|	SellerBuyerTin == "1776452" ///
|	SellerBuyerTin == "1638239"|	SellerBuyerTin == "1377606" ///
|	SellerBuyerTin == "1385788"|	SellerBuyerTin == "1248727" ///
|	SellerBuyerTin == "1548770"|	SellerBuyerTin == "1379214" ///
|	SellerBuyerTin == "1947969"|	SellerBuyerTin == "1442956" ///
|	SellerBuyerTin == "1637524"|	SellerBuyerTin == "1757731" ///
|	SellerBuyerTin == "1566841"|	SellerBuyerTin == "1704506" ///
|	SellerBuyerTin == "1073349"|	SellerBuyerTin == "1834911" ///
|	SellerBuyerTin == "1190151"|	SellerBuyerTin == "1924738" ///
|	SellerBuyerTin == "1639760"|	SellerBuyerTin == "1677120") 
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop // no observation

** purchase side firms and 2b (don't include Master Bogus firm)
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if (Mtin == "1910917"|	Mtin == "1046135" ///
|	Mtin == "1407938"|	Mtin == "1260243" ///
|	Mtin == "1585403"|	Mtin == "1913662")  & SaleOrPurchase == "BF"
keep if (SellerBuyerTin == "1635613"|	SellerBuyerTin == "1461527" ///
|	SellerBuyerTin == "1328204"|	SellerBuyerTin == "1294778" ///
|	SellerBuyerTin == "1592994"|	SellerBuyerTin == "1339067" ///
|	SellerBuyerTin == "1651268"|	SellerBuyerTin == "1698794" ///
|	SellerBuyerTin == "1362430"|	SellerBuyerTin == "1776452" ///
|	SellerBuyerTin == "1638239"|	SellerBuyerTin == "1377606" ///
|	SellerBuyerTin == "1385788"|	SellerBuyerTin == "1248727" ///
|	SellerBuyerTin == "1548770"|	SellerBuyerTin == "1379214" ///
|	SellerBuyerTin == "1947969"|	SellerBuyerTin == "1442956" ///
|	SellerBuyerTin == "1637524"|	SellerBuyerTin == "1757731" ///
|	SellerBuyerTin == "1566841"|	SellerBuyerTin == "1704506" ///
|	SellerBuyerTin == "1073349"|	SellerBuyerTin == "1834911" ///
|	SellerBuyerTin == "1190151"|	SellerBuyerTin == "1924738" ///
|	SellerBuyerTin == "1639760"|	SellerBuyerTin == "1677120") 
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

/* Import more information about firms interacting with Firm 1 */
*import the file (created manually)
import delim "${analysis_path1}/network_analysis/Firm5_list.csv", varn(1) clear case(preserve)
merge 1:m Mtin using "${features_final}/All_return_features_minus_q12.dta"
keep if _merge == 3
keep Mtin Rename bogus_flag RegistrationStatus
duplicates drop
merge 1:1 Mtin using "${final_list}/final/FinalSelectedFirms.dta", keepusing(p_allfeatures) 
keep if _merge == 3
drop _merge
gsort Rename


**********************************************************
/* Firm 6 */
**********************************************************
* mtin == 1380115 taxquarter == 22 (2015-16, q2)
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1380115" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop
			
*check if reverse is true
use "${output_path}/2a2b_2015_q2.dta", clear
keep if (Mtin == "1046135" | Mtin == "1910917" | Mtin == "1553644" | Mtin == "1896970" | Mtin == "1908789" | Mtin == "1205498")& ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1380115"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches

/* EXPLORE each 1nd degree seller firms */ 
** Seller 1 
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1046135" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

** Seller 2 
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1910917" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

** Seller 3 
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1553644" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

*check if reverse is true
use "${output_path}/2a2b_2015_q2.dta", clear
keep if (Mtin == "1893402" | Mtin == "1032951" | Mtin == "1896970" | Mtin == "1045974" | Mtin == "1260243" | Mtin == "1407938" )& ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1553644"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches

** Seller 4
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1896970" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

*check if reverse is true
use "${output_path}/2a2b_2015_q2.dta", clear
keep if (Mtin == "1045974" | Mtin == "1068698" | Mtin == "1380115" )& ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1896970"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches

** Seller 5
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1908789" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

*check if reverse is true
use "${output_path}/2a2b_2015_q2.dta", clear
keep if (Mtin == "1207611" | Mtin == "1380115" | Mtin == "1097713" )& ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1908789"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches

** Seller 6
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1205498" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

*check if reverse is true
use "${output_path}/2a2b_2015_q2.dta", clear
keep if (Mtin == "1207611" | Mtin == "1380115" )& ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1205498"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches


/* EXPLORE each 2nd degree seller firms */ 
** Seller 8
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1893402" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

*check if reverse is true
use "${output_path}/2a2b_2015_q2.dta", clear
keep if (Mtin == "1207611" | Mtin == "1380115" | Mtin == "1363724" )& ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1893402"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches

** Seller 9
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1032951" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop // no values

** Seller 10
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1045974" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

*check if reverse is true
use "${output_path}/2a2b_2015_q2.dta", clear
keep if (Mtin == "1068698" | Mtin == "1207611" )& ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1045974"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches

** Seller 11
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1260243" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

** Seller 12
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1407938" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

*check if reverse is true
use "${output_path}/2a2b_2015_q2.dta", clear
keep if (Mtin == "1046135" | Mtin == "1553644" | Mtin == "1068698" | Mtin == "1910917" )& ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1407938"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches


** Seller 13
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1068698" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

*check if reverse is true
use "${output_path}/2a2b_2015_q2.dta", clear
keep if (Mtin == "1908789" | Mtin == "1045974" | Mtin == "1694906" | Mtin == "1896970" | Mtin == "1893402")& ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1068698"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches

** Seller 14
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1207611" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

*check if reverse is true
use "${output_path}/2a2b_2015_q2.dta", clear
keep if (Mtin == "1407938" | Mtin == "1380115" | Mtin == "1046135" | Mtin == "1363724" | Mtin == "1068698" | Mtin == "1910917")& ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1207611"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches

** Seller 15
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1097713" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

/* EXPLORE each 3rd degree seller firms */ 
** Seller 16
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1363724" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

*check if reverse is true
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1915931"& ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1363724"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches

** Seller 17
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1694906" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

/* EXPLORE each 4th degree seller firms */ 
** Seller 18
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1915931" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

/* Sales side of Master Bogus Firm */
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1380115" & SaleOrPurchase == "BF"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

/*check interaction between purchase and sales firm*/
** sales side firms and 2a
use "${output_path}/2a2b_2015_q2.dta", clear
keep if (Mtin == "1102506" | Mtin == "1382677" | Mtin == "1557335" ///
	| Mtin == "1190151" | Mtin == "1052134" | Mtin == "1677120" ///
	| Mtin == "1560137" | Mtin == "1834911" | Mtin == "1404230" ///
	| Mtin == "1149793" | Mtin == "1603716" | Mtin == "1028048" ///
	| Mtin == "1123980" | Mtin == "1888547" | Mtin == "1502871" ///
	| Mtin == "1896755" | Mtin == "1284565" | Mtin == "1639760" ///
	| Mtin == "1002356" | Mtin == "1736155" | Mtin == "1924738" ///
	| Mtin == "1496951" | Mtin == "1280698" | Mtin == "1484280" ///
	| Mtin == "1635613" | Mtin == "1328204" | Mtin == "1294778" ///
	| Mtin == "1446102" | Mtin == "1592994" | Mtin == "1835029" ///
	| Mtin == "1106734" | Mtin == "1528632" | Mtin == "1698794" ///
	| Mtin == "1057588" | Mtin == "1696645" | Mtin == "1162385" ///
	| Mtin == "1338273" | Mtin == "1442956" | Mtin == "1638239" ///
	| 	Mtin == "1755429") & SaleOrPurchase == "AE"
keep if (SellerBuyerTin == "1380115" | SellerBuyerTin == "1046135" ///
	| SellerBuyerTin == "1910917" | SellerBuyerTin == "1553644" ///
	| SellerBuyerTin == "1896970" | SellerBuyerTin == "1908789" ///
	| SellerBuyerTin == "1205498" | SellerBuyerTin == "1893402" ///
	| SellerBuyerTin == "1032951" | SellerBuyerTin == "1045974" ///
	| SellerBuyerTin == "1260243" | SellerBuyerTin == "1407938" ///
	| SellerBuyerTin == "1068698" | SellerBuyerTin == "1207611" ///
	| SellerBuyerTin == "1097713" | SellerBuyerTin == "1363724" ///
	| SellerBuyerTin == "1694906" | SellerBuyerTin == "1915931")  
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 
	
** sales side firms and 2b
use "${output_path}/2a2b_2015_q2.dta", clear
keep if (Mtin == "1102506" | Mtin == "1382677" | Mtin == "1557335" ///
	| Mtin == "1190151" | Mtin == "1052134" | Mtin == "1677120" ///
	| Mtin == "1560137" | Mtin == "1834911" | Mtin == "1404230" ///
	| Mtin == "1149793" | Mtin == "1603716" | Mtin == "1028048" ///
	| Mtin == "1123980" | Mtin == "1888547" | Mtin == "1502871" ///
	| Mtin == "1896755" | Mtin == "1284565" | Mtin == "1639760" ///
	| Mtin == "1002356" | Mtin == "1736155" | Mtin == "1924738" ///
	| Mtin == "1496951" | Mtin == "1280698" | Mtin == "1484280" ///
	| Mtin == "1635613" | Mtin == "1328204" | Mtin == "1294778" ///
	| Mtin == "1446102" | Mtin == "1592994" | Mtin == "1835029" ///
	| Mtin == "1106734" | Mtin == "1528632" | Mtin == "1698794" ///
	| Mtin == "1057588" | Mtin == "1696645" | Mtin == "1162385" ///
	| Mtin == "1338273" | Mtin == "1442956" | Mtin == "1638239" ///
	| 	Mtin == "1755429") & SaleOrPurchase == "BF"
keep if (SellerBuyerTin == "1380115" | SellerBuyerTin == "1046135" ///
	| SellerBuyerTin == "1910917" | SellerBuyerTin == "1553644" ///
	| SellerBuyerTin == "1896970" | SellerBuyerTin == "1908789" ///
	| SellerBuyerTin == "1205498" | SellerBuyerTin == "1893402" ///
	| SellerBuyerTin == "1032951" | SellerBuyerTin == "1045974" ///
	| SellerBuyerTin == "1260243" | SellerBuyerTin == "1407938" ///
	| SellerBuyerTin == "1068698" | SellerBuyerTin == "1207611" ///
	| SellerBuyerTin == "1097713" | SellerBuyerTin == "1363724" ///
	| SellerBuyerTin == "1694906" | SellerBuyerTin == "1915931")
keep SaleOrPurchase Mtin SellerBuyerTin // no observations
duplicates drop 

** purchase side firms and 2a
use "${output_path}/2a2b_2015_q2.dta", clear
keep if (Mtin == "1380115" | Mtin == "1046135" ///
	| Mtin == "1910917" | Mtin == "1553644" ///
	| Mtin == "1896970" | Mtin == "1908789" ///
	| Mtin == "1205498" | Mtin == "1893402" ///
	| Mtin == "1032951" | Mtin == "1045974" ///
	| Mtin == "1260243" | Mtin == "1407938" ///
	| Mtin == "1068698" | Mtin == "1207611" ///
	| Mtin == "1097713" | Mtin == "1363724" ///
	| Mtin == "1694906" | Mtin == "1915931") & SaleOrPurchase == "AE"
keep if (SellerBuyerTin == "1102506" | SellerBuyerTin == "1382677" | SellerBuyerTin == "1557335" ///
	| SellerBuyerTin == "1190151" | SellerBuyerTin == "1052134" | SellerBuyerTin == "1677120" ///
	| SellerBuyerTin == "1560137" | SellerBuyerTin == "1834911" | SellerBuyerTin == "1404230" ///
	| SellerBuyerTin == "1149793" | SellerBuyerTin == "1603716" | SellerBuyerTin == "1028048" ///
	| SellerBuyerTin == "1123980" | SellerBuyerTin == "1888547" | SellerBuyerTin == "1502871" ///
	| SellerBuyerTin == "1896755" | SellerBuyerTin == "1284565" | SellerBuyerTin == "1639760" ///
	| SellerBuyerTin == "1002356" | SellerBuyerTin == "1736155" | SellerBuyerTin == "1924738" ///
	| SellerBuyerTin == "1496951" | SellerBuyerTin == "1280698" | SellerBuyerTin == "1484280" ///
	| SellerBuyerTin == "1635613" | SellerBuyerTin == "1328204" | SellerBuyerTin == "1294778" ///
	| SellerBuyerTin == "1446102" | SellerBuyerTin == "1592994" | SellerBuyerTin == "1835029" ///
	| SellerBuyerTin == "1106734" | SellerBuyerTin == "1528632" | SellerBuyerTin == "1698794" ///
	| SellerBuyerTin == "1057588" | SellerBuyerTin == "1696645" | SellerBuyerTin == "1162385" ///
	| SellerBuyerTin == "1338273" | SellerBuyerTin == "1442956" | SellerBuyerTin == "1638239" ///
	| 	SellerBuyerTin == "1755429") // no observations
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

** purchase side firms and 2b (don't include Master Bogus firm)
use "${output_path}/2a2b_2015_q2.dta", clear
keep if (Mtin == "1380115" | Mtin == "1046135" ///
	| Mtin == "1910917" | Mtin == "1553644" ///
	| Mtin == "1896970" | Mtin == "1908789" ///
	| Mtin == "1205498" | Mtin == "1893402" ///
	| Mtin == "1032951" | Mtin == "1045974" ///
	| Mtin == "1260243" | Mtin == "1407938" ///
	| Mtin == "1068698" | Mtin == "1207611" ///
	| Mtin == "1097713" | Mtin == "1363724" ///
	| Mtin == "1694906" | Mtin == "1915931") & SaleOrPurchase == "BF"
keep if (SellerBuyerTin == "1102506" | SellerBuyerTin == "1382677" | SellerBuyerTin == "1557335" ///
	| SellerBuyerTin == "1190151" | SellerBuyerTin == "1052134" | SellerBuyerTin == "1677120" ///
	| SellerBuyerTin == "1560137" | SellerBuyerTin == "1834911" | SellerBuyerTin == "1404230" ///
	| SellerBuyerTin == "1149793" | SellerBuyerTin == "1603716" | SellerBuyerTin == "1028048" ///
	| SellerBuyerTin == "1123980" | SellerBuyerTin == "1888547" | SellerBuyerTin == "1502871" ///
	| SellerBuyerTin == "1896755" | SellerBuyerTin == "1284565" | SellerBuyerTin == "1639760" ///
	| SellerBuyerTin == "1002356" | SellerBuyerTin == "1736155" | SellerBuyerTin == "1924738" ///
	| SellerBuyerTin == "1496951" | SellerBuyerTin == "1280698" | SellerBuyerTin == "1484280" ///
	| SellerBuyerTin == "1635613" | SellerBuyerTin == "1328204" | SellerBuyerTin == "1294778" ///
	| SellerBuyerTin == "1446102" | SellerBuyerTin == "1592994" | SellerBuyerTin == "1835029" ///
	| SellerBuyerTin == "1106734" | SellerBuyerTin == "1528632" | SellerBuyerTin == "1698794" ///
	| SellerBuyerTin == "1057588" | SellerBuyerTin == "1696645" | SellerBuyerTin == "1162385" ///
	| SellerBuyerTin == "1338273" | SellerBuyerTin == "1442956" | SellerBuyerTin == "1638239" ///
	| SellerBuyerTin == "1755429") 
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

/* Import more information about firms interacting with Firm 1 */
*import the file (created manually)
import delim "${analysis_path1}/network_analysis/Firm6_list.csv", varn(1) clear case(preserve)
merge 1:m Mtin using "${features_final}/All_return_features_minus_q12.dta"
keep if _merge == 3
keep Mtin Rename bogus_flag RegistrationStatus
duplicates drop
merge 1:1 Mtin using "${final_list}/final/FinalSelectedFirms.dta", keepusing(p_allfeatures) 
keep if _merge == 3
drop _merge
gsort Rename


**********************************************************
/* Firm 7 */
**********************************************************
* mtin == 1394065 taxquarter == 17 (2014-15, q1)
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "First Quarter-2014"
keep if Mtin == "1394065" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 
			
*check if reverse is true
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "First Quarter-2014"
keep if (Mtin == "1817153" | Mtin == "1529065") & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1394065"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches

/* EXPLORE each 1nd degree seller firms */ 
** Seller 2 
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "First Quarter-2014"
keep if Mtin == "1817153" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

*check if reverse is true
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "First Quarter-2014"
keep if Mtin == "1556191"  & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1817153"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches

** Seller 3
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "First Quarter-2014"
keep if Mtin == "1529065" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "First Quarter-2014"
keep if (Mtin == "1025755" | Mtin == "1271673" | Mtin == "1817153" | Mtin == "1198325" | Mtin == "1164819" | Mtin == "1966499" | Mtin == "1845720" | Mtin == "1488394")& ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1529065"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches


/* EXPLORE each 1nd degree seller firms */ 
** Seller 4 
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "First Quarter-2014"
keep if Mtin == "1556191" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

*check if reverse is true
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "First Quarter-2014"
keep if Mtin == "1759857"  & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1556191"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // all matches


** Seller 5 
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "First Quarter-2014"
keep if Mtin == "1025755" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop // 292 firms

** Seller 6 
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "First Quarter-2014"
keep if Mtin == "1271673" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

*check if reverse is true
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "First Quarter-2014"
keep if (Mtin == "1384785" | Mtin == "1989186" | Mtin == "1546150" | Mtin == "1311887" | Mtin == "1739340")  & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1271673"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // all matches

** Seller 7 
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "First Quarter-2014"
keep if Mtin == "1198325" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

*check if reverse is true
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "First Quarter-2014"
keep if (Mtin == "1031270" | Mtin == "1990325" | Mtin == "1476331" )  & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1198325"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // all matches

** Seller 8
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "First Quarter-2014"
keep if Mtin == "1164819" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

*check if reverse is true
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "First Quarter-2014"
keep if (Mtin == "1554697" | Mtin == "1729594" | Mtin == "1842709" | Mtin == "1152063")  & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1164819"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // all matches

** Seller 9
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "First Quarter-2014"
keep if Mtin == "1966499" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "First Quarter-2014"
keep if Mtin == "1556191"   & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1966499"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // all matches

** Seller 10 
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "First Quarter-2014"
keep if Mtin == "1845720" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "First Quarter-2014"
keep if (Mtin == "1476331" | Mtin == "1031270" | Mtin == "1990325")  & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1845720"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // all matches

** Seller 11 
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "First Quarter-2014"
keep if Mtin == "1488394" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "First Quarter-2014"
keep if Mtin == "1556191"  & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1488394"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // all matches

** Purchaser from bogus firm
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "First Quarter-2014"
keep if Mtin == "1394065" & SaleOrPurchase == "BF"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

/*check interaction between purchase and sales firm*/
** sales side firms and 2a
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "First Quarter-2014"
keep if (Mtin == "1113847" |	Mtin == "1564755" |	Mtin == "1150829" ///
	  |	 Mtin == "1770740" |	Mtin == "1878930" |	Mtin == "1661128" ///
	  |	 Mtin == "1954029" |	Mtin == "1367771" |	Mtin == "1158901" ///
	  |	 Mtin == "1762396" |	Mtin == "1211759" |	Mtin == "1956719" ///
	  |	Mtin == "1329748" |	Mtin == "1456546" |	Mtin == "1054852") & SaleOrPurchase == "AE"
keep if ( SellerBuyerTin == "1394065" |	SellerBuyerTin == "1817153" |	SellerBuyerTin == "1529065" ///
	|	SellerBuyerTin == "1556191" |	SellerBuyerTin == "1025755" |	SellerBuyerTin == "1271673" ///
	|	SellerBuyerTin == "1198325" |	SellerBuyerTin == "1164819" |	SellerBuyerTin == "1966499" ///
	|	SellerBuyerTin == "1845720" |	SellerBuyerTin == "1488394" |	SellerBuyerTin == "1759857" ///
	|	SellerBuyerTin == "1384785" |	SellerBuyerTin == "1989186" |	SellerBuyerTin == "1546150" ///
	|	SellerBuyerTin == "1311887" |	SellerBuyerTin == "1739340" |	SellerBuyerTin == "1031270" ///
	|	SellerBuyerTin == "1990325" |	SellerBuyerTin == "1476331" |	SellerBuyerTin == "1554697" ///
	|	SellerBuyerTin == "1729594" |	SellerBuyerTin == "1842709" |	SellerBuyerTin == "1152063")
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 
	
** sales side firms and 2b
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "First Quarter-2014"
keep if (Mtin == "1113847" |	Mtin == "1564755" |	Mtin == "1150829" ///
	  |	 Mtin == "1770740" |	Mtin == "1878930" |	Mtin == "1661128" ///
	  |	 Mtin == "1954029" |	Mtin == "1367771" |	Mtin == "1158901" ///
	  |	 Mtin == "1762396" |	Mtin == "1211759" |	Mtin == "1956719" ///
	  |	Mtin == "1329748" |	Mtin == "1456546" |	Mtin == "1054852") & SaleOrPurchase == "BF"
keep if ( SellerBuyerTin == "1394065" |	SellerBuyerTin == "1817153" |	SellerBuyerTin == "1529065" ///
	|	SellerBuyerTin == "1556191" |	SellerBuyerTin == "1025755" |	SellerBuyerTin == "1271673" ///
	|	SellerBuyerTin == "1198325" |	SellerBuyerTin == "1164819" |	SellerBuyerTin == "1966499" ///
	|	SellerBuyerTin == "1845720" |	SellerBuyerTin == "1488394" |	SellerBuyerTin == "1759857" ///
	|	SellerBuyerTin == "1384785" |	SellerBuyerTin == "1989186" |	SellerBuyerTin == "1546150" ///
	|	SellerBuyerTin == "1311887" |	SellerBuyerTin == "1739340" |	SellerBuyerTin == "1031270" ///
	|	SellerBuyerTin == "1990325" |	SellerBuyerTin == "1476331" |	SellerBuyerTin == "1554697" ///
	|	SellerBuyerTin == "1729594" |	SellerBuyerTin == "1842709" |	SellerBuyerTin == "1152063")
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

** purchase side firms and 2a
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "First Quarter-2014"
keep if ( Mtin == "1394065" |	Mtin == "1817153" |	Mtin == "1529065" ///
	|	Mtin == "1556191" |	Mtin == "1025755" |	Mtin == "1271673" ///
	|	Mtin == "1198325" |	Mtin == "1164819" |	Mtin == "1966499" ///
	|	Mtin == "1845720" |	Mtin == "1488394" |	Mtin == "1759857" ///
	|	Mtin == "1384785" |	Mtin == "1989186" |	Mtin == "1546150" ///
	|	Mtin == "1311887" |	Mtin == "1739340" |	Mtin == "1031270" ///
	|	Mtin == "1990325" |	Mtin == "1476331" |	Mtin == "1554697" ///
	|	Mtin == "1729594" |	Mtin == "1842709" |	Mtin == "1152063") ///
	& SaleOrPurchase == "AE"
keep if (SellerBuyerTin == "1113847" |	SellerBuyerTin == "1564755" |	SellerBuyerTin == "1150829" ///
	  |	 SellerBuyerTin == "1770740" |	SellerBuyerTin == "1878930" |	SellerBuyerTin == "1661128" ///
	  |	 SellerBuyerTin == "1954029" |	SellerBuyerTin == "1367771" |	SellerBuyerTin == "1158901" ///
	  |	 SellerBuyerTin == "1762396" |	SellerBuyerTin == "1211759" |	SellerBuyerTin == "1956719" ///
	  |	SellerBuyerTin == "1329748"  |	SellerBuyerTin == "1456546" |	SellerBuyerTin == "1054852") 
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

** purchase side firms and 2b (don't include Master Bogus firm)
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "First Quarter-2014"
keep if ( Mtin == "1394065" |	Mtin == "1817153" |	Mtin == "1529065" ///
	|	Mtin == "1556191" |	Mtin == "1025755" |	Mtin == "1271673" ///
	|	Mtin == "1198325" |	Mtin == "1164819" |	Mtin == "1966499" ///
	|	Mtin == "1845720" |	Mtin == "1488394" |	Mtin == "1759857" ///
	|	Mtin == "1384785" |	Mtin == "1989186" |	Mtin == "1546150" ///
	|	Mtin == "1311887" |	Mtin == "1739340" |	Mtin == "1031270" ///
	|	Mtin == "1990325" |	Mtin == "1476331" |	Mtin == "1554697" ///
	|	Mtin == "1729594" |	Mtin == "1842709" |	Mtin == "1152063") ///
	& SaleOrPurchase == "BF"
keep if (SellerBuyerTin == "1113847" |	SellerBuyerTin == "1564755" |	SellerBuyerTin == "1150829" ///
	  |	 SellerBuyerTin == "1770740" |	SellerBuyerTin == "1878930" |	SellerBuyerTin == "1661128" ///
	  |	 SellerBuyerTin == "1954029" |	SellerBuyerTin == "1367771" |	SellerBuyerTin == "1158901" ///
	  |	 SellerBuyerTin == "1762396" |	SellerBuyerTin == "1211759" |	SellerBuyerTin == "1956719" ///
	  |	SellerBuyerTin == "1329748"  |	SellerBuyerTin == "1456546" |	SellerBuyerTin == "1054852") 
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 


/* Import more information about firms interacting with Firm 1 */
*import the file (created manually)
import delim "${analysis_path1}/network_analysis/Firm7_list.csv", varn(1) clear case(preserve)
merge 1:m Mtin using "${features_final}/All_return_features_minus_q12.dta"
keep if _merge == 3
keep Mtin Rename bogus_flag RegistrationStatus
duplicates drop
merge 1:1 Mtin using "${final_list}/final/FinalSelectedFirms.dta", keepusing(p_allfeatures) 
keep if _merge == 3
drop _merge
gsort Rename


**********************************************************
/* Firm 8 */
**********************************************************
* mtin == 1394065 taxquarter == 22 (2015-16, q2)
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1553644" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 
			
*check if reverse is true
use "${output_path}/2a2b_2015_q2.dta", clear
keep if (Mtin == "1893402" | Mtin == "1032951" | Mtin == "1896970" | Mtin == "1045974" | Mtin == "1260243" | Mtin == "1407938") & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1553644"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches

/* EXPLORE each 1st degree seller/purchaser firms */ 
** Seller 2
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1893402" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

*check if reverse is true
use "${output_path}/2a2b_2015_q2.dta", clear
keep if (Mtin == "1207611" | Mtin == "1380115" | Mtin == "1363724" ) & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1893402"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches

** Seller 3 
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1032951" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

** Seller 4 
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1896970" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

*check if reverse is true
use "${output_path}/2a2b_2015_q2.dta", clear
keep if (Mtin == "1045974" | Mtin == "1380115" | Mtin == "1068698" ) & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1896970"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop 

** Seller 5 
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1045974" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

*check if reverse is true
use "${output_path}/2a2b_2015_q2.dta", clear
keep if (Mtin == "1207611" | Mtin == "1046135") & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1045974"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // no observations


** Seller 6 
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1260243" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

** Seller 7 
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1407938" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

*check if reverse is true
use "${output_path}/2a2b_2015_q2.dta", clear
keep if (Mtin == "1046135" | Mtin == "1910917" | Mtin == "1908789" | Mtin == "1205498") & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1407938"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // no observations

/* EXPLORE each 2nd degree seller/purchaser firms */ 
** Seller 8
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1380115" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

*check if reverse is true
use "${output_path}/2a2b_2015_q2.dta", clear
keep if (Mtin == "1553644" | Mtin == "1896970" | Mtin == "1046135" | Mtin == "1910917" | Mtin == "1908789" | Mtin == "1205498") & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1380115"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // no observations

** Seller 9 
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1207611" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

*check if reverse is true
use "${output_path}/2a2b_2015_q2.dta", clear
keep if (Mtin == "1407938" | Mtin == "1380115" | Mtin == "1207611" | Mtin == "1363724" | Mtin == "1068698" | Mtin == "1046135" | Mtin == "1910917") & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1207611"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // no observations

** Seller 10 
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1363724" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

*check if reverse is true
use "${output_path}/2a2b_2015_q2.dta", clear
keep if (Mtin == "1915931" ) & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1363724"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // no observations

** Seller 11 
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1068698" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

*check if reverse is true
use "${output_path}/2a2b_2015_q2.dta", clear
keep if (Mtin == "1893402" | Mtin == "1896970" | Mtin == "1045974" | Mtin == "1908789" | Mtin == "1915931" ) & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1068698"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // no observations

** Seller 12
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1046135" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

** Seller 13 
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1910917" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

** Seller 14
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1908789" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

*check if reverse is true
use "${output_path}/2a2b_2015_q2.dta", clear
keep if (Mtin == "1407938" | Mtin == "1207611" | Mtin == "1097713" ) & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1908789"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // no observations

** Seller 15 
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1205498" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

use "${output_path}/2a2b_2015_q2.dta", clear
keep if (Mtin == "1407938" | Mtin == "1207611" ) & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1205498"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // no observations

/* EXPLORE each 1st degree seller/purchaser firms */ 
** Seller 16
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1915931" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop // no observations

** Seller 17
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1694906" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop // no observations

** Seller 18
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1097713" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop // no observations

** Purchaser from bogus firm
use "${output_path}/2a2b_2015_q2.dta", clear
keep if Mtin == "1553644" & SaleOrPurchase == "BF"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 


/*check interaction between purchase and sales firm*/
** sales side firms and 2a
use "${output_path}/2a2b_2015_q2.dta", clear
keep if (Mtin == "1698794" |	Mtin == "1704506" |	Mtin == "1187616" ///
	|	Mtin == "1385788" |	Mtin == "1294778" |	Mtin == "1073349" ///
	|	Mtin == "1592994" |	Mtin == "1328204" |	Mtin == "1442956" ///
	|	Mtin == "1638239" |	Mtin == "1635613" |	Mtin == "1887710" ///
	|	Mtin == "1446102" |	Mtin == "1835029" |	Mtin == "1922267" ///
	|	Mtin == "1404230" |	Mtin == "1502871" |	Mtin == "1888547" ///
	|	Mtin == "1265483" |	Mtin == "1834911" |	Mtin == "1560137" ///
	|	Mtin == "1639760" |	Mtin == "1677120" |	Mtin == "1028895" ///
	|	Mtin == "1557335" |	Mtin == "1284374" |	Mtin == "1190151" ///
	|	Mtin == "1781440" |	Mtin == "1924738" |	Mtin == "1703469") & SaleOrPurchase == "AE"	
keep if SellerBuyerTin == "1553644" |	SellerBuyerTin == "1893402" ///
	|	SellerBuyerTin == "1032951" |	SellerBuyerTin == "1896970" ///
	|	SellerBuyerTin == "1045974" |	SellerBuyerTin == "1260243" ///
	|	SellerBuyerTin == "1407938" |	SellerBuyerTin == "1380115" ///
	|	SellerBuyerTin == "1207611" |	SellerBuyerTin == "1363724" ///
	|	SellerBuyerTin == "1068698" |	SellerBuyerTin == "1046135" ///
	|	SellerBuyerTin == "1910917" |	SellerBuyerTin == "1908789" ///
	|	SellerBuyerTin == "1205498" |	SellerBuyerTin == "1915931" ///
	|	SellerBuyerTin == "1694906" |	SellerBuyerTin == "1097713" 
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 
	
** sales side firms and 2b
use "${output_path}/2a2b_2015_q2.dta", clear
keep if (Mtin == "1698794" |	Mtin == "1704506" |	Mtin == "1187616" ///
	|	Mtin == "1385788" |	Mtin == "1294778" |	Mtin == "1073349" ///
	|	Mtin == "1592994" |	Mtin == "1328204" |	Mtin == "1442956" ///
	|	Mtin == "1638239" |	Mtin == "1635613" |	Mtin == "1887710" ///
	|	Mtin == "1446102" |	Mtin == "1835029" |	Mtin == "1922267" ///
	|	Mtin == "1404230" |	Mtin == "1502871" |	Mtin == "1888547" ///
	|	Mtin == "1265483" |	Mtin == "1834911" |	Mtin == "1560137" ///
	|	Mtin == "1639760" |	Mtin == "1677120" |	Mtin == "1028895" ///
	|	Mtin == "1557335" |	Mtin == "1284374" |	Mtin == "1190151" ///
	|	Mtin == "1781440" |	Mtin == "1924738" |	Mtin == "1703469") & SaleOrPurchase == "BF"	
keep if SellerBuyerTin == "1553644" |	SellerBuyerTin == "1893402" ///
	|	SellerBuyerTin == "1032951" |	SellerBuyerTin == "1896970" ///
	|	SellerBuyerTin == "1045974" |	SellerBuyerTin == "1260243" ///
	|	SellerBuyerTin == "1407938" |	SellerBuyerTin == "1380115" ///
	|	SellerBuyerTin == "1207611" |	SellerBuyerTin == "1363724" ///
	|	SellerBuyerTin == "1068698" |	SellerBuyerTin == "1046135" ///
	|	SellerBuyerTin == "1910917" |	SellerBuyerTin == "1908789" ///
	|	SellerBuyerTin == "1205498" |	SellerBuyerTin == "1915931" ///
	|	SellerBuyerTin == "1694906" |	SellerBuyerTin == "1097713" 
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

** purchase side firms and 2a
use "${output_path}/2a2b_2015_q2.dta", clear
keep if (Mtin == "1553644" |	Mtin == "1893402" ///
	|	Mtin == "1032951" |	Mtin == "1896970" ///
	|	Mtin == "1045974" |	Mtin == "1260243" ///
	|	Mtin == "1407938" |	Mtin == "1380115" ///
	|	Mtin == "1207611" |	Mtin == "1363724" ///
	|	Mtin == "1068698" |	Mtin == "1046135" ///
	|	Mtin == "1910917" |	Mtin == "1908789" ///
	|	Mtin == "1205498" |	Mtin == "1915931" ///
	|	Mtin == "1694906" |	Mtin == "1097713") & SaleOrPurchase == "AE"
keep if (SellerBuyerTin == "1698794" |	SellerBuyerTin == "1704506" |	SellerBuyerTin == "1187616" ///
	|	SellerBuyerTin == "1385788" |	SellerBuyerTin == "1294778" |	SellerBuyerTin == "1073349" ///
	|	SellerBuyerTin == "1592994" |	SellerBuyerTin == "1328204" |	SellerBuyerTin == "1442956" ///
	|	SellerBuyerTin == "1638239" |	SellerBuyerTin == "1635613" |	SellerBuyerTin == "1887710" ///
	|	SellerBuyerTin == "1446102" |	SellerBuyerTin == "1835029" |	SellerBuyerTin == "1922267" ///
	|	SellerBuyerTin == "1404230" |	SellerBuyerTin == "1502871" |	SellerBuyerTin == "1888547" ///
	|	SellerBuyerTin == "1265483" |	SellerBuyerTin == "1834911" |	SellerBuyerTin == "1560137" ///
	|	SellerBuyerTin == "1639760" |	SellerBuyerTin == "1677120" |	SellerBuyerTin == "1028895" ///
	|	SellerBuyerTin == "1557335" |	SellerBuyerTin == "1284374" |	SellerBuyerTin == "1190151" ///
	|	SellerBuyerTin == "1781440" |	SellerBuyerTin == "1924738" |	SellerBuyerTin == "1703469")
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

** purchase side firms and 2b (don't include Master Bogus firm)
use "${output_path}/2a2b_2015_q2.dta", clear
keep if (Mtin == "1893402" ///
	|	Mtin == "1032951" |	Mtin == "1896970" ///
	|	Mtin == "1045974" |	Mtin == "1260243" ///
	|	Mtin == "1407938" |	Mtin == "1380115" ///
	|	Mtin == "1207611" |	Mtin == "1363724" ///
	|	Mtin == "1068698" |	Mtin == "1046135" ///
	|	Mtin == "1910917" |	Mtin == "1908789" ///
	|	Mtin == "1205498" |	Mtin == "1915931" ///
	|	Mtin == "1694906" |	Mtin == "1097713") & SaleOrPurchase == "BF"
keep if (SellerBuyerTin == "1698794" |	SellerBuyerTin == "1704506" |	SellerBuyerTin == "1187616" ///
	|	SellerBuyerTin == "1385788" |	SellerBuyerTin == "1294778" |	SellerBuyerTin == "1073349" ///
	|	SellerBuyerTin == "1592994" |	SellerBuyerTin == "1328204" |	SellerBuyerTin == "1442956" ///
	|	SellerBuyerTin == "1638239" |	SellerBuyerTin == "1635613" |	SellerBuyerTin == "1887710" ///
	|	SellerBuyerTin == "1446102" |	SellerBuyerTin == "1835029" |	SellerBuyerTin == "1922267" ///
	|	SellerBuyerTin == "1404230" |	SellerBuyerTin == "1502871" |	SellerBuyerTin == "1888547" ///
	|	SellerBuyerTin == "1265483" |	SellerBuyerTin == "1834911" |	SellerBuyerTin == "1560137" ///
	|	SellerBuyerTin == "1639760" |	SellerBuyerTin == "1677120" |	SellerBuyerTin == "1028895" ///
	|	SellerBuyerTin == "1557335" |	SellerBuyerTin == "1284374" |	SellerBuyerTin == "1190151" ///
	|	SellerBuyerTin == "1781440" |	SellerBuyerTin == "1924738" |	SellerBuyerTin == "1703469")
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

/* Import more information about firms interacting with Firm 1 */
*import the file (created manually)
import delim "${analysis_path1}/network_analysis/Firm8_list.csv", varn(1) clear case(preserve)
merge 1:m Mtin using "${features_final}/All_return_features_minus_q12.dta"
keep if _merge == 3
keep Mtin Rename bogus_flag RegistrationStatus
duplicates drop
merge 1:1 Mtin using "${final_list}/final/FinalSelectedFirms.dta", keepusing(p_allfeatures) 
keep if _merge == 3
drop _merge
gsort Rename


**********************************************************
/* Firm 9 */
**********************************************************
* mtin == 1570028 taxquarter == 20 (2014-15, q4)
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if Mtin == "1570028" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 
			
*check if reverse is true
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if Mtin == "1817153" & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1570028"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches

/* EXPLORE each 1nd degree seller firms */ 
** Seller 2 
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if Mtin == "1817153" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

*check if reverse is true
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if Mtin == "1556191" & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1817153"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches

/* EXPLORE each 2nd degree seller firms */ 
** Seller 3 
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if Mtin == "1556191" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

*check if reverse is true
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if Mtin == "1759857" & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1556191"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop

/* EXPLORE each 3rd degree seller firms */ 
** Seller 4 
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if Mtin == "1759857" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop //no observation

** Purchaser from bogus firm
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if Mtin == "1570028" & SaleOrPurchase == "BF"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

** Since Firm 9 and 10 interact with the same firms, written codes for only Firm 10

/* Import more information about firms interacting with Firm 1 */
*import the file (created manually)
import delim "${analysis_path1}/network_analysis/Firm9_list.csv", varn(1) clear case(preserve)
merge 1:m Mtin using "${features_final}/All_return_features_minus_q12.dta"
keep if _merge == 3
keep Mtin Rename bogus_flag RegistrationStatus
duplicates drop
gsort Rename

**********************************************************
/* Firm 10 */
**********************************************************
* mtin == 1570028 taxquarter == 20 (2014-15, q4)
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if Mtin == "1871200" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 
			
*check if reverse is true
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if Mtin == "1817153" & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1871200"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop // none of the reverse matches


/* EXPLORE each 1st degree seller firms */ 
** Seller 2 
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if Mtin == "1817153" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

*check if reverse is true
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if Mtin == "1556191" & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1817153"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop 

/* EXPLORE each 2nd degree seller firms */ 
** Seller 3
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if Mtin == "1556191" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

*check if reverse is true
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if Mtin == "1759857" & ///
	SaleOrPurchase == "BF" & SellerBuyerTin == "1556191"
keep SaleOrPurchase Mtin SellerBuyerTin 
duplicates drop 

/* EXPLORE each 3rd degree seller firms */ 
** Seller 4
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if Mtin == "1759857" & SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop // no observation

** Purchaser from bogus firm
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if Mtin == "1871200" & SaleOrPurchase == "BF"
keep SaleOrPurchase Mtin SellerBuyerTin
duplicates drop 

/*check interaction between purchase and sales firm*/
** sales side firms and 2a
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if (Mtin == "1762396" | Mtin == "1211759" ///
	| Mtin == "1956719" | Mtin == "1329748"  ///
	| Mtin == "1456546" | Mtin == "1054852"  ///
	| Mtin == "1113847" | Mtin == "1564755"  ///
	| Mtin == "1150829" | Mtin == "1770740"  ///
	| Mtin == "1878930" | Mtin == "1661128"  ///
	| Mtin == "1954029" | Mtin == "1367771" | Mtin == "1158901") & SaleOrPurchase == "AE"
keep if (SellerBuyerTin == "1871200" | SellerBuyerTin == "1759857"  ///
	| SellerBuyerTin == "1556191" | SellerBuyerTin == "1817153") 

** sales side firms and 2b
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if (Mtin == "1762396" | Mtin == "1211759" ///
	| Mtin == "1956719" | Mtin == "1329748"  ///
	| Mtin == "1456546" | Mtin == "1054852"  ///
	| Mtin == "1113847" | Mtin == "1564755"  ///
	| Mtin == "1150829" | Mtin == "1770740"  ///
	| Mtin == "1878930" | Mtin == "1661128"  ///
	| Mtin == "1954029" | Mtin == "1367771" | Mtin == "1158901") & SaleOrPurchase == "BF"
keep if (SellerBuyerTin == "1871200" | SellerBuyerTin == "1759857"  ///
	| SellerBuyerTin == "1556191" | SellerBuyerTin == "1817153") 

** purchase side firms and 2a
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if ( Mtin == "1759857" | Mtin == "1556191" | Mtin == "1817153" | Mtin == "1871200") ///
		& SaleOrPurchase == "AE"
keep SaleOrPurchase Mtin SellerBuyerTin
keep if SellerBuyerTin == "1762396" | SellerBuyerTin == "1211759" ///
	| SellerBuyerTin == "1956719" | SellerBuyerTin == "1329748"  ///
	| SellerBuyerTin == "1456546" | SellerBuyerTin == "1054852"  ///
	| SellerBuyerTin == "1113847" | SellerBuyerTin == "1564755"  ///
	| SellerBuyerTin == "1150829" | SellerBuyerTin == "1770740"  ///
	| SellerBuyerTin == "1878930" | SellerBuyerTin == "1661128"  ///
	| SellerBuyerTin == "1954029" | SellerBuyerTin == "1367771" | SellerBuyerTin == "1158901"

** purchase side firms and 2b
use "${output_path}/2a2b_quarterly_2014.dta", clear
keep if OriginalTaxPeriod == "Fourth Quarter-2014"
keep if ( Mtin == "1759857" | Mtin == "1556191" | Mtin == "1817153") ///
		& SaleOrPurchase == "BF"
keep SaleOrPurchase Mtin SellerBuyerTin
keep if SellerBuyerTin == "1762396" | SellerBuyerTin == "1211759" ///
	| SellerBuyerTin == "1956719" | SellerBuyerTin == "1329748"  ///
	| SellerBuyerTin == "1456546" | SellerBuyerTin == "1054852"  ///
	| SellerBuyerTin == "1113847" | SellerBuyerTin == "1564755"  ///
	| SellerBuyerTin == "1150829" | SellerBuyerTin == "1770740"  ///
	| SellerBuyerTin == "1878930" | SellerBuyerTin == "1661128"  ///
	| SellerBuyerTin == "1954029" | SellerBuyerTin == "1367771" | SellerBuyerTin == "1158901"

/* Import more information about firms interacting with Firm 1 */
*import the file (created manually)
import delim "${analysis_path1}/network_analysis/Firm9_list.csv", varn(1) clear case(preserve)
merge 1:m Mtin using "${features_final}/All_return_features_minus_q12.dta"
keep if _merge == 3
keep Mtin Rename bogus_flag RegistrationStatus
duplicates drop
merge 1:1 Mtin using "${final_list}/final/FinalSelectedFirms.dta", keepusing(p_allfeatures) 
keep if _merge == 3
drop _merge
gsort Rename



