proc import
	datafile='/home/iangelov0/kaggle/train.csv'
	out=train
	dbms=CSV
 	replace;
	getnames=yes;
	datarow=2;
	guessingrows=2000;

proc import
	datafile='/home/iangelov0/kaggle/test.csv'
	out=test
	dbms=CSV
 	replace;
	getnames=yes;
	datarow=2;
	guessingrows=2000;

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


data dataset;
	set train test;
	SalePrice = log10(SalePrice);

data continuous;
	set dataset;
	drop Id;
	drop SalePrice;

	array vars _numeric_;
	do over vars;
		vars=log(vars+1);
	end;

data continuous;
	merge dataset continuous;

proc print data=continuous (obs=10);
proc means data=continuous;


/*
 * Get cooks'd for all continious vars
 * influence will contain the result
 */
proc reg data=continuous plots=diagnostics;
	model SalePrice=LotArea OverallQual OverallCond YearBuilt YearRemodAdd _1stFlrSF GrLivArea BsmtFullBath BsmtHalfBath FullBath HalfBath TotRmsAbvGrd Fireplaces GarageCars
	/ noprint;
	output out=influence cookd=cookd NOPRINT;

/*
 * Remove all columns but cookd
 * Just to keep the dataset clean
 */
data influence;
	set influence;
	keep cookd;

/*
 * Merge the two datasets
 * dataset will now have a variable cookd
 * Remove all very large cooks'd
 * A rule of thumb cutoff is 4/N (N - obs)
 * I use 5/N because only want to exclude more extreme outliers
 */

data dataset;
	merge dataset continuous influence;

data dataset;
	set dataset;
	where cookd < 5/1460;
	drop cookd Intercept;

/*
 * Standartize the continuous variables
 */

PROC STANDARD data=dataset mean=0 std=1 out=dataset;
	var LotArea OverallQual OverallCond YearBuilt YearRemodAdd _1stFlrSF GrLivArea BsmtFullBath BsmtHalfBath FullBath HalfBath TotRmsAbvGrd Fireplaces GarageCars;
run;


/*
 * Output some data
 */
proc print data=dataset (obs=10);
proc means data=dataset;
proc means data=dataset N NMISS;

/*
 * Get PCA analysis
 */

proc princomp data=dataset;
	var LotArea OverallQual OverallCond YearBuilt YearRemodAdd _1stFlrSF GrLivArea BsmtFullBath BsmtHalfBath FullBath HalfBath TotRmsAbvGrd Fireplaces GarageCars;
run;


/*
 * create regression with PCA
 */
ods graphics on;
proc pls data=dataset cv=SPLIT(4) nfac=8;
	model SalePrice = LotArea OverallQual OverallCond YearBuilt YearRemodAdd _1stFlrSF GrLivArea BsmtFullBath BsmtHalfBath FullBath HalfBath TotRmsAbvGrd Fireplaces GarageCars;
	output out=regout(where=(SalePrice=.)) p=predicted;
run;


/*
 * Create the final dataset
 */
data submission;
	set regout;
	/* since we took square root now have to addjuct back */
	SalePrice = 10 ** predicted;
	keep Id SalePrice;

/*
 * Export the result to csv
 */
proc export data=submission dbms=csv
	outfile="/home/iangelov0/kaggle/submission.csv"
	replace;
/*
 * Kaggle score: 0.14266
 */
run;
quit;
