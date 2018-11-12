/* 
	Author Name: Ashwin MB
	Data - 29/07/2018
	Last Edit - 29/07/2018
	Purpose - Compare new VAT data received with older VAT data
*/

clear all
pause off
set more off

/***************** Comparing basic levels stats for DP data *****************/
/* Variables in the new data is combination of Form 4, 11 and DP-1 */
/* Equivalent file in new data = "Report1" */
use "D:\data\DealerProfile.dta"
keep DealerTIN Name RegistrationDate Ward Nature Constitution OtherConstitution OptConstitution RegistrationType OptConstitution BooleanRegisteredCE BooleanServiceTax BooleanRegisteredIEC ItemDescription
//keep if DealerTIN != ""

duplicates tag DealerTIN, gen(repetitions)
gsort -repetitions DealerTIN -RegistrationDate
duplicates drop DealerTIN, force

/***Registrated firms during a Specific Year ***/
gen temp_month1 = month(dofc(RegistrationDate))
gen temp_year = year(dofc(RegistrationDate))

replace temp_year1=0
replace temp_year1 = 1  if (temp_year == 2012 & temp_month1 <4) 

replace temp_year2 = 0 
replace temp_year2 = 1 if (temp_year < 2012) 

*Total registed firms in Specific Year*
bro if temp_year1 ==1 | temp_year2 ==1


use "D:\data\CancellationForm.dta"
bro




/****************** Comparing Cancellation forms data **************************/
/* Variables in the new data is Form 37 */
/* Equivalent file in new data = Report2 */
use "D:\data\form37_data_auditnotice.dta"

/*Count no of audit notices in yr 13-14 */
gen temp_month1 = month(dofc(DateActualNotice))
gen temp_year = year(dofc(DateActualNotice))

replace temp_year1=0
replace temp_year1 = 1  if (temp_year == 2013 & temp_month >=4) 

gen temp_year2 = 0 
replace temp_year2 = 1 if (temp_year == 2014 & temp_month <=3) 

*Total audit notices in 13-14*
keep if temp_year1 == 1 | temp_year2 == 1

*Unique Dealer TIN in 13-14*
duplicates tag DealerTIN, gen(repitions)
duplicates drop DealerTIN, force
tab DealerTIN


/***Count no of audit notices in yr 14-15 ***/
gen temp_month1 = month(dofc(DateActualNotice))
gen temp_year = year(dofc(DateActualNotice))

gen temp_year1=0
replace temp_year1 = 1  if (temp_year == 2014 & temp_month >=4) 

gen temp_year2 = 0 
replace temp_year2 = 1 if (temp_year == 2015 & temp_month <=3) 

*Total audit notices in 14-15*
keep if temp_year1 == 1 | temp_year2 == 1

*Unique Dealer TIN in 14-15*
duplicates tag DealerTIN, gen(repitions)
duplicates drop DealerTIN, force
tab DealerTIN





/****************** Comparing Form 16 data **************************/
/* Equivalent file in new data = Report3 */
use "D:\data\form16_data.dta"
bro


/****************** Comparing 2A data **************************/
/* Equivalent file in new data = Report4 */
use "D:\data\annexure_2A2B_quarterly_2013.dta.dta"
bro

/****************** Comparing 2B data **************************/
/* Equivalent file in new data = Report5 */
use "D:\data\annexure_2A2B_quarterly_2013.dta.dta"
bro

