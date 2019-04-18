/************************************************* 
* Filename: 
* Input: 
* Purpose: Form 16 Challan data: Created consolidated list of Challan data 
	          of 5 years and renamed variables;
* Output:
* Author: Ashwin MB
* Date: 25/09/2018
* Last modified: 17/10/2018 (Ashwin)
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
global sample_path "H:/Ashwin/dta/sample"

*--------------------------------------------------------
** Merging all challan form 16 data (12-13 data got deleted - fix it)
*--------------------------------------------------------
foreach var in "1213" "1314" "1415" "1516" "1617" {
use "${input_path}/form16_`var'_challan.dta", clear
replace year = `var'
save "${input_path}/form16_`var'_challan.dta", replace
}

use "${input_path}/form16_1213_challan.dta", clear

foreach var in "1314" "1415" "1516" "1617" {
append using "${input_path}\form16_`var'_challan.dta"
}

rename (From_Date To_Date Deposit_Date Amount) ///
		(from_date to_date deposit_date amount)
		
save "${output_path}/form16_challan_consolidated.dta", replace

*--------------------------------------------------------
** Add TaxPeriod to challan form16 data
*-------------------------------------------------------

use "${output_path}/form16_challan_consolidated.dta", clear

/* Create variable that identifies challan deposit month */ 

gen deposit_month = month(dofc(deposit_date))
gen deposit_year = year(dofc(deposit_date))

gen TaxQuarter = 0
replace TaxQuarter = 9 if (deposit_month>=4 & deposit_month<=6) & deposit_year == 2012
replace TaxQuarter = 10 if (deposit_month>=7 & deposit_month<=9) & deposit_year == 2012
replace TaxQuarter = 11 if (deposit_month>=10 & deposit_month<=12) & deposit_year == 2012
replace TaxQuarter = 12 if (deposit_month>=1 & deposit_month<=3) & deposit_year == 2013
replace TaxQuarter = 13 if (deposit_month>=4 & deposit_month<=6) & deposit_year == 2013
replace TaxQuarter = 14 if (deposit_month>=7 & deposit_month<=9) & deposit_year == 2013
replace TaxQuarter = 15 if (deposit_month>=10 & deposit_month<=12) & deposit_year == 2013
replace TaxQuarter = 16 if (deposit_month>=1 & deposit_month<=3) & deposit_year == 2014
replace TaxQuarter = 17 if (deposit_month>=4 & deposit_month<=7) & deposit_year == 2014
replace TaxQuarter = 18 if (deposit_month>=7 & deposit_month<=9) & deposit_year == 2014
replace TaxQuarter = 19 if (deposit_month>=10 & deposit_month<=12) & deposit_year == 2014
replace TaxQuarter = 20 if (deposit_month>=1 & deposit_month<=3) & deposit_year == 2015
replace TaxQuarter = 21 if (deposit_month>=4 & deposit_month<=6) & deposit_year == 2015
replace TaxQuarter = 22 if (deposit_month>=7 & deposit_month<=9) & deposit_year == 2015
replace TaxQuarter = 23 if (deposit_month>=10 & deposit_month<=12) & deposit_year == 2015
replace TaxQuarter = 24 if (deposit_month>=1 & deposit_month<=3) & deposit_year == 2016
replace TaxQuarter = 25 if (deposit_month>=4 & deposit_month<=6) & deposit_year == 2016
replace TaxQuarter = 26 if (deposit_month>=7 & deposit_month<=9) & deposit_year == 2016
replace TaxQuarter = 27 if (deposit_month>=10 & deposit_month<=12) & deposit_year == 2016
replace TaxQuarter = 28 if (deposit_month>=1 & deposit_month<=3) & deposit_year == 2017

*Number of the challans paid based Tax Quarter*
tab TaxQuarter
/*
 TaxQuarter |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |     22,538        0.44        0.44
         17 |         30        0.00        0.44
         18 |         15        0.00        0.44
         20 |        882        0.02        0.45
         21 |    483,048        9.34        9.79
         22 |  1,139,512       22.03       31.82
         23 |  1,186,555       22.94       54.76
         24 |  1,461,237       28.25       83.01
         25 |    726,596       14.05       97.05
         26 |     49,999        0.97       98.02
         27 |     28,437        0.55       98.57
         28 |     74,089        1.43      100.00
------------+-----------------------------------
      Total |  5,172,938      100.00
*/

gen TaxMonth = 0 
replace TaxMonth = 25 if TaxQuarter == 9 & deposit_month == 4
replace TaxMonth = 26 if TaxQuarter == 9 & deposit_month == 5
replace TaxMonth = 27 if TaxQuarter == 9 & deposit_month == 6
replace TaxMonth = 28 if TaxQuarter == 10 & deposit_month == 7
replace TaxMonth = 29 if TaxQuarter == 10 & deposit_month == 8
replace TaxMonth = 30 if TaxQuarter == 10 & deposit_month == 9
replace TaxMonth = 31 if TaxQuarter == 11 & deposit_month == 10
replace TaxMonth = 32 if TaxQuarter == 11 & deposit_month == 11
replace TaxMonth = 33 if TaxQuarter == 11 & deposit_month == 12
replace TaxMonth = 34 if TaxQuarter == 12 & deposit_month == 1
replace TaxMonth = 35 if TaxQuarter == 12 & deposit_month == 2
replace TaxMonth = 36 if TaxQuarter == 12 & deposit_month == 3

replace TaxMonth = 37 if TaxQuarter == 13 & deposit_month == 4
replace TaxMonth = 38 if TaxQuarter == 13 & deposit_month == 5
replace TaxMonth = 39 if TaxQuarter == 13 & deposit_month == 6
replace TaxMonth = 40 if TaxQuarter == 14 & deposit_month == 7
replace TaxMonth = 41 if TaxQuarter == 14 & deposit_month == 8
replace TaxMonth = 42 if TaxQuarter == 14 & deposit_month == 9
replace TaxMonth = 43 if TaxQuarter == 15 & deposit_month == 10
replace TaxMonth = 44 if TaxQuarter == 15 & deposit_month == 11
replace TaxMonth = 45 if TaxQuarter == 15 & deposit_month == 12
replace TaxMonth = 46 if TaxQuarter == 16 & deposit_month == 1
replace TaxMonth = 47 if TaxQuarter == 16 & deposit_month == 2
replace TaxMonth = 48 if TaxQuarter == 16 & deposit_month == 3

replace TaxMonth = 49 if TaxQuarter == 17 & deposit_month == 4
replace TaxMonth = 50 if TaxQuarter == 17 & deposit_month == 5
replace TaxMonth = 51 if TaxQuarter == 17 & deposit_month == 6
replace TaxMonth = 52 if TaxQuarter == 18 & deposit_month == 7
replace TaxMonth = 53 if TaxQuarter == 18 & deposit_month == 8
replace TaxMonth = 54 if TaxQuarter == 18 & deposit_month == 9
replace TaxMonth = 55 if TaxQuarter == 19 & deposit_month == 10
replace TaxMonth = 56 if TaxQuarter == 19 & deposit_month == 11
replace TaxMonth = 57 if TaxQuarter == 19 & deposit_month == 12
replace TaxMonth = 58 if TaxQuarter == 20 & deposit_month == 1
replace TaxMonth = 59 if TaxQuarter == 20 & deposit_month == 2
replace TaxMonth = 60 if TaxQuarter == 20 & deposit_month == 3

replace TaxMonth = 61 if TaxQuarter == 21 & deposit_month == 4
replace TaxMonth = 62 if TaxQuarter == 21 & deposit_month == 5
replace TaxMonth = 63 if TaxQuarter == 21 & deposit_month == 6
replace TaxMonth = 64 if TaxQuarter == 22 & deposit_month == 7
replace TaxMonth = 65 if TaxQuarter == 22 & deposit_month == 8
replace TaxMonth = 66 if TaxQuarter == 22 & deposit_month == 9
replace TaxMonth = 67 if TaxQuarter == 23 & deposit_month == 10
replace TaxMonth = 68 if TaxQuarter == 23 & deposit_month == 11
replace TaxMonth = 69 if TaxQuarter == 23 & deposit_month == 12
replace TaxMonth = 70 if TaxQuarter == 24 & deposit_month == 1
replace TaxMonth = 71 if TaxQuarter == 24 & deposit_month == 2
replace TaxMonth = 72 if TaxQuarter == 24 & deposit_month == 3

replace TaxMonth = 73 if TaxQuarter == 25 & deposit_month == 4
replace TaxMonth = 74 if TaxQuarter == 25 & deposit_month == 5
replace TaxMonth = 75 if TaxQuarter == 25 & deposit_month == 6
replace TaxMonth = 76 if TaxQuarter == 26 & deposit_month == 7
replace TaxMonth = 77 if TaxQuarter == 26 & deposit_month == 8
replace TaxMonth = 78 if TaxQuarter == 26 & deposit_month == 9
replace TaxMonth = 79 if TaxQuarter == 27 & deposit_month == 10
replace TaxMonth = 80 if TaxQuarter == 27 & deposit_month == 11
replace TaxMonth = 81 if TaxQuarter == 27 & deposit_month == 12
replace TaxMonth = 82 if TaxQuarter == 28 & deposit_month == 1
replace TaxMonth = 83 if TaxQuarter == 28 & deposit_month == 2
replace TaxMonth = 84 if TaxQuarter == 28 & deposit_month == 3

save "${output_path}/form16_challan_consolidated.dta", replace
