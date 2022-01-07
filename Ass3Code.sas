*Q2.;
proc import datafile = "/home/u59455388/Ass3/trees.csv"
out = trees
dbms = csv 
replace 
;
run;

*trees contains records of the volume (cubic feet), the diameter 
in feet, and the height in feet of 38 cherry blossom trees;

*(a) State the linear model without transformations relating volume (y)
to the other two variables (x1 and x2). Be sure to define any x variables that are introduced.;


*(b) Estimate the model and use the appropriate diagnostic plots to check if
any model assumptions appear to be violated. Be sure to comment on implications
from each plot.;

proc reg data=trees plots = none;
model volume = height diameter;
run;

Title "Model 1";
proc reg data = trees plots(only)=(Residualplot residualbypredicted QQplot);
model volume = height diameter;

Title "Model 1";
proc reg data = trees plots(only)=partial;
model volume = height diameter/partial;





proc reg data=trees plots = none;
model volume = height diameter;
run;

*diagnostic plots;
Title "Model 1 with residual plots";
proc reg data = trees plots(only)=(Residualplot);
model volume = height diameter;

Title "Model 1 with partial plots";
proc reg data = trees plots(only)=partial;
model volume = height diameter/partial;

Title "Model 1 with residual fitted plots";
proc reg data = trees plots(only)=residualbypredicted;
model volume = height diameter;

Title "Model 1 with QQ plots";
proc reg data = trees plots(only)=QQplot;
model volume = height diameter;


*(c) Consider the model with a natural logarithm transformation applied to volume. 
State the new model and use the appropriate diagnostic plots to check if any model 
assumptions appear to be violated. Be sure to comment on implications from each plot
and define any variables.;
data treesnew;
set trees;
logvolume = log(volume);
run;

Title "Model 1 with residual plots";
proc reg data = treesnew plots(only)=Residualplot;
model logvolume = height diameter;

*plots of partial plots;
Title "Model 1 with partial plots";
proc reg data = treesnew plots(only)=partial;
model logvolume = height diameter/partial;

*plots of residual versus fitted value;
Title "Model 1 with residual fitted plots";
proc reg data = treesnew plots(only)=residualbypredicted;
model logvolume = height diameter;

*QQplots;
Title "Model 1 with QQ plots";
proc reg data = treesnew plots(only)=QQplot;
model logvolume = height diameter;

*(d) Which of the two models is preferable? In a sentence, briefly justify your answer.;


*(e) Carefully interpret the estimated regression coefficient for height from the fitted
model in (c).;

*Q3.;
proc import datafile = "/home/u59455388/Ass3/Q3outlierdataset.csv"
out = Q3outlierdataset
dbms = csv 
replace 
;
run;

*(a) Fit the regression model and use measures and plots from class to identify
outliers and high influence points. Justify whether each of these points is an 
outlier, influential or both.;

proc reg data = Q3outlierdataset plot (label only)=(COOKSD);
model Y = X1 X2 X3 X4 X5 ;
run;

proc reg data = Q3outlierdataset plot (label only)=(DFFITS);
model Y = X1 X2 X3 X4 X5 ;
run;

proc reg data = Q3outlierdataset plot (label only)=(DFBETAS);
model Y = X1 X2 X3 X4 X5 ;
run;

proc reg data = Q3outlierdataset;
	model Y = X1 X2 X3 X4 X5;
	output out = OUTLIERinfluence
	H = leverage
	DFFITS = influence
	COOKD = cooksd;
run;

*(b) Refit the linear model for the scenarios: model without outliers and model without outliers
and leverage points. What differences do you notice between these two results and the full model.;


data Q3new;
set Q3outlierdataset;
if _n_ = 8 then delete;
run;

proc reg data = Q3new plot (label only)=(COOKSD);
model Y = X1 X2 X3 X4 X5 ;
run;

proc reg data = Q3new plot (label only)=(DFFITS);
model Y = X1 X2 X3 X4 X5 ;
run;

proc reg data = Q3new plot (label only)=(DFBETAS);
model Y = X1 X2 X3 X4 X5 ;
run;