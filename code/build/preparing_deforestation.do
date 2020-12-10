cd "C:\Users\kras\Dropbox\SFP-v2"

global deforestation_types "all margono primary degraded"
foreach dType in $deforestation_types {  
	import delimited "C:\Users\kras\Downloads\annual_deforestation_sfpAll_`dType'.csv", clear
	keep id lossyear

	merge 1:1 id using "Shapefiles/sfpArea.dta"

	split lossyear, gen(year) parse(",")

	replace year1 = subinstr(year1,"{2001=","",.)

	forvalues i = 2/9 {
		local n "`i'"
		replace year`n' = subinstr(year`n',"200`n'=","",.)
	}

	forvalues i = 10/17 {
		local n "`i'"
		replace year`n' = subinstr(year`n',"20`n'=","",.)
	}

	replace year18 = subinstr(year18,"2018=","",.)
	replace year18 = subinstr(year18,"}","",.)

	replace year19 = subinstr(year19,"2019=","",.)
	replace year19 = subinstr(year19,"}","",.)

	drop lossyear

	foreach var of varlist _all {
		if strpos("`var'","year"){
			destring `var', replace
		}
	}

	duplicates drop

	reshape long year, i(id) j(obs_year)
	replace obs_year = obs_year + 2000

	rename year loss_area_sqm
	rename obs_year year

	g loss_area_ha = loss_area_sqm/10000
	g loss_rate = loss_area_ha/areaSize

	drop loss_area_sqm

	drop if loss_rate > 1 & !mi(loss_rate)

	rename loss_rate loss_rate_`dType'
	rename loss_area_ha loss_area_ha_`dType'

	keep id year loss_rate_`dType' loss_area_ha_`dType'
	save "Panels/annual_deforestation_sfpAll_`dType'.dta", replace
}

// Merging all deforestation types
clear
use "Panels/annual_deforestation_sfpAll_all.dta"
global deforestation_types "margono primary degraded"
foreach dType in $deforestation_types { 
	merge 1:m id year using "Panels/annual_deforestation_sfpAll_`dType'.dta"
	drop _merge
}

merge m:1 id using "Shapefiles/sfpAllGeo.dta"
drop _merge

/* merge m:1 id using "Shapefiles/KLHK_shapes/raw/Hutan_Desa_new_Luas_ID.dta"
drop _merge

g HDprotectionShare = (LUAS_HL + LUAS_HPT)/LUAS_HPHD */

g treatment_year = landTitle if landTitle != "Proses"
replace treatment_year = substr(treatment_year,-4,4)

gen byte notnumeric = real(treatment_year)==.
replace treatment_year = "" if notnumeric == 1 & !mi(treatment_year)
drop notnumeric

destring treatment_year, replace
drop if treatment_year == 2107

replace treatment_year = 2019 if treatment_year == 19

g treated = 1 if treatment_year == year

bys A2CODE year: egen treatedD = max(treated)
drop treated

merge 1:1 id year using "Panels/Controls/precipitationNew.dta"
drop if _merge == 2
drop _merge

// Drop small stripe of land with higher deforestation rate than area
drop if id == "PIAPS315974All"

global deforestation_types "all margono primary degraded"
foreach dType in $deforestation_types { 
	bys id: egen loss_rate_`dType'_total = total(loss_rate_`dType')
	drop if loss_rate_`dType'_total > 1 & !mi(loss_rate_`dType'_total)
}

encode id, gen(id_factor)

replace forestFunction = "HL" if forestFunction == "1001"
replace forestFunction = "HP" if forestFunction == "1003"
replace forestFunction = "HPT" if forestFunction == "1004"
replace forestFunction = "HPK" if forestFunction == "1005"

save "Panels/sfpAll_deforestation_allTypes.dta", replace



/* // For R 
use "Panels/sfpAll_deforestation_allTypes.dta", clear

* keep if dataset == "sfpNew" & !mi(treatment_year)

keep if dataset == "PIAPS" & recentlyTitled != 0

g treated = 1 if inrange(year,treatment_year,.)
replace treated = 0 if year < treatment_year

g event_t = year - treatment_year

bys event_t: su loss_rate_primary if inrange(event_t,-5,5), detail

gcollapse loss_rate_margono,by(year)
line loss_rate_margono year

save "Panels/sfpAll_deforestation_allTypes_R.dta", replace
 */
