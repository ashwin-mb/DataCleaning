/* 
	Author Name: Ashwin MB
	Data - 1/08/2018
	Last Edit - 02/08/2018
	Purpose - Do Sanity checks for DP1 data 
*/

*What/ How are you going to do* 

/*
** New Data **
Check if each DP is for registered firms within that year
Add another column for FY 
Append the data
Take tabulate to count the firms each year 
Check for repetitions 
Check values for each variable

Old Data
Year wise registration of firms 
Remove for duplicates/ missing data
Compare it with older DP1 data
Create a table with this information
*/

/***************** Append all the years data  *****************/
/* Extract all years data */
clear all
pause off
set more off

/***DP information mistakedly combined for FY 12-13 and FY 13-14  
* Removing FY 13-14 information and saving *
gen temp_month = month(Data_of_original_registration)
gen temp_year = year(Data_of_original_registration)

gen temp_year1=0
replace temp_year1 = 1  if (temp_year == 2014 & temp_month <4) 

gen temp_year2 = 0 
replace temp_year2 = 1 if (temp_year == 2013 & temp_month >= 4) 

* Remove FY 13-14 information *
drop if temp_year1 == 1 | temp_year2 == 1 
drop temp_year1 temp_year2 temp_month temp_year

save "H:\Ashwin\Dta_files\DP_1213.dta", replace
*/

use "H:\Ashwin\Raw_dta_files\DP_1213.dta"
gen fy = "12-13"

* Append all the files * 

append using "H:\Ashwin\Raw_dta_files\DP_1314.dta"
replace fy = "13-14" if fy == ""

append using "H:\Ashwin\Raw_dta_files\DP_1415.dta"
replace fy = "14-15" if fy == ""
replace mtin = MTin if mtin == ""
drop MTin

append using "H:\Ashwin\Raw_dta_files\DP_1516.dta"
replace fy = "15-16" if fy == ""
replace mtin = MTin if mtin == ""
drop MTin

append using "H:\Ashwin\Raw_dta_files\DP_1617.dta"
replace fy = "16-17" if fy == ""
replace mtin = MTin if mtin == ""
drop MTin

*Count year wise split of firms*
tab fy

*Check duplicates across years*
duplicates tag mtin, gen(mtin_repetitions)
gsort -mtin_repetitions //no duplicates found
drop mtin_repetitions

*Consolidated list of DP information*
save "H:\Ashwin\Processed_dta_files\DP_consolidated.dta", replace

*List of all firms*
keep mtin
save "H:\Ashwin\Processed_dta_files\DP_mtin_list.dta", replace

/* Renaming all the variables appropriately*/
use "H:\Ashwin\Processed_dta_files\DP_consolidated.dta"

rename var2 Date_liable_DVAT
rename var7 Type_of_registration
rename var8 Top_items
rename var9 registered_csa
rename var11 registered_services
rename var12 commodities_interstate

** Sanity checks on DP variables **
tab fy if fy == "16-17"
tab Ward if fy == "16-17"
tab Zone if fy == "16-17"
tab Nature_of_Bussiness if fy == "16-17"
tab Constitution_of_Business if fy == "16-17"
tab Type_of_registration if fy=="16-17"
//tab Top_items if fy=="16-17"
tab registered_csa if fy=="16-17"
tab Whether_registered_for_IEC if fy == "16-17"
tab registered_services if fy=="16-17"
tab commodities_interstate if fy=="16-17"
tab Sale_Wise if fy=="16-17"
tab Purchase_Wise if fy=="16-17"
tab Whether_opted_for_composition if fy=="16-17"
sum Turnover_in_preceding_year if fy=="16-17"
tab Current_status if fy=="16-17"
tab Reason_for_cancellation if fy=="16-17"
tab Date_of_cancellation if fy=="16-17"


** compare old data with new data ** 
use "D:\Data\DealerProfile.dta", clear
keep DealerTIN Name RegistrationDate Ward Nature Constitution OtherConstitution OptConstitution RegistrationType OptConstitution BooleanRegisteredCE BooleanServiceTax BooleanRegisteredIEC ItemDescription TurnoverPreviousYear

* Drop repetitions of TIN by retaining the latest registration date *
duplicates tag DealerTIN, gen(repetitions)
gsort -repetitions DealerTIN -RegistrationDate
duplicates drop DealerTIN, force

/***Registrated firms during a Specific Year ***/
gen temp_month = month(dofc(RegistrationDate))
gen temp_year = year(dofc(RegistrationDate))


gen temp_year1=0
replace temp_year1 = 1 if (temp_year == 2012 & temp_month <= 3) 
gen temp_year2 = 0 
replace temp_year2 = 1 if (temp_year < 2012)
gen fy = ""
replace fy = "Before 2012" if (temp_year1 == 1 | temp_year2 == 1)

*keep changing the year*
replace temp_year1=0
replace temp_year1 = 1 if (temp_year == 2013 & temp_month <= 3) 
replace temp_year2 = 0 
replace temp_year2 = 1 if (temp_year == 2012 & temp_month > 3)
replace fy = "12-13" if (temp_year1 == 1 | temp_year2 == 1)

* Count values for each year old data *

tab fy if fy == "12-13"
sum TurnoverPreviousYear if fy== "12-13" & TurnoverPreviousYear == 0
tab Ward if fy == "14-15"
tab Nature if fy == "14-15"
tab Constitution if fy == "14-15"
tab RegistrationType if fy == "14-15"
tab OptConstitution if fy == "14-15"
tab BooleanRegisteredCE if fy == "14-15"
tab BooleanServiceTax if fy == "14-15"
tab BooleanRegisteredIEC if fy == "14-15"
tab ItemDescription if  fy == "14-15"









