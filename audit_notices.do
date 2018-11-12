/************************************************* 
* Filename: 
* Input: H:/Ashwin/dta/Audit_notices_year.dta
* Purpose: Creates a consolidated data of audit notices data
* Output: H:/Ashwin/dta/Audit_notices_consolidated.dta
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
global input_path "H:/Ashwin/dta"

*output files*
//global output_path "H:/Ashwin/dta"

*--------------------------------------------------------
** Creating a consolidated audit notices
*--------------------------------------------------------
foreach var in "1314" "1415" "1516" "1617" {
use "${input_path}/Audit_notices_`var'.dta", clear
replace year = `var'
save "${input_path}/Audit_notices_`var'.dta", replace
}

use "${input_path}/Audit_notices_1314.dta", clear

foreach var in "1415" "1516" "1617" {
append using "${input_path}\Audit_notices_`var'.dta"
}
	
rename (MTin Date_of_Notice Period_Of_Notice) (Mtin date_of_notice period_of_notice)

save "${input_path}/Audit_notices_consolidated.dta", replace



*2. Clean the data*
use "H:\Ashwin\Dta_files\Audit_notices_consolidated.dta", clear

*remove audit notices without Mtin*
drop if Mtin == "" 
/* 158 observations from 13-14 were without Mtin and deleted*/

*Check for the duplicacy of data*
/*Several duplicates found; dropping 806 observations*/
duplicates tag date_of_notice period_of_notice Mtin, gen(duplicate)
duplicates drop date_of_notice period_of_notice Mtin, force 
drop duplicate

save "H:\Ashwin\Dta_files\Audit_notices_consolidated.dta", replace


*3. Conduct basic checks*
*3.a Check whether date_of_notice column corresponds with year column
use "H:\Ashwin\Dta_files\Audit_notices_consolidated.dta", clear

tab year
/* Most of audit notices were sent in 13-14, 14-15
------------+-----------------------------------
      13-14 |     15,305       83.82       83.82
      14-15 |      1,848       10.12       93.94
      15-16 |        472        2.59       96.53
      16-17 |        634        3.47      100.00
------------+-----------------------------------
      Total |     18,259      100.00
*/

gen temp_year = regexs(0) if regexm(Date_of_Notice, "([0-9][0-9][0-9][0-9])")
gen temp_month = regexs(2) if regexm(Date_of_Notice, "([0-9][0-9])[-]([0-9][0-9])[-]([0-9][0-9][0-9][0-9])")
destring temp_year temp_month, replace

gen temp_audit_year = "16-17" if (temp_year == 2016 & temp_month >=4) |  (temp_year == 2017 & temp_month <4)
replace temp_audit_year = "15-16" if (temp_year == 2015 & temp_month >=4) |  (temp_year == 2016 & temp_month <4)
replace temp_audit_year = "14-15" if (temp_year == 2014 & temp_month >=4) |  (temp_year == 2015 & temp_month <4)
replace temp_audit_year = "13-14" if (temp_year == 2013 & temp_month >=4) |  (temp_year == 2014 & temp_month <4)


tab temp_audit_year
/* Discrepancy in audit notice year: some Mtins missing, notices in wrong year
temp_audit_ |
       year |      Freq.     Percent        Cum.
------------+-----------------------------------
      13-14 |     15,153       83.74       83.74
      14-15 |      1,840       10.17       93.90
      15-16 |        469        2.59       96.50
      16-17 |        634        3.50      100.00
------------+-----------------------------------
      Total |     18,096      100.00
*/

*Flag all discrepancy values as 1: Audit_year not matching with given year*
gen year_flag = 0 if year == temp_audit_year
replace year_flag = 1 if year_flag == . 
bro if year_flag ==1

*Create comment to address discrepancy*
gen comment = 1 if Date_of_Notice =="" // Date of notice is missing
replace comment = 2 if year_flag ==1 & comment == . // Audit year not matching with given year

label define comments 1 "Date of notice missing" 2 "audit & original year not matching" 
label values comment comments
*Replace given year with generated year*
drop temp_year temp_month
rename (temp_audit_year year) (audit_year original_year)

*3.b Check for duplicacy of data* 
duplicates tag Mtin, gen(repetitions)
tab repetitions
/* Several notices are sent to a firm mostly within the same year
repetitions |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |     10,292       59.51       59.51
          1 |      3,858       22.31       81.82
          2 |      2,544       14.71       96.53
          3 |        468        2.71       99.23
          4 |         70        0.40       99.64
          5 |         24        0.14       99.77
          7 |          8        0.05       99.82
          8 |         18        0.10       99.92
         12 |         13        0.08      100.00
------------+-----------------------------------
      Total |     17,295      100.00
*/

drop repetitions

label variable Mtin "Encrypted Tin number of the dealer"
label variable original_year "Year as given by tnt department"
label variable audit_year "Year extracted from date of notice"
label variable year_flag "Flagging notices with some discrepancy"
label variable comment "Discrepancy type: 1 Date of notice missing 2 audit & original year not same"

save "H:\Ashwin\Dta_files\Audit_notices_consolidated.dta", replace

*3.c Merge with Mtin original list* 
tempfile audit_notice
save `audit_notice'

*Merge with UnqiueMtin list* 
use "H:\Ashwin\Dta_files\unique_mtin_list.dta", clear
merge 1:m Mtin using `audit_notice'

/* All Mtins from audit notices matched with original list
. merge 1:m Mtin using `audit_notice'

    Result                           # of obs.
    -----------------------------------------
    not matched                       673,265
        from master                   673,265  (_merge==1)
        from using                          0  (_merge==2)

    matched                            17,295  (_merge==3)
    -----------------------------------------
*/

*Create a sample dataset (Not needed since the dataset is small)* 
use "H:\Ashwin\Dta_files\Audit_notices_consolidated.dta", clear
save "H:\Ashwin\Sample_Dta_files\Audit_notices_consolidated.dta", replace



