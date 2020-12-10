cd "C:\Users\kras\Dropbox\SFP-v2"

use "aux_files/IBS_geobase.dta", clear

drop if mi(prov_name, island_name)
keep prov_name island_name

duplicates drop

save "aux_files/province_island.dta"

use "final_panel.dta", clear
duplicates drop

tostring label Prov, gen(Prov_str)
