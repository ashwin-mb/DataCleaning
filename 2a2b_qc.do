  /************************************************* 
* Filename: 
* Input: 2a2b dta_files
* Purpose: Compare new and old 2a2b data
* Output:
* Author: Ashwin MB
* Date: 09/10/2018
* Last modified: 09/10/2018 (Ashwin)
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
global output_path "H:/Ashwin/dta/final"
global qc_path "H:/Ashwin/dta/qc"
global prob_path "H:/Ashwin/dta/prob"

*--------------------------------------------------------
** Comparing new 2a2b data with old 2a2b data
*--------------------------------------------------------

****************** 2012-13 Monthly data *****************

** Loading old 2a2b dataset
use "${old_path}/annexure_2A2B_monthly_201213.dta", clear
/*
. tab Month Year

           |               Year
     Month |      2011       2012       2013 |     Total
-----------+---------------------------------+----------
         1 |         0 14,446,310  3,015,728 |17,462,038 
         2 |         0 11,544,660  2,935,327 |14,479,987 
         3 |         0 11,366,778  3,143,788 |14,510,566 
         4 |         0  2,847,322          0 | 2,847,322 
         5 |         0  3,001,472          0 | 3,001,472 
         6 |         0  2,942,949          0 | 2,942,949 
         7 |         0  3,021,751          0 | 3,021,751 
         8 |         0  2,989,978          0 | 2,989,978 
         9 |         0  3,098,230          0 | 3,098,230 
        10 |         0  3,242,476          0 | 3,242,476 
        11 |         0  3,015,173          1 | 3,015,174 
        12 |        17  3,248,914          0 | 3,248,931 
-----------+---------------------------------+----------
     Total |        17 64,766,013  9,094,844 |73,860,874 
*/

	/* Loading new dataset */ 
use "${output_path}/2a2b_monthly_2012.dta", clear
tab TaxPeriod TaxYear

/* 
 TaxPeriod |      2011       2012       2013 |     Total
-----------+---------------------------------+----------
         1 |     1,458     17,996        155 |    19,609 
         2 |     1,730     23,754         46 |    25,530 
         3 |     6,188     34,621        119 |    40,928 
         4 |         0  2,840,353          0 | 2,840,353 
         5 |         0  2,994,700          0 | 2,994,700 
         6 |         0  2,936,299          0 | 2,936,299 
         7 |         0  3,016,582          0 | 3,016,582 
         8 |         0  2,984,651          0 | 2,984,651 
         9 |         0  3,092,614          0 | 3,092,614 
        10 |         0  3,239,521          0 | 3,239,521 
        11 |         0  3,007,976          1 | 3,007,977 
        12 |         0  3,244,408          0 | 3,244,408 
-----------+---------------------------------+----------
     Total |     9,376 27,433,475        321 |27,443,172 
*/

****************** 2013-14 Quarterly data *****************

** 2013 2a2b data
	/* Loading old dataset */ 
use "${old_path}/annexure_2A2B_quarterly_2013.dta", clear
tab Month
* Tabulate no. of entries every quarter
/* 
      Month |      Freq.     Percent        Cum.
------------+-----------------------------------
         41 |  6,261,404       25.30       25.30
         42 |  6,225,620       25.15       50.45
         43 |  6,114,606       24.70       75.15
         44 |  6,150,091       24.85      100.00
------------+-----------------------------------
      Total | 24,751,721      100.00
*/

	/* Loading new dataset */ 
use "${output_path}/2a2b_quarterly_2013.dta", clear
tab TaxPeriod 
*Tabulate no. of entries every quarter 
/* 
  TaxPeriod |      Freq.     Percent        Cum.
------------+-----------------------------------
         41 |  6,263,658       25.30       25.30
         42 |  6,227,668       25.15       50.45
         43 |  6,117,659       24.71       75.17
         44 |  6,148,474       24.83      100.00
------------+-----------------------------------
      Total | 24,757,459      100.00

*/

****************** 2013-14 Quarterly data *****************

	/* Loading old dataset */
use "${old_path}/annexure_2A2B_quarterly_2014.dta", clear
tab Month
*Tabulate no. of entries every quarter
/*
      Month |      Freq.     Percent        Cum.
------------+-----------------------------------
          9 |         60        0.00        0.00
         41 |  6,013,150       24.82       24.82
         42 |  6,134,286       25.32       50.14
         43 |  6,033,836       24.90       75.04
         44 |  6,046,717       24.96      100.00
------------+-----------------------------------
      Total | 24,228,049      100.00
*/

	/* Loading new dataset */ 
use "${output_path}/2a2b_quarterly_2014.dta", clear
tab TaxPeriod 

/*
  TaxPeriod |      Freq.     Percent        Cum.
------------+-----------------------------------
          1 |          2        0.00        0.00
          5 |          9        0.00        0.00
          9 |         60        0.00        0.00
         41 |  6,033,869       24.73       24.73
         42 |  6,159,508       25.25       49.98
         43 |  6,071,148       24.89       74.87
         44 |  6,131,654       25.13      100.00
------------+-----------------------------------
      Total | 24,396,250      100.00
*/

*--------------------------------------------------------
** Check missing values & values in 2a2b data
*--------------------------------------------------------

** Monthly 2012 values
use "${output_path}/2a2b_monthly_2012.dta", clear

tab SaleOrPurchase // AB, AE, AN, BF
tab SalePurchaseType // Childnode
tab DealerGoodType // UD RD OT (other values present)
tab TransactionType // C, Exempted, E1/E2,GD, H, I, J, None, WC (other values present)
tab Rate // Rates other than 0-5-12-18 (some in thousands)
tab TaxYear // 2011, 2012, 2013

* Missing Return ID, Mtin, PartyTin
bro if  MReturn_ID == "" // 41.8% don't have return Ids
bro if Mtin == "" //99.99% data present
bro if SellerBuyerTin == "" // 99.9% data present

** Quarterly 2013-14 data
use "${output_path}/2a2b_quarterly_2013.dta", clear

tab SaleOrPurchase // AB, AE, AN, BF
tab SalePurchaseType // Childnode
tab DealerGoodType // UD RD OT (other values present)
tab TransactionType // C, Exempted, E1/E2,GD, H, I, J, None, WC 
tab Rate // Rates proper
tab TaxYear // 2013

* Missing Return ID, Mtin, PartyTin
bro if  MReturn_ID == "" // 84.3% don't have return Ids
bro if Mtin == "" //99.99% data present
bro if SellerBuyerTin == "" // 99.99% data present

** Quarterly 2014-15 data
use "${output_path}/2a2b_quarterly_2014.dta", clear

tab SaleOrPurchase // AE, AN, BF
tab SalePurchaseType // Childnode
tab DealerGoodType // UD RD OT (other values present)
tab TransactionType // C, Exempted, E1/E2,GD, H, I, J, None, WC 
tab Rate // Rates proper
tab TaxYear // 2012, 2013, 2014

* Missing Return ID, Mtin, PartyTin
bro if  MReturn_ID == "" // 99.5% don't have return Ids
bro if Mtin == "" //99.99% data present
bro if SellerBuyerTin == "" // 99.99% data present

*--------------------------------------------------------
** Aggregating Type 1 & 2 values and checking with Form 16
*--------------------------------------------------------

** Quarterly 2014-15 data
use "${output_path}/2a2b_quarterly_2014.dta", clear

bysort SaleOrPurchase SalePurchaseType DealerGoodType TransactionType ///
							TaxPeriod: gen NetAmount_1 = sum(NetAmount)
bysort SaleOrPurchase SalePurchaseType DealerGoodType TransactionType ///
							TaxPeriod: gen Tax_1 = sum(Tax)
bysort SaleOrPurchase SalePurchaseType DealerGoodType TransactionType ///
							TaxPeriod: gen Total_1 = sum(Total)

keep SaleOrPurchase SalePurchaseType DealerGoodType TransactionType ///
							TaxPeriod NetAmount_1 Tax_1 Total_1							
duplicates drop SaleOrPurchase SalePurchaseType TaxPeriod, force

save "${temp_path1}/2a2b_aggregated.dta", replace
export excel "$

*Form 16 data
use "${output_path}\form16_data_consolidated.dta", clear

*Retaining the latest return per dealer
gsort TaxPeriod Mtin -DateofReturnFiled
duplicates drop TaxPeriod Mtin, force

collapse (sum) *Turnover* *OutputTax* *Labor* *Land* *Purchase* *Sale* Credit* *Credit WCCredit*, by(TaxPeriod)
save "${temp_path1}/form16_data_aggregated.dta" ,replace











