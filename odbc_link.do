/************************************************* 
* Filename: 
* Input: 
* Purpose: This code links SQL database with STATA using ODBC driver
		     All the restored files have been saved as dta files
* Output: 
* Author: Ashwin MB
* Date: 30/07/2018
* Last modified: 22/10/2018 (Ashwin)
****************************************************/

** Initializing environment

clear all
version 1
set more off
qui cap log c
set mem 100m
odbc list 
odbc query "Cycle2_data"

*--------------------------------------------------------
** Setting directories and files
*--------------------------------------------------------

*input files*
global restored_path "Z:\Restored\"
global input_path1 "H:/Ashwin/dta/original" 

cd `restored_path'
*output files*
//global output_path "H:/Ashwin/dta"

**************************************************************************

**--------------------------------------------------------
** Bogus firms
*--------------------------------------------------------
	/* Convert suspicious firms for every year into dta files */
	
local query1 "SELECT * from Berkeley_Non_Existing_Firm.dbo.B_Report_NonExistingFirms_1213"
local query2 "SELECT * from Berkeley_Non_Existing_Firm.dbo.B_Report_NonExistingFirms_1314"
local query3 "SELECT * from Berkeley_Non_Existing_Firm.dbo.B_Report_NonExistingFirms_1415"
local query4 "SELECT * from Berkeley_Non_Existing_Firm.dbo.B_Report_NonExistingFirms_1516"
local query5 "SELECT * from Berkeley_Non_Existing_Firm.dbo.B_Report_NonExistingFirms_1617"

* replace query for each year's data
odbc load, exec ("`query5'") dsn("Cycle2_data") clear

* save bogus firms by replacing relevant year
save "${input_path}\bogus_1617", replace 

*--------------------------------------------------------
** Dealer Profile
*--------------------------------------------------------
	/* Convert DP consolidated information into dta file */
local query1 "SELECT * from Berkeley_1.dbo.B_Report1_all_withMTIN"

* Link odbc and save as dta file
odbc load, exec ("`query1'") dsn("Cycle2_data") clear
save "${input_path1}/dp_form", replace 

*--------------------------------------------------------
** Audit notices
*--------------------------------------------------------
	/* Convert audit notices for every year into dta files */

local query1 "SELECT * from Berekeley_1314.dbo.B_Report2_1314_withoutTIN"
local query2 "SELECT * from Berekeley_1314.dbo.B_Report2_1415_withoutTIN"
local query3 "SELECT * from Berekeley_1314.dbo.B_Report2_1516_withoutTIN"
local query4 "SELECT * from Berekeley_1314.dbo.B_Report2_1617_withoutTIN"

* Link odbc for every year and save as dta file for each year 
odbc load, exec ("`query1'") dsn("Cycle2_data") clear
save "H:\Ashwin\dta\audit_1314", replace 

*--------------------------------------------------------
** Form 16
*--------------------------------------------------------

** Form 16 (includes 3 forms per year)
	/* Form 16 contains three forms and saved as following 
	a) challan data - form16_year_1
	b) complete data - form16_year_2 
	c) tds data - form16_year_3
	*/

*1. Form 16 information 12-13*
local query1 "SELECT * from Berkeley_1213_1.dbo.B_Report3_1213_Challan_withMTIN"

local query2 "SELECT * from Berkeley_1213_1.dbo.B_report3_1213_return_commodity_withMTIN"
odbc load, exec ("`query1'") dsn("Cycle2_data") clear

save "H:\Ashwin\dta\original\Form16_1213_2", replace

*2. Form 16 information 13-14*
local query1 "SELECT * from Berkeley_1314_1.dbo.B_Report3_1314_Challan_withMTIN"
local query2 "SELECT * from Berkeley_1314_1.dbo.B_report3_1314_return_commodity_withMTIN"
local query3 "SELECT * from Berkeley_1314_1.dbo.B_Report3_1314_TDS_withMTIN"

odbc load, exec ("`query1'") dsn("Cycle2_data") clear
save "H:\Ashwin\dta\original\form16_1314_2", replace

*3. Form 16 information 14-15*
local query1 "SELECT * from Berkeley_1415_1.dbo.B_Report3_1415_Challan_withMTIN"
local query2 "SELECT * from Berkeley_1415_1.dbo.B_report3_1415_return_commodity_withMTIN"
local query3 "SELECT * from Berkeley_1415_1.dbo.B_Report3_1415_TDS_withMTIN"

odbc load, exec ("`query1'") dsn("Cycle2_data") clear
save "H:\Ashwin\dta\original\form16_1415_2", replace

*4. Form 16 information 15-16*
local query1 "SELECT * from Berkeley_1516_1.dbo.B_Report3_1516_Challan_withMTIN"
local query2 "SELECT * from Berkeley_1516_1.dbo.B_report3_1516_return_commodity_withMTIN"
local query3 "SELECT * from Berkeley_1516_1.dbo.B_Report3_1516_TDS_withMTIN"

odbc load, exec ("`query1'") dsn("Cycle2_data") clear
save "H:\Ashwin\dta\original\form16_1516_2", replace

*5. Form 16 information 16-17*
local query1 "SELECT * from Berkeley_1617_1.dbo.B_Report3_1617_Challan_withMTIN"
local query2 "SELECT * from Berkeley_1617_1.dbo.B_report3_1617_return_commodity_withMTIN"
local query3 "SELECT * from Berkeley_1617_1.dbo.B_Report3_1617_TDS_withMTIN"

odbc load, exec ("`query1'") dsn("Cycle2_data") clear
save "H:\Ashwin\dta\original\form16_1617_2", replace



*--------------------------------------------------------
** 2a2b forms
*--------------------------------------------------------

local query1 "SELECT * from Berkeley_2A2B_all.dbo.B_Report_2A2B_1Q_2013_withoutTIN"
odbc load, exec ("`query1'") dsn ("Cycle2_data") clear
save "H:\Ashwin\dta\original\2a2b_1q_2013"

local query2 "SELECT * from Berkeley_2A2B_all.dbo.B_Report_2A2B_1Q_2014_withoutTIN"
odbc load, exec ("`query2'") dsn ("Cycle2_data") clear
save "H:\Ashwin\dta\original\2a2b_1q_2014"

local query3 "SELECT * from Berkeley_2A2B_all.dbo.B_Report_2A2B_1Q_2015_withoutTIN"
odbc load, exec ("`query3'") dsn ("Cycle2_data") clear
save "H:\Ashwin\dta\original\2a2b_1q_2015"

local query4 "SELECT * from Berkeley_2A2B_all.dbo.B_Report_2A2B_1Q_2016_withoutTIN"
odbc load, exec ("`query4'") dsn ("Cycle2_data") clear
save "H:\Ashwin\dta\original\2a2b_1q_2016"

local query5 "SELECT * from Berkeley_2A2B_all.dbo.B_Report_2A2B_2Q_2013_withoutTIN"
odbc load, exec ("`query5'") dsn ("Cycle2_data") clear
save "H:\Ashwin\dta\original\2a2b_2q_2013"

local query6 "SELECT * from Berkeley_2A2B_all.dbo.B_Report_2A2B_2Q_2014_withoutTIN"
odbc load, exec ("`query6'") dsn ("Cycle2_data") clear
save "H:\Ashwin\dta\original\2a2b_2q_2014"

local query7 "SELECT * from Berkeley_2A2B_all.dbo.B_Report_2A2B_2Q_2015_withoutTIN"
odbc load, exec ("`query7'") dsn ("Cycle2_data") clear
save "H:\Ashwin\dta\original\2a2b_2q_2015"

local query8 "SELECT * from Berkeley_2A2B_all.dbo.B_Report_2A2B_2Q_2016_withoutTIN"
odbc load, exec ("`query8'") dsn ("Cycle2_data") clear
save "H:\Ashwin\dta\original\2a2b_2q_2016"

local query9 "SELECT * from Berkeley_2A2B_all.dbo.B_Report_2A2B_3Q_2013_withoutTIN"
odbc load, exec ("`query9'") dsn ("Cycle2_data") clear
save "H:\Ashwin\dta\original\2a2b_3q_2013"

local query10 "SELECT * from Berkeley_2A2B_all.dbo.B_Report_2A2B_3Q_2014_withoutTIN"
odbc load, exec ("`query10'") dsn ("Cycle2_data") clear
save "H:\Ashwin\dta\original\2a2b_3q_2014"

local query11 "SELECT * from Berkeley_2A2B_all.dbo.B_Report_2A2B_3Q_2015_withoutTIN"
odbc load, exec ("`query11'") dsn ("Cycle2_data") clear
save "H:\Ashwin\dta\original\2a2b_3q_2015"

local query12 "SELECT * from Berkeley_2A2B_all.dbo.B_Report_2A2B_3Q_2016_withoutTIN"
odbc load, exec ("`query12'") dsn ("Cycle2_data") clear
save "H:\Ashwin\dta\original\2a2b_3q_2016"

local query13 "SELECT * from Berkeley_2A2B_all.dbo.B_Report_2A2B_4Q_2013_withoutTIN"
odbc load, exec ("`query13'") dsn ("Cycle2_data") clear
save "H:\Ashwin\dta\original\2a2b_4q_2013"

local query14 "SELECT * from Berkeley_2A2B_all.dbo.B_Report_2A2B_4Q_2014_withoutTIN"
odbc load, exec ("`query14'") dsn ("Cycle2_data") clear
save "H:\Ashwin\dta\original\2a2b_4q_2014"

local query15 "SELECT * from Berkeley_2A2B_all.dbo.B_Report_2A2B_4Q_2015_withoutTIN"
odbc load, exec ("`query15'") dsn ("Cycle2_data") clear
save "H:\Ashwin\dta\original\2a2b_4q_2015"

local query16 "SELECT * from Berkeley_2A2B_all.dbo.B_Report_2A2B_4Q_2016_withoutTIN"
odbc load, exec ("`query16'") dsn ("Cycle2_data") clear
save "H:\Ashwin\dta\original\2a2b_4q_2016"

local query17 "SELECT * from Berkeley_2A2B_all.dbo.B_Report_2A2B_April_2012_withoutTIN"
odbc load, exec ("`query17'") dsn ("Cycle2_data") clear
save "H:\Ashwin\dta\original\2a2b_apr_2012"

local query18 "SELECT * from Berkeley_2A2B_all.dbo.B_Report_2A2B_Aug_2012_withoutTIN"
odbc load, exec ("`query18'") dsn ("Cycle2_data") clear
save "H:\Ashwin\dta\original\2a2b_aug_2012"

local query19 "SELECT * from Berkeley_2A2B_all.dbo.B_Report_2A2B_Dec_2012_withoutTIN"
odbc load, exec ("`query19'") dsn ("Cycle2_data") clear
save "H:\Ashwin\dta\original\2a2b_dec_2012"

local query20 "SELECT * from Berkeley_2A2B_all.dbo.B_Report_2A2B_Feb_2013_withoutTIN"
odbc load, exec ("`query20'") dsn ("Cycle2_data") clear
save "H:\Ashwin\dta\original\2a2b_feb_2013"

local query21 "SELECT * from Berkeley_2A2B_all.dbo.B_Report_2A2B_Jan_2013_withoutTIN"
odbc load, exec ("`query21'") dsn ("Cycle2_data") clear
save "H:\Ashwin\dta\original\2a2b_jan_2013"

local query22 "SELECT * from Berkeley_2A2B_all.dbo.B_Report_2A2B_July_2012_withoutTIN"
odbc load, exec ("`query22'") dsn ("Cycle2_data") clear
save "H:\Ashwin\dta\original\2a2b_jul_2012"

local query23 "SELECT * from Berkeley_2A2B_all.dbo.B_Report_2A2B_June_2012_withoutTIN"
odbc load, exec ("`query23'") dsn ("Cycle2_data") clear
save "H:\Ashwin\dta\original\2a2b_jun_2012"

local query24 "SELECT * from Berkeley_2A2B_all.dbo.B_Report_2A2B_Mar_2013_withoutTIN"
odbc load, exec ("`query24'") dsn ("Cycle2_data") clear
save "H:\Ashwin\dta\original\2a2b_mar_2013"

local query25 "SELECT * from Berkeley_2A2B_all.dbo.B_Report_2A2B_May_2012_withoutTIN"
odbc load, exec ("`query25'") dsn ("Cycle2_data") clear
save "H:\Ashwin\dta\original\2a2b_may_2012"

local query26 "SELECT * from Berkeley_2A2B_all.dbo.B_Report_2A2B_Nov_2012_withoutTIN"
odbc load, exec ("`query26'") dsn ("Cycle2_data") clear
save "H:\Ashwin\dta\original\2a2b_nov_2012"

local query27 "SELECT * from Berkeley_2A2B_all.dbo.B_Report_2A2B_Oct_2012_withoutTIN"
odbc load, exec ("`query27'") dsn ("Cycle2_data") clear
save "H:\Ashwin\dta\original\2a2b_oct_2012"

local query28 "SELECT * from Berkeley_2A2B_all.dbo.B_Report_2A2B_sept_2012_withoutTIN"
odbc load, exec ("`query28'") dsn ("Cycle2_data") clear
save "H:\Ashwin\dta\original\2a2b_sep_2012"



