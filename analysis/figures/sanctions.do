graph set window fontface PTSerif-Regular
graph set eps fontface Times
set scheme lean1
use dp_data.dta, clear	

*===============================================================================
* average sanctions
*===============================================================================
preserve
collapse (mean) s_v if mon == 1, by(treatment period type)
egen m_s_v = mean(s_v), by(treatment type) 
global obs s_v period
global avg m_s_v period
twoway 	(connected $obs if treatment==1 & type==1,  sort msymbol(O) msize(medlarge) color("0 255 0" ) ) ///
		(connected $obs if treatment==1 & type==2,  sort msize(medlarge) color("0 0 255" ) ) ///
		(line $avg if treatment == 1 & type==1, lpattern(solid) lcolor(red)) ///
		(line $avg if treatment == 1 & type==2, lpattern(dash) lcolor(red )), ///			
				xlabel(1(2)15)  ytitle("Average sanctions") xtitle(" ")   ///
				legend( order(1 2 3 4) lab(1 "Insiders") lab(2 "Outsiders") lab(3 "Treatment mean") lab(4 "Treatment mean") cols(2)) ///
				subtitle("{bf:Zero}") name(zeroS,replace) scheme(lean1) ysize(1) xsize(2) nodraw 
twoway 	(connected $obs if treatment==2 & type==1,  sort msymbol(O) msize(medlarge) color("0 255 0" ) ) ///
		(connected $obs if treatment==2 & type==2,  sort msize(medlarge) color("0 0 255" ) ) ///
		(line $avg if treatment == 2 & type==1, lpattern(solid) lcolor(red)) ///
		(line $avg if treatment == 2 & type==2, lpattern(dash) lcolor(red)), ///
				xlabel(1(2)15)  ytitle(" ") xtitle("Period") ///						
				subtitle("{bf:Partial}") name(partialS,replace) scheme(lean1) ysize(1) xsize(2)  nodraw			
twoway 	(connected $obs if treatment==3 & type==1,  sort msymbol(O) msize(medlarge) color("0 255 0" ) ) ///
		(connected $obs if treatment==3 & type==2,  sort msize(medlarge) color("0 0 255" ) ) ///
		(line $avg if treatment == 3 & type==1, lpattern(solid) lcolor(red)) ///
		(line $avg if treatment == 3 & type==2, lpattern(dash) lcolor(red)), ///			
				xlabel(1(2)15)  ytitle(" ") xtitle(" ") ///	
				subtitle("{bf:Full}") name(fullS,replace) scheme(lean1) nodraw
grc1leg zeroS partialS fullS, ///
	cols(3) ycommon ///
	graphregion(color(white)) ///
	name(sanctions,replace)
restore
graph display sanctions, ysize(4) xsize(8)
cd "/Users/LawrenceDeGeest/Documents/DE_analysis_15/presentations/esa/images"
graph export sanctions.pdf, replace
 


*===============================================================================
* average initial payoff reduced to zero 
*===============================================================================

use chop.dta, clear

twoway 	(line c period if treatment==1 & type==1,  sort lcolor(black) ) ///
		(line c period if treatment==1 & type==2,  sort lcolor(gray) lp(l) ) ///
		(scatter c period if treatment==1 & type==1,  sort mcolor(black) msymbol(o) ) ///
		(scatter c period if treatment==1 & type==2,  sort mcolor(gray) msymbol(o)), ///
				xlabel(0(5)15) ytitle("Average percent of intitial payoff deducted") xtitle("Period") legend( order(3 4) lab(3 "Insiders") lab(4 "Outsiders") cols(2))  ///						
				subtitle(Zero) name(zeroC,replace) scheme(lean1) nodraw
twoway 	(line c period if treatment==2 & type==1, sort lcolor(black) ) ///
		(line c period if treatment==2 & type==2,  sort lcolor(gray) lp(l) ) ///
		(scatter c period if treatment==2 & type==1,  sort mcolor(black) msymbol(o) ) ///
		(scatter c period if treatment==2 & type==2,  sort mcolor(gray) msymbol(o)), ///
				xlabel(0(5)15) ytitle("Average percent of intitial payoff deducted") xtitle("Period") ///						
				subtitle(Partial) name(partialC,replace) scheme(lean1)  nodraw			
twoway 	(line c period if treatment==3 & type==1, sort lcolor(black) ) ///
		(line c period if treatment==3 & type==2,  sort lcolor(gray) lp(l) ) ///
		(scatter c period if treatment==3 & type==1,  sort mcolor(black) msymbol(o) ) ///
		(scatter c period if treatment==3 & type==2,  sort mcolor(gray) msymbol(o)), ///
				xlabel(0(5)15) ytitle("Average percent of intitial payoff deducted") xtitle("Period") ///						
				subtitle(Full) name(fullC,replace) scheme(lean1)  nodraw
grc1leg zeroC partialC fullC, ///
	cols(3) ycommon ///
	graphregion(color(white)) ///
	legendfrom(zeroC) name(chop,replace) 
	
*===============================================================================
* SANCTIONS BAR PLOT 
*===============================================================================
use dp_data, clear

// get a sense of how to cut the data
bysort treatment: tab ls

// create bins and collapse data
preserve

egen bins = cut(ls), at(0,1,10,20,76) icodes
table bins, contents(min ls max ls)
label define bins 0  "0" 1  "<10" 2  "<20" 3  ">20"
label values bins bins
collapse (mean) mdh = deltah (count) n = ls, by(treatment type bins) 
drop if bins == .

*======================
* count plots 
*======================
// Zero Monitoring	 
graph bar n if treatment == 1, over(type) over(bins) asyvars bar(1, color(black)) bar(2, color(gray)) ///
	ytitle("Total sanctions in {it:t}") b1title(" ") ///
	legend(lab(1 "Insiders") lab(2 "Outsiders") cols(2)) /// 
	title({bf:A}, size(large) ring(0) pos(10)) subtitle("{bf:Zero}")  ///
	scheme(lean1) name(zero_count_b, replace) nodraw
// Partial Monitoring
graph bar n if treatment == 2, over(type) over(bins) asyvars bar(1, color(black)) bar(2, color(gray)) ///
	ytitle(" ") b1title("Sanctions") ///
	legend(lab(1 "Insiders") lab(2 "Outsiders")) /// 
	subtitle("{bf:Partial}")  ///
	scheme(lean1) name(partial_count_b, replace) nodraw	
// Full Monitoring
graph bar n if treatment == 3, over(type) over(bins) asyvars bar(1, color(black)) bar(2, color(gray)) ///
	ytitle(" ") b1title(" ") ///
	legend(lab(1 "Insiders") lab(2 "Outsiders")) /// 
	subtitle("{bf:Full}")  ///
	scheme(lean1) name(full_count_b, replace) nodraw
*======================
* response plots 
*======================
// Zero Monitoring	 
graph bar mdh if treatment == 1, over(type) over(bins) asyvars bar(1, color(black)) bar(2, color(gray)) ///
	ytitle("Average {&Delta} harvest (h{subscript:t+1} - h{subscript:t})") b1title(" ") ///
	legend(lab(1 "Insiders") lab(2 "Outsiders") cols(2)) /// 
	title({bf:B}, size(large) ring(0) pos(10)) subtitle("{bf:Zero}")  ///
	scheme(lean1) name(zero_response_b, replace) nodraw
// Partial Monitoring
graph bar mdh if treatment == 2, over(type) over(bins) asyvars bar(1, color(black)) bar(2, color(gray)) ///
	ytitle(" ") b1title("Sanctions") ///
	legend(lab(1 "Insiders") lab(2 "Outsiders")) /// 
	subtitle("{bf:Partial}")  ///
	scheme(lean1) name(partial_response_b, replace) nodraw	
// Full Monitoring
graph bar mdh if treatment == 3, over(type) over(bins) asyvars bar(1, color(black)) bar(2, color(gray)) ///
	ytitle(" ") b1title(" ") ///
	legend(lab(1 "Insiders") lab(2 "Outsiders")) /// 
	subtitle("{bf:Full}") b1title(" ") ///
	scheme(lean1) name(full_response_b, replace) nodraw
*======================
* combine 
*======================
grc1leg ///
	zero_count_b partial_count_b full_count_b ///
	zero_response_b partial_response_b full_response_b, /// 
	cols(3) ///
	legendfrom(zero_response_b)  ///
	graphregion(color(white))  ///
	name(Bar, replace)	

restore	
