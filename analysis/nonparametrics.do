* =========================
*	1.1 Harvest
* =========================

* INSIDERS
** aggregate 
qui xtreg h i.treatment if type == 1, re cluster(group)
*** test // chi_sq, p-val
test 2.treatment 
test 3.treatment 
test 2.treatment = 3.treatment 
** first/second
qui xtreg h i.treatment i.first i.treatment#i.first if type == 1, re cluster(group)
*** test // chi_sq, p-val
test 2.first 
test 2.first + 2.treatment#2.first = 0 
test 2.first + 3.treatment#2.first = 0 

* OUTSIDERS
** aggregate 
xtreg h i.treatment if type == 2, re cluster(group)
*** test // chi_sq, p-val
test 2.treatment 
test 3.treatment 
test 2.treatment = 3.treatment 
** first/second
xtreg h i.treatment i.first i.treatment#i.first if type == 2, re cluster(group)
*** test // chi_sq, p-val
test 2.first 
test 2.first + 2.treatment#2.first = 0 
test 2.first + 3.treatment#2.first = 0 

**** compare partial second to zero and full second
test -2.treatment - 2.treatment#2.first = 0 
test 3.treatment + 3.treatment#2.first - 2.first - 2.treatment#2.first = 0 

* =========================
*	2. Sanctions
* =========================
* table of averages and standard deviations
collapse (mean) sv_mean = s_v (sd) s_v if mon==1, by(treatment type first)

* INSIDERS
** aggregate 
qui xtreg s_v i.treatment if type == 1, re cluster(group)
*** test // chi_sq, p-val
test 2.treatment 
test 3.treatment 
test 2.treatment = 3.treatment 
** first/second
xtreg s_v i.treatment i.first i.treatment#i.first if type == 1, re cluster(group)
*** test // chi_sq, p-val
test 2.first 
test 2.first + 2.treatment#2.first = 0 
test 2.first + 3.treatment#2.first = 0 

**** compare partial second to zero and full second
test -2.treatment - 2.treatment#2.first = 0 
test 3.treatment + 3.treatment#2.first - 2.first - 2.treatment#2.first = 0 


* OUTSIDERS
** aggregate 
qui xtreg s_v i.treatment if type == 2 & mon == 1, re cluster(group)
*** test // chi_sq, p-val
test 3.treatment 
** first/second
xtreg s_v i.treatment i.first i.treatment#i.first if type == 2 & mon==1, re cluster(group)
*** test // chi_sq, p-val
test 2.first 
test 2.first + 3.treatment#2.first = 0 

**** compare partial second to full second
test -3.treatment - 3.treatment#2.first = 0 


* INSIDERS AND OUTSIDERS
** aggregate 
xtreg s_v i.treatment i.type i.treatment#i.type if mon == 1, re cluster(group)
*** test // chi_sq, p-val
test 2.type 
test 2.type + 3.treatment#2.type = 0 

** aggregate 
xtreg s_v i.treatment i.type i.first i.treatment#i.type i.treatment#i.type#i.first if mon == 1, re cluster(group)

* ===========================
*	3.1 Efficiency: individual
* ===========================
use dp_data_eff, clear
collapse (mean) mei = ei mef = ef (sd) sd_ei = ei sd_ef = ef, by(treatment type)
* break down by group and send to R
collapse (mean) mef = ef if type == 1, by(group first)
save dp_insider_efficiency_groups.dta

* ===========================
*	3.2 Efficiency: group
* ===========================

use eff.group_means.dta, clear

collapse (mean) mef_2 = mef, by(treatment type)

* INSIDERS
** nonparametrics
*	across treatments
ranksum mef if type==1  & (treatment == 1 | treatment == 2), by(treatment) 
ranksum mef if type==1  & (treatment == 1 | treatment == 3), by(treatment) 
ranksum mef if type==1  & (treatment == 2 | treatment == 3), by(treatment) 

ranksum mef if type==1  & treatment == 1  & (first == 1 | first == 2), by(first) 

ranksum mef if type==1 & first == 1  & (treatment == 1 | treatment == 2), by(treatment) 
ranksum mef if type==1 & first == 2  & (treatment == 1 | treatment == 2), by(treatment) 


* regression
reg mef i.treatment if type == 1, robust
*** test // chi_sq, p-val
test 2.treatment 
test 3.treatment 
test 2.treatment = 3.treatment 


* OUTSIDERS
** nonparametrics
*	across treatments
ranksum mef if type==2  & (treatment == 1 | treatment == 2), by(treatment) 
ranksum mef if type==2  & (treatment == 1 | treatment == 3), by(treatment) 
ranksum mef if type==2  & (treatment == 2 | treatment == 3), by(treatment) 

ranksum mei if type==2  & (treatment == 1 | treatment == 2), by(treatment) 
ranksum mei if type==2  & (treatment == 1 | treatment == 3), by(treatment)  
ranksum mei if type==2  & (treatment == 2 | treatment == 3), by(treatment) 0

* regression
reg mef i.treatment if type == 2, robust
*** test // chi_sq, p-val
test 2.treatment 
test 3.treatment 
test 2.treatment = 3.treatment 


