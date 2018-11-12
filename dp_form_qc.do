/************************************************* 
* Filename: 
* Input: H:/Ashwin/dta/Form16_year_3.dta
* Purpose: Conduct QC on DP forms
* Output: H:/Ashwin/dta/Form16_tds_consolidated.dta
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

global comparison_path "H:/Ashwin/output/comparison_old_new"
global old_input_path "D:/data"
*output files*
global output_path "H:/Ashwin/dta/final"
global qc_path "H:/Ashwin/dta/qc"
global prob_path "H:/Ashwin/dta/prob"

*--------------------------------------------------------
** Conduct QC
	/* 1. All Mtins should be unique
		2. Year-wise registration data
		3. Check if data values are present or missing
		4. Overall registered and cancelled firms
			a. Yearwise cancelled firms
	*/
*--------------------------------------------------------

****** New Data **********
*Load DP information of firms*
use "${output_path}/dp_form.dta", clear

********** 1. All Mtins should be unique ************
duplicates tag Mtin, gen(repetitions) 
tab repetitions 
/*
. 91 missing MTin values (all 2018 registrations) 

repetitions |      Freq.     Percent        Cum.
------------+-----------------------------------
          0 |    686,473       99.99       99.99
         91 |         92        0.01      100.00
------------+-----------------------------------
      Total |    686,565      100.00
*/
drop repetitions
	
*********** 2. Yearwise registration data *****
	/* Calculate registration for each year */
gen temp_year = year(OriginalRegistrationDate)
replace temp_year = 1999 if temp_year < 2000
replace temp_year = 1 if temp_year == .
replace temp_year = 2019 if temp_year >=2019
tostring temp_year, replace
replace temp_year = "before 2000" if temp_year == "1999"
replace temp_year = "Missing" if temp_year == "1"
replace temp_year = "After 2018" if temp_year == "2019"

tab temp_year

/*
 temp_year |      Freq.     Percent        Cum.
------------+-----------------------------------
       2000 |      9,011        1.31        1.31
       2001 |      5,141        0.75        2.06
       2002 |      5,372        0.78        2.84
       2003 |      5,952        0.87        3.71
       2004 |      6,781        0.99        4.70
       2005 |    182,198       26.54       31.24
       2006 |     16,552        2.41       33.65
       2007 |     15,256        2.22       35.87
       2008 |     15,613        2.27       38.14
       2009 |     16,968        2.47       40.61
       2010 |     19,154        2.79       43.40
       2011 |     22,645        3.30       46.70
       2012 |     49,659        7.23       53.94
       2013 |     37,228        5.42       59.36
       2014 |     39,808        5.80       65.16
       2015 |     52,423        7.64       72.79
       2016 |     75,250       10.96       83.75
       2017 |     48,534        7.07       90.82
       2018 |        105        0.02       90.84
 After 2018 |          9        0.00       90.84
    Missing |         13        0.00       90.84
before 2000 |     62,893        9.16      100.00
------------+-----------------------------------
      Total |    686,565      100.00
*/
drop temp_year

************** 3. Check if data values are present or missing***************
/*	/* Checking values for each variable */
tab Ward
tab Zone
tab nature_of_business //264,659 values
tab Constitution_of_Business //264,659 values
tab type_of_registration //232,808 values
tab top_5_items
tab cea_registered //264,659 values
tab Whether_registered_for_IEC //264,659 values
tab sa_registered //264,659 values
tab commodities_interstate
tab Sale_Wise
tab Purchase_Wise
tab Whether_opted_for_composition //401,449 values
tab Current_status
tab Reason_for_cancellation
tab Date_of_cancellation
tab turnover_last_fy
*/
************** 4. Overall registered and cancelled firms **************

	/* Registered and cancelled firms */
tab RegistrationStatus
/*
 Registered |
         or |
  Cancelled |      Freq.     Percent        Cum.
------------+-----------------------------------
  Cancelled |    283,094       41.23       41.23
 Registered |    403,471       58.77      100.00
------------+-----------------------------------
      Total |    686,565      100.00
*/

	/* Yearwise cancelled firms */
gen CancellationYear = regexs(0) if regexm(CancellationDate, "([0-9][0-9][0-9][0-9])")
destring CancellationYear, replace
gen temp_year = CancellationYear
replace temp_year = 1999 if CancellationYear < 2000
replace temp_year = 1 if CancellationYear == .
//replace temp_year = 2019 if cancellation_year >=2018
tostring temp_year, replace
replace temp_year = "before 2000" if temp_year == "1999"
replace temp_year = "Missing" if temp_year == "1"
replace temp_year = "After 2018" if temp_year == "2019"
replace temp_year = "" if temp_year == "Missing"

tab temp_year
/* Yearwise Distribution of Cancelled Firms
  temp_year |      Freq.     Percent        Cum.
------------+-----------------------------------
       2000 |      3,718        1.31        1.31
       2001 |      6,707        2.37        3.68
       2002 |      5,335        1.88        5.57
       2003 |      5,945        2.10        7.67
       2004 |     13,734        4.85       12.52
       2005 |     15,673        5.54       18.05
       2006 |      6,207        2.19       20.25
       2007 |      5,897        2.08       22.33
       2008 |      7,055        2.49       24.82
       2009 |      8,110        2.86       27.69
       2010 |      7,324        2.59       30.27
       2011 |      8,121        2.87       33.14
       2012 |     20,304        7.17       40.32
       2013 |     57,917       20.46       60.77
       2014 |     34,772       12.28       73.06
       2015 |     18,901        6.68       79.73
       2016 |     16,267        5.75       85.48
       2017 |     13,599        4.80       90.28
       2018 |         30        0.01       90.29
before 2000 |     27,478        9.71      100.00
------------+-----------------------------------
      Total |    283,094      100.00
*/

drop temp_year
drop CancellationYear

************** 5. Output variables from new and old data***************

********Load new DP information*******
** Extract variable names and labels from DP 
	/* Saving DP variables in a xlsx format */
use "${output_path}/dp_form.dta", clear
descsave, ///
	saving("${comparison_path}/dp_variables_new.dta", replace)

use "${comparison_path}/dp_variables_new.dta", clear

drop format vallab
export excel  "${comparison_path}/dp_variables.xlsx", firstrow(variables) 

********Load old DP information*******
** ** Extract variable names and labels from DP 
	/* Saving DP variables in a xlsx format */
use "${old_input_path}/DealerProfile.dta", clear

descsave, saving("${comparison_path}/dp_variables_old.dta", replace)

use "${comparison_path}/dp_variables_old.dta", clear

drop format vallab
export excel  "${comparison_path}/dp_variables.xlsx", 



