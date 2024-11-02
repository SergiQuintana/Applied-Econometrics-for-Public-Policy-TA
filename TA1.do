
		*==========================*
		* Econometrics III : TA 1  *
		*==========================*
		
		/* In this class we will learn how produce histograms and
		kernels with options and extensions*/
		
		
		// Import the data
		
		use acs_class, clear
		
		// The firts thing we should do is describe the data 
		
		describe
		
		// HISTOGRAM
		*************
		
		// We can do a histogram of the variable incwage with the command hist.
		
		hist incwage
		
		// The command hist allows for some options:
		
		hist incwage, bin(3)    // we can change the number of bins
		hist incwage, bin(100)
		
		hist incwage, width(4)      // We can change the width of the bins
		hist incwage, width(10000)  // We can change the width of the bins
		
		hist incwage, start(-2)    // we can also change the starting point
		
		// Notice that the option start does not allow for values greater than 
		// the smaller value of the variable.
		
		hist incwage,start(20)
		
		
		// Can we combine the options?
		
		hist incwage, bin(4) width(4)
		
		// There are other options that can be included :
		
		hist incwage, freq      // We can draw the frequency without normalizing
		hist incwage, percent   // Or the relative frequency
		
		hist incwage, addl   // We can include the height of the bar
		
		
		// Finally, related to next topic
		
		hist incwage, norm   // We can include a density estimate of a normalizing
		hist incwage, kdens  // or even the kernel
		
		
		hist incwage if incwage > 0  // It can be combined with if statements.
		
		// KERNEL
		*********
		
		// The main function to work with kernels is kdensity
		
		// Let's work with the log of wage, without 0s
		
		gen logwage = log(incwage)
		
		kdensity logwage
		
		// By default kdensity will use the epanechnikov kernel function, but it can be changed
		
		kdensity logwage, kernel(gaussian)
		
		// By default the kernel uses the optimal bandwidth, but we can change it
		
		kdensity logwage, bw(0.5)
		kdensity logwage, bw(1)
		kdensity logwage, bw(3)   // way too large bandwith
		
		
		kdensity logwage, bw(0.001)   // Too small bandwidth
		
		// Notice that if the bandwidth is not optimal, nothing can be done by changing the kernels
		
		kdensity logwage, bw(0.001) kernel(gaussian)
		kdensity logwage, bw(0.001) kernel(bi)
		kdensity logwage, bw(0.001) kernel(cos)
		kdensity logwage, bw(0.001) kernel(par)
		
		// We can also add a normal density for comparison purpses
		
		kdensity logwage, normal
		
		// We can include two densities in a graph
		
		twoway kdensity logwage if degfield == 62 || kdensity logwage if degfield == 21
		
		// Or perform many plots 
		
		twoway kdensity logwage, by(degfield)
		
		// We can also store the generated density into a new variable
		
		kdensity logwage, gen(x_axis y_axis)
		
		// the x_axis variable corresponds to the support of the distribution
		// the y_axis variable corresponds to the relative frequenci of the density. 
		
		// We can also use the multidensity package from ssc
		
		ssc install multidensity
		
		multidensity gen logwage, by(race)
		multidensity super, name(G1, replace)
		multidensity clear
		
		// BIVARIATE KERNEL
		********************
		
		// Sometimes we might want to represent two variables
		
		ssc install tddens
		
		// This package estimates a bivariate density using a symmetric triangle kerlen with bandwith given as proportion of sample range.
		
		tddens inctot incwage
		
		tddens inctot incwage, sgraph bgraph
		
		tddens inctot incwage, bw(0.1) sgraph bgraph  // we can also change the bandwidth
	
		// USING THE BIDENSITY PACKAGE
	
		ssc install bidensity
		
		// The result is a contourline plot
		
		preserve
		webuse grunfeld, clear
		gen linv = log(invest)
		lab var linv "Log[Investment]"
		gen lmkt = log(mvalue)
		lab var lmkt "Log[Mkt value]"
		bidensity linv lmkt
	
		
		// We can also include a scatter plot
		bidensity linv lmkt, scatter(msize(vsmall) mcolor(black)) colorlines levels(8) format(%3.2f)
		restore
		
		
		//////////////////////////////////////////////////////////////////////
		
		// Second Part: Bootstrap and Confidence Interval Estimation
		
		//////////////////////////////////////////////////////////////////////
		
		// BOOTSTRAP
		*************
		
		webuse auto, clear
		
		// Get the bootstrap standard error of the sample mean:
		
		summarize mpg
		
		help summarize

		bootstrap r(mean), reps(1000) seed(1234): summarize mpg , detail
		
		help bootstrap
		
		
		// Get the boostrap estimate of a regression coefficient
		
		reg price mpg
		
		
		bootstrap _b[mpg], reps(1000) seed(1234): reg price mpg
		
		// It is easier since reg command allows boostrap option!
		
		reg price mpg, vce(bootstrap (_b[mpg]),rep(1000) seed(1234))
		
		
		// We can even get a boostrap estimate of the standard errors: 
		// (In class!)
		* Use bootstrap to get the standard error of the standard deviation of the variable mpg. 
		
		
		* Use bootstrap to get the standard error of the standard error of a regression coefficient:

		
		// We can also bootstrap a build in program:
		program myratio, rclass
          version 17
          summarize length
          local length = r(mean)
          summarize turn
          local turn = r(mean)
          return scalar ratio = `length'/`turn'
		end
		
		bootstrap r(ratio), reps(100): myratio
		
		// Bootstrap can be used to compute a bias (not to confuse with the kernel bias):
		
		reg price mpg, vce(bootstrap (_b[mpg]),rep(100) seed(1234))
		
		estat bootstrap, all
		
		matrix list e(b_bs)  // bootstrap estimate of the E(hat(beta))
		
		// This is never used since the bootstrap estimate of the bias is very noisy. 
	
		// CONFIDENCE INTERVAL ESTIMATION
		**********************************
		
		// We will now use the package kdensity
		
		ssc install kdens
		
		kdens logwage  // The default option is like kdensity
		
		kdensity logwage
		
		
		// However notice the optimal bandwidth is different
		
		// BIAS CORRECTION
		*******************
		
		kdens logwage, ci
		
		kdens logwage, ci us
		
		
		kdens logwage, ci us bootstrap(100)
		
		///////////////////////////////
		// BIAS SIMULATION EXERCICE
		///////////////////////////////
		
		// We will now compute the bias of the kernel estimation, and show how it converges towards 0 as n increases.
		
capture program drop kernel_asymptotic_mc


program define kernel_asymptotic_mc
    version 15.1
    args n reps asymptotic
	
	// n -> number of observations
	// reps -> number of simulated samples
	
	capture drop *  // drop all generated variables

    // Generate data from a normal distribution with mean 0 and standard deviation 1
    set seed 123
	set obs `n'
	
	
	if `asymptotic' == 0 {
		
		forvalues r = 1(1)`reps'{
		
			capture drop sample_data density
			gen sample_data = rnormal(0,1)
				
			qui kdensity sample_data, nograph g(density gaussian_`r')  kernel(gaussian) n(100) //  optimal bw
		}		
		
		// Evaluate the normaldesity
		
		gen normal = normalden(density)
	
		// Compute the average of the density esimates (this is the estimated expected value)
		
		qui egen expected = rowmean(gaussian_*)
		
		
		// Compute the bias and plot
		
		gen bias = expected - normal
		graph twoway (line bias density)
			
		}
		
	
	// Option if the interest is on the asymptotic distribution
	if `asymptotic' == 1{
		
		forvalues r = 1(1)`reps'{
		
			capture drop sample_data density normal
			qui gen sample_data = rnormal(0,1)
				
			qui kdensity sample_data, nograph g(density gaussian_`r')  kernel(gaussian) n(100) //  optimal bw
			
			// Evaluate the normaldesity
		
			qui gen normal = normalden(density)
			
			local h = `r(bwidth)'
			qui gen asymptotic_`r' = sqrt(`n'*`h')*(gaussian_`r'- normal)
		}
	
		
		// Compute the average
		egen expected = rowmean(asymptotic_*)
	
		graph twoway (line expected density)
		
	}
	
end


kernel_asymptotic_mc 100000 100 1
		
		
		// But what happens with the asymptotic distribution? The bias there does not converge to 0!
		
		
		