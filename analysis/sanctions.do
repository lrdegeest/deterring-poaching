* =========================
*	Sanctions
* =========================
use dp_data, clear

* table of averages and standard deviations
preserve
collapse (mean) sv_mean = s_v (sd) s_v if mon==1, by(treatment type first)
restore

* INSIDERS AND OUTSIDERS SEPERATE
forvalues i = 1/2 {
	display "Results for type `i' "
	if `i' == 2 {
		drop if treatment == 1 & type == 2
	}
	** aggregate 
	qui xtreg s_v i.treatment if type == `i' & mon == 1, re cluster(group)
	display "Aggregate tests, type `i' "
	*** test // chi_sq, p-val
	if `i' == 1 {
		test 2.treatment
		test 2.treatment = 3.treatment 
	}
	test 3.treatment 
	
	
	** first/second
	qui xtreg s_v i.treatment i.first i.treatment#i.first if type == `i' & mon == 1, re cluster(group)
	display "First/Second within treatment tests, type `i' "
	*** test // chi_sq, p-val
	test 2.first 
	if `i' == 1 {
		test 2.first + 2.treatment#2.first = 0 
	}
	test 2.first + 3.treatment#2.first = 0 
	
	** compare partial second to zero and full second
	*** test // chi_sq, p-val
	display "First/Second across treatment tests, type `i' "
	if `i' == 1 {
		test -2.treatment - 2.treatment#2.first = 0 
		test 3.treatment + 3.treatment#2.first - 2.first - 2.treatment#2.first = 0
	}
	else if `i' == 2 {
		test -3.treatment - 3.treatment#2.first = 0 
	}
}



* INSIDERS AND OUTSIDERS TOGETHER
** aggregate 
xtreg s_v i.treatment i.type i.treatment#i.type if mon == 1, re cluster(group)
*** test // chi_sq, p-val
test 2.type // 6.60, 0.0102
test 2.type + 3.treatment#2.type = 0 //  3.80, 0.0511

** aggregate 
xtreg s_v i.treatment i.type i.first i.treatment#i.type i.treatment#i.type#i.first if mon == 1, re cluster(group)


* FIGURE
* plot percent deterrence 
gen fp_h = fp - pp - transfer
gen deter_hp = ((hp - fp_h)/hp) * 100 if h > 0
collapse (mean) deter_hp = deter_hp if mon==1 & type == 2, by(treatment h)
set scheme lean1
tw (connected deter_hp h), ///
	xlab(0(2)12) ylab(0(20)100,nogrid) yline(100, lpattern(dash) lcolor(red)) /// 
	ytitle("Average deterrence (percent)") xtitle("Poaching") ///
	text(95 3 "{it:Theoretical deterrence}", color(red)) ///
	by(treatment, note(" ")) 

	

