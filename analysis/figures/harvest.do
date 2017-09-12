*===============================================================================
* best response plot with insider cooperative and noncooperative strategies
* insiders (h + br_c + br_nc)
*===============================================================================
use BestResponse.dta, clear	
graph set window fontface PTSerif-Regular
graph set eps fontface Times
set scheme lean1

*===============================================================================
* FOR PAPER
*===============================================================================
 		
// INSIDERS
preserve
global observed mh period
global cooperative br_c period
global noncooperative br_nc period
keep if type == 1
twoway 	(connected $observed if treatment==1, sort msymbol(o)) ///
		(connected $cooperative if treatment==1, sort msymbol(sh) ) ///
		(connected $noncooperative if treatment==1, sort msymbol(th)), ///
			xlabel(1(2)15) ylabel(0(4)12) ytitle("Insider harvest") xtitle(" ") ///
			legend(cols(3) lab(1 "Mean harvest") lab(2 "Cooperative best-response") lab(3 "Noncooperative best-response") size(vsmall))   ///						
			title("", size(large) ring(0) pos(10) ) /// 
			subtitle("{bf:Zero}") name(zeroIn,replace) nodraw
twoway 	(connected $observed if treatment==2, sort msymbol(o)) ///
		(connected $cooperative if treatment==2, sort msymbol(sh) ) ///
		(connected $noncooperative if treatment==2, sort msymbol(th)), ///
			xlabel(1(2)15) ylabel(0(4)12) ytitle(" ") xtitle("Period")  legend(off) ///						
			subtitle("{bf:Partial}") name(partialIn,replace) nodraw			
twoway 	(connected $observed if treatment==3, sort msymbol(o)) ///
		(connected $cooperative if treatment==3, sort msymbol(sh) ) ///
		(connected $noncooperative if treatment==3, sort msymbol(th)), ///
			xlabel(1(2)15) ylabel(0(4)12) ytitle(" ") xtitle(" ")  legend(off) ///						
			subtitle("{bf:Full}") name(fullIn,replace) nodraw	
restore			
// OUTSIDERS			
preserve
global observed mh period
global noncooperative br period
keep if type == 2
twoway 	(connected $observed if treatment==1, sort msymbol(o)) ///
		(connected $noncooperative if treatment==1, sort lcolor(black) mcolor(black) msymbol(th) ), ///
			xlabel(1(2)15) ylabel(0(4)12) ytitle("Outsider harvest") xtitle(" ") ///
			title("", size(large) ring(0) pos(10))  ///
			subtitle("{bf:Zero}") name(zeroOUT,replace) nodraw		
twoway 	(connected $observed if treatment==2, sort msymbol(o)) ///
		(connected $noncooperative if treatment==2, sort lcolor(black) mcolor(black) msymbol(th) ), ///
			xlabel(1(2)15) ylabel(0(4)12) ytitle(" ") xtitle("Period") legend(off) ///						
			subtitle("{bf:Partial}") name(partialOUT,replace)  nodraw			
twoway 	(connected $observed if treatment==3, sort msymbol(o)) ///
		(connected $noncooperative if treatment==3, sort msymbol(th) ), ///
			xlabel(1(2)15) ylabel(0(4)12) ytitle(" ") xtitle(" ") legend(off)  ///						
			subtitle("{bf:Full}") name(fullOUT,replace) nodraw	
restore
			
grc1leg zeroIn partialIn fullIn zeroOUT partialOUT fullOUT, ///
	cols(3) ycommon ///
	graphregion(color(white)) ///
	legendfrom(zeroIn) name(harvest, replace) 			

cd "/Users/LawrenceDeGeest/Documents/DE_analysis_15/Figures"
graph export harvest.eps, replace 
graph export harvest.pdf, replace

			
*===============================================================================
* FOR PRESENTATION
* green = insiders = color("0 255 0")
* blue = outsiders = color("0 0 255")
*===============================================================================

preserve
keep if type == 1
egen mean_h = mean(mh), by(treatment)
global observed mh period
global cooperative br_c period
global noncooperative br_nc period
global avg mean_h period
twoway 	(connected $observed if treatment==1, sort  msymbol(O) msize(medlarge) color("0 255 0")) ///		
		(connected $cooperative if treatment==1, sort msymbol(Sh) msize(medlarge)  ) ///
		(connected $noncooperative if treatment==1, sort msymbol(Th) msize(medlarge)  ) ///
		(line $avg if treatment == 1, lpattern(solid) lcolor(red)), ///
			xlabel(1(2)15) ylabel(0(4)12) ytitle("Harvest") xtitle(" ") ///
			legend(order(1 2 3 4) cols(4) lab(1 "Mean harvest") lab(2 "Cooperative best-response") lab(3 "Noncooperative best-response") lab(4 "Treatment mean"))   ///						
			subtitle("{bf:Zero}") name(zeroIn,replace) nodraw
twoway 	(connected $observed if treatment==2, sort msymbol(O) msize(medlarge) color("0 255 0")) ///
		(connected $cooperative if treatment==2, sort msymbol(Sh) msize(medlarge)) ///
		(connected $noncooperative if treatment==2, sort msymbol(Th) msize(medlarge) ) ///
		(line $avg if treatment == 2, lpattern(solid) lcolor(red)), ///		
			xlabel(1(2)15) ylabel(0(4)12) ytitle(" ") xtitle("Period")  legend(off) ///						
			subtitle("{bf:Partial}") name(partialIn,replace) nodraw			
twoway 	(connected $observed if treatment==3, sort msymbol(O) msize(medlarge) color("0 255 0") ) ///
		(connected $cooperative if treatment==3, sort msymbol(Sh) msize(medlarge) ) ///
		(connected $noncooperative if treatment==3, sort msymbol(Th) msize(medlarge) ) ///
		(line $avg if treatment == 3, lpattern(solid) lcolor(red)), ///		
			xlabel(1(2)15) ylabel(0(4)12) ytitle(" ") xtitle(" ")  legend(off) ///						
			subtitle("{bf:Full}") name(fullIn,replace) nodraw	
grc1leg zeroIn partialIn fullIn, ///
	cols(3) ycommon xcommon ///
	graphregion(color(white)) ///
	legendfrom(zeroIn) name(harvest_in, replace) ///
	note("{it:Best response paths calculated from observed outsider poaching}") 
graph display harvest_in, ysize(4) xsize(8)
cd "/Users/LawrenceDeGeest/Documents/DE_analysis_15/presentations/lafayette/images"	
graph export harvest_in.pdf, replace
restore


preserve
keep if type == 2
egen mean_h = mean(mh), by(treatment)
global observed mh period
global noncooperative br period
global avg mean_h period
twoway 	(connected $observed if treatment==1, sort msymbol(O) msize(medlarge) color("0 0 255")) ///
		(connected $noncooperative if treatment==1, sort lcolor(black) mcolor(black) msymbol(Th) msize(medlarge) ) ///
		(line $avg if treatment == 1, lpattern(solid) lcolor(red)), ///		
			xlabel(1(2)15) ylabel(0(4)12) ytitle("Poaching") xtitle(" ") ///
			legend(order(1 2 3) cols(3) lab(1 "Mean poaching") lab(2 "Noncooperative best-response") lab(3 "Treatment mean"))   ///		)   ///						
			subtitle("{bf:Zero}") name(zeroOUT,replace) nodraw		
twoway 	(connected $observed if treatment==2, sort msymbol(O) msize(medlarge) color("0 0 255")) ///
		(connected $noncooperative if treatment==2, sort lcolor(black) mcolor(black) msymbol(Th)  msize(medlarge)) ///
		(line $avg if treatment == 2, lpattern(solid) lcolor(red)), ///		
			xlabel(1(2)15) ylabel(0(4)12) ytitle(" ") xtitle("Period") legend(off) ///						
			subtitle("{bf:Partial}") name(partialOUT,replace)  nodraw			
twoway 	(connected $observed if treatment==3, sort msymbol(O) msize(medlarge) color("0 0 255")) ///
		(connected $noncooperative if treatment==3, sort msymbol(Th) msize(medlarge) ) ///
		(line $avg if treatment == 3, lpattern(solid) lcolor(red)), ///		
			xlabel(1(2)15) ylabel(0(4)12) ytitle(" ") xtitle(" ") legend(off)  ///						
			subtitle("{bf:Full}") name(fullOUT,replace) nodraw	
grc1leg zeroOUT partialOUT fullOUT, ///
	cols(3) ycommon xcommon ///
	graphregion(color(white)) ///
	legendfrom(zeroOUT) name(harvest_out, replace) ///
	note("{it:Best response paths calculated from observed insider harvest}")
restore
graph display harvest_out, ysize(4) xsize(8)
cd "/Users/LawrenceDeGeest/Documents/DE_analysis_15/presentations/esa/images"	
graph export harvest_out.pdf, replace
restore	
		
