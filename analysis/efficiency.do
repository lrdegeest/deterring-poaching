* ===========================
*	3. Efficiency
* ===========================

use eff.group_means.dta, clear

* table
preserve
collapse (mean) mef_2 = mef, by(treatment type)
restore

* NONPARAMETRICS
* overall final efficiency
* INSIDERS AND OUTSIDERS
forvalues i = 1/2 {
	forvalues j = 1/3 {
		forvalues k = 1/3 {
			if `j' != `k' & `j' < `k' {
				display "Nonparametrics for type `i' "
				display "rank sum test for treatments `j' and `k' " 
				qui ranksum mef if type== `i'  & (treatment == `j' | treatment == `k'), by(treatment)
				display "z-value = " r(z)
				display "p-value = " 2 * normprob(-abs(r(z)))
				display " "
			}
		}
	}
}



* Insider final efficiency over time, across treatments
forvalues i = 1/3 {	
	forvalues j = 1/3 {
		forvalues k = 1/2 {
			if `i' != `j' & `i' < `j' {	
				display "Nonparametrics for type 1"
				display "rank sum test for treatments `i' and `j' in time `k' " 
				qui ranksum mef if type==1 & first == `k'  & (treatment == `i' | treatment == `j'), by(treatment) 
				display "z-value = " r(z)
				display "p-value = " 2 * normprob(-abs(r(z)))
				display " "
			}
		}
	}
}

* estimation
forvalues i=1/2 {
	display "Regression results for type `i' "
	reg mef i.treatment if type == `i', robust
	display "test // chi_sq, p-val "
	test 2.treatment 
	test 3.treatment 
	test 2.treatment = 3.treatment 
}



* count instances of low payoffs outsiders
use dp_data, clear
bysort treatment: count if ip<=138.9| fp<=138.9 & type == 2
bysort treatment: count if ip<=112.8 | fp<=112.8 & type == 2
