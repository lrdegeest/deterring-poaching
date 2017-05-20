use ~/Desktop/notebook/research/dissertation/first_paper/analysis/data/dp_data_with_sanctions_breakdown.dta, clear

*===============================================================================
* 1. Examine types of insiders who sanction outsiders
*===============================================================================
keep if type == 1 
keep if treatment > 1
foreach var in subject{
	egen th = total(h), by(group period)
	gen n = 5
	gen in_avg = th / n
	gen other_in_avg = (th - h) / (n - 1)
}
drop th n
gen OverUnder_in = cond(h-in_avg>0,1,0)
label define OverUnder_in 0 "Under" 1 "Over" 
label values OverUnder_in OverUnder_in
replace OverUnder = 0 if OverUnder == 1
replace OverUnder = 1 if OverUnder == 2
label drop OverUnder
label define OverUnder 0 "Under" 1 "Over" 
label values OverUnder OverUnder
xtset subject period


// update 4/12: restrict analysis of types to an "80/20" thing
// Q: how many sanctions on outsiders? 
tabstat s_a_outsider, by(treatment) stat(sum)
// Q: how many insiders sanctioned outsiders? 
preserve
collapse (sum) total_s_a_outsider = s_a_outsider, by(treatment subject)
gen N = cond(total_s_a > 0, 1, 0)
tabstat N, by(treatment) stat(sum)
restore
// Q: what percent of total sanctions were made by overs and unders in a given period?
graph bar (sum) s_a_outsider, ///
	over(OverUnder_in) over(treatment) asyvars percent ///
	ylab(,nogrid) bar(1, color(black)) bar(2, color(gray)) ///
	ytitle("Percent contribution to total") subtitle("Sanctions on outsiders") ///
	blabel(total, format(%9.0f)) ///
	note("Note: insiders are classified as harvesting above or below the mean" "of other insiders in their group in a given period")

// Q: what percent of total sanctions were made by subject types? (80% and 60% Under cutoff)
sort treatment subject group period	
egen type_insider = sum(OverUnder_in), by(subject) // [0,15]: 0 means always under, 15 means always over
// hist type_insider, by(treatment) // histogram shows a) few subjects were strict unders and b) no subjects were strict overs
replace type_insider = 1 if type_insider > 0 & type_insider <=3  // under at least 80% of the time
replace type_insider = 2 if type_insider > 3 & type_insider <= 6 // under at least 60% of the time
replace type_insider = 3 if type_insider > 6
label define type_insider 0 "strict_under"  1 "under_80" 2 "under_60" 3 "leftovers" 
label values type_insider type_insider
// now visualize
graph bar (sum) s_a_outsider, over(type_insider) over(treatment) asyvars percent bar(1, color(red)) bar(2, color(green)) bar(3, color(blue)) ylab(0(20)100, nogrid) ytitle("Percent contribution of all sanctions") subtitle("Sanctions on outsiders") blabel(total, format(%9.0f)) name(contributions, replace)

// Q: how many subjects are in each category?
* table
preserve
keep if period == 1
bysort treatment: tabstat subject, by(type_insider) stat(count)
restore
* visual
gen strict_under = 1 if type_insider == 0
gen under80 = 1 if type_insider == 1
gen under60 = 1 if type_insider == 2
gen leftovers = 1 if type_insider == 3
graph bar (count) strict_under under80 under60 leftovers, over(treatment) asyvar bar(1, color(red)) bar(2, color(green)) bar(3, color(blue)) ylab(0(20)100, nogrid) ytitle("Percent") legend(lab(1 "Always Under") lab(2 "Under 80% of time") lab(3 "Under 60% of time") lab(4 "Leftovers")) subtitle("Number of types") blabel(total) name(counts, replace)
drop strict_under under80 under60 leftovers
* better visual
preserve 
keep if period == 1
graph bar (count) subject, over(type_insider) over(treatment) asyvar percent bar(1, color(red)) bar(2, color(green)) bar(3, color(blue)) ylab(0(20)100, nogrid) ytitle("Percent of total (20 subjects per treatment)") legend(cols(4) lab(1 "Always Under") lab(2 "Under 80% of time") lab(3 "Under 60% of time") lab(4 "Leftovers")) subtitle("Number of types") blabel(total) name(counts, replace)
restore
// joint visual of a) percent contributions to sanctions by type and b) percent of types in each treatment
grc1leg contributions counts, ycommon cols(2) legendfrom(counts)

//Q: what are the contributions to outsider sanctions by each subject, independent of harvest type?

// A: aggregating by treatment
graph bar (sum) s_a_outsider if treatment == 2, legend(off) ylabel(0(20)100,nogrid) over(subject, sort(s_a_outsider) descending) blabel(name) asyvar percent name(pm_total, replace) nodraw
graph bar (sum) s_a_outsider if treatment == 3, legend(off) ylabel(0(20)100,nogrid) over(subject, sort(s_a_outsider) descending) blabel(name) asyvar percent name(fm_total, replace) nodraw
gr combine pm_total fm_total

// A: aggregating treatment and group
collapse (sum) s_a_outsider = s_a_outsider, by(treatment group subject)
sort treatment group -s_a_outsider
egen rank = rank(-s_a_outsider), by(treatment group)
gen uniquesubject = subject - 100*group
replace uniquesubject = cond(uniquesubject > 8, uniquesubject - 8, uniquesubject)
gen uniquegroup = group - 10*treatment
// average of the top punisher across treatment: compare ranks across treatments
egen total_s_a = sum(s_a_outsider), by(treatment group)
gen contribution = (s_a_outsider / total_s_a) * 100
tabstat contribution if rank == 1, by(treatment) stat(mean)
bysort treatment: tabstat contribution, by(rank) stat(mean) nototal
egen mean_top = mean(contribution) if rank == 1, by(treatment)
// plot each treatment
graph bar (sum) s_a_outsider if treatment == 2, ///
	over(rank, sort(s_a_outsider) descending) over(uniquegroup) ///
	asyvars percent nofill legend(off) ylabel(0(20)100,nogrid) ///
	bar(1, color(black)) bar(2, color(gs4)) bar(3, color(gs8)) bar(4, color(gs12)) bar(6, color(gs14)) ///
	b1title("Group") ytitle("Contribution to total sanctions" "on outsiders (percent) by group") title("Partial Monitoring") ///
	name(pm, replace) yline(48, lcolor(red)) nodraw
graph bar (sum) s_a_outsider if treatment == 3, ///
	over(rank, sort(s_a_outsider) descending) over(uniquegroup) ///
	asyvars percent nofill legend(off) ylabel(0(20)100,nogrid) ///
	bar(1, color(black)) bar(2, color(gs4)) bar(3, color(gs8)) bar(4, color(gs12)) bar(5, color(gs14)) ///
	b1title("Group") ytitle("Contribution to total sanctions" "on outsiders (percent) by group") title("Full Monitoring") ///
	name(fm, replace) yline(36, lcolor(red)) nodraw
// display the joint plot
graph combine pm fm, ///
	note("Insiders are collected by groups (1-4) across treatments. Each bar represents an insider in that group." /// 
	"Line indicates the average contribution to sanctions by the leading insider across treatments.")

// Q: are there any sig differences between ranks across treatments?
ttest contribution if rank == 1 & inlist(treatment, 2,3), by(treatment)

// Q: can you plot average ranks across groups within treatments? 
graph bar (mean) contribution if rank != 4.5, /// 
	over(treatment) over(rank) asyvars ylab(0(20)100, nogrid) blabel(total, format(%9.0f)) ///
	ytitle("Mean contribution to" "outsider sanctions (percent)") b1title("Insider rank") ///
	note("Insider rank is calculated within groups.")


// Q: any differences in skewness?
// http://www.stata.com/statalist/archive/2013-02/msg01235.html
// compare if distribution is symmetric (all points on 45 degree line)
qplot s_a_outsider, over(treatment) recast(line)

*===============================================================================
* 2. Compare expenditures on sanctions
*===============================================================================

* raw table
tabstat s_a s_a_insider s_a_outsider, by(treatment) stat(sum) nototal

* visual
** aggregate time
graph bar (sum) s_a, over(treatment) asyvars title("total sanctions") ytitle("expenditure ({c S|})") bar(1, color(red)) bar(2, color(green)) bar(3, color(blue)) legend(cols(3)) blabel(total) name(bar_total, replace) nodraw
graph bar (sum) s_a_insider, over(treatment) asyvars title("sanctions on insiders") ytitle("expenditure ({c S|})") bar(1, color(red)) bar(2, color(green)) bar(3, color(blue)) blabel(total) name(bar_in, replace) nodraw
graph bar (sum) s_a_outsider, over(treatment) asyvars title("sanctions on outsiders") ytitle("expenditure ({c S|})") bar(1, color(red)) bar(2, color(green)) bar(3, color(blue)) blabel(total) name(bar_out, replace) nodraw
** with first/second
graph bar (sum) s_a, over(treatment) over(first) asyvars title("sanctions") ytitle("expenditure ({c S|})") bar(1, color(red)) bar(2, color(green)) bar(3, color(blue)) legend(cols(3)) blabel(total) name(bar_total_time, replace) nodraw
graph bar (sum) s_a_insider, over(treatment) over(first) asyvars title("sanctions on insiders") ytitle("expenditure ({c S|})") bar(1, color(red)) bar(2, color(green)) bar(3, color(blue)) blabel(total) name(bar_in_time, replace) nodraw
graph bar (sum) s_a_outsider, over(treatment) over(first) asyvars title("sanctions on outsiders") ytitle("expenditure ({c S|})") bar(1, color(red)) bar(2, color(green)) bar(3, color(blue)) blabel(total) name(bar_out_time, replace) nodraw
grc1leg bar_total bar_in bar_out, ycommon title("Expenditures on sanctions") cols(3)

// for stack overflow post
graph bar (sum) s_a_insider if treatment > 1, over(treatment) asyvars title("good A") ytitle("spent ({c S|})") bar(1, color(gray)) bar(2, color(black)) blabel(total) name(bar_in, replace) legend(lab(1 "control") lab(2 "treatment")) nodraw
graph bar (sum) s_a_outsider if treatment > 1, over(treatment) asyvars title("good B") ytitle("spent ({c S|})") bar(1, color(gray)) bar(2, color(black)) blabel(total) name(bar_out, replace) nodraw
grc1leg bar_in bar_out, ycommon cols(2)

* distributions
preserve 
keep if treatment > 1
tw (kdensity s_a_insider if s_a_insider > 0 & s_a_insider < 30), by(treatment) name(hist1, replace) nodraw
tw (kdensity s_a_outsider if s_a_outsider > 0 & s_a_outsider < 30), by(treatment) name(hist2, replace) nodraw
//gr combine hist1 hist2
restore

tabstat s_a_outsider if s_a_outsider > 0 & treatment > 1, by(treatment) stat(sum mean sd N) nototal
tabstat s_a_insider if s_a_insider > 0 & treatment > 1, by(treatment) stat(sum mean sd N) nototal

*============================
* Differences across treatments
*============================
* check for differences: total sanctions (insiders)
forvalues i = 1/3 {	
	forvalues j = 1/3 {
		if `i' != `j' & `i' < `j' {	
			display "Nonparametrics for total sanctions"
			display "rank sum test for treatments `i' and `j' " 
			qui ranksum s_a if inlist(treatment, `i', `j'), by(treatment) 
			display "z-value = " r(z)
			display "p-value = " 2 * normprob(-abs(r(z)))
			display " "
		}
	}
}


* check for differences: total sanctions (insiders)
forvalues i = 1/3 {	
	forvalues j = 1/3 {
		if `i' != `j' & `i' < `j' {	
			display "Nonparametrics for total sanctions (insiders)"
			display "rank sum test for treatments `i' and `j' " 
			qui ranksum s_a_insider if s_a_insider > 0 & inlist(treatment, `i', `j'), by(treatment) 
			display "z-value = " r(z)
			display "p-value = " 2 * normprob(-abs(r(z)))
			display " "
		}
	}
}

* check for differences: total sanctions (outsiders)
ranksum s_a_outsider if s_a_outsider > 0 & inlist(treatment, 2, 3), by(treatment)
preserve
keep if s_a_outsider > 0
tw (kdensity s_a_outsider if treatment == 2) (kdensity s_a_outsider if treatment == 3), ///
	ytitle("Kernel density") xtitle("Positve outsider sanctions") ///
	legend(order(1 "Partial" 2 "Full") ring(0) position(2))
restore

* check for differences: total sanctions over time (outsiders)
forvalues i = 2/3 {	
	forvalues j = 2/3 {
		forvalues k = 1/2 {
			if `i' != `j' & `i' < `j' {	
				display "Nonparametrics for total sanctions"
				display "rank sum test for treatments `i' and `j' in time `k' " 
				qui ranksum s_a_outsider if s_a_outsider > 0 &  first == `k' & inlist(treatment, `i', `j'), by(treatment) 
				display "z-value = " r(z)
				display "p-value = " 2 * normprob(-abs(r(z)))
				display " "
			}
		}
	}
}



*============================
* Differences within treatments
*============================
* check for differences within type: total sanctions (outsiders and insiders by time)
forvalues i = 1/2 {	
	forvalues j = 1/2 {
		forvalues k = 2/3 {
			if `i' != `j' & `i' < `j' {	
				display "Nonparametrics for total sanctions (outsiders)"
				display "rank sum test for treatment `k' in times `i' and `j' " 
				qui ranksum s_a_outsider if s_a_outsider > 0 & treatment == `k' & inlist(first, `i', `j'), by(first) 
				display "z-value = " r(z)
				display "p-value = " 2 * normprob(-abs(r(z)))
				display " "
				display "Nonparametrics for total sanctions (insiders)"
				display "rank sum test for treatment `k' in times `i' and `j' " 
				qui ranksum s_a_insider if s_a_insider > 0 & s_a_insider < 139 & treatment == `k' & inlist(first, `i', `j'), by(first) 
				display "z-value = " r(z)
				display "p-value = " 2 * normprob(-abs(r(z)))
				display " "
				
			}
		}
	}
}


* check for differences across type: total sanctions (outsiders versus insiders by time)
* note: need to use signrank since these are matching pairs
forvalues i = 1/2 {	
	forvalues j = 1/2 {
		forvalues k = 2/3 {
			if `i' != `j' & `i' < `j' {	
				// aggregate
				display "Nonparametrics for total outsider vs insider sanctions (total)"
				display "rank sum test for treatment `k' "
				qui signtest s_a_outsider = s_a_insider if treatment == `k'
				display "z-value = " r(z)
				display "p-value = " 2 * normprob(-abs(r(z)))
				display " "
				// first
				display "Nonparametrics for total outsider vs insider sanctions (first)"
				display "rank sum test for treatment `k' in times `i' "
				qui signtest s_a_outsider = s_a_insider if treatment == `k' & first == `i'
				display "z-value = " r(z)
				display "p-value = " 2 * normprob(-abs(r(z)))
				display " "
				// second
				display "Nonparametrics for total outsider vs insider sanctions (second)"
				display "rank sum test for treatment `k' in times `j' " 
				qui signtest s_a_outsider = s_a_inside if treatment == `k' & first == `j'
				display "z-value = " r(z)
				display "p-value = " 2 * normprob(-abs(r(z)))
				display " "		
			}
		}
	}
}

*===============================================================================
* 3. Communication
*===============================================================================

// Q: were there differences in harvest decisions in communication periods?
// Note: drop last period (end game effects) 
gen chat = mod(period,2)
preserve
keep if type == 1
forvalues i = 1/3 {	
	display "Nonparametrics for harvest in chat and non-chat periods"
	display "rank sum test for treatment `i' " 
	qui ranksum h if treatment == `i' & period < 15 & inlist(chat, 1, 0), by(chat) 
	display "z-value = " r(z)
	display "p-value = " 2 * normprob(-abs(r(z)))
	display " "
}
restore

// Q: were there differences in sanctioning decisions in communication periods?
// Note: drop last period (end game effects) 
preserve
keep if type == 1
forvalues i = 1/3 {	
	display "Nonparametrics for sanctions on INSIDERS in chat and non-chat periods"
	display "rank sum test for treatment `i' " 
	qui ranksum s_a_insider  if treatment == `i' & period < 15 & inlist(chat, 1, 0), by(chat) 
	display "z-value = " r(z)
	display "p-value = " 2 * normprob(-abs(r(z)))
	display " "
	if `i' > 1 {
		display "Nonparametrics for sanctions on OUTSIDERS in chat and non-chat periods"
		display "rank sum test for treatment `i' " 
		qui ranksum s_a_outsider if treatment == `i' & period < 15 & inlist(chat, 1, 0), by(chat) 
		display "z-value = " r(z)
		display "p-value = " 2 * normprob(-abs(r(z)))
		display " "
	}
}
restore


// Visualize harvest and sanctions by chat periods
preserve
keep if type == 1
graph bar (mean) h, ///
	over(chat) over(treatment) asyvar ylabel(0(2)12,nogrid) ///
	subtitle("Average Harvest") ytitle("Harvest") legend(lab(1 "Non-communication periods") lab(2 "Communication periods") cols(2)) name(harvest, replace) nodraw
graph bar (mean) s_a_insider, ///
	over(chat) over(treatment) asyvar ylabel(0(1)3,nogrid) ///
	subtitle("Average Insider Sanctions") ytitle("Deduction points") name(s_in, replace) nodraw
graph bar (mean) s_a_outsider, /// 
	over(chat) over(treatment) asyvar ylabel(,nogrid) ///
	subtitle("Average Outsider Sanctions") ytitle("Deduction points") name(s_out, replace) nodraw
grc1leg harvest s_in s_out, cols(3)
restore	


// Q: is there a significant increase in insider sanctions in PM over time? 
preserve
keep if type == 1 & treatment == 2
ranksum s_a_insider if s_a_insider >0 & inlist(first,1,2), by(first)
ranksum s_a_outsider if s_a_outsider >0 & inlist(first,1,2), by(first)
restore



