*===============================================================================
* SET UP
*===============================================================================

program setup

	cd "/Users/LawrenceDeGeest/Documents/DE_analysis_15/Data"
	
	set scheme lean1
	graph set window fontface Times 
	graph set eps fontface Times

	use dp_data, clear
	xtset subject period
	replace mon = 1 if treatment == 3
	keep if mon == 1 // drop non-monitored outsiders in partial monitoring	
	drop if treatment == 1 & type == 2 // drop zero monitoring outsiders
	// drop outliers
	drop if s == 149 & treatment == 2 // drop outlier insider

	// labels
	label define treatment 1 "zero" 2 "partial" 3 "full"
	label values treatment treatment
	label define type 1 "insider" 2 "outsider"
	label values type type

	// dummies make it easier to 	 the code
	gen byte zero = cond(treatment == 1, 1, 0)
	gen byte partial = cond(treatment == 2, 1, 0)
	gen byte full = cond(treatment == 3, 1, 0)
	gen byte insider = cond(type == 1, 1, 0)
	gen byte outsider = cond(type == 2, 1, 0)


	// eyeball guess puts the knot at 5
	// x?_11 is zero, insider 
	* zero
	mkspline x1_11 5 x2_11 = h, marginal
	*partial
	mkspline x1_21 5 x2_21 = h, marginal
	mkspline x1_22 5 x2_22 = h, marginal
	*full
	mkspline x1_31 5 x2_31 = h, marginal
	mkspline x1_32 5 x2_32 = h, marginal


	// interact with dummies
	* zero
	replace x1_11 = x1_11 * zero * insider
	replace x2_11 = x2_11 * zero * insider
	* partial
	replace x1_21 = x1_21 * partial * insider
	replace x2_21 = x2_21 * partial * insider
	replace x1_22 = x1_22 * partial * outsider
	replace x2_22 = x2_22 * partial * outsider
	* full
	replace x1_31 = x1_31 * full * insider
	replace x2_31 = x2_31 * full * insider
	replace x1_32 = x1_32 * full * outsider
	replace x2_32 = x2_32 * full * outsider
	
end



*===============================================================================	
// Insiders	
*===============================================================================

program estimate_insider_spline

	preserve
	keep if type == 1
	* initial estimation
	qui xtreg s x1_11 x2_11 x1_21 x2_21 x1_31 x2_31 i.period if type == 1, fe vce(cluster group)
	* store coefficients into macros to use in hockey stick estimation
	* constant
	local cons = _b[_cons]
	* zero
	local b1 = _b[x1_11]
	local b2 = _b[x2_11] //  right slope
	*partial
	local b3 = _b[x1_21]
	local b4 = _b[x2_21] // right slope
	* full
	local b5 = _b[x1_31]
	local b6 = _b[x2_31] // right slope
	* hockey stick estimation
	qui nl (s = {cons=`cons'} + /// 
		{b1=`b1'}*h*zero + {b2=`b2'}*max(h - {k1=5},0)*zero + /// 
		{b3=`b3'}*h*partial + {b4=`b4'}*max(h - {k2=5},0)*partial +  ///
		{b5=`b5'}*h*full + {b6=`b6'}*max(h - {k3=5},0)*full /// 
	)
	restore
end



// visualize splines
program plot_insider_spline

	* predict
	matrix T = r(table)
	predict s_hat, yhat
	* Zero Monitoring
	preserve
	keep if treatment == 1 & type == 1
	expand 2 in L
	replace h = _b[k1:_cons] in L
	replace s_hat = _b[_cons] + _b[b1:_cons]*h in L
	gen byte esample = e(sample)
	rename h h1
	rename s_hat s_hat1
	sort subject
	save zero_in, replace
	restore 
	* Partial Monitoring
	preserve
	keep if treatment == 2 & type == 1
	expand 2 in L
	replace h = _b[k2:_cons] in L
	replace s_hat = _b[_cons] + _b[b3:_cons]*h in L
	gen byte esample = e(sample)
	rename h h2
	rename s_hat s_hat2
	sort subject
	save partial_in, replace
	restore 
	* Full Monitoring
	preserve
	keep if treatment == 3 & type == 1
	expand 2 in L
	replace h = _b[k3:_cons] in L
	replace s_hat = _b[_cons] + _b[b5:_cons]*h in L
	gen byte esample = e(sample)
	rename h h3
	rename s_hat s_hat3
	sort subject
	save full_in, replace
	restore 
	* merge data
	use zero_in, clear
	merge subject using partial_in full_in
	tw	(line s_hat1 h1, lp(".-") lcolor("0 255 0") lwidth(medthick) sort) ///
		(line s_hat2 h2, lp(_) lcolor("0 255 0") lwidth(medthick) sort) ///
		(line s_hat3 h3, lp(l) lcolor("0 255 0") lwidth(medthick)  sort), ///
		xlab(0(4)12) ///
		xtitle("Harvest") ytitle("Estimated Sanctions") ///
		legend(ring(0) pos(11) cols(1) lab(1 "Zero") lab(2 "Partial") lab(3 "Full")) ///
		subtitle("{bf:Insiders}") name(splinesIn, replace) nodraw

end
	
*===============================================================================
// Outsiders
*===============================================================================
 
program estimate_outsider_spline
	preserve
	keep if type == 2
	* intitial estimation using xtreg controling for random effects
	qui xtreg s x1_22 x2_22 x1_32 x2_32 i.period if type == 2, fe vce(cluster group)
	* store coefficients into macros to use in hockey stick estimation
	* constant
	local cons = _b[_cons]
	*partial
	local b3 = _b[x1_22]
	local b4 = _b[x2_22] // right slope
	* full
	local b5 = _b[x1_32]
	local b6 = _b[x2_32] // right slope
	* hockey stick
	qui nl (s = {cons=`cons'} + /// 
		{b3=`b3'}*h*partial + {b4=`b4'}*max(h - {k2=5},0)*partial +  ///  PM Outsiders
		{b5=`b5'}*h*full + {b6=`b6'}*max(h - {k3=5},0)*full /// FM Outsiders
	)
	restore 
end

// visualize splines
program plot_outsider_spline

	* predict
	matrix T = r(table)
	predict s_hat, yhat
	* Partial Monitoring
	preserve
	keep if treatment == 2 & type == 2
	expand 2 in L
	replace h = _b[k2:_cons] in L
	replace s_hat = _b[_cons] + _b[b3:_cons]*h in L
	gen byte esample = e(sample)
	rename h h2
	rename s_hat s_hat2
	sort subject
	save partial_out, replace
	restore 
	* Full Monitoring
	preserve
	keep if treatment == 3 & type == 2
	expand 2 in L
	replace h = _b[k3:_cons] in L
	replace s_hat = _b[_cons] + _b[b5:_cons]*h in L
	gen byte esample = e(sample)
	rename h h3
	rename s_hat s_hat3
	sort subject
	save full_out, replace
	restore 
	* merge data
	use partial_out, clear
	merge subject using full_out
	tw	(line s_hat2 h2, lp(_) sort lcolor("0 0 255") lwidth(medthick) ) ///
		(line s_hat3 h3, lp(l) sort lcolor("0 0 255") lwidth(medthick) ), ///
		xlab(0(4)12) ///
		xtitle("Poaching") ytitle(" ") ///
		legend(ring(0) pos(11) cols(1) lab(1 "Partial") lab(2 "Full")) ///
		subtitle("{bf:Outsiders}") name(splinesOut, replace) nodraw

end

*===============================================================================
*  visualize joint spline
*===============================================================================

program plot_joint_spline
		
	graph combine splinesIn splinesOut, /// 
	ycommon ///
	graphregion(color(white))
	
	cd "/Users/LawrenceDeGeest/Documents/DE_analysis_15/Figures"
	graph set eps fontface Times
	graph export splines.eps, replace 

end	
