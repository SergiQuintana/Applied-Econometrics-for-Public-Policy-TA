
cd "C:\Users\Sergi\Dropbox\PhD\Second Year\Econometrics III\Laura\TA4"

*******************************
// Basic qreg commands

help qreg

**************************
sysuse auto, clear

// qreg
qreg price weight length foreign
qreg price weight length foreign, vce(r)


// sqreg
sqreg price weight length foreign, q(.25 .5 .75)

// iqreg 
iqreg price weight length foreign, q(.25  .75)

//  bsqreg

bsqreg price weight length foreign

// Test for different effects across quantiles:
sqreg price weight length foreign, q(.25 .5 .75)
test[q25]weight = [q75]weight

// Confidence interval for the difference in quantiles:
lincom [q75]weight-[q25]weight

// We can also directly estimate quantile differences in Stata:
iqreg price weight length foreign, q(.25 .75)


*********************************************
// Fast algorithms for quantile regressions

net install qrprocess, from("https://raw.githubusercontent.com/bmelly/Stata/main/")

/* Benefits:

1- Faster.
2- Estimates the variance-ccovariance matrix analytically. 
3- Allows for weights and clustering. 
4- Plots coefficients

It has other advanced options. 
*/
qreg price weight length foreign

qrprocess price weight length foreign
qrprocess  // repeat the regressions

// Advanced variance-covariance estimation:
*variance with Hendricks and Koenker (1992) method and the Bofinger bandwidth

qrprocess price weight length foreign, quantile(.25) vce(nid, bofinger)


// Bootstraped standard errors:
qrprocess price weight length foreign, vce(boot)

// Kernel variance-covariance following Powell 1991
qrprocess price weight length foreign, vce(kernel)

// Multiple quantiles with bootstrapped standard errors:
qrprocess price weight length foreign, vce(boot) quantile(0.25 0.5 0.75)

// Bootstrap with subsample size
qrprocess price weight length foreign, vce(boot, bm(subsampling) subsize(50) reps(200))quantile(0.95)


use "http://www.stata.com/data/jwooldridge/eacsap/cps91" , clear

// Plot coefficients of quantile regressions: 
qrprocess lwage c.age# #c.age i.black i.hispanic educ, quantile(0.1(0.01)0.9) noprint
plotprocess


********************************
// PANEL DATA 
use panelexample,clear

egen newid = group(famper)

// Standard panel data to the mean
reg medexpend taxincome age 
reg medexpend taxincome age i.newid

// Or using reghdfe

reg medexpend taxincome age i.newid  // unfeasible
reghdfe medexpend taxincome, absorb(newid)


// IMPLEMENT Canay 2011: 

* We are interested in the effect of taxincome on medexpend, controlling for age and individual fixed effects. 

// STEP 1: 

reg medexpend taxincome age, r
predict res, res

* Compute the individual fixed effect as the average residual per individual

bys famper: egen fe = mean(res)

// STEP 2: 

gen ynew = medexpend - fe

qreg ynew taxincome age, q(0.5)


// Perform modifications
net install mdqr,from("https://raw.githubusercontent.com/bmelly/Stata/main/")

mdqr medexpend taxincome age, group(famper) q(0.5)