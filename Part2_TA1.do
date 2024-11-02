***********
// bacon decomp


 use "http://pped.org/bacon_example.dta", clear
 xtset stfips year
 
 xtreg asmrs post pcinc asmrh cases i.year, fe robust

bacondecomp asmrs post pcinc asmrh cases, stub(Bacon_) robust

bacondecomp asmrs post pcinc asmrh cases, ddetail


// did_imputation



