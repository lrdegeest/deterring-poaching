* ==========================================================
* DATA
* ==========================================================

cd "/Users/LawrenceDeGeest/Desktop/notebook/research/dissertation/first_paper/analysis/data"
use dp_data, clear

* ==========================================================
* update 20 July
* regressions instead of nonparametrics
* test differences between coefficients to test differences between treatments
* control for random effects at the subject level and cluster standard errors by group
* ==========================================================

* =========================
*	1.1 Harvest
* =========================

* INSIDERS
** aggregate 
qui xtreg h i.treatment if type == 1, re cluster(group)
*** test // chi_sq, p-val
test 2.treatment // 0.00, 0.99
test 3.treatment // 0.67, 0.41
test 2.treatment = 3.treatment // 1.26, 0.26
** first/second
qui xtreg h i.treatment i.first i.treatment#i.first if type == 1, re cluster(group)
*** test // chi_sq, p-val
test 2.first // 9.62, 0.00
test 2.first + 2.treatment#2.first = 0 // 0.23, 0.63
test 2.first + 3.treatment#2.first = 0 // 2.34, 0.13

* OUTSIDERS
** aggregate 
xtreg h i.treatment if type == 2, re cluster(group)
*** test // chi_sq, p-val
test 2.treatment // 1.85, 0.18
test 3.treatment // 1.21, 0.27
test 2.treatment = 3.treatment // 12.07, 0.00
** first/second
xtreg h i.treatment i.first i.treatment#i.first if type == 2, re cluster(group)
*** test // chi_sq, p-val
test 2.first // 1.94, 0.16
test 2.first + 2.treatment#2.first = 0 // 12.73, 0.00
test 2.first + 3.treatment#2.first = 0 // 0.18, 0.67

**** compare partial second to zero and full second
test -2.treatment - 2.treatment#2.first = 0 // 4.00, 0.0454
test 3.treatment + 3.treatment#2.first - 2.first - 2.treatment#2.first = 0 // 13.65, 0.00


* =========================
*	1.2 Harvest
* =========================

use BestResponse2.dta, clear


* =========================
*	2. Sanctions
* =========================
* table of averages and standard deviations
collapse (mean) sv_mean = s_v (sd) s_v if mon==1, by(treatment type first)

* INSIDERS
** aggregate 
qui xtreg s_v i.treatment if type == 1, re cluster(group)
*** test // chi_sq, p-val
test 2.treatment // 0.19, 0.6644
test 3.treatment // 0.38, 0.5386
test 2.treatment = 3.treatment // 0.96, 0.3274
** first/second
xtreg s_v i.treatment i.first i.treatment#i.first if type == 1, re cluster(group)
*** test // chi_sq, p-val
test 2.first //  1.53, 0.2165
test 2.first + 2.treatment#2.first = 0 //  0.83, 0.3631
test 2.first + 3.treatment#2.first = 0 // 4.56, 0.0327

**** compare partial second to zero and full second
test -2.treatment - 2.treatment#2.first = 0 // 1.17, 0.282
test 3.treatment + 3.treatment#2.first - 2.first - 2.treatment#2.first = 0 // 0.78, 0.3767


* OUTSIDERS
** aggregate 
qui xtreg s_v i.treatment if type == 2 & mon == 1, re cluster(group)
*** test // chi_sq, p-val
test 3.treatment // 1.31, 0.253
** first/second
xtreg s_v i.treatment i.first i.treatment#i.first if type == 2 & mon==1, re cluster(group)
*** test // chi_sq, p-val
test 2.first // 0.41, 0.52
test 2.first + 3.treatment#2.first = 0 // 1.50, 0.22

**** compare partial second to full second
test -3.treatment - 3.treatment#2.first = 0 // 0.95, 0.3292


* INSIDERS AND OUTSIDERS
** aggregate 
xtreg s_v i.treatment i.type i.treatment#i.type if mon == 1, re cluster(group)
*** test // chi_sq, p-val
test 2.type // 6.60, 0.0102
test 2.type + 3.treatment#2.type = 0 //  3.80, 0.0511

** aggregate 
xtreg s_v i.treatment i.type i.first i.treatment#i.type i.treatment#i.type#i.first if mon == 1, re cluster(group)
*** test // chi_sq, p-val



* ===========================
*	3. Efficiency: individual
*		all this is wrong. eff is a group measure
* ===========================

use dp_data_eff, clear
xtset subject period

* sanity check: same as table in paper - but need to update sd's
collapse (mean) mei = ei mef = ef (sd) sd_ei = ei sd_ef = ef, by(treatment type)


* INSIDERS
** aggregate 
xtreg ef i.treatment if type == 1, re cluster(group)
*** test // chi_sq, p-val
test 2.treatment //  1.32, 0.2498
test 3.treatment // 0.93, 0.3349
test 2.treatment = 3.treatment // 7.19, 0.0073
** first/second
xtreg ef i.treatment i.first i.treatment#i.first if type == 1, re cluster(group)
*** test // chi_sq, p-val
test 2.first //  1.27, 0.2595
test 2.first + 2.treatment#2.first = 0 // 2.06, 0.1508
test 2.first + 3.treatment#2.first = 0 // 0.00, 0.9563

**** compare partial first to zero and full first
test 2.treatment // 0.04, 0.8363
test 2.treatment+3.treatment = 0 // 0.15, 0.6946

**** compare partial second to zero and full second
test 2.treatment + 2.treatment#2.first = 0 // 3.45, 0.0633
test 3.treatment + 3.treatment#2.first - 2.first - 2.treatment#2.first = 0 // 2.67,  0.1025


* what is going on with PM insiders? break down by group and send to R
collapse (mean) mef = ef if type == 1, by(group first)
save dp_insider_efficiency_groups.dta

* OUTSIDERS
** aggregate 
xtreg ef i.treatment if type == 2, re cluster(group)
*** test // chi_sq, p-val
test 2.treatment //  1.83,  0.1759
test 3.treatment //  2.19, 0.1388
test 2.treatment = 3.treatment // 0.06, 0.8120
** first/second
xtreg ef i.treatment i.first i.treatment#i.first if type == 2, re cluster(group)
*** test // chi_sq, p-val
test 2.first // 38.46, 0.0000
test 2.first + 2.treatment#2.first = 0 // 0.38, 0.5367
test 2.first + 3.treatment#2.first = 0 // 2.77, 0.0961

**** compare partial first to zero and full first
test 2.treatment // 0.00, 0.9893
test 2.treatment+3.treatment = 0 // 0.28, 0.5968


**** compare partial second to zero and full second
test 2.treatment + 2.treatment#2.first = 0 // 5.22,  0.0223
test 3.treatment + 3.treatment#2.first - 2.first - 2.treatment#2.first = 0 // 3.98, 0.0461

* ===========================
*	3. Efficiency: group
* ===========================

use eff.group_means.dta, clear

* sanity check - same as table in paper
collapse (mean) mef_2 = mef, by(treatment type)

* INSIDERS
** nonparametrics
*	across treatments
ranksum mef if type==1  & (treatment == 1 | treatment == 2), by(treatment) // ZM > PM, p = 0.0107
ranksum mef if type==1  & (treatment == 1 | treatment == 3), by(treatment) // FM > ZM, p = 0.0564 
ranksum mef if type==1  & (treatment == 2 | treatment == 3), by(treatment) // FM > PM, p = 0.0000

ranksum mef if type==1  & treatment == 1  & (first == 1 | first == 2), by(first) // 0.4108

ranksum mef if type==1 & first == 1  & (treatment == 1 | treatment == 2), by(treatment) // 0.74
ranksum mef if type==1 & first == 2  & (treatment == 1 | treatment == 2), by(treatment) // 0.74


* regression
reg mef i.treatment if type == 1, robust
*** test // chi_sq, p-val
test 2.treatment //  8.33, 0.0044
test 3.treatment // 6.95, 0.0091
test 2.treatment = 3.treatment // 32.46, 0.0000


* OUTSIDERS
** nonparametrics
*	across treatments
ranksum mef if type==2  & (treatment == 1 | treatment == 2), by(treatment) // ZM > PM, p = 0.0613
ranksum mef if type==2  & (treatment == 1 | treatment == 3), by(treatment) // ZM > FM, p = 0.0250 
ranksum mef if type==2  & (treatment == 2 | treatment == 3), by(treatment) // PM > FM, p = 0.7409

ranksum mei if type==2  & (treatment == 1 | treatment == 2), by(treatment) // PM > ZM, p = 0.7468
ranksum mei if type==2  & (treatment == 1 | treatment == 3), by(treatment) // FM > ZM, p = 0.0238 
ranksum mei if type==2  & (treatment == 2 | treatment == 3), by(treatment) // FM > PM, p = 0.0550

* regression
reg mef i.treatment if type == 2, robust
*** test // chi_sq, p-val
test 2.treatment //  6.77, 0.0100
test 3.treatment // 7.28, 0.0076
test 2.treatment = 3.treatment // 0.21, 0.6455


