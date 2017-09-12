* ==========================================================
* DATA
* ==========================================================

use dp_data, clear

* =========================
* Harvest
* =========================
foreach i in 1 2 {
	display "Results for type == " `i'
	
	** aggregate 
	qui xtreg h i.treatment if type == `i', re cluster(group)
	eststo m1_`i'
	display "test aggregate coefficients: chi_sq, p-val"
	test 2.treatment 
	test 3.treatment 
	test 2.treatment = 3.treatment 
	
	** first/second
	qui xtreg h i.treatment i.first i.treatment#i.first if type == `i', re cluster(group)
	eststo m2_`i'
	display "test first/second coefficients: chi_sq, p-val"
	test 2.first 
	test 2.first + 2.treatment#2.first = 0 
	test 2.first + 3.treatment#2.first = 0 
	
	**compare partial second to zero and full second for outsiders 
	if `i' == 2 {
		display "compare partial second to zero and full second for outsiders"
		test -2.treatment - 2.treatment#2.first = 0 
		test 3.treatment + 3.treatment#2.first - 2.first - 2.treatment#2.first = 0 
	}
	
}

** export latex table
esttab m1_1 m2_1 m1_2  m2_2 using appendix1_table.tex, replace ///
	cells(b(star fmt(3)) se(par fmt(2))) ///
	stats(r2_o N) ///
	mgroups("Insiders" "Outsiders", pattern(1 0 1 0) prefix(\multicolumn{@span}{c}{) suffix(}) span erepeat(\cmidrule(lr){@span})) ///	
	numbers mlabels("Aggregate" "First/Second" "Aggregate" "First/Second") ///
	drop(1.treatment 1.first 1.treatment#2.first *.treatment#1.first) ///
	label legend  ///
	collabels(none) ///
	varlabels(_cons Constant PARTIAL Partial)
