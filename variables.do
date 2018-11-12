/************************************************* 
* Filename: 
* Input: H:/Ashwin/dta/final/DP_forms.dta
		 H:/data/dp_form.dta
* Purpose: Compare old and new dp forms by saving the variables names
* Output: 
* Author: Ashwin MB
* Date: 30/10/2018
* Last modified: 30/10/2018 (Ashwin)
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

global comparison_path "H:/Ashwin/output/comparison_old_new"
global old_input_path "D:/data"

*output files*
global output_path "H:/Ashwin/dta/final"

*--------------------------------------------------------
** DP Forms
*--------------------------------------------------------
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
export excel  "${comparison_path}/dp_variables.xlsx", firstrow(variables) she("Sheet2") sheetmodify

*--------------------------------------------------------
** Cancellation Forms
*--------------------------------------------------------
********Load new DP information*******
** New DP information contains Cancellation data 
	/* Saving DP variables in a xlsx format */
use "${output_path}/dp_form.dta", clear
descsave, ///
	saving("${comparison_path}/cancellation_variables_new.dta", replace)

use "${comparison_path}/cancellation_variables_new.dta", clear

drop format vallab
export excel  "${comparison_path}/cancellation_variables.xlsx", firstrow(variables) 

********Load old cancellation information*******
** Extract variable names and labels from DP 
	/* Saving DP variables in a xlsx format */
use "${old_input_path}/CancellationForm.dta", clear

descsave, saving("${comparison_path}/cancellation_variables_old.dta", replace)

use "${comparison_path}/cancellation_variables_old.dta", clear

drop format vallab
export excel  "${comparison_path}/cancellation_variables.xlsx", firstrow(variables) she("Sheet2") sheetmodify





