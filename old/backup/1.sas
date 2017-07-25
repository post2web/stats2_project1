/*
 * Import the train dataset
 */
proc import
	datafile='/home/iangelov0/kaggle/train.csv'
	out=train
    DBMS=CSV
 	 replace;
	GETNAMES=yes;
	DATAROW=2;
	GUESSINGROWS=2000;
/*
 * Work only with the numeric values for now
 */
data train;
	set train;
	KEEP _numeric_;
	drop ID;

/* 
 * replace 'NA's with nans
data train;
	set train;
	array change _character_;
	do over change;
		if change='NA' then change=.;
	end;
run ;
*/

/* 
 * sample output
 * train has 1460 obs and 81 columns
 * test has 1459 obs 80 columns
 */
proc print data=train (obs=10);
proc means data=train;

/*
 * Get VIF and influential points
 */
proc reg data=train plots=diagnostics;
	model SalePrice=MSSubClass--MiscVal/ vif influence;
	output out=influance cookd=cookd;

/* mix with train  */
data influance;
	set influance;
	keep cookd;

/* remove all very large cooks'd  */
data train;
	merge train influance;

data train;
	set train;
	where cookd < 4/1460;
	drop cookd;

proc print data=influance (obs=10);
proc means data=train;

data train;
	set train;
	SalePriceSqrt=sqrt(SalePrice);

/*other methods: LASSO stepwise(choose=BIC) */	
proc glmselect data=train;
	model SalePriceSqrt=MSSubClass--YrSold / selection=LAR(stop=CV) cvMethod=RANDOM(5);

	
