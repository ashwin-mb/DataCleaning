/************************************************* 
* Filename: 
* Input: H:/Ashwin/dta/Non_existing_firm_consolidated.dta
* Purpose: Conducts QCs on the input file (Bogus firms)
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

*output files*
global output_path "H:/Ashwin/dta/final"
global qc_path "H:/Ashwin/dta/qc"
global prob_path "H:/Ashwin/dta/prob"

*--------------------------------------------------------
** Conduct Quality Checks
*--------------------------------------------------------

** Merge with Mtin original list
	/* Mtin from bogus firms should be a subset of unique mtin list */

use "${output_path}/bogus_consolidated.dta", clear

tostring Mtin, replace
tempfile bogus_firms
save `bogus_firms'

*Merge with UnqiueMtin list* 
use "${output_path}/mtin_list.dta", clear
merge m:1 Mtin using `bogus_firms'

/* All Mtins from bogus firms matched with original list
    Result                           # of obs.
    -----------------------------------------
    not matched                       680,344
        from master                   680,344  (_merge==1)
        from using                          0  (_merge==2)

    matched                             6,221  (_merge==3)
    -----------------------------------------
*/

** Bogus firms cancelled
	/*Check how many bogus firms were cancelled */
	
keep if _merge == 3
tab Current_status

/* Split of bogus firms cancelled and registered
Current_sta |
        tus |      Freq.     Percent        Cum.
------------+-----------------------------------
  Cancelled |      5,701       91.64       91.64
 Registered |        520        8.36      100.00
------------+-----------------------------------
      Total |      6,221      100.00
*/

*Bogus firms with inspection year
tab inspection_year

/* 
 inspection_|
       year |      Freq.     Percent        Cum.
------------+-----------------------------------
       1213 |          1        0.02        0.02
       1314 |          3        0.05        0.06
       1415 |      1,586       25.49       25.56
       1516 |      3,667       58.95       84.50
       1617 |        964       15.50      100.00
------------+-----------------------------------
      Total |      6,221      100.00
*/

*Bogus firms registration and inspected info
tab cancellation_year inspection_year if Current_status == "Cancelled"

/*
cancellati |                    inspection_year
   on_year |      1213       1314       1415       1516       1617 |     Total
-----------+-------------------------------------------------------+----------
      2014 |         0          0        693         16          0 |       709 
      2015 |         0          3        725      2,095          3 |     2,826 
      2016 |         1          0         17      1,132        779 |     1,929 
      2017 |         0          0         37        110         90 |       237 
-----------+-------------------------------------------------------+----------
     Total |         1          3      1,472      3,353        872 |     5,701 

*/

*Cross tab firms with registration year and inspected year
gen registration_year = year(original_registration_date)
tab inspection_year registration_year if Current_status == "Registered"

/* 
inspection |                   registration_year
     _year |      2013       2014       2015       2016       2017 |     Total
-----------+-------------------------------------------------------+----------
      1415 |         3        100         11          0          0 |       114 
      1516 |         0         54        254          6          0 |       314 
      1617 |         0          9         36         45          2 |        92 
-----------+-------------------------------------------------------+----------
     Total |         3        163        301         51          2 |       520 
*/

** Merge bogus firms list with Form16 consolidated data

tostring Mtin, replace
tempfile bogus_firms
save `bogus_firms'


*Merge with UnqiueMtin list* 
use "${output_path}/unique_mtin_form16.dta", clear
duplicates drop Mtin, force
merge m:1 Mtin using `bogus_firms'

/* Some bogus firms don't have Form 16 returns (2.5k firms don't have form 16)

    Result                           # of obs.
    -----------------------------------------
    not matched                       446,076
        from master                   443,564  (_merge==1)
        from using                      2,512  (_merge==2)

    matched                             3,709  (_merge==3)
    -----------------------------------------

*/

* Check unmerged bogus firms with DP data
keep if _merge == 2 
drop _merge
tempfile unmerged
save `unmerged'

use "${output_path}/dp_form.dta", clear
merge m:1 Mtin using `unmerged'
keep if _merge == 3

/* Registation status of firms which are bogus & don't match with Form16

 Registered |
         or |
  Cancelled |      Freq.     Percent        Cum.
------------+-----------------------------------
  Cancelled |      2,466       98.17       98.17
 Registered |         46        1.83      100.00
------------+-----------------------------------
      Total |      2,512      100.00
*/

** Clean Bogus firms list 
use "${output_path}/bogus_consolidated.dta", clear
export excel "${output_path}/bogus_consolidated.xlsx", replace firstrow(variables)

*save bogus firms list with flag for other types of bogus
import excel "${output_path}/bogus_consolidated.xlsx", clear firstrow
save "${output_path}/bogus_consolidated_clean.dta", replace

*--------------------------------------------------------
** Time Series of Bogus firms cancellation
*--------------------------------------------------------
use "${output_path}/dp_form.dta", clear
destring Mtin, replace
merge m:1 Mtin using "${output_path}/bogus_consolidated.dta"
keep if _merge == 3

keep Mtin RegistrationStatus CancellationDate Reason inspection_year

gen CancellationYear = regexs(0) if regexm(CancellationDate, "([0-9][0-9][0-9][0-9])")
destring CancellationYear, replace
gen CancellationMonth = regexs(0) if regexm(CancellationDate, "(-[0-9][0-9]-)")
replace CancellationMonth = regexs(0) if regexm(CancellationMonth, "([0-9][0-9])")
destring CancellationMonth, replace

* Assign quarter to cancelled firms
replace CancellationQuarter = ""
foreach var in 2014 2015 2016 2017{
replace CancellationQuarter = "First Quarter-`var'" ///
	if CancellationYear == `var' & (CancellationMonth>=4 & CancellationMonth<=6)
replace CancellationQuarter = "Second Quarter-`var'" ///
	if CancellationYear == `var' & (CancellationMonth>=7 & CancellationMonth<=9)
replace CancellationQuarter = "Third Quarter-`var'" /// 
	if CancellationYear == `var' & (CancellationMonth>=10 & CancellationMonth<=12)
}

replace CancellationQuarter = "Fourth Quarter-2013" ///
	if CancellationYear == 2015 & (CancellationMonth>=1 & CancellationMonth<=3)
replace CancellationQuarter = "Fourth Quarter-2014" ///
	if CancellationYear == 2015 & (CancellationMonth>=1 & CancellationMonth<=3)
replace CancellationQuarter = "Fourth Quarter-2015" ///
	if CancellationYear == 2016 & (CancellationMonth>=1 & CancellationMonth<=3)
replace CancellationQuarter = "Fourth Quarter-2016" ///
	if CancellationYear == 2017 & (CancellationMonth>=1 & CancellationMonth<=3)

/*
CancellationQuarter |      Freq.     Percent       
--------------------+-------------------------
 First Quarter-2014 |          4        0.07      
Second Quarter-2014 |        220        3.86
 Third Quarter-2014 |        484        8.49
Fourth Quarter-2014 |        538        9.44
 First Quarter-2015 |        931       16.33    
Second Quarter-2015 |        765       13.42
 Third Quarter-2015 |        596       10.46
Fourth Quarter-2015 |        908       15.93 
 First Quarter-2016 |        370        6.49    
Second Quarter-2016 |        490        8.60
 Third Quarter-2016 |        158        2.77
Fourth Quarter-2016 |        111        1.95
 First Quarter-2017 |         57        1.00    
Second Quarter-2017 |         68        1.19
--------------------+-------------------------
              Total |      5,700      100.00
*/




