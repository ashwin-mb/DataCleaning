/************************************************* 
* Filename: 
* Input: H:/Ashwin/dta/Non_existing_firm_year.dta
* Purpose: Creates summary stats for bogus firms and firms linked to bogus
* Output: H:/Ashwin/dta/Non_existing_firm_consolidated.dta
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

*output files*
global output_path "H:/Ashwin/dta/final"
global analysis_path "H:/Ashwin/dta/analysis"
global qc_path "H:/Ashwin/dta/qc"
global prob_path "H:/Ashwin/dta/prob"

*--------------------------------------------------------
** Quarterly level summary stats of bogus firms
*--------------------------------------------------------

use "${output_path}/bogus_consolidated.dta", clear
tostring Mtin, replace
merge 1:m Mtin using "${output_path}/dp_form.dta"
keep if _merge == 3 
keep Mtin Reason inspection_year RegistrationStatus CancellationDate

*Merge Form16 data with Bogus firms list* 
merge 1:m Mtin using "${output_path}/form16_data_consolidated.dta"

*Retain only completely merged data
keep if _merge == 3 

tab TaxPeriod
/* Number of forms filed by Firms per Quarter

    The tax period for |
 which the returns has |
            been filed |      Freq.     Percent        Cum.
-----------------------+-----------------------------------
    First Quarter-2013 |          5        0.03        0.03
    First Quarter-2014 |        206        1.41        1.45
    First Quarter-2015 |      1,857       12.74       14.19
    First Quarter-2016 |      1,196        8.20       22.39
   Fourth Quarter-2013 |          8        0.05       22.45
   Fourth Quarter-2014 |      1,349        9.25       31.70
   Fourth Quarter-2015 |      1,485       10.19       41.89
   Fourth Quarter-2016 |        616        4.23       46.11
   Second Quarter-2013 |          7        0.05       46.16
   Second Quarter-2014 |        725        4.97       51.14
   Second Quarter-2015 |      2,082       14.28       65.42
   Second Quarter-2016 |      1,047        7.18       72.60
    Third Quarter-2013 |          5        0.03       72.63
    Third Quarter-2014 |      1,301        8.93       81.56
    Third Quarter-2015 |      1,899       13.03       94.59
    Third Quarter-2016 |        789        5.41      100.00
-----------------------+-----------------------------------
                 Total |     14,577      100.00

*/

* Contains list of bogus firms that have form16 data
save "${temp_path1}/bogus_form16_merged.dta", replace 

*--------------------------------------------------------
** Summary Stats of bogus firms at quarter level
*--------------------------------------------------------
use "${temp_path1}/bogus_form16_merged.dta", clear
//keep Mtin Reason inspection_year 
//export excel "${temp_path1}/bogus_form16_merged.xlsx", firstrow(variables)

*Retain the latest return
gsort Mtin TaxPeriod -DateofReturnFiled
duplicates drop Mtin TaxPeriod, force

*Count firms at quarter level
gen g_turnover = 0 
gen c_turnover = 0
gen l_turnover = 0
gen tax_paid = 0
replace g_turnover = 1 if GrossTurnover == 0  
replace c_turnover = 1 if CentralTurnover == 0 
replace l_turnover = 1 if LocalTurnover == 0 
replace tax_paid = 1 if AmountDepositedByDealer>0

bysort TaxPeriod: egen no_firms = count(Mtin)
bysort TaxPeriod: egen firms_paid_tax = sum(tax_paid)
bysort TaxPeriod: egen firms_zero_gross = sum(g_turnover)
bysort TaxPeriod: egen firms_zero_central = sum(c_turnover)
bysort TaxPeriod: egen firms_zero_local = sum(l_turnover)

*Ratio of VAT local, central to total ratio
gen vat_ratio = LocalTurnover/GrossTurnover
gen vat_central_ratio = CentralTurnover/GrossTurnover

bysort TaxPeriod: egen output_tax = sum(TotalOutputTax)
bysort TaxPeriod: egen input_credit = sum(TotalTaxCredit)
bysort TaxPeriod: egen net_tax = sum(NetTax)
bysort TaxPeriod: egen amount_deposited = sum(AmountDepositedByDealer)
bysort TaxPeriod: egen net_balance = sum(NetBalance)
bysort TaxPeriod: egen gross_turnover = sum(GrossTurnover)
bysort TaxPeriod: egen central_turnover = sum(CentralTurnover)
bysort TaxPeriod: egen local_turnover = sum(LocalTurnover)

bysort TaxPeriod: egen total_vat_ratio = sum(vat_ratio)
bysort TaxPeriod: egen total_vat_central_ratio = sum(vat_central_ratio)

duplicates drop TaxPeriod, force

gen mean_output_tax = output_tax/no_firms
gen mean_input_credit = input_credit/no_firms
gen mean_net_tax = net_tax/no_firms
gen mean_amount_deposited = amount_deposited/no_firms
gen mean_net_balance = net_balance/no_firms

gen mean_vat_ratio = total_vat_ratio/no_firms
gen mean_vat_central_ratio = total_vat_central_ratio/no_firms

gen mean_vat_ratio_nonzero = total_vat_ratio/(no_firms - firms_zero_gross)
gen mean_vat_central_ratio_nonzero = total_vat_central_ratio/(no_firms - firms_zero_gross)

*Retaining only relevant columns*
*no of firms, total tax, mean value, mean of ratios*
keep TaxPeriod ///
no_firms firms_paid_tax firms_zero_gross firms_zero_central firms_zero_local ///
output_tax input_credit net_tax amount_deposited net_balance ///
gross_turnover central_turnover local_turnover ///
mean_output_tax mean_input_credit mean_net_tax mean_amount_deposited mean_net_balance ///
mean_vat_ratio mean_vat_central_ratio mean_vat_ratio_nonzero mean_vat_central_ratio_nonzero

save "${analysis_path}\bogus_summarystats.dta", replace
export excel "${analysis_path}\bogus_summarystats.xlsx", firstrow(variables)

*--------------------------------------------------------
** Identify list of dealer who interact with bogus firms
*--------------------------------------------------------
** Merge bogus firms with Form16 with dealers who interact with them

*Merge 2012 2a2b monthly data
use "${temp_path1}/bogus_form16_merged.dta", clear
keep Mtin
duplicates drop
merge 1:m Mtin using "${output_path}/2a2b_monthly_2012.dta" 
keep if _merge == 3 
keep Mtin SellerBuyerTin
save "${analysis_path}/Bogus_network_firms.dta", replace

*Merge with 2013, 2014 2a2b quarterly data
foreach var1 in 2013 2014 {
use "${temp_path1}/bogus_form16_merged.dta", clear
keep Mtin
duplicates drop
merge 1:m Mtin using "${output_path}/2a2b_quarterly_`var1'.dta" 
keep if _merge == 3 
keep Mtin SellerBuyerTin
append using "${analysis_path}/Bogus_network_firms.dta"
save "${analysis_path}/Bogus_network_firms.dta", replace
}

*Merge with 2015 2016 2a2b quarterly data 
foreach var1 in 2015 2016 {
foreach var2 in 1 2 3 4 {
use "${temp_path1}/bogus_form16_merged.dta", clear
keep Mtin
duplicates drop
merge 1:m Mtin using "${output_path}/2a2b_`var1'_q`var2'.dta" 
keep if _merge == 3 
keep Mtin SellerBuyerTin
append using "${analysis_path}/Bogus_network_firms.dta"
save "${analysis_path}/Bogus_network_firms.dta", replace
}
}

*--------------------------------------------------------
** Local firms that interact with bogus dealers
*--------------------------------------------------------
use "${analysis_path}/Bogus_network_firms.dta", clear

duplicates drop
destring SellerBuyerTin, replace
*Identify and remove outside dealers
gen outside_state = 0 
replace outside_state = 1 if SellerBuyerTin >1000000000
tab outside_state
keep if outside_state == 0 
*Remove bogus firms and retain network bogus firms
drop Mtin
duplicates drop SellerBuyerTin, force
rename SellerBuyerTin Mtin
tostring Mtin, replace
drop outside_state

save "${output_path}/bogus_network_firms_local.dta", replace

*--------------------------------------------------------
** Summary stats of dealers with bogus buyers or sellers
*--------------------------------------------------------

use "${output_path}/bogus_network_firms_local.dta", clear

*Merge Form16 data with Network Bogus firms list* 
merge 1:m Mtin using "${output_path}/form16_data_consolidated.dta"

*Retain only completely merged data
keep if _merge == 3

*Retain the latest return
gsort Mtin TaxPeriod -DateofReturnFiled
duplicates drop Mtin TaxPeriod, force

*Count firms at quarter level
gen g_turnover = 0 
gen c_turnover = 0
gen l_turnover = 0
gen tax_paid = 0
replace g_turnover = 1 if GrossTurnover == 0  
replace c_turnover = 1 if CentralTurnover == 0 
replace l_turnover = 1 if LocalTurnover == 0 
replace tax_paid = 1 if AmountDepositedByDealer>0

bysort TaxPeriod: egen no_firms = count(Mtin)
bysort TaxPeriod: egen firms_paid_tax = sum(tax_paid)
bysort TaxPeriod: egen firms_zero_gross = sum(g_turnover)
bysort TaxPeriod: egen firms_zero_central = sum(c_turnover)
bysort TaxPeriod: egen firms_zero_local = sum(l_turnover)

*Ratio of VAT local, central to total ratio
gen vat_ratio = LocalTurnover/GrossTurnover
gen vat_central_ratio = CentralTurnover/GrossTurnover

bysort TaxPeriod: egen output_tax = sum(TotalOutputTax)
bysort TaxPeriod: egen input_credit = sum(TotalTaxCredit)
bysort TaxPeriod: egen net_tax = sum(NetTax)
bysort TaxPeriod: egen amount_deposited = sum(AmountDepositedByDealer)
bysort TaxPeriod: egen net_balance = sum(NetBalance)
bysort TaxPeriod: egen gross_turnover = sum(GrossTurnover)
bysort TaxPeriod: egen central_turnover = sum(CentralTurnover)
bysort TaxPeriod: egen local_turnover = sum(LocalTurnover)

bysort TaxPeriod: egen total_vat_ratio = sum(vat_ratio)
bysort TaxPeriod: egen total_vat_central_ratio = sum(vat_central_ratio)

duplicates drop TaxPeriod, force

gen mean_output_tax = output_tax/no_firms
gen mean_input_credit = input_credit/no_firms
gen mean_net_tax = net_tax/no_firms
gen mean_amount_deposited = amount_deposited/no_firms
gen mean_net_balance = net_balance/no_firms

gen mean_vat_ratio = total_vat_ratio/no_firms
gen mean_vat_central_ratio = total_vat_central_ratio/no_firms

gen mean_vat_ratio_nonzero = total_vat_ratio/(no_firms - firms_zero_gross)
gen mean_vat_central_ratio_nonzero = total_vat_central_ratio/(no_firms - firms_zero_gross)


*Retaining only relevant columns*
keep TaxPeriod ///
no_firms firms_paid_tax firms_zero_gross firms_zero_central firms_zero_local ///
output_tax input_credit net_tax amount_deposited net_balance ///
gross_turnover central_turnover local_turnover ///
mean_output_tax mean_input_credit mean_net_tax mean_amount_deposited mean_net_balance ///
mean_vat_ratio mean_vat_central_ratio mean_vat_ratio_nonzero mean_vat_central_ratio_nonzero

save "${analysis_path}\network_bogus_summarystats.dta", replace
export excel "${analysis_path}\network_bogus_summarystats.xlsx", firstrow(variables)

*--------------------------------------------------------
** Refund Status of all the firms
*--------------------------------------------------------
** Plot a histogram of Refund Status
	/* For each quarter, plot a histogram of refund at firm level */


use "${output_path}/form16_data_consolidated.dta", clear

duplicates tag MReturn_ID, gen(repeat1)
gsort -repeat1 MReturn_ID //21 entries have same returnIds but different Mtins & Tax Period

* Retain the latest returns
gsort Mtin TaxPeriod -DateofReturnFiled
duplicates drop Mtin TaxPeriod, force

save "${output_path}/form16_latestreturns_consolidated.dta", replace

local quarter "First Quarter-2012" "Second Quarter-2012" ///
	"Third Quarter-2012" "Fourth Quarter-2012" "First Quarter-2013" ///
	"Second Quarter-2013" "Third Quarter-2013" "Fourth Quarter-2013" ///
	"First Quarter-2014" 

use "${output_path}/form16_latestreturns_consolidated.dta", clear
keep if TaxPeriod == "First Quarter-2016"
keep if RefundClaimed >20000 & RefundClaimed < 2000000
hist RefundClaimed, frequency bin(100) subtitle("First Quarter-2016")
graph export "H:\Ashwin\output\graph\graphrefund_q1_1617_histogram.pdf", replace 

use "${output_path}/form16_latestreturns_consolidated.dta", clear
keep if TaxPeriod == "Second Quarter-2016"
keep if RefundClaimed >20000 & RefundClaimed < 2000000
hist RefundClaimed, frequency bin(100) subtitle("Second Quarter-2016")
graph export "H:\Ashwin\output\graph\graphrefund_q2_1617_histogram.pdf", replace 

use "${output_path}/form16_latestreturns_consolidated.dta", clear
keep if TaxPeriod == "Third Quarter-2016"
keep if RefundClaimed >20000 & RefundClaimed < 2000000
hist RefundClaimed, frequency bin(100) subtitle("Third Quarter-2016")
graph export "H:\Ashwin\output\graph\graphrefund_q3_1617_histogram.pdf", replace 

use "${output_path}/form16_latestreturns_consolidated.dta", clear
keep if TaxPeriod == "Fourth Quarter-2016"
keep if RefundClaimed >20000 & RefundClaimed < 2000000
hist RefundClaimed, frequency bin(100) subtitle("Fourth Quarter-2016")
graph export "H:\Ashwin\output\graph\graphrefund_q4_1617_histogram.pdf", replace 

*--------------------------------------------------------
** Tax Deposited by Network Bogus Firms
*--------------------------------------------------------
** Plot a histogram of Tax deposited Status
	/* For each quarter, plot a histogram of tax deposited at firm-quater level*/


use "${output_path}/form16_latestreturns_consolidated.dta", clear
merge m:1 Mtin using "${output_path}/bogus_network_firms_local.dta"
keep if _merge == 3 
keep Mtin TaxPeriod LocalTurnover CentralTurnover GrossTurnover AmountDepositedByDealer
keep if TaxPeriod == "First Quarter-2016"
keep if GrossTurnover<= 10000000
//winsor2 AmountDepositedByDealer, cuts (10 90)
//keep if AmountDepositedByDealer>20000 & AmountDepositedByDealer<20000000
hist GrossTurnover, frequency bin(50) subtitle("First Quarter-2016")
graph export "H:\Ashwin\output\graph\nbogus_gturnover_q1_1617_histogram.pdf", replace

use "${output_path}/form16_latestreturns_consolidated.dta", clear
merge m:1 Mtin using "${output_path}/bogus_network_firms_local.dta"
keep if _merge == 3 
keep Mtin TaxPeriod LocalTurnover CentralTurnover GrossTurnover AmountDepositedByDealer
keep if TaxPeriod == "Second Quarter-2016"
keep if GrossTurnover<= 10000000
//winsor2 AmountDepositedByDealer, cuts (10 90)
//keep if AmountDepositedByDealer>20000 & AmountDepositedByDealer<20000000
hist GrossTurnover, frequency bin(50) subtitle("Second Quarter-2016")
graph export "H:\Ashwin\output\graph\nbogus_gturnover_q2_1617_histogram.pdf", replace

use "${output_path}/form16_latestreturns_consolidated.dta", clear
merge m:1 Mtin using "${output_path}/bogus_network_firms_local.dta"
keep if _merge == 3 
keep Mtin TaxPeriod LocalTurnover CentralTurnover GrossTurnover AmountDepositedByDealer
keep if TaxPeriod == "Third Quarter-2016"
keep if GrossTurnover<= 10000000
//winsor2 AmountDepositedByDealer, cuts (10 90)
//keep if AmountDepositedByDealer>20000 & AmountDepositedByDealer<20000000
hist GrossTurnover, frequency bin(50) subtitle("Third Quarter-2016")
graph export "H:\Ashwin\output\graph\nbogus_gturnover_q3_1617_histogram.pdf", replace

use "${output_path}/form16_latestreturns_consolidated.dta", clear
merge m:1 Mtin using "${output_path}/bogus_network_firms_local.dta"
keep if _merge == 3 
keep Mtin TaxPeriod LocalTurnover CentralTurnover GrossTurnover AmountDepositedByDealer
keep if TaxPeriod == "Fourth Quarter-2016"
keep if GrossTurnover<= 10000000
//winsor2 AmountDepositedByDealer, cuts (10 90)
//keep if AmountDepositedByDealer>20000 & AmountDepositedByDealer<20000000
hist GrossTurnover, frequency bin(50) subtitle("Fourth Quarter-2016")
graph export "H:\Ashwin\output\graph\nbogus_gturnover_q4_1617_histogram.pdf", replace























