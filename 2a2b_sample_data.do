foreach var in "2013" "2014" "2015"  {
use "H:\Ashwin\dta_files\2a2b_1q_`var'.dta", clear
gsort MTIn
gen number= _n
keep if number <= 20000
drop number

export delimited "H:\Ashwin\sample_dta\sample_2a2b_1q_`var'.csv", replace
}

foreach var in "2013" "2014" "2015"  {
use "H:\Ashwin\dta_files\2a2b_2q_`var'.dta", clear
gsort MTIn
gen number= _n
keep if number <= 20000
drop number

export delimited "H:\Ashwin\sample_dta\sample_2a2b_2q_`var'.csv", replace
}

foreach var in "2013" "2014" "2015"  {
use "H:\Ashwin\dta_files\2a2b_3q_`var'.dta", clear
gsort MTIn
gen number= _n
keep if number <= 20000
drop number

export delimited "H:\Ashwin\sample_dta\sample_2a2b_3q_`var'.csv", replace
}

foreach var in "2013" "2014" "2015"  {
use "H:\Ashwin\dta_files\2a2b_4q_`var'.dta", clear
gsort MTIn
gen number= _n
keep if number <= 20000
drop number

export delimited "H:\Ashwin\sample_dta\sample_2a2b_4q_`var'.csv", replace
}
