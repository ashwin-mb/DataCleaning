/************************************************* 
* Filename: 
* Input: H:/Ashwin/dta/DP_forms.dta
* Purpose: Rename DP variables 
			create unique Mtin list and cancelled mtin list
* Output: H:/Ashwin/dta/DP_forms.dta
			H:/Ashwin/dta/unique_mtin_list.dta
			H:/Ashwin/dta/cancelled_mtin_list.dta
* Author: Ashwin MB
* Date: 21/09/2018
* Last modified: 22/10/2018 (Ashwin)
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
** Cleaning variables
*--------------------------------------------------------

****** New Data **********
* Load DP information of firms
use "${input_path1}/dp_form.dta", clear

* renaming (some based on old data) and ordering variables appropriately
rename mtin Mtin
rename Data_of_original_registration OriginalRegistrationDate
rename var2 RegistrationDate
rename Nature_of_Bussiness Nature
rename Constitution_of_Business Constitution
rename var7 RegistrationType
rename var8 Top5Items
rename var9 BooleanRegisteredCE
rename Whether_registered_for_IEC BooleanRegisteredIEC
rename var11 BooleanServiceTax
rename var12 CommoditiesInterstate
rename Sale_Wise SaleWise
rename Purchase_Wise PurchaseWise
rename Whether_opted_for_composition	OptComposition
rename Current_status 			RegistrationStatus
rename Reason_for_cancellation 			CancellationReason
rename Date_of_cancellation 			CancellationDate
rename var20 TurnoverPreviousYear

order Mtin, before(OriginalRegistrationDate)

* Renaming variables labels according to the old data * 

label variable Mtin "Deidentified Dealer TIN"
label variable Ward "Original Ward"
label variable Nature "Nature of Business"
label variable OptComposition "Opting for Composition"
label variable RegistrationStatus "Registered or Cancelled"
label variable CancellationReason "Reason for Cancellation"
label variable CancellationDate "Date of Cancellation"
label variable SaleWise "Interstate Commodities by Sale"
label variable PurchaseWise "Interstate Commodities by Purchase"


save "${output_path}/dp_form.dta", replace

** Rename Cancellation Date to proper format
	/* Most CancellationDate rows are in xxxx-xx-xx format. Making other 
	format data into same */
use "${output_path}/dp_form.dta", clear

replace CancellationDate = "2015-09-11" if Mtin == "1094567"
replace CancellationDate = "2015-09-07" if Mtin == "1460562"
replace CancellationDate = "2015-10-12" if Mtin == "1810197"
replace CancellationDate = "2015-07-31" if Mtin == "1434711"
replace CancellationDate = "2015-07-14" if Mtin == "1532286"
replace CancellationDate = "2015-01-18" if Mtin == "1647832"
replace CancellationDate = "2015-01-18" if Mtin == "1694222"
replace CancellationDate = "2015-08-16" if Mtin == "1267792"
replace CancellationDate = "2015-08-06" if Mtin == "1300742"
replace CancellationDate = "2015-08-03" if Mtin == "1056028"

save "${output_path}/dp_form.dta", replace

************** Create list of unique TIN numbers **********
* Create list of unique TIN number and their status, year of cancellation
use "${output_path}/dp_form.dta", clear

gen CancellationYear = ""
replace CancellationYear = regexs(0) ///
	if regexm(CancellationDate, "([0-9][0-9][0-9][0-9])")

keep Mtin OriginalRegistrationDate RegistrationDate RegistrationStatus CancellationYear 

save "${output_path}/unique_mtin_dp.dta", replace // Contains 92 missing TIN values


