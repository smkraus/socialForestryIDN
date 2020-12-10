cd "C:\Users\kras\Dropbox\SFP-v2"

// Never treated only control group
local controlTypes treatedNT

foreach var in `controlTypes' {	
	local cT_list
	forvalues i = 2009/2019 {
		use "Panels/sfpAll_deforestation_allTypes.dta", clear
		g `var' = 1 if treatment_year == `i'		
		replace `var' = 0 if mi(treatment_year)

		g post = 1 if year >= `i' & !mi(year)
		replace post = 0 if year < `i'
		g event_t = year - `i'
		g cohort = `i'
	 		
		tempfile cT_`var'`i'
		save `cT_`var'`i''
		local cT_list `cT_list' `cT_`var'`i''
	}
	clear
	foreach cT of local cT_list {
		append using `cT'
	}
	drop if mi(id)
	save "Panels/stacked/cT_`var'.dta", replace
}
