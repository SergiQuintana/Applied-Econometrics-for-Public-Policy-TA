	*===============================*
	* ECONOMETRICS 3
	*
	


// Using lpoly: 

use "https://www.stata-press.com/data/r17/motorcycle",clear

lpoly accel time, degree(3)
lpoly accel time, degree(3) kernel(epan2)

graph twoway (lpoly accel time) (lfit accel time)

// Choice of bandwidth

lpoly accel time, degree(1) kernel(epan2) bwidth(1) generate(at smooth1) nograph
lpoly accel time, degree(1) kernel(epan2) bwidth(7) at(at) generate(smooth2)nograph
label variable smooth1 "smooth: width = 1"
label variable smooth2 "smooth: width = 7"
lpoly accel time, degree(1) kernel(epan2) at(at) addplot(line smooth* at) legend(label(2 "smooth: width = 3.42 (ROT)")) note("kernel = epan2, degree = 1")


// Confidence bands:

lpoly accel time, degree(3) kernel(epan2) ci

*============
* NPREGRESS
*============

// Import data


use "https://www.stata-press.com/data/r17/dui", clear


* Estimate a kernel local-linear model
npregress kernel citations fines

describe *_*, fullnames

* Estimate a kernel local-constant model
npregress kernel citations fines, estimator(constant)


// We can change the bandwidth for the mean or for the derivatives

// bw -> 2 for each indepvar
// meanbwidth -> 1 for each indepvar
// derivbwidth -> 1 for each indepvar


npregress kernel citations fines,derivbwidth(0.003,copy)

npregress kernel citations fines i.college, meanbwidth (0.1 0.2,copy)

// We can identify observations violating the identification assumption!


// We can supress the derivative estimate

npregress kernel citations fines, noderivatives


// Bootstrapping Standard Errors
*********************************
npregress kernel citations fines, reps(100) seed(12)

// We can change the bw at each bootstrap replication

npregress kernel citations fines, reps(100) seed(12) bwreplace




// We can predict the mean and the derivative;
npregress kernel citations fines, predict(mean deriv)

describe mean deriv

// Effect of a percentage change in a covariate:
************************************************
* We can't just multiply the coefficient by 1.15 since the effect might be different at each xi. 

npregress kernel citations fines i.taxes i.csize i.college, nolog
margins, at(fines=generate(fines*1.15)) reps(100) seed(12)


// Contrast changes:
margins, at(fines=generate(fines)) at(fines=generate(fines*1.15)) contrast(atcontrast(r) nowald) reps(50) seed(12)
* This will estimate the difference in means


// Effect of a change in level:
********************************
* Increase fines from $10000 to $11000
margins, at(fines=10 taxes=1 csize=2 college=1) at(fines=11 taxes=1 csize=2 college=1) reps(50) seed(12)

* Use contrast to estimate the difference in means: 

margins, at(fines=10 taxes=1 csize=2 college=1) at(fines=11 taxes=1 csize=2 college=1)contrast(atcontrast(r) nowald) reps(50) seed(12)

// Population-averaged covariate effects:
*****************************************
* estimate population-averaged means instead of means at specific levels of all covariates.
margins, at(fines=10) at(fines=11) reps(20) seed(12)
margins, at(fines=10) at(fines=11) contrast(atcontrast(r) nowald) reps(20) seed(12)

* estimate the effect of taxing alcholic beverages.
margins taxes, reps(20) seed(12)
margins r.taxes, reps(20) seed(12)  // similar to contrast, where r. is the reference category


// Pos Estimation Visualization:
*********************************
npregress kernel citations fines, reps(10) seed(12)
npgraph   // This will plot the conditional mean. 

npregress kernel citations fines i.taxes i.csize i.college, nolog

margins, at(fines=(8(0.5)12) taxes=1 csize=2 college=1) reps(20) seed(12)

marginsplot

* for contrasts:

margins, at(fines=(8(0.5)12) taxes=1 csize=2 college=1) contrast(atcontrast(ar)) reps(10) seed(12)

marginsplot, yline(0)

margins, at(fines=(8(0.5)12) taxes=1 csize=2 college=1) contrast(atcontrast(r)) reps(10) seed(12)

marginsplot, yline(0)

* margis at a discrete variable
npregress kernel citations fines i.taxes i.csize i.college, nolog
margins college, at(fines=(8(0.5)12) taxes=1 csize=2) reps(10)
marginsplot

/* IN CLASS EXERCICE:
The dataset that we will use includes three covariates—continuous variables x1 and x2 and categorical variable a with three levels.
*/

use "http://www.stata.com/users/kmacdonald/blog/npblog", clear

// Fit the model:
npregress kernel y x1 x2 i.a, vce(boot, rep(10) seed(111))

// Predict the value of y at  when a=1, x1=2, and x2=5:

margins 1.a, at(x1=2 x2=5) reps(10)

// Moving from 1 to 2
margins r(1 2).a, at(x1=2 x2=5) reps(10)

//  Range of x1
margins a, at(x1=(1(1)4) x2=5) reps(10)
marginsplot

// Interval for x2:
margins a, at(x1=(1(1)4) x2=(2 5 8)) reps(10)
marginsplot, bydimension(x2) byopts(cols(3))


// Moving from a=1 to a=3:
margins r.a, at(x1=(1(1)4) x2=(2 5 8)) reps(10)
marginsplot, bydimension(x2) byopts(cols(3)) yline(0)


