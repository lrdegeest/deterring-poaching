// load programs
clear
program drop _all
do "/Users/LawrenceDeGeest/Desktop/notebook/research/dissertation/first_paper/deterring-poaching/analysis/spline_programs.do"

// run and plot insider spline
setup
estimate_insider_spline
plot_insider_spline
* inference
** test differences in knots
test _b[k1:_cons] = _b[k2:_cons] // p = 0.04, ZM > PM
test _b[k1:_cons] = _b[k3:_cons] // p = 0.02, ZM > FM
test _b[k2:_cons] = _b[k3:_cons] // p = 0.85
** test differences in slopes
test _b[b2:_cons] = _b[b4:_cons] // p = 0.01, ZM > PM
test _b[b2:_cons] = _b[b6:_cons] // p = 0.00, ZM > FM
test _b[b4:_cons] = _b[b6:_cons] // p = 0.43

// run and plot outsider spline
setup
estimate_outsider_spline
plot_outsider_spline
// test differences in knots
test _b[k2:_cons] = _b[k3:_cons] // p = 0.46
// test differences in slopes
test _b[b4:_cons] = _b[b6:_cons] // p = 0.00, FM > PM

// plot
plot_joint_spline
graph export spline.pdf, replace

// updated outsider spline
use partial_out, clear
merge subject using full_out
gen s_hat2_all = cond(h2>0,(1/3)*s_hat2,s_hat2)
tw	(line s_hat2 h2, lp(_) sort) ///
	(line s_hat2_all h2, lp(.) sort) ///
	(line s_hat3 h3, lp(l) sort), ///
	xlab(0(4)12) ///
	xtitle("Poaching") ytitle(" ") ///
	legend(ring(0) pos(11) cols(1) lab(1 "Partial (monitored)") lab(2 "Partial (all)") lab(3 "Full")) ///
	subtitle("{bf:Outsiders}") name(splinesOut, replace) 
