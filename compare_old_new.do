 /************************************************* 
* Filename: 
* Input: H:/Ashwin/demonetization/dta/output/old_data.dta
		 H:/Ashwin/demonetization/dta/output/demonetization_data.dta
* Purpose: Clean old data by removing unneccessary quarters and compare with 
			new data
* Output: 
* Author: Ashwin MB
* Date: 12/10/2018
* Last modified: 12/10/2018 (Ashwin)
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

global input_path "H:\Ashwin\demonetization\dta\output"

****** Clean old data *******
	/* load old data */
	
use "${input_path}\old_data.dta", clear

*removing all quarters before 2013*

keep if TaxPeriod =="First Quarter-2013" | TaxPeriod =="First Quarter-2014" ///
	|  TaxPeriod =="Second Quarter-2013" | TaxPeriod =="Second Quarter-2014" /// 
	|  TaxPeriod =="Third Quarter-2013" | TaxPeriod =="Third Quarter-2014" ///
	|  TaxPeriod =="Fourth Quarter-2013" | TaxPeriod =="Fourth Quarter-2014"

export delimited "${input_path}\old_data_clean.csv", replace

	
	
	
	