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
global input_path4 "H:/Ashwin/dta"

*output files*
global output_path "H:/Ashwin/dta/final"
global analysis_path "H:/Ashwin/dta/analysis"
global qc_path "H:/Ashwin/dta/qc"
global prob_path "H:/Ashwin/dta/prob"
global features_path "H:/Ashwin/dta/bogusdealers"
global features_final "H:/Ashwin/dta/features"
global temp_path2 "Z:/features"


*--------------------------------------------------------
** Basic Numbers
*--------------------------------------------------------
use "${output_path}/bogus_consolidated.dta", clear
tab inspection_year

/*
inspection_ |
       year |      Freq.     Percent        Cum.
------------+-----------------------------------
       1213 |          1        0.02        0.02
       1314 |          3        0.05        0.06
       1415 |      1,586       25.49       25.56
       1516 |      3,667       58.95       84.50
       1617 |        964       15.50      100.00
------------+-----------------------------------
      Total |      6,221      100.00
*/

tostring Mtin, replace
merge 1:m Mtin using "${output_path}/dp_form.dta"
keep if _merge == 3 
keep Mtin Reason inspection_year RegistrationStatus CancellationDate

*--------------------------------------------------------
** Quarterly level summary stats of bogus firms
*--------------------------------------------------------

use "${output_path}/bogus_consolidated.dta", clear
tostring Mtin, replace
merge 1:m Mtin using "${output_path}/dp_form.dta"
keep if _merge == 3 
keep Mtin Reason inspection_year RegistrationDate RegistrationStatus CancellationDate
tab RegistrationStatus
/*
 Registered |
         or |
  Cancelled |      Freq.     Percent        Cum.
------------+-----------------------------------
  Cancelled |      5,701       91.64       91.64
 Registered |        520        8.36      100.00
------------+-----------------------------------
      Total |      6,221      100.00
*/

*Merge Form16 data with Bogus firms list* 
merge 1:m Mtin using "${output_path}/form16_latestreturns_consolidated.dta"

*Retain only completely merged data
keep if _merge == 3 

tab TaxPeriod

/* Number of forms filed by Firms per Quarter
    The tax period for |
 which the returns has |
            been filed |      Freq.     Percent        Cum.
-----------------------+-----------------------------------
    First Quarter-2013 |          5        0.05        0.05
    First Quarter-2014 |        185        1.69        1.73
    First Quarter-2015 |      1,444       13.16       14.89
    First Quarter-2016 |        843        7.68       22.57
   Fourth Quarter-2013 |          8        0.07       22.64
   Fourth Quarter-2014 |      1,081        9.85       32.49
   Fourth Quarter-2015 |      1,115       10.16       42.65
   Fourth Quarter-2016 |        419        3.82       46.47
   Second Quarter-2013 |          6        0.05       46.52
   Second Quarter-2014 |        626        5.70       52.22
   Second Quarter-2015 |      1,515       13.80       66.03
   Second Quarter-2016 |        704        6.41       72.44
    Third Quarter-2013 |          5        0.05       72.49
    Third Quarter-2014 |      1,099       10.01       82.50
    Third Quarter-2015 |      1,403       12.78       95.28
    Third Quarter-2016 |        518        4.72      100.00
-----------------------+-----------------------------------
                 Total |     10,976      100.00
*/

* Contains list of bogus firms that have form16 data
save "${temp_path1}/bogus_form16_merged.dta", replace 


* Distribution of firms by registrationstatus across taxquarters
use "${temp_path1}/bogus_form16_merged.dta", clear

gen TaxQuarter =0
replace TaxQuarter=13 if TaxPeriod=="First Quarter-2013"
replace TaxQuarter=14 if TaxPeriod=="Second Quarter-2013"
replace TaxQuarter=15 if TaxPeriod=="Third Quarter-2013"
replace TaxQuarter=16 if TaxPeriod=="Fourth Quarter-2013"
replace TaxQuarter=17 if TaxPeriod=="First Quarter-2014"
replace TaxQuarter=18 if TaxPeriod=="Second Quarter-2014"
replace TaxQuarter=19 if TaxPeriod=="Third Quarter-2014"
replace TaxQuarter=20 if TaxPeriod=="Fourth Quarter-2014"
replace TaxQuarter=21 if TaxPeriod=="First Quarter-2015"
replace TaxQuarter=22 if TaxPeriod=="Second Quarter-2015"
replace TaxQuarter=23 if TaxPeriod=="Third Quarter-2015"
replace TaxQuarter=24 if TaxPeriod=="Fourth Quarter-2015"
replace TaxQuarter=25 if TaxPeriod=="First Quarter-2016"
replace TaxQuarter=26 if TaxPeriod=="Second Quarter-2016"
replace TaxQuarter=27 if TaxPeriod=="Third Quarter-2016"
replace TaxQuarter=28 if TaxPeriod=="Fourth Quarter-2016"

save "${temp_path1}/bogus_form16_merged.dta", replace 

tab TaxQuarter RegistrationStatus

/*         |     Registered or
           |       Cancelled
TaxQuarter | Cancelled  Registe.. |     Total
-----------+----------------------+----------
        13 |         2          3 |         5 
        14 |         3          3 |         6 
        15 |         2          3 |         5 
        16 |         5          3 |         8 
        17 |       160         25 |       185 
        18 |       555         71 |       626 
        19 |       956        143 |     1,099 
        20 |       894        187 |     1,081 
        21 |     1,174        270 |     1,444 
        22 |     1,176        339 |     1,515 
        23 |     1,020        383 |     1,403 
        24 |       717        398 |     1,115 
        25 |       439        404 |       843 
        26 |       300        404 |       704 
        27 |       120        398 |       518 
        28 |        36        383 |       419 
-----------+----------------------+----------
     Total |     7,559      3,417 |    10,976 
*/

*Calculating average quarter life span of bogus/ bogus_registered/ bogus_cancelled
drop count_1
bys Mtin: gen count_1 = _N
duplicates drop Mtin RegistrationStatus count_1, force
gen total_count = _N
bys RegistrationStatus: gen total_count_status = _N
bys RegistrationStatus: egen total_returns = sum(count_1)
egen total_returns_1 = sum(count_1)
duplicates drop total_count total_count_status total_returns total_returns_1, force
drop Mtin TaxQuarter count_1
gen av_life_span_bogus = total_returns_1/total_count
gen av_life_span_reg = total_returns/total_count_status

/*
RegistrationStatus	av_life_span_reg 	av_life_span_bogus
Cancelled				2.336631			2.959288
Registered				7.208861			2.959288
*/

* Understanding returns filed by cancelled firms
use "${temp_path1}/bogus_form16_merged.dta", clear
gen CancellationYear = regexs(0) if (regexm(CancellationDate, "[0-9][0-9][0-9][0-9]"))
gen CancellationMonth = regexs(1) if (regexm(CancellationDate, "[-]([0-9][0-9])[-]"))
destring CancellationYear, replace
destring CancellationMonth, replace
//drop CancellationQuarter
gen CancellationQuarter = "12" if (CancellationYear == 2013 & (CancellationMonth>=1 & CancellationMonth<=3))
replace CancellationQuarter = "13" if (CancellationYear == 2013 & (CancellationMonth>=4 & CancellationMonth<=6))
replace CancellationQuarter = "14" if (CancellationYear == 2013 & (CancellationMonth>=7 & CancellationMonth<=9))
replace CancellationQuarter = "15" if (CancellationYear == 2013 & (CancellationMonth>=10 & CancellationMonth<=12))
replace CancellationQuarter = "16" if (CancellationYear == 2014 & (CancellationMonth>=1 & CancellationMonth<=3))
replace CancellationQuarter = "17" if (CancellationYear == 2014 & (CancellationMonth>=4 & CancellationMonth<=6))
replace CancellationQuarter = "18" if (CancellationYear == 2014 & (CancellationMonth>=7 & CancellationMonth<=9))
replace CancellationQuarter = "19" if (CancellationYear == 2014 & (CancellationMonth>=10 & CancellationMonth<=12))
replace CancellationQuarter = "20" if (CancellationYear == 2015 & (CancellationMonth>=1 & CancellationMonth<=3))
replace CancellationQuarter = "21" if (CancellationYear == 2015 & (CancellationMonth>=4 & CancellationMonth<=6))
replace CancellationQuarter = "22" if (CancellationYear == 2015 & (CancellationMonth>=7 & CancellationMonth<=9))
replace CancellationQuarter = "23" if (CancellationYear == 2015 & (CancellationMonth>=10 & CancellationMonth<=12))
replace CancellationQuarter = "24" if (CancellationYear == 2016 & (CancellationMonth>=1 & CancellationMonth<=3))
replace CancellationQuarter = "25" if (CancellationYear == 2016 & (CancellationMonth>=4 & CancellationMonth<=6))
replace CancellationQuarter = "26" if (CancellationYear == 2016 & (CancellationMonth>=7 & CancellationMonth<=9))
replace CancellationQuarter = "27" if (CancellationYear == 2016 & (CancellationMonth>=10 & CancellationMonth<=12))
replace CancellationQuarter = "28" if (CancellationYear == 2017 & (CancellationMonth>=1 & CancellationMonth<=3))
replace CancellationQuarter = "After 28" if (CancellationYear == 2017 & CancellationMonth> 3)

tab CancellationQuarter if TaxQuarter == 28
/* Cancellatio |
   nQuarter |      Freq.     Percent        Cum.
------------+-----------------------------------
         24 |          1        2.78        2.78
         27 |          1        2.78        5.56
         28 |         14       38.89       44.44
   After 28 |         20       55.56      100.00
------------+-----------------------------------
      Total |         36      100.00
*/

*save the file to conduct further analysis in the python
keep Mtin TaxQuarter CancellationQuarter RegistrationStatus
export delim "${features_path}/bogus_cancellationquarter.csv", replace 


* Reasons bogus firms didn't file returns before quarter<17
use "${temp_path1}/bogus_form16_merged.dta", clear
keep Mtin RegistrationStatus RegistrationDate TaxQuarter inspection_year
gen RegistrationMonth = month(RegistrationDate)
gen RegistrationYear = year(RegistrationDate)
tab RegistrationYear

/* 
Registratio |
      nYear |      Freq.     Percent        Cum.
------------+-----------------------------------
       2013 |         49        0.45        0.45
       2014 |      4,079       37.16       37.61
       2015 |      6,069       55.29       92.90
       2016 |        776        7.07       99.97
       2017 |          3        0.03      100.00
------------+-----------------------------------
      Total |     10,976      100.00
*/

* Number of the firms that have filed returns
use "${temp_path1}/bogus_form16_merged.dta", clear
 
keep Mtin RegistrationStatus CancellationDate inspection_year
duplicates drop
tab RegistrationStatus

/* Types of firms that filed returns
 Registered |
         or |
  Cancelled |      Freq.     Percent        Cum.
------------+-----------------------------------
  Cancelled |      3,235       87.22       87.22
 Registered |        474       12.78      100.00
------------+-----------------------------------
      Total |      3,709      100.00
*/

* Distribution of ward (bogus and total)
use "${features_final}/All_return_features_minus_q12.dta", clear
duplicates drop Mtin, force
tab Ward_Number
collapse (count) Mtin (sum)bogus_flag, by(Ward_Number)
rename (Mtin bogus_flag) (total_firms bogus_firms)
gen perc_bogus = bogus_firms/total_firms 
replace perc_bogus = perc_bogus * 100
export delim "H:/Ashwin/bogus_ward_distribution.csv", replace
twoway bar perc_bogus Ward_Number, barw(2)
destring  Ward_Number, replace

* Distribution of ward for OLD DATA(bogus and total)
import delim "D:/Ofir/output_data/all_returns_features_minus_q12.csv", clear case(preserve) varn(1)
save "D:/Ofir/output_data/all_returns_features_minus_q12.dta", replace

use "D:/Ofir/output_data/all_returns_features_minus_q12.dta", clear
duplicates drop DealerTIN, force
tab Ward_Number
collapse (count) DealerTIN (sum) bogus_flag, by(Ward_Number)




* Distribution of start year (bogus and total)
use "${features_final}/All_return_features_minus_q12.dta", clear
duplicates drop Mtin, force
tab StartYear
collapse (count) Mtin (sum)bogus_flag, by(StartYear)
drop if StartYear >2017 | StartYear<1900
rename (Mtin bogus_flag) (total_firms bogus_firms)
gen perc_bogus = bogus_firms/total_firms 
replace perc_bogus = perc_bogus * 100
gen StartYear_1 = "Before 2013" if StartYear <2013 // no bogus firms before 2013
replace StartYear_1 = "2013" if StartYear==2013
replace StartYear_1 = "2014" if StartYear==2014
replace StartYear_1 = "2015" if StartYear==2015
replace StartYear_1 = "2016" if StartYear==2016
replace StartYear_1 = "2017" if StartYear==2017
collapse (sum) total_firms (sum)bogus_firms, by(StartYear_1)
gen perc_bogus = bogus_firms/total_firms 
replace perc_bogus = perc_bogus * 100
export delim "H:/Ashwin/bogus_startyear_distribution.csv", replace
twoway bar perc_bogus StartYear_1, barw(2)
gen index = _n
replace index = 0 if index == 6
gsort index
graph bar perc_bogus, over(StartYear_1) blabel(bar)
destring  Ward_Number, replace




*--------------------------------------------------------
** Quarter-wise distribution of ITC/ Output Tax Liability
*--------------------------------------------------------

use "${temp_path1}/bogus_form16_merged.dta", clear
destring Mtin, replace
collapse (sum) TotalOutputTax (sum)TotalTaxCredit (count)Mtin, by(TaxQuarter)
twoway (connected TotalOutputTax TotalTaxCredit TaxQuarter, c(1) yaxis(1)) ///
	   (connected Mtin TaxQuarter, c(1) yaxis(2)), title("Bogus Firms") xscale(range(14 28))

*--------------------------------------------------------
** Distribution of ITC for top 5000 firms
*--------------------------------------------------------
import delim "H:/Ashwin/BogusFirmCatching_minus_glm/output_data/avg_predictions20190227.csv", varn(1) clear case(preserve)
tostring Mtin, replace
*Merge Form16 data with Bogus firms list* 
merge 1:m Mtin using "${output_path}/form16_latestreturns_consolidated.dta"
keep if _merge==3
bysort Mtin: egen TotalTaxCredit_1 = sum(TotalTaxCredit)
duplicates drop Mtin, force
keep Mtin bogus_flag model_score_bogus_flag TotalTaxCredit_1
gsort -model_score_bogus_flag
export delim "H:/Ashwin/avg_predictions_itc_claimed.csv", replace

*top 5000 firms (contains already identified firms)
gen index = _n
keep if index <=5000
twoway (bar TotalTaxCredit_1 index if bogus_flag == 0, mcolor (`f0') c(1) yaxis(1)) ///
	   (bar TotalTaxCredit_1 index  if bogus_flag == 1, mcolor(`f1') c(1) yaxis(1)) ///
	   (line model_score_bogus_flag index, c(1) yaxis(2))

*top 1000 firms (all non-identified firms)
keep if bogus_flag == 0 
gen index = _n
keep if index <=1000
twoway (bar  TotalTaxCredit_1 index, c(1) yaxis(1)) ///
	   (line model_score_bogus_flag index, c(1) yaxis(2))

*Log distribution of ITC - new and old firms
use "${output_path}/form16_latestreturns_consolidated.dta", clear
destring Mtin, replace
merge m:1 Mtin using "${output_path}/bogus_consolidated.dta"
drop if _merge == 2 
gen bogus_flag = 0 
replace bogus_flag = 1 if _merge == 3
//collapse (sum) TotalOutputTax (sum)TotalTaxCredit (count)Mtin, by(TaxQuarter)
collapse (sum) TotalTaxCredit (mean) bogus_flag, by(Mtin)
gen log_TotalTaxCredit = 1+ log10(TotalTaxCredit)   
twoway (hist log_TotalTaxCredit, density legend(label(1 "Total_ITC"))) /// 
	   (hist log_TotalTaxCredit if bogus_flag == 1, bcolor(red) density legend(label(2 "Total_ITC_bogus")))
*	   (hist log_TotalTaxCredit if bogus_flag == 0, bcolor(blue))
	   
import delim "H:/Ashwin/avg_predictions_itc_claimed.csv", clear varn(1) case(preserve)  
gen log_TotalTaxCredit = 1 + log10(TotalTaxCredit_1)
gsort -model_score_bogus_flag
gen index = _n
keep if index <=3000
hist log_TotalTaxCredit, subtitle("Top 3000 suspicious firms for new data")
	   
*--------------------------------------------------------
** Summary Stats of bogus firms at quarter level
*--------------------------------------------------------
use "${temp_path1}/form16_latestreturns_consolidated.dta", clear
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























