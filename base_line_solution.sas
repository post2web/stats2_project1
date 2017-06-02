/*
 * Import the datasets
 * train has 1460 obs and 81 columns
 * test has 1459 obs 80 columns
 */

proc import
	datafile='/home/iangelov0/kaggle/train.csv'
	out=train
    DBMS=CSV
 	replace;
	GETNAMES=yes;
	DATAROW=2;
	GUESSINGROWS=2000;

proc import
	datafile='/home/iangelov0/kaggle/test.csv'
	out=test
    DBMS=CSV
 	replace;
	GETNAMES=yes;
	DATAROW=2;
	GUESSINGROWS=2000;

/*
 * Some vars in the test dataset have char data type instead of numeric
 * This will change their data type
 * Ugly but I don't know a better way to change daypes
 */
data test;
	set test;

	new1 = input(BsmtFinSF1, 8.);
	drop BsmtFinSF1;
	if new1=. then new1=0;
	rename new1=BsmtFinSF1;

	new2 = input(BsmtFinSF2, 8.);
	drop BsmtFinSF2;
	if new2=. then new2=0;
	rename new2=BsmtFinSF2;

	new3 = input(BsmtUnfSF, 8.);
	drop BsmtUnfSF;
	if new3=. then new3=0;
	rename new3=BsmtUnfSF;

	new4 = input(TotalBsmtSF, 8.);
	drop TotalBsmtSF;
	if new4=. then new4=0;
	rename new4=TotalBsmtSF;

	new5 = input(BsmtFullBath, 8.);
	drop BsmtFullBath;
	if new5=. then new5=0;
	rename new5=BsmtFullBath;

	new6 = input(BsmtHalfBath, 8.);
	drop BsmtHalfBath;
	if new6=. then new6=0;
	rename new6=BsmtHalfBath;

	new7 = input(GarageArea, 8.);
	drop GarageArea;
	if new7=. then new7=0;
	rename new7=GarageArea;

	new8 = input(GarageCars, 8.);
	drop GarageCars;
	if new8=. then new8=0;
	rename new8=GarageCars;


/*
 * Append the test dataset on the end of train
 */
data dataset;
	set train test;

	/*
	 * replace character missing values with 'NA'
	 */
	array change _character_;
	do over change;
		if missing(change) then change='NA';
	end;


/*
 * Output some data
 */
proc print data=dataset (obs=10);
proc means data=dataset;
proc means data=dataset N NMISS;


/* proc means data=test N NMISS; */

/*
 * Work only with the numeric values for now
 */
data dataset;
	set dataset;
 	KEEP _numeric_;



/*
 * Get VIF and influential points
 */
proc reg data=dataset plots=diagnostics;
	model SalePrice=MSSubClass--MiscVal/ noprint;
	output out=influance cookd=cookd NOPRINT;


/* remove all columns but cookd */
data influance;
	set influance;
	keep cookd;

/* remove all very large cooks'd  */
data dataset;
	merge dataset influance;

data dataset;
	set dataset;
	where cookd < 4/1460;
	drop cookd;

proc print data=dataset (obs=10);
proc means data=dataset;

/* variable transformation */
data dataset;
	set dataset;
	SalePriceSqrt=sqrt(SalePrice);
	drop SalePrice;

/* get only train part of the data */
data train;
	set dataset;
	OBS=1460;

/*other methods: LASSO stepwise(choose=BIC) */
proc glmselect data=train;
	model SalePriceSqrt=MSSubClass--YrSold / selection=LAR(stop=CV) cvMethod=RANDOM(5);

/* fit the linear regression and create a regout dataset */
proc reg data=dataset;
	model SalePriceSqrt =  MSSubClass LotArea OverallQual OverallCond YearBuilt YearRemodAdd BsmtFinSF1 TotalBsmtSF _1stFlrSF LowQualFinSF GrLivArea BsmtFullBath FullBath BedroomAbvGr KitchenAbvGr TotRmsAbvGrd Fireplaces GarageCars GarageArea WoodDeckSF ScreenPorch YrSold;
	output out=regout(where=(SalePriceSqrt=.)) p=predicted;


proc print data=regout (obs=10);

/* create the final dataset */
data submission;
	set regout;
	/* since we took square root now we addjuct back  */
	SalePrice = predicted * predicted;
	keep Id SalePrice;


proc print data=submission (obs=10);

/* export the result to csv */
proc export data=submission dbms=csv
	outfile="/home/iangelov0/kaggle/submission.csv"
	replace;

run;
