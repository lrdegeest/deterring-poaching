cd "/Users/LawrenceDeGeest/Documents/DE_analysis_15/analysis/data"
insheet using "rawdata.csv", clear

*===============================================================================
* create, rename, label
*===============================================================================
//encode and label treatments
rename treatment treatment_string
label def treatment_label 1 "ZERO" 2 "PARTIAL" 3 "FULL" 
encode treatment_string, gen(treatment) lab(treatment_label)
drop treatment_string

// label subject types
label def type_label 1 "insider" 2 "outsider", modify
label values type type_label

// create unique subjects and groups
gen uniquesubject = (treatment * 1000) + (group * 100) + subject
gen uniquegroup = (treatment * 10) + group
drop subject group
rename uniquesubject subject
rename uniquegroup group

//convert typep to monitoring dummy
gen mon = 1 if typep == "1"
replace mon = 0 if mon == .

// rename payoffs
rename profit fp
rename totalprofit cp
rename profit1_public_total shp
rename profit1_private pp
rename profit1_public hp
rename fixed transfer
rename profit1 ip
// rename harvest
rename investment h
rename suminvestment group_h
rename suminvestmentgroup1 in_h
rename suminvestmentgroup2 out_h
// sanctions
rename assigned s_a
rename receivedpoints s
rename received s_v
rename reduction s_l

//calculate group norms
// g_norm: mean harvest of the entire group
// other_g_norm: mean harvest of the group not including the subject
foreach var in subject{
	egen th = total(h), by(group period)
	egen th_i = total(h), by(subject period)
	gen n = 8
	gen g_norm = th / n
	gen other_g_norm = (th - th_i) / ((n - 1))
	drop th th_i n
}

//add labels
label data "Experiment data for working paper by De Geest, Stranlund & Spraggon. March 2015."
label variable treatment "Zero, Partial and Full"
label variable type "Insider or Outsider"
label variable period "Period"
label variable subject "Unique subject (Treatment [1-3], Group [1-4], Subject [1-8])"
label variable group "Unique group (Treatment [1-3], Group [1-4])"
label variable h "Harvest"
label variable group_h "Total group harvest, including subject"
label variable in_h "Insider harvest"
label variable out_h "Outsider harvest"
label variable fp "Initial payoff net of sanctions"
label variable cp "Cumulative payoff"
label variable shp "Group harvest payoff"
label variable ip "Payoff from harvest and private investment"
label variable fp "Constant transfer in the payoff function"
label variable pp "Payoff from private investment"
label variable hp "Payoff from harvest"
label variable mon "Dummy describing whether the subject was monitored, mostly applies to outsiders in Partial"
label variable s_a "Sanctions (Points) Assigned"
label variable s "Sanctions (Points) Received"
label variable s_v "Sanctions (Value: Points*3) Received"
label variable s_l "Value of sanctions assigned and received"
label variable other_g_norm "Average harvest not including the subject"
label variable g_norm "Average harvest including the subject"

*===============================================================================
* lags
*===============================================================================

// describe the panel to stata
// since the panel variable is "uniquesubject", the "fe" and "re" commands apply at the subject level
tsset subject period

// generate lagged sanctions
gen ls = l.s
label var ls "Sanctions received in {it:t}"
// generate change in harvest from t to t+1
gen lh = l.h
gen deltah = h - lh
label var deltah "{&Delta} harvest (h{sub:t+1} - h{sub:t})"
drop lh

// generate lagged deviations
// first need to reset the panel 
tsset subject period
//deviations from other group norm
gen dev = h - other_g_norm
gen ldev = l.dev
//deviations from group norm
label var ldev "Deviation from the group norm in {it:t}"

// generate an indicator variable for Over and Under harvesters (over: deviation from the group mean is positive, as in, the subject harvested above the group mean in that period)
gen OverUnder = 1 if dev > 0
replace OverUnder = 0 if OverUnder == .
label values OverUnder OverUnder
gen lOverUnder = l.OverUnder
label values lOverUnder OverUnder

// first-half and second-half indicator. First: peridos 1-7. Second: periods 8-15. 
gen first = 1 if period < 8
replace first = 2 if first == .
label values first first 

// convert all mon=0 to mon=1 in full monitoring
replace mon=1 if treatment == 3

*===============================================================================
* order and save
*===============================================================================
// profit2 is the same as profit
drop profit2
order treatment subject group type group1_id group2_id period first
order fp cp, last

save dp_data, replace
