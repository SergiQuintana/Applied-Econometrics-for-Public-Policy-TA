*================
* TA Session 3
*================



*====================
* Series Regression
*====================

* Back to citations data!


use "https://www.stata-press.com/data/r17/dui", clear

npregress series citations fines

* Analyze created variables:
describe *_*, fullnames

* We can modify the names:

qui: npregress series citations fines, basis(basis)
describe basis*, fullnames


// We can include more than one regressor

npregress series citations fines i.csize i.college

// We can copmute effects:

margins, at(fines=(8 9 10 11))
marginsplot

* We can also compute contrast test:

margins, at(fines=(8 9 10 11)) contrast(atcontrast(ar._at) nowald effects)
marginsplot

// Estimate the effect of increasing fines at different juridiction sizes

margins csize, dydx(fines)
marginsplot

* And at different levels of fines:

margins csize, at(fines=(8(1)11))
marginsplot

*********************************************
// Until now we have used the default values 

npregress series citations fines
predict cmean
graph twoway (scatter citations fines) (scatter cmean fines)

* Visualize the polynomial
npregress series citations fines, polynomial(3)
margins, at(fines=(7.5(.05)12))
marginsplot, noci plotopts(msymbol(none)) addplot(scatter citations fines)



npregress series citations fines, spline
predict cmean_spline
graph twoway (scatter citations fines) (scatter cmean_spline fines)
margins, at(fines=(8(.25)12)) plot 


// We can manually set the number of knots

npregress series citations fines, spline knots(10)
margins, at(fines=(8(.25)12)) plot 

// We can change the order of the spline polynomial
_pctile fines, percentiles(25 50 75)
local p25 =  r(r1)
local p50 =  r(r2)
local p75 = r(r3)

npregress series citations fines, spline(1) knots(1)
margins, at(fines=(8(.25)12))
marginsplot, xline(`p50')


*twoway  (kdensity fines ,xline(`p25' `p50' `p75'))
npregress series citations fines, spline(1) knots(3)
margins, at(fines=(8(.25)12)) 
marginsplot, xline(`p25' `p50' `p75')



// Try to see the shape:
npregress series citations fines, spline(1) knots(5)
margins, at(fines=(7.5(.05)12))
marginsplot, noci plotopts(msymbol(none)) addplot(scatter citations fines)

* Increase the order of the polynomial
npregress series citations fines, spline(3) knots(5)
margins, at(fines=(7.5(.05)12))
marginsplot, noci plotopts(msymbol(none)) addplot(scatter citations fines)



* Introduce many knots with degreee 1
npregress series citations fines, spline(1) knots(50)
margins, at(fines=(7.5(.05)12))
marginsplot, noci plotopts(msymbol(none)) addplot(scatter citations fines)


// We can also introduce other covariates

cd "C:\Users\Sergi\Dropbox\PhD\Second Year\Econometrics III\Laura\TA3"
use data1, clear

npregress series earnings exp asvab_mean

// We can introduce restrictions to the model we are estimating; 

npregress series earnings exp asvab_mean, nointeract(exp)

npregress series earnings exp asvab_mean s, nointeract(s asvab_mean)

npregress series earnings exp asvab_mean , asis(s)  // this becomes semi-parametric
margins, at(asvab_mean=(29.75(1)63))
marginsplot, noci plotopts(msymbol(none)) addplot(scatter earnings asvab_mean)

********************************************************************************
********************************************************************************

* ============================
* Semi-Parametric Estimatoin
* ============================

semipar earnings exp, nonpar(asvab_mean)
semipar earnings asvab_mean, nonpar(exp)

npregress series earnings exp, asis(asvab_mean)


*********
* Simulation example:

 clear // warning, this command removes data from memory
 set seed 1234
 set obs 1000
 drawnorm x1-x3 e
 replace x2=x2+50
 replace x1=x1+10
 gen y=40+5*x1+x2+x3+x3^2+e

 
 semipar y x1 x2, nonpar(x3) gen(semiparfit) degree(4)
 npregress series y x3, asis(x1 x2) // For Stata 16 and above
 margins, at(x3=(-2.5(0.1)3.5)) nose post // For Stata 16 and above
 marginsplot, plotopts(msymbol(none)) addplot(line semiparfit  x3, sort legend(rows(1) order(2 "npregress" 3 "semipar"))) title(Predictive margins)

// Perform Robinson's manually:

use data1, clear


// Single Index Model

* package sls
* Applies semiparametric single index regression from Ichumura 1993. 

sysuse auto, clear
sls mpg weight length displacement
predict mpghat, ey
predict Index , xb
twoway (scatter mpg Index) (line mpghat Index , sort) , xtitle("Index") ytitle("MPG") legend(label(1 "Actual") label(2 "Predicted"))



