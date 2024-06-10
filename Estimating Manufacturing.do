// Estimating Manufacturing prior to 2001 //

import excel "\Users\averyatencio\Documents\Master's Thesis\Thesis\Beginning Sets/manufacturing_est1.xlsx", firstrow clear

encode State, gen(state)
encode County, gen(county)

** generating one **
sort State Year
gen stmf = state_manufacturing

** generating two **
sort State Year
gen stemp = state_emp

** generating three **
sort county_fips Year
gen cemp = county_emp


** generating four **
sort county_fips Year

preserve
keep if Year == 2001
keep county_fips county_manufacturing
rename county_manufacturing county_manufacturing_2001

tempfile temp2001
save `temp2001'

restore

merge m:1 county_fips using `temp2001'

assert _merge == 3
drop _merge

rename county_manufacturing_2001 cmf_2001

** generating one_2001 **
sort State Year

preserve
keep if Year == 2001
keep State state_manufacturing county_fips
rename state_manufacturing state_manufacturing_2001

tempfile temp20012
save `temp20012'

restore

merge m:1 county_fips using `temp20012'

assert _merge == 3
drop _merge

rename state_manufacturing_2001 stmf_2001

** calculating the variables **

bysort Year State: gen b1 = (stmf/stemp)*cemp

bysort Year State: gen b2 = (cmf_2001/stmf_2001)*stmf

bysort county_fips: gen b3 = cemp / stemp


gen ln_b1 = log(b1)
gen ln_b2 = log(b2)
gen ln_b3 = log(b3)
gen log_countymf = log(county_manufacturing)

summarize log_countymf ln_b1 ln_b2 ln_b3


* predicting with no county FE *

reghdfe log_countymf ln_b1 ln_b2 ln_b3

outreg2 using "Estimated Maunufacturing.doc", replace title("Estimating Manufacturing prior to 2001")

predict double log_countymf_pred, xb
gen countymf_pred = exp(log_countymf_pred)


twoway (scatter countymf_pred Year, mcolor(red)) ///
       (scatter county_manufacturing Year, mcolor(blue)), ///
       xtitle(Year) ///
       ytitle("County Manufacturing") ///
       legend(order(1 "Predicted" 2 "Actual")) ///
       title("Predicted vs Real County Manufacturing")


** collapsing **
  

 collapse (sum) countymf_pred  county_manufacturing, by(Year)
 
 
twoway (line countymf_pred Year, lcolor(red)) ///
       (line county_manufacturing Year, lcolor(blue)), ///
       xtitle(Year) ///
       ytitle("County Manufacturing") ///
       legend(order(1 "Predicted" 2 "Actual")) ///
       title("Predicted vs Real US Manufacturing")
	   
** combined trend **

import excel "\Users\averyatencio\Documents\Master's Thesis\Thesis\mfest.xlsx", firstrow clear

twoway scatter mfest Year, title("Combined Trend")

 collapse (sum) mfest, by(Year)
 
 twoway line mfest Year, title("Combined Trend")

