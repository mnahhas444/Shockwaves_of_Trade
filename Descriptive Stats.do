*******************************************************************************
*************************** // Descriptive Statistics // **********************
*******************************************************************************

** Load Data ** 
import excel "\Users\averyatencio\Documents\Master's Thesis\Thesis\Code and Excel\final.xlsx", sheet("Sheet 1") firstrow clear

** All variables **
summarize, detail

summarize shoot exposure_est Deaths_Est_Rate Suicide_Est_Rate PopDen Law_Rank FOR Percent_Poverty gini, detail

asdoc summarize shoot exposure_est Deaths_Est_Rate Suicide_Est_Rate Percent_Poverty gini PopDen Law_Rank FOR, detail save(descriptive_stats.doc), replace


** Exposure **
summarize exposure_est pempest, detail

asdoc summarize exposure_est pempest, detail save(exposure_est.doc) replace


** Death Rates **
summarize Deaths_Est_Rate Death_Min_Rate Death_Max_Rate Suicide_Est_Rate Suicide_Max_Rate Suicide_Min_Rate, detail

asdoc summarize Deaths_Est_Rate Death_Min_Rate Death_Max_Rate, detail save(deaths_percentiles.doc) replace

asdoc summarize Suicide_Est_Rate Suicide_Max_Rate Suicide_Min_Rate, detail save(suicide_percentiles.doc) replace

** Ineqaulity **
summarize gini Percent_Poverty, detail

bysort Year: summarize gini, detail

asdoc summarize gini, detial save(gini.doc), replace

asdoc summarize Percent_Poverty, detail save(poverty.doc), replace


** TAA **

summarize TAA_total, detail

asdoc summarize TAA_total, detail save(TAA.doc), replace

** Voting **
summarize class, detail

histogram class

********************************** Graphing ***********************************

** Share **

summarize exposure_est

gen pempestk = pempest/10
gen pempestk1 = pempest/100
summarize pempestk 

collapse (mean) exposure_est pempest pempestk pempestk1, by(Year)


twoway (line exposure_est Year, lcolor()) ///
       (line pempestk Year, lcolor(red)), ///
       xtitle(Year) ytitle(Values) ///
       legend(label(1 "Exposure") label(2 "Share of Manufacturing Emp")) ///
	   title("Exposure v Share of Manufacturing Employment U.S.")
	   
	   
** Death Rates **

summarize Deaths_Est_Rate

collapse (mean) Deaths_Est_Rate Death_Min_Rate Death_Max_Rate Suicide_Est_Rate Suicide_Min_Rate Suicide_Max_Rate exposure_est, by(Year)

keep if Year <= 2021

gen exposure_est1 = exposure_est *10
gen exposure_est2 = exposure_est *100

twoway (line Deaths_Est_Rate Year, lcolor(blue)) ///
       (line Death_Min_Rate Year, lcolor(ltblue)) ///
       (line Death_Max_Rate Year, lcolor(black)) ///
       (line exposure_est1 Year, lcolor(red)), ///
       xtitle("Year") ytitle("Crude Rate") ///
       legend(order(1 "Estimated Death Rate" ///
                    2 "Minimum Death Rate" ///
                    3 "Maximum Death Rate" ///
                    4 "Exposure"))
					
twoway (line Suicide_Est_Rate Year, lcolor(blue)) ///
       (line Suicide_Min_Rate Year, lcolor(ltblue)) ///
       (line Suicide_Max_Rate Year, lcolor(black)) ///
       (line exposure_est2 Year, lcolor(red)), ///
       xtitle("Year") ytitle("Crude Rate") ///
       legend(order(1 "Estimated Suicide Rate" ///
                    2 "Minimum Suicide Rate" ///
                    3 "Maximum Suicide Rate" ///
                    4 "Exposure"))

	   
** Inequality **

collapse (mean) gini Percent_Poverty exposure_est, by(Year)

twoway (line Percent_Poverty Year, lcolor(blue)) ///
       (line exposure_est1 Year, lcolor(red)), ///
       xtitle("Year") ytitle("Value") ///
       legend(order(1 "Percent Poverty" ///
                    2 "Exposure"))
					
keep if inlist(Year, 1990, 2000, 2010)

twoway (line gini Year, lcolor(blue)), ///
       xtitle("Year") ytitle("Gini Coefficient")

** Shoot **
collapse (sum) shoot shoot_count exposure_est, by(Year)


twoway (bar shoot Year, barwidth(0.5)) ///
    (scatter shoot Year, msymbol(none) mlabel(shoot) mlabposition(12) mlabcolor(black)), ///
    ytitle("Number of Shootings") ///
    title("Number of Counties that Experienced a Mass Shooting by Year") ///
    legend(off)

gen exposure_est0 = exposure_est/10

twoway (line shoot Year, lcolor(blue)), ///
       xtitle("Year") ytitle("Number of Shootings")
	   
twoway (bar shoot_count Year, barwidth(0.5)) ///
    (scatter shoot_count Year, msymbol(none) mlabel(shoot_count) mlabposition(12) mlabcolor(black)), ///
    ytitle("Number of Shootings") ///
    legend(off)

				
** TAA **
 
collapse (mean) TAA exposure, by(Year) 

keep if Year >= 2009

gen TAAkk1 = TAA/10000

gen exposure0 = exposure * 100000

twoway (line TAA_total Year, lcolor(blue)), ///
       xtitle("Year") ytitle("TAA ($)")
   
twoway (line TAA_total Year, lcolor()), ///
       xtitle(Year) ytitle("TAA ($)") ///
	   title("Average TAA funding Allocated to States")
	   
** Voting **

* change_rep is if a county changed from voting republican to democrat *

collapse (sum) class change_dem change_rep class_change, by(Year)

keep if inlist(Year, 2000, 2004, 2008, 2012, 2016, 2020)

twoway scatter class Year

twoway (line class Year, lcolor(blue)), ///
       xtitle("Year") ytitle("Number of Counties that Voted Right-Wing")
	   
twoway (line change_dem Year, lcolor(blue)), ///
       xtitle("Year") ytitle("Number of Counties that changed from LW to RW")
	   
twoway (line change_rep Year, lcolor(blue)), ///
       xtitle("Year") ytitle("Number of Counties that changed from RW to LW")

twoway (line class Year, lcolor(blue)) ///
       (line change_dem Year, lcolor(red)) ///
       (line change_rep Year, lcolor(green)), ///
       xtitle("Year") ytitle("Number of Counties") ///
       legend(order(1 "Counties Voted Right-Wing" 2 "Change from LW to RW" 3 "Change from RW to LW"))

* Generate frequency counts for each year and class
collapse (count) count=county_fips, by(Year class)

* Separate the counts into Democrat and Republican
gen dem_count = count if class == 0
gen rep_count = count if class == 1

* Replace missing values with 0
replace dem_count = 0 if dem_count == .
replace rep_count = 0 if rep_count == .

* Drop the original count variable and class
drop count class

* Reshape the data to wide format for easy plotting
reshape wide dem_count rep_count, i(Year)

collapse (sum) dem_count rep_count, by(Year)

* Plot the data using graph bar
graph bar (asis) dem_count rep_count, ///
    over(Year) ///
    blabel(bar) ///
    legend(label(1 "Democrat") label(2 "Republican")) ///
    ytitle("Number of Counties") ///
    title("Number of Counties Voting Democrat and Republican by Year")
	

** testing which counties have the highest exposure **
* Calculate the 90th percentile of the variable 'exposure'
summarize exposure_est, detail

* The 90th percentile will be displayed in the output under 'Percentiles'
* Extract the 90th percentile value
scalar p99 = r(p99)

* List the counties with exposure values greater than the 90th percentile

list County exposure_est gini if exposure_est > p99

export excel County exposure_est gini if exposure_est > p99 using "high_exposure_counties.xlsx", firstrow(variables) replace

histogram gini if Year == 2010

	   
import excel "\Users\averyatencio\Documents\Master's Thesis\Thesis\final1.xlsx", sheet("Sheet 1") firstrow clear

sort county_fips Year

* Drop duplicates based on the combination of county_fips and Year
duplicates drop county_fips Year, force



