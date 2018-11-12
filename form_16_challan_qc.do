 /* 
	Author Name: Ashwin MB
	Data - 25/09/2018
	Last Edit - 04/10/2018
	Purpose - Conduct basic checks
*/

clear all
pause off
set more off

************* Clean data ****************
use "H:\Ashwin\dta\final\form16_challan_consolidated.dta", clear
rename (From_Date To_Date Deposit_Date Amount) (from_date to_date deposit_date amount)
tab year

/* Yearwise breakdown of challan data 
       year |      Freq.     Percent        Cum.
------------+-----------------------------------
      12-13 |    912,501       17.64       17.64
      13-14 |    977,533       18.90       36.54
      14-15 |  1,060,581       20.50       57.04
      15-16 |  1,118,300       21.62       78.66
      16-17 |  1,104,023       21.34      100.00
------------+-----------------------------------
      Total |  5,172,938      100.00
*/

************** 1.b Conduct basic checks ***************
*Check if deposit date, from and to date correspond to the year column*
/* From_date, To_date, and Deposit_date don't match with the year*/

gen temp_year_from_date = year(dofc(from_date))
gen temp_month_from_date = month(dofc(from_date))

gen temp_year_to_date = year(dofc(to_date))
gen temp_month_to_date = month(dofc(to_date))

gen temp_year_deposit_date = year(dofc(deposit_date))
gen temp_month_deposit_date = month(dofc(deposit_date))

set trace on
foreach var in "from_date" "to_date" "deposit_date" {
gen fy_year_`var' = "16-17" if (temp_year_`var' == 2016 & temp_month_`var' >=4) |  (temp_year_`var' == 2017 & temp_month_`var' <4)
replace fy_year_`var' = "15-16" if (temp_year_`var' == 2015 & temp_month_`var' >=4) |  (temp_year_`var' == 2016 & temp_month_`var' <4)
replace fy_year_`var' = "14-15" if (temp_year_`var' == 2014 & temp_month_`var' >=4) |  (temp_year_`var' == 2015 & temp_month_`var' <4)
replace fy_year_`var' = "13-14" if (temp_year_`var' == 2013 & temp_month_`var' >=4) |  (temp_year_`var' == 2014 & temp_month_`var' <4)
}



drop temp_year_* temp_month_*
*Flag when from and to date FY is different from deposit_date FY*
gen flag = 0 if fy_year_from_date == fy_year_to_date & fy_year_to_date == fy_year_deposit_date

*Flag when original_year (FY given) is different from deposit_date FY*
gen flag_1 = 0 if fy_year_deposit_date == year
replace flag_1 =1 if flag_1 == .
tab flag_1

/* Several instances when deposit_date FY is different from original_year FY
Need to confirm why deposit_date year is different considering that I need 
to merge with different FY data

How to merge challan data with Form 16 (and compare 7.8 data)
------------+-----------------------------------
          0 |  1,111,574       21.49       21.49
          1 |  4,061,364       78.51      100.00
------------+-----------------------------------
      Total |  5,172,938      100.00
*/


*Check if from and to date are within on financial year*
gen flag_2 = 0 if fy_year_from_date == fy_year_to_date 
replace flag_2 =1 if flag_2 == .
drop flag_2
/*from and to date are always within one financial year*/

*Mtin missing values*
bro if Mtin == ""
/* No Mtin missing in the data */

* Merge with Mtin original list* 
use "H:\Ashwin\dta\final\form16_challan_consolidated.dta", clear
tempfile challan_data
save `challan_data'



*Merge with UnqiueMtin list* 
use "H:\Ashwin\Dta_files\unique_mtin_list.dta", clear
merge 1:m Mtin using `challan_data'

/* All Mtins from challan data matched with original list
 Result                           # of obs.
    -----------------------------------------
    not matched                       505,865
        from master                   505,865  (_merge==1)
        from using                          0  (_merge==2)

    matched                         5,172,938  (_merge==3)
    -----------------------------------------
*/

*Sum of the r7.8 from form 16 should add up to value of Mtin period *





