// Final LPM Regressions // 
** Load Data ** 
import excel "\Users\averyatencio\Documents\Master's Thesis\Thesis\Code and Excel\final.xlsx", sheet("Sheet 1") firstrow clear


** Generate Relevant Variables ** 
encode State, gen(state)
encode County, gen(county)
gen FORk = FOR/100000
gen popdenk = PopDen/100000
gen loginc = ln(HH_Income)
gen exposurek = exposure/100000
gen povertyk = Poverty/100000
gen TAAk = TAA/100000


* Generate percentile ranks
xtile percentile = exposure, nquantiles(4)

* Create categorical variable based on percentiles
generate exposurep = .
replace exposurep = 1 if percentile == 1
replace exposurep = 2 if percentile == 2
replace exposurep = 3 if percentile == 3
replace exposurep = 4 if percentile == 4

xtile percentile1 = exposure_est, nquantiles(4)

generate exposurep1 = .
replace exposurep1 = 1 if percentile1 == 1
replace exposurep1 = 2 if percentile1 == 2
replace exposurep1 = 3 if percentile1 == 3
replace exposurep1 = 4 if percentile1 == 4

gen exposure_med = .
replace exposure_med = 0 if percentile <= 2
replace exposure_med = 1 if percentile > 2

duplicates list Year county_fips

***************************************************************************
**************************** // Baseline Regressions // *******************
***************************************************************************

** Original LPM **
reg shoot_count exposure_est i.Year

reg shoot exposure prevshoot FORk Law_Rank popdenk if Year >= 2001, r
outreg2 using "Baseline LPM.doc", replace title("Baseline LPM") keep ( exposure prevshoot FORk Law_Rank popdenk) label addtext("Controls", "Yes", "Year FE", "No", "State FE", "No", "County FE", "No")


** Correlation **

* Poverty *
* no controls
reg Percent_Poverty exposure if Year >= 2001, r
outreg2 using "Associations.doc", replace title("Associations") label addtext("Controls", "No")

* controls
reg Percent_Poverty exposure FORk Law_Rank popdenk if Year >= 2001, t
outreg2 using "Associations.doc", append title("Associations") label addtext("Controls", "Yes")

* Inequality *
* no controls
reg gini exposure, r
outreg2 using "Associations.doc", append title("Associations") label addtext("Controls", "No")

*controls 
reg gini exposure FORk Law_Rank popdenk, r 
outreg2 using "Associations.doc", append title("Associations") label addtext("Controls", "Yes")

* Suicides *
* no controls *
reg Suicide_Est_Rate exposure if Year >= 2001, r
outreg2 using "Associations death.doc", replace title("Associations") label addtext("Controls", "No")

*controls *
reg Suicide_Est_Rate exposure FORk Law_Rank popdenk if Year >= 2001, r
outreg2 using "Associations death.doc", append title("Associations") label addtext("Controls", "Yes")

* Opioid Deaths *
* no controls
reg Deaths_Est_Rate exposure if Year >= 2001, r
outreg2 using "Associations death.doc", append title("Associations") label addtext("Controls", "No")

* controls 
reg Deaths_Est_Rate exposure FORk Law_Rank popdenk if Year >= 2001, r
outreg2 using "Associations death.doc", append title("Associations") label addtext("Controls", "Yes")


** Associations with shoot **

reg shoot Percent_Poverty prevshoot FORk Law_Rank popdenk if Year >= 2001, r
outreg2 using "Association LPM.doc", replace title("LPM with factors") label addtext("Controls", "Yes")

reg shoot gini prevshoot FORk Law_Rank popdenk if Year >= 2001, r
outreg2 using "Association LPM.doc", append title("LPM with factors") label addtext("Controls", "Yes")

reg shoot Deaths_Est_Rate prevshoot FORk Law_Rank popdenk if Year >= 2001, r
outreg2 using "Association LPM.doc", append title("LPM with factors") label addtext("Controls", "Yes")

reg shoot Suicide_Est_Rate prevshoot FORk Law_Rank popdenk if Year >= 2001, r
outreg2 using "Association LPM.doc", append title("LPM with factors") label addtext("Controls", "Yes")


****************************************************************************
*************************** // Robustness Checks // ************************
************************** // Baseline Regressions //***********************
****************************************************************************

** LPM with Year FE **
reg shoot exposure prevshoot FORk Law_Rank popdenk i.Year if Year >= 2001, r
outreg2 using "Baseline LPM.doc", append title("Baseline LPM") keep ( exposure prevshoot FORk Law_Rank popdenk) label addtext("Controls", "Yes", "Year FE", "Yes", "State FE", "No", "County FE", "No")


** LPM with State FE **
reg shoot exposure prevshoot FORk Law_Rank popdenk i.state i.Year if Year >= 2001, r
outreg2 using "Baseline LPM.doc", append title("Baseline LPM") keep ( exposure prevshoot FORk Law_Rank popdenk) label addtext("Controls", "Yes", "Year FE", "Yes", "State FE", "Yes", "County FE", "No")

** LPM with County FE **
reghdfe shoot exposure prevshoot FORk Law_Rank popdenk if Year >= 2001, absorb(county_fips Year)
outreg2 using "Baseline LPM.doc", append title("Baseline LPM") keep ( exposure prevshoot FORk Law_Rank popdenk) label addtext("Controls", "Yes", "Year FE", "Yes", "State FE", "No", "County FE", "Yes ")

****************************************************************************
*************************** // Robustness Checks // ************************
************************** // 1990-2022 Regressions //**********************
****************************************************************************

** Baseline LPM **
reg shoot exposure_est prevshoot FORk Law_Rank popdenk, r
outreg2 using "LPM.doc", replace title("1990-2022 LPM") keep ( exposure_est prevshoot FORk Law_Rank popdenk) label addtext("Controls", "Yes", "Year FE", "No", "State FE", "No", "County FE", "No")

** LPM with Year FE **
reg shoot exposure_est prevshoot FORk Law_Rank popdenk i.Year, r
outreg2 using "LPM.doc", append title("1990-2022 LPM") keep ( exposure_est prevshoot FORk Law_Rank popdenk) label addtext("Controls", "Yes", "Year FE", "Yes", "State FE", "No", "County FE", "No")

** LPM with State FE **
reg shoot exposure_est prevshoot FORk Law_Rank popdenk i.state i.Year, r
outreg2 using "LPM.doc", append title("1990-2022 LPM") keep ( exposure_est prevshoot FORk Law_Rank popdenk) label addtext("Controls", "Yes", "Year FE", "Yes", "State FE", "Yes", "County FE", "No")

** LPM with County FE **
reghdfe shoot exposure_est prevshoot FORk Law_Rank popdenk, absorb(county_fips Year)
outreg2 using "LPM.doc", append title("1990-2022 LPM") keep ( exposure_est prevshoot FORk Law_Rank popdenk) label addtext("Controls", "Yes", "Year FE", "Yes", "State FE", "No", "County FE", "Yes ")

****************************************************************************
*************************** // Robustness Checks // ************************
****************************** // Further RC //*****************************
****************************************************************************

** Original LPM with percentiles **
reg shoot i.exposurep1 prevshoot FORk Law_Rank popdenk if Year >= 2001, r
outreg2 using "RC.doc", replace title("RC LPM") keep (i.exposurep1 prevshoot FORk Law_Rank popdenk) label addtext("Controls", "Yes", "Year FE", "No")

reg shoot i.exposurep1 prevshoot FORk Law_Rank popdenk i.Year if Year >= 2001, r
outreg2 using "RC.doc", append title("RC LPM") keep (i.exposurep1 prevshoot FORk Law_Rank popdenk) label addtext("Controls", "Yes", "Year FE", "Yes")

** Original LPM with median **
reg shoot exposure_med prevshoot FORk Law_Rank popdenk if Year >= 2001, r
outreg2 using "RC.doc", append title("RC LPM") keep (exposure_med prevshoot FORk Law_Rank popdenk) label addtext("Controls", "Yes", "Year FE", "No")

reg shoot exposure_med prevshoot FORk Law_Rank popdenk i.Year if Year >= 2001, r
outreg2 using "RC.doc", append title("RC LPM") keep (exposure_med prevshoot FORk Law_Rank popdenk) label addtext("Controls", "Yes", "Year FE", "Yes")

** LPM with anyshoot == 1 **
reg shoot exposure prevshoot FORk Law_Rank popdenk if Year >= 2001 & anyshoot == 1
outreg2 using "RC.doc", append title("RC LPM") keep (exposure prevshoot FORk Law_Rank popdenk) label addtext("Controls", "Yes")

********************************************************************************
******************************* Further Analysis *******************************
********************************************************************************

* no controls *
reg shoot exposure TAA_total if Year >= 2009, r
outreg2 using "TAA.doc", replace title("TAA LPM") keep (exposure TAAk) label addtext("Controls", "No")

* controls *
reg shoot exposure TAAk prevshoot FORk Law_Rank popdenk if Year >= 2009, r
outreg2 using "TAA.doc", append title("TAA LPM") keep (exposure TAAk prevshoot FORk Law_Rank popdenk) label addtext("Controls", "Yes")

* associations
reg Percent_Poverty TAAk if Year >= 2009, r
outreg2 using "TAA1.doc", replace title("TAA LPM") label addtext("Controls", "No")

reg gini TAAk i.Year if Year >= 2009, r
outreg2 using "TAA1.doc", append title("TAA LPM") label addtext("Controls", "No")

reg Deaths_Est_Rate TAAk if Year >= 2009, r
outreg2 using "TAA1.doc", append title("TAA LPM") label addtext("Controls", "No")

reg Suicide_Est_Rate TAAk if Year >= 2009, r
outreg2 using "TAA1.doc", append title("TAA LPM") label addtext("Controls", "No")


*Voting*
*no controls
reg class exposure, r
outreg2 using "voting.doc", replace title("voting") label addtext("Controls", "No")

reg class exposure FORk Law_Rank popdenk, r
outreg2 using "voting.doc", append title("voting") label addtext("Controls", "Yes")

* TAA assocations *
reg class TAAk if Year >= 2009, r
outreg2 using "voting TAA.doc", replace title("voting") label addtext("Controls", "No")

reg class TAAk FORk Law_Rank popdenk if Year >= 2009, r
outreg2 using "voting TAA.doc", append title("voting") label addtext("Controls", "Yes")

*******************************************************************************
******************************** Deaths RC Baseline ****************************
*******************************************************************************

** Opioid Deaths **
** Max Estimate **
reg Death_Max_Rate exposure if Year >= 2001, r
outreg2 using "opioid RC.doc", replace title("Opioid RC") label addtext("Controls Check", "No")

** Max Estimate with controls **
reg Death_Max_Rate exposure FORk Law_Rank popdenk if Year >= 2001, r
outreg2 using "opioid RC.doc", append title("Opioid RC") label addtext("Controls Check", "Yes")

** Min Estimate **
reg Death_Min_Rate exposure if Year >= 2001, r
outreg2 using "opioid RC.doc", append title("Opioid RC") label addtext("Controls Check", "No")

** Min Estimate with controls **
reg Death_Min_Rate exposure FORk Law_Rank popdenk if Year >= 2001, r
outreg2 using "opioid RC.doc", append title("Opioid RC") label addtext("Controls Check", "Yes")

** Suicides **
* Max Estimate *
reg Suicide_Max_Rate exposure  if Year >= 2001, r
outreg2 using "suicide RC.doc", replace title("Opioid RC") label addtext("Controls Check", "No")

** Max Estimate with controls **
reg Suicide_Max_Rate exposure FORk Law_Rank popdenk if Year >= 2001, r
outreg2 using "suicide RC.doc", append title("Opioid RC") label addtext("Controls Check", "Yes")

* Min Estimate *
reg Suicide_Min_Rate exposure if Year >= 2001. r
outreg2 using "suicide RC.doc", append title("Opioid RC") label addtext("Controls Check", "No")

** Min Estimate with controls **
reg Suicide_Min_Rate exposure FORk Law_Rank popdenk if Year >= 2001, r
outreg2 using "suicide RC.doc", append title("Opioid RC") label addtext("Controls Check", "Yes")

********************************************************************************
****************************** Casualties **************************************
********************************************************************************

* Causualties * 
reg casualties exposure if Year >= 2001, r
outreg2 using "causaulties.doc", replace title("table 7") label addtext("Controls", "No")

reg casualties exposure prevshoot FORk Law_Rank popdenk if Year >= 2001, r
outreg2 using "causualties.doc", append title("table 7") label addtext("Controls", "Yes")

poisson casualties exposure if Year >= 2001, r
outreg2 using "causualties.doc", append title("table 7") label addtext("Controls", "No")

poisson casualties exposure prevshoot FORk Law_Rank popdenk if Year >= 2001, r
outreg2 using "causualties.doc", append title("table 7") label addtext("Controls", "Yes")



