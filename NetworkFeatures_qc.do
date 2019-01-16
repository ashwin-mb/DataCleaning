/************************************************* 
* Filename: 
* Input: 
* Purpose: Compare old network features with new network features
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
** 1. Setting directories and files
*--------------------------------------------------------

*input files*
global input_path1 "H:/Ashwin/dta/original"
global input_path2 "H:/Ashwin/dta/intermediate"
global input_path3 "H:/Ashwin/dta/intermediate2"
global temp_path1 "H:/Ashwin/dta/temp"


*output files*
global output_path "H:/Ashwin/dta/final"
global analysis_path "H:/Ashwin/dta/analysis"
global qc_path "H:/Ashwin/dta/qc"
global prob_path "H:/Ashwin/dta/prob"
global features_path "H:/Ashwin/dta/bogusdealers"


import delim "H:/Ashwin/dta/bogusdealersNetworkFeaturesPurchases9.csv", varn(1) clear
save "H:/Ashwin/dta/bogusdealersNetworkFeaturesPurchases9.dta", replace




import delim "D:/Ofir/output_data/all_returns_features_minus_q12.csv", varn(1) clear

