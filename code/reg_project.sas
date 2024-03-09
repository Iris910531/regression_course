%let indir=C:\Users\user\Desktop\resume\datasets;
proc import datafile="&indir\barrel.csv" out=barrel dbms=csv replace;
getnames=yes;
run;
proc contents data=barrel;run;

/* model 1*/
data barrel2;
set barrel;
if 25<= player_age <=29 then age0=1;
else age0=0;
run;
proc print data=barrel2(obs=100);run;


/* model 1 - Linear Tendency */
proc reg data=barrel2;
  model woba_percent=age0 exit_velocity_avg launch_angle_avg sweet_spot_percent barrel_batted_rate/clb;
   output out=ryhat0 p=yhat r=r;
run;

/* model 1 - Error Normality */
proc univariate data=ryhat0 normal;
 var r;
run;
/* model 1 - Constant Variance */
proc reg data=barrel2;
  model woba_percent=age0 exit_velocity_avg launch_angle_avg sweet_spot_percent barrel_batted_rate/spec;
run;


/* test whether barrel has interaction */
proc glmselect data=barrel2;
 class age0/param=reference ref=first; 
 model woba_percent=age0 | exit_velocity_avg | launch_angle_avg | sweet_spot_percent | barrel_batted_rate@2/
           showpvalues selection=backward (select=SL slstay=0.05) hier=single details=all ;
run;

/* model 2*/
data barrel_new;
set barrel2;
x6=launch_angle_avg*barrel_batted_rate;
x7=sweet_spot_percent*barrel_batted_rate;
run;

/* model 2 - diagnosis */
proc reg data=barrel_new;
  model woba_percent=age0 exit_velocity_avg launch_angle_avg sweet_spot_percent barrel_batted_rate x6 x7/clb;
   output out=ryhat p=yhat r=r;
run;
/* model 2 - Linear Tendency */
proc reg data=barrel_new;
  model woba_percent=age0 exit_velocity_avg launch_angle_avg sweet_spot_percent barrel_batted_rate x6 x7/lackfit;
   output out=ryhat p=yhat r=r;
run;

/* model 2 - Error Normality */
proc univariate data=ryhat normal;
 var r;
run;

/* model 2 - Constant Variance */
proc reg data=barrel_new;
  model woba_percent=age0 exit_velocity_avg launch_angle_avg sweet_spot_percent barrel_batted_rate x6 x7/spec;
run;


/* Remedial Measure */
proc transreg data=barrel_new;
model boxcox(woba_percent)=identity(age0 exit_velocity_avg launch_angle_avg sweet_spot_percent barrel_batted_rate x6 x7);
run;

/*model2*/
data barrel_new2;
set barrel_new;
woba2=(woba_percent)**(0.5);
run;


/*model 2 diagnosis(after remedial)*/
/*linear tendency*/
proc reg data=barrel_new2;
  model woba2=age0 exit_velocity_avg launch_angle_avg sweet_spot_percent barrel_batted_rate x6 x7/lackfit;
   output out=ryhat2 p=yhat r=r;
run;

/*normality */
proc univariate data=ryhat2 normal;
 var r;
run;

/*constant variance*/
proc reg data=barrel_new2;
  model woba2=age0 exit_velocity_avg launch_angle_avg sweet_spot_percent barrel_batted_rate x6 x7/spec;
  output out=ryhat2 p=yhat r=r;
run;

proc glm data=barrel_new;
 model woba_percent=age0 exit_velocity_avg launch_angle_avg sweet_spot_percent barrel_batted_rate x6 x7;
 estimate 'k' launch_angle_avg 1 barrel_batted_rate 0.65;
 run;
