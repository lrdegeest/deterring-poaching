*===============================================================================
* efficiency insiders + outsiders (intial + final)
*===============================================================================
cd "/Users/LawrenceDeGeest/Documents/DE_analysis_15/Data"
use HarvestEfficiency, clear
label var period "Period"
set scheme lean1
graph set window fontface PTSerif-Regular
graph set eps fontface Times
global initial e1 period
global final e period

//INSIDERS
preserve
keep if type==1
twoway 	(connected $initial if treatment==1, sort lp(-) msymbol(oh)) ///
		(connected $final if treatment==1, sort lp(l)  msymbol(o)), ///
			xlabel(1(2)15)  ytitle("Insider efficiency") xtitle(" ") legend(lab(1 "Initial efficiency") lab(2 "Final efficiency") cols(2) size(vsmall))  ///						
			subtitle("{bf:Zero}") name(zeroIn_E,replace) nodraw
twoway 	(connected $initial if treatment==2, sort lp(-)  msymbol(oh)) ///
		(connected $final if treatment==2, sort  lp(l) msymbol(o)), ///
			xlabel(1(2)15) ytitle(" ") xtitle("Period") ///						
			subtitle("{bf:Partial}")name(partialIn_E,replace) nodraw			
twoway 	(connected $initial if treatment==3, sort  lp(-) msymbol(oh)) ///
		(connected $final if treatment==3, sort lp(l)  msymbol(o)), ///
			xlabel(1(2)15) ytitle(" ") xtitle(" ") ///						
			subtitle("{bf:Full}") name(fullIn_E,replace) nodraw
restore			
//OUTSIDERS
preserve
keep if type == 2
twoway 	(connected $initial if treatment==1, sort lp(-) msymbol(oh)) ///
		(connected $final if treatment==1, sort lp(l)  msymbol(o)), ///
			xlabel(1(2)15)  ytitle("Outsider efficiency") xtitle(" ") legend( order(3 4) lab(3 "Initial efficiency") lab(4 "Final efficiency") cols(2) size(small))  ///						
			subtitle("{bf:Zero}") name(zeroOut_E,replace) nodraw
twoway 	(connected $initial if treatment==2, sort lp(-) msymbol(oh)) ///
		(connected $final if treatment==2, sort lp(l) msymbol(o)), ///
			xlabel(1(2)15) ytitle(" ") xtitle("Period") ///						
			subtitle("{bf:Partial}")name(partialOut_E,replace) nodraw			
twoway 	(connected $initial if treatment==3, sort lp(-) msymbol(oh)) ///
		(connected $final if treatment==3, sort lp(l) msymbol(o)), ///
			xlabel(1(2)15) ytitle(" ") xtitle(" ") ///						
			subtitle("{bf:Full}") name(fullOut_E,replace) nodraw
restore
*===============================================================================
* combined efficiency plot
*===============================================================================				
grc1leg ///
	zeroIn_E partialIn_E fullIn_E ///
	zeroOut_E partialOut_E fullOut_E, ///
	cols(3) ycommon ///
	graphregion(color(white)) ///
	legendfrom(zeroIn_E) name(efficiency,replace) 
	
cd "/Users/LawrenceDeGeest/Documents/DE_analysis_15/Figures"
graph export efficiency.eps, replace
graph export efficiency.pdf, replace


*===============================================================================
* PRESENTATION
*===============================================================================	

//INSIDERS
preserve
keep if type==1
egen m_e = mean(e), by(treatment)
global avg m_e period
twoway 	(connected $initial if treatment==1, sort lp(-) msymbol(Oh) msize(medlarge) color("0 255 0")) ///
		(connected $final if treatment==1, sort lp(l)  msymbol(O) msize(medlarge) color("0 255 0")) ///
		(line $avg if treatment == 1, lpattern(solid) lcolor(red)), ///		
			xlabel(1(2)15)  ytitle("Efficiency") xtitle(" ") legend(order(1 2 3) lab(1 "Initial efficiency") lab(2 "Final efficiency") lab(3 "Treatment mean") cols(3) )  ///						
			subtitle("{bf:Zero}") name(zeroIn_E,replace) nodraw
twoway 	(connected $initial if treatment==2, sort lp(-)  msymbol(Oh) msize(medlarge) color("0 255 0")) ///
		(connected $final if treatment==2, sort  lp(l) msymbol(O) msize(medlarge) color("0 255 0")) ///
		(line $avg if treatment == 2, lpattern(solid) lcolor(red)), ///		
			xlabel(1(2)15) ytitle(" ") xtitle("Period") ///						
			subtitle("{bf:Partial}")name(partialIn_E,replace) nodraw			
twoway 	(connected $initial if treatment==3, sort  lp(-) msymbol(Oh) msize(medlarge)  color("0 255 0")) ///
		(connected $final if treatment==3, sort lp(l)  msymbol(O) msize(medlarge) color("0 255 0")) ///
		(line $avg if treatment == 3, lpattern(solid) lcolor(red)), ///		
			xlabel(1(2)15) ytitle(" ") xtitle(" ") ///						
			subtitle("{bf:Full}") name(fullIn_E,replace) nodraw
restore	
grc1leg ///
	zeroIn_E partialIn_E fullIn_E, ///
	cols(3) ycommon ///
	graphregion(color(white)) ///
	legendfrom(zeroIn_E) name(eff_in,replace) 
graph display eff_in, ysize(4) xsize(8)	
cd "/Users/LawrenceDeGeest/Documents/DE_analysis_15/presentations/esa/images"
graph export eff_in.pdf, replace
