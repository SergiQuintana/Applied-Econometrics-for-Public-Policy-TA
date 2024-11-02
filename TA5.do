******************

/* To implement nonlinear panel models we will use xtlogit. It allows for:

-> re option
-> fe option
-> pa option (pooled)
*/ 


// DATA:

// Randomly assigned families to different health insurances. 

use mus18data, clear

describe dmdu med mdu lcoins ndisease female age lfam child id year

summarize dmdu med mdu lcoins ndisease female age lfam child id year

* dmudu -> individual has visited the doctor this year.

// First we need to declare the panel structure of the data:

xtset id year

xtdescribe

// The panel is unbalanced


// QUANTIFY WITHIN VS BETWEEN VARIATION

xtsum age lfam child

// Since the FE rely on within variation, they might not be very efficient.


// Pooled logit estimator:

logit dmdu lcoins ndisease female age lfam child, vce(cluster id) nolog

// Assumes independence over i and t. xtlogit accomodates the panel complications.


// PA MODEL:

xtlogit dmdu lcoins ndisease female age lfam child, pa corr(exch) vce(robust)

// We allow for correlation on the error term. 

// RE Logit 

xtlogit dmdu lcoins ndisease female age lfam child, re

// The RE has a different conditoinal mean than the PA so results are not comparable. 

// FE logit

// Time invariant coefficients will not be identified. 

xtlogit dmdu lcoins ndisease female age lfam child, fe

* we drop all observations where there is no variation in y. 

//*************
// Comparison table 

global xlist  lcoins ndisease female age lfam child

quietly logit dmdu $xlist, vce(cluster id)
est store POOLED
quietly xtlogit dmdu $xlist, pa corr(exch) vce(robust)
est store PA
quietly xtlogit dmdu $xlist, re
est store RE
quietly xtlogit dmdu $xlist, fe
est store FE

est table POOLED PA RE FE, equations(1) se b(%8.4f) stats(N ll) stfmt(%8.0f)