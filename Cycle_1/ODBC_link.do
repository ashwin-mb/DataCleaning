/* 
	Author Name: Ashwin MB
	Data - 30/07/2018
	Last Edit - 30/07/2018
	Purpose - Link Stata to SQL DB using ODBC driver and save as DTA files
*/

clear all
pause off
set more off
odbc list 
odbc query "VAT"

**************************************************************************
global path "Z:\Restored"

local query1 "SELECT * from Berkeley_1213.dbo.B_Report1_1213_withoutTIN"
local query2 "SELECT * from Berkeley_1213.dbo.B_report3_1213_updated_withoutTIN"

local query3 "SELECT * from Berekeley_1314.dbo.B_Report1_1314_withoutTIN"
local query4 "SELECT * from Berekeley_1314.dbo.B_Report2_1314_withoutTIN"
local query5 "SELECT * from Berekeley_1314.dbo.B_report3_1314_updated_withoutTIN"
local query6 "SELECT * from Berekeley_1314.dbo.B_Report4_1314_updated_withoutTIN"
local query7 "SELECT * from Berekeley_1314.dbo.B_Report5_1314_updated_withoutTIN"

local query3 "SELECT * from Berekeley_1415.dbo.B_Report1_1415_withoutTIN"
local query4 "SELECT * from Berekeley_1415.dbo.B_Report2_1415_withoutTIN"
local query5 "SELECT * from Berekeley_1415.dbo.B_report3_1415_updated_withoutTIN"
local query6 "SELECT * from Berekeley_1415.dbo.B_Report4_1415_updated_withoutTIN"
local query7 "SELECT * from Berekeley_1415.dbo.B_Report5_1415_updated_withoutTIN"

local query3 "SELECT * from Berekeley_1516.dbo.B_Report1_1516_withoutTIN"
local query4 "SELECT * from Berekeley_1516.dbo.B_Report2_1516_withoutTIN"
local query5 "SELECT * from Berekeley_1516.dbo.B_report3_1516_updated_withoutTIN"
local query6 "SELECT * from Berekeley_1516.dbo.B_Report4_1516_updated_withoutTIN"
local query7 "SELECT * from Berekeley_1516.dbo.B_Report5_1516_updated_withoutTIN"

local query3 "SELECT * from Berekeley_1617.dbo.B_Report1_1617_withoutTIN"
local query4 "SELECT * from Berekeley_1617.dbo.B_Report2_1617_withoutTIN"
local query5 "SELECT * from Berekeley_1617.dbo.B_report3_1617_updated_withoutTIN"
local query6 "SELECT * from Berekeley_1617.dbo.B_Report4_1617_updated_withoutTIN"
local query7 "SELECT * from Berekeley_1617.dbo.B_Report5_1617_updated_withoutTIN"

**************************************************************************
*Loading the descriptions of VAT variables*
**odbc load, exec ("`query'") dsn("VAT") clear**

odbc load, exec ("SELECT * from Berekeley_1617.dbo.B_Report2_1617_withoutTIN") dsn("VAT") clear
save "H:\Ashwin\Dta_files\Audit_notices_1617.dta", replace


