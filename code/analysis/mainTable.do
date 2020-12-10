cd "C:\Users\kras\Dropbox\SFP-v2"

eststo clear

// SFP Types
global stackedInd "stacked"
global cTlist "NT"
global fixedEffects "fe"
global dsType "PIAPS"
global tOG ""
global sfpTypeList "HD HKm HTR"
global estimatorList "ppmlhdfe"
global forestFunctions "all"

foreach fF in $forestFunctions {
	global fFG `fF'
	foreach estT in $estimatorList {
		global estTG `estT'
		foreach sfpT in $sfpTypeList {
			global sfpTG `sfpT'
			foreach cT in $cTlist {
				foreach dsT in $dsType {
					global dsTG `dsT'
					foreach feI in $fixedEffects { 
						global feIG `feI'
						
						if "`sfpT'" != "HTR" {
							global deforestation_types "all degraded primary"
						}
						if "`sfpT'" == "HTR" {
							global deforestation_types "all degraded"
						}

						foreach dType in $deforestation_types { 
								global cTG `cT' 
								use "Panels/stacked/cT_treated`cT'.dta", clear


					/* 			fasterxtile loss_rate_xtile_`dType' = loss_rate_`dType',nq(1000)
								drop if loss_rate_xtile_`dType' == 1000
								drop loss_rate_xtile_`dType'
					 */	

								if "`fF'" == "all" {
									di "`sfpT'"
									replace treated`cT' = . if treated`cT' == 1 & (dataset != "sfpNew" | Proposed == 1 | sfpType != "`sfpT'" | forestFunction != "all")
									if "`dsT'" == "PIAPS" {
										replace treated`cT' = . if treated`cT' == 0 & (dataset != "PIAPS" | recentlyTitled != 0)
									}
									if "`dsT'" == "Usulan" {
										replace treated`cT' = . if treated`cT' == 0 & (dataset != "Usulan" | recentlyTitled != 0 | forestFunction != "all")
									}
								}

							if "`feI'" == "fe" {
								eststo: `estT' loss_rate_`dType' treated`cT'##post precMeanAnnual if inrange(cohort,2009,2019), absorb(id year) vce(cl id)
							}
							if "`feI'" == "fep" {
								eststo: `estT' loss_rate_`dType' treated`cT'##post precMeanAnnual if inrange(cohort,2009,2019), absorb(id A1CODE#year) vce(cl id)
							}
							if "`feI'" == "" {
								eststo: `estT' loss_rate_`dType' treated`cT'##post precMeanAnnual if inrange(cohort,2009,2019), noabsorb vce(cl id)
							}
								global cTG
							}
						}
						global feIG
					}
					global dsTG
			}
			global sfpTG
		}
		global estTG
	}
	global fFG
}
global stackedInd
global tOG


esttab est* using "_outputs/mainTable.tex", replace ///
		keep(1.treatedNT#1.post) ///	
		varl(1.treatedNT#1.post "Land title") ///
		se ///
		nonotes ///
		booktabs compress gaps ///
		mgroups( ///
			"HD" "HKM" "HTR", ///
			pattern(1 0 0 1 0 0 1 0 ) ///
			prefix(\multicolumn{@span}{c}{) suffix(})   ///
			span erepeat(\cmidrule(lr){@span})) ///
		mtitles( ///
			"\shortstack{All forest}" ///
			"\shortstack{Degraded}" ///
			"\shortstack{Primary}" ///
			"\shortstack{All}" ///
			"\shortstack{Degraded}" ///
			"\shortstack{Primary}" ///
			"\shortstack{All}" ///
			"\shortstack{Degraded}" ///
			) ///
		b(3) se(3) ///
		stats(N_clust N,label("Clusters" "N") layout("\multicolumn{1}{c}{@}" "\multicolumn{1}{c}{@}") fmt(%5.0f)) ///
		star(* 0.10 ** 0.05 *** 0.01)
