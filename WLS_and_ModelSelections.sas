*Part 1 - WLS (weighted least squares).
*Part 2 - interaction term and testing its significance.
*Part 3 - comparing Forward and Backward selection.


*Part 1;
proc import datafile="/home/u59455388/Ass4/survival.csv" 
out=survival 
dbms=csv 
replace;
run;

*Plotting radiation dosage versus the log of the survival rate;

data survivalnew;
set survival;
logsurvival=log(survival);
run;

proc sgplot data=survivalnew;
scatter y=logsurvival x=dosage;
title "Radiation Dosage vs the Log of Survival Rate";
label logsurvival="log(Survival)";
label dosage="Radiation Dosage";

proc reg data=survivalnew plots(only label)=(Residualplot residualbypredicted QQPLOT);
model logsurvival=dosage;
run;

*EVIDENCE OF HETEROSKEDASTICITY so want to use weighted least squares.

proc means data=survivalnew VAR;
var logsurvival;
by dosage;
run;

data survivalwt;
set survivalnew;
if dosage=100 then wt=1/0.0273207;
else if dosage=200 then wt=1/0.0156047;
else if dosage=300 then wt=1/1.4898599;
else if dosage=400 then wt=1/0.0665855;
else if dosage=500 then wt=1/1.2089769;
else wt=1/0.0068193;
run;

proc reg data=survivalwt;
model logsurvival=dosage;
weight wt;
output out= survivalwt
residual=res 
predicted=fitted;
run;

data survivalwt;
set survivalwt;
weightedres=res*sqrt(wt);
run;

proc sgplot data= survivalwt;
scatter x=fitted y=weightedres;
label weightedres="Weighted Residual";
label fitted="Fitted Value";
run;
*Plots improved compared to OLS estimation.

*Part 2;
*Consider an experiment studying the effect of vitamin C
on tooth growth in guinea pigs. The recorded variables are: len, supp, dose.;

proc import datafile="/home/u59455388/Ass4/guineapigs.csv" out=guineapigs 
dbms=csv 
replace;
run;

data gp1;
set guineapigs;
if supp="VC" then supp1=0; else supp1=1;
run;

*finding full linear model with interaction term;
proc glm data=gp1;
class supp;
model len=dose supp dose*supp/solution;
run;

*without interaction term;
proc glm data=gp1 alpha = 0.05;
class supp;
model len=dose supp /solution;
run;

*same thing but proc reg;
data gp2;
set gp1;
cross1=supp1 * dose;

proc reg data=gp2 plots=none;
model len=supp1 dose cross1;
	
*y = 3.2950 + 11.7157x1 + 8.2550x2 -3.90428571x1x2 + eps;
*Want to  use an F test to determine the significance of the interaction term at the 5%.;

proc glm data=gp1;
class supp;
model len=dose supp dose*supp/solution;
run;
*under type iii error in proc glm f value = 5.33 and pvalue = 0.0246. Since pvalue < 0.05, interaction term is statistically significant.;

*Part 3.;
proc import datafile="/home/u59455388/Ass3/Q3outlierdataset.csv" 
out=dataset 
dbms=csv 
replace;
run;

*Want to use forward selection to select covariates with significance level 5%;

Title "Forward Selection";
proc reg Data=dataset plot=none;
model y=x1 x2 x3 x4 x5 x6 /Selection=Forward SLentry=0.05;
run;

*Want to use backward selection to select covariates with significance level 5%;

Title "Backward Selection";
proc reg Data=dataset plot=none;
model y=x1 x2 x3 x4 x5 x6 /Selection=Backward SLStay=0.05;
run;

*Diagnostic plots for forward and backward selection. Checking for any model violation.

proc reg Data=dataset plots(only)=(Residualplot residualbypredicted QQplot);
model y=x4 x6;
run;
proc reg Data=dataset plots(only)=(partial);
model y=x4 x6/partial; 
run;

proc reg Data=dataset plots(only)=(Residualplot residualbypredicted QQplot);
model y=x1 x2 x3 x4;
run;
proc reg Data=dataset plots(only)=(partial);
model y=x1 x2 x3 x4/partial;
run;

*(d)Selection using AIC and BIC. 

proc reg Data=dataset plots=none OUTEST=MODELSELECTION;
model y=x1 x2 x3 x4 x5 x6 / Selection= CP AIC BIC;
run;

proc sort data=MODELSELECTION OUT=MODELSELECTION;
BY _AIC_;
run;

proc sort data=MODELSELECTION OUT=MODELSELECTION;
BY _BIC_;
run;
