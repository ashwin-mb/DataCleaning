  /************************************************* 
* Filename: 
* Input: 
* Purpose: This master do files contains all do files 
			*All sample do files, output sample dta files
			*All cleaning do files, output dta files
			*All output do files, output dta files
* Output:
* Author: Ashwin MB
* Date: 17/10/2018
* Last modified: 22/10/2018 (Ashwin)
****************************************************/

*--------------------------------------------------------
** New Do files
*--------------------------------------------------------

***** ODBC file
	/* Links SQL database with STATA using ODBC driver
		Saves files in dta format */
"D:/Ashwin/do/odbc_link.do"

***** Creates sample data
	/* Creates sample for all the forms */
 "D:/Ashwin/do/sample.do" 
 
***** DP forms
	/* Cleans variables and creates uniques list of Mtins */
 "D:/Ashwin/do/dp_form.do"
 
	/* Conduct quality checks on DP forms */
 "D:/Ashwin/do/dp_form_qc.do"
 
***** Form 16
	/* Creates a consolidated data of form 16 tds data
			and cleans all the variables */
 "D:/Ashwin/do/Form_16_tds.do" 
 
	/* Creates a consolidated data of form 16 challan data
			and cleans all the variables */
 "D:/Ashwin/do/Form_16_challan.do" 
 
 	/* Cleans the form 16 data by renaming the variables */
 "D:/Ashwin/do/Form_16.do" 
 
 
 ***** Audit forms
		/* Creates a consolidated data of audit forms data
			and cleans all the variables */
 "D:/Ashwin/do/audit_notices.do"
 
 ***** Bogus firms
		/* Creates a consolidated data of bogus firms data
			and cleans all the variables */
 "D:/Ashwin/do/Non_existing_firms_consolidated.do"
 
 *--------------------------------------------------------
** Old Do files
*--------------------------------------------------------
 
 ***** DP form
	/* Cleans old DP forms */
	
"D:\data\TableCreation\DealerProfile.do"
 

*--------------------------------------------------------
** Old Dta files
*--------------------------------------------------------

***** DP form
	/* Cleaned old DP form */

use "D:\data\DealerProfile.dta", clear
	
	
	
	
	
*--------------------------------------------------------
** Sample dta files 
*--------------------------------------------------------

* DP sample data * 
"H:/Ashwin/sample_dta/sample_dp.dta"

* Form 16 sample data *
"H:/Ashwin/sample_dta/sample_form16.dta"

* Form 16 challan sample data *
"H:/Ashwin/sample_dta/sample_form16_challan.dta"

* Form 16 tds sample data *
"H:/Ashwin/sample_dta/sample_form16_tds.dta"

/* Audit notices and bogus list do not require sample data set 
	since they are small data sets */

*--------------------------------------------------------
** Other dta files 
*--------------------------------------------------------

* Unique list of Mtins *
"H:\Ashwin\dta\final\mtin_list.dta"
	




