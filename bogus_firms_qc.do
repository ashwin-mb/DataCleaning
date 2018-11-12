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
global input_path "H:/Ashwin/dta/original"
global input_path2 "H:/Ashwin/dta/intermediate"

*output files*
global output_path "H:/Ashwin/dta/final"

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


