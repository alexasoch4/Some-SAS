proc import datafile="/home/u59455388/Ass4/survival.csv" out=survival dbms=csv 
		replace;
run;

*#2;
*(a) plot radiation dosage versus the log of the survival rate;

proc import datafile="/home/u59455388/Ass4/survival.csv" out=survival dbms=csv 
		replace;
run;

data survivalnew;
	set survival;
	logsurvival=log(survival);
run;

proc sgplot data=survivalnew;
	scatter y=logsurvival x=dosage;
	title "Radiation Dosage vs the Log of Survival Rate";
	label logsurvival="log(Survival)";
	label dosage="Radiation Dosage";

proc reg data=survivalnew plots(only label)=(Residualplot residualbypredicted 
		QQPLOT);
	model logsurvival=dosage;
	run;
	*lecture 26 and 27
*(b) if you decided to use a linear model for regressing log of surival rate 
* with covariate dosage, would it be preferable to use OLS or WLS estimation. 
*Briefly explain;
	*EVIDENCE OF HETEROSKEDASTICITY.(IDK MAKING THIS UP)




*(c) Perform the appropriate estimation and state the fitted model. ;

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
	*(d) Plot and comment on the residuals versus fitted values.;
	*create weighted residual;

data survivalwt;
set survivalwt;
weightedres=res*sqrt(wt);
run;

proc sgplot data= survivalwt;
scatter x=fitted y=weightedres;
label weightedres="Weighted Residual";
label fitted="Fitted Value";
run;


*MUCH IMPROVED PLOT.

*LAB 10, LECTURE 29 AND 30;
*#3. Consider an experiment studying the effect of vitamin C
on tooth growth in guinea pigs. The recorded variables are: len, supp, dose.;

proc import datafile="/home/u59455388/Ass4/guineapigs.csv" out=guineapigs 
dbms=csv 
replace;
run;

data gp1;
set guineapigs;
if supp="VC" then supp1=0; else supp1=1;
*if supp = "OJ" then supp2 = 0;*else supp2 = 1;
run;

proc glm data=gp1;
class supp;
model len=dose supp dose*supp/solution;
run;

*(a) state full linear model with interactions using the variables provided;

proc glm data=gp1;
class supp;
model len=dose supp dose*supp/solution;
run;

proc glm data=gp1;
class supp;
model len=dose supp /solution;
run;

*same thing but proc reg?;

data gp2;
set gp1;
cross1=supp1 * dose;
*cross2=supp2 * dose;

proc reg data=gp2 plots=none;
model len=supp1 dose cross1 cross2;

*(b) give the corresponding fitted model from (a) using OLS estimation; *use info from part (a);

data gp1;
set guineapigs;
if supp="VC" then supp1=0; else supp1=1;
if supp = "OJ" then supp2 = 0; else supp2 = 1;
run;

proc glm data=gp1 alpha = 0.05;
class supp;
model len=dose supp dose*supp/solution;
run;


	
*y = 3.2950 + 11.7157x1 + 8.2550x2 -3.90428571x1x2 + eps;
*(c) Use an F test to determine whether the interaction is significant at the 5% level.;

proc glm data=gp1;
class supp;
model len=dose supp dose*supp/solution;
run;

	*under type iii error in proc glm, f value = 5.33, pvalue = 0.0246;
	*(d) How does the estimated effect of dosage on tooth growth compare betweeb delivery methods?;
	*not much, R^2 adjusted is slighlty higher;

data gp2;
set gp1;
cross=supp1 * dose;

*complete model;
proc reg data=gp2;
model len=dose supp1 cross;

*reduced model;
proc reg data=gp2;
model len=dose supp1;

*#4. ;

proc import datafile="/home/u59455388/Ass3/Q3outlierdataset.csv" out=dataset 
dbms=csv 
replace;
run;

*(a)Use forward selection to select covariates for your model with significance level
5% to select a model. Clearly state the final model. Please show only relevant output for each step;

Title "Forward Selection";
proc reg Data=dataset plot=none;
model y=x1 x2 x3 x4 x5 x6 /Selection=Forward SLentry=0.05;
run;



*(b)Use backward selection to select covariates for your model with significance level
5% to select a model. Clearly state the final model. Please show only relevant output for each step;

Title "Backward Selection";
proc reg Data=dataset plot=none;
model y=x1 x2 x3 x4 x5 x6 /Selection=Backward SLStay=0.05;
run;

*(c);

proc reg Data=dataset plots(only)=(Residualplot residualbypredicted QQplot);
model y=x4 x6; *model from (a);
run;
proc reg Data=dataset plots(only)=(partial);
model y=x4 x6/partial; 
run;

proc reg Data=dataset plots(only)=(Residualplot residualbypredicted QQplot);
model y=x1 x2 x3 x4; *model from (b);
run;
proc reg Data=dataset plots(only)=(partial);
model y=x1 x2 x3 x4/partial;
run;



	
	*(d)Perform variable selection using AIC and BIC, and compare the final models. 
Title "All Subset AIC BIC";

proc reg Data=dataset;
model y= x4 x6;
run;


proc reg Data=dataset plots=none OUTEST=MODELSELECTION;
model y=x1 x2 x3 x4 x5 x6 / Selection= CP AIC BIC;
run;

proc reg data = dataset plots = cp;
model  y=x1 x2 x3 x4 x5 x6 / Selection = CP best = 5;
run;

proc reg data = dataset plots = none;
model y=x1 x2 x3 x4 x5 x6 / Selection = AdjRsq best = 5;
run;

proc reg data = dataset plots = none;
model y = x4 x6;
run;


proc sort data=MODELSELECTION OUT=MODELSELECTION;
BY _AIC_;
run;

proc sort data=MODELSELECTION OUT=MODELSELECTION;
BY _BIC_;
run;