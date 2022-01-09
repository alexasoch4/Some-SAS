*Part 1;
proc import datafile = "/home/u59455388/Ass3/trees.csv"
out = trees
dbms = csv 
replace;
run;

*trees.csv contains records of the volume in cubic feet, the diameter 
in feet, and the height in feet of 38 cherry blossom trees;

* Want to estimate the model and use the appropriate diagnostic plots to check if
any model assumptions appear to be violated.;

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


*Want to apply a natural logarithm transformation to volume.;

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


*Part 2;
proc import datafile = "/home/u59455388/Ass3/Q3outlierdataset.csv"
out = Q3outlierdataset
dbms = csv 
replace 
;
run;

* Want to find points that are outliers, influential or both.;

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

* Want to fit the model without outliers and model without outliers and leverage points.;

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
