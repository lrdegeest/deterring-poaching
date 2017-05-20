* ==========================================================
* Estimate changes in harvest following sanctions
* ==========================================================

cd "/Users/LawrenceDeGeest/Documents/DE_analysis_15/Data"
use dp_data, clear
replace mon = 1 if treatment == 3
keep if mon == 1 // drop zm outsiders (180) and pm outsiders mon==0 (120). 1140 observations left


// drop outliers
//drop if s == 149 & treatment == 2 // drop outlier insider
//drop if treatment == 2 & h == 0 & s == 18 //drop outlier outsider	

// set controls
global controls i.treatment#i.first#c.ls i.treatment#i.first#c.ldev i.period


// Insiders
quietly eststo IN_under: xtreg deltah $controls if type == 1 & lOverUnder == 0, fe cluster(group)
quietly eststo IN_over: xtreg deltah $controls if type == 1 & lOverUnder == 1, fe cluster(group)

// Outsiders
quietly eststo OUT_under: xtreg deltah $controls if type == 2 & lOverUnder == 0, fe cluster(group)
quietly eststo OUT_over: xtreg deltah $controls if type == 2 & lOverUnder == 1, fe cluster(group)


coefplot(IN_under, label("{it:Below} group mean") msize(small) msymbol(Sh) mcolor("0 255 0")) ///
		(IN_over, label("{it:Above} group mean") msize(small) mcolor("0 255 0")) , ///
			yscale(alt) /// 
			title("Insiders") ///
			xtitle("Coefficient estimate") ///
			ciopts(recast(rcap) color("0 255 0")) ///
			xline(0, lcolor(red)) /// 
			scheme(lean1) ///
			grid(between glcolor(white)) ///
			omitted baselevels ///
			legend(ring(0) position(11) size(small)) ///
			keep(*.treatment#*.first#c.ls *.treatment#*.first#c.ldev) ///
			headings( ///
			1.treatment#1.first#c.ls = "{bf: Sanctions in {it:t}}" ///
			1.treatment#1.first#c.ldev = "{bf: Deviations in {it:t}}" ) ///
				coeflabels( ///
					1.treatment#1.first#c.ls = "{it: Zero} x First" /// 
					1.treatment#2.first#c.ls = "{it: Zero} x Second" /// 
					2.treatment#1.first#c.ls = "{it: Partial} x First" ///
					2.treatment#2.first#c.ls = "{it: Partial}  x Second" /// 
					3.treatment#1.first#c.ls = "{it: Full} x First " /// 
					3.treatment#2.first#c.ls = "{it: Full} x Second" /// 
					1.treatment#1.first#c.ldev = "{it: Zero} x First" /// 
					1.treatment#2.first#c.ldev = "{it: Zero} x Second" /// 
					2.treatment#1.first#c.ldev = "{it: Partial}  x First" ///
					2.treatment#2.first#c.ldev = "{it: Partial}  x Second" /// 
					3.treatment#1.first#c.ldev = "{it: Full} x First " /// 
					3.treatment#2.first#c.ldev = "{it: Full} x Second" ) ///
			name(insiders, replace) nodraw 			
				
coefplot(OUT_under, label("{it:Below} group mean") msize(small) msymbol(Sh)  mcolor("0 0 255")) ///
		(OUT_over, label("{it:Above} group mean") msize(small) mcolor("0 0 255")) , ///
			yscale(alt) /// 
			title("Outsiders") ///
			xtitle("Coefficient estimate") ///
			ciopts(recast(rcap) color("0 0 255")) ///
			xline(0, lcolor(red)) /// 
			scheme(lean1) ///
			grid(between glcolor(white)) ///
			omitted baselevels ///
			legend(ring(0) position(11) size(small)) ///
			keep(*.treatment#*.first#c.ls *.treatment#*.first#c.ldev) ///
			headings( ///
			2.treatment#1.first#c.ls = "{bf: Sanctions in {it:t}}" ///
			2.treatment#1.first#c.ldev = "{bf: Deviations in {it:t}}" ) ///
				coeflabels( ///
					2.treatment#1.first#c.ls = "{it: Partial} x First" ///
					2.treatment#2.first#c.ls = "{it: Partial}  x Second" /// 
					3.treatment#1.first#c.ls = "{it: Full} x First " /// 
					3.treatment#2.first#c.ls = "{it: Full} x Second" /// 
					2.treatment#1.first#c.ldev = "{it: Partial}  x First" ///
					2.treatment#2.first#c.ldev = "{it: Partial}  x Second" /// 
					3.treatment#1.first#c.ldev = "{it: Full} x First " /// 
					3.treatment#2.first#c.ldev = "{it: Full} x Second" ) ///
			name(outsiders, replace) nodraw 					

	
graph combine insiders outsiders, graphregion(color(white)) 












