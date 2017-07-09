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

	new5 = input(BsmtFullBath, 8.);
	drop BsmtFullBath;
	if new5=. then new5=0;
	rename new5=BsmtFullBath;

	new6 = input(BsmtHalfBath, 8.);
	drop BsmtHalfBath;
	if new6=. then new6=0;
	rename new6=BsmtHalfBath;

	new8 = input(GarageCars, 8.);
	drop GarageCars;
	if new8=. then new8=0;
	rename new8=GarageCars;
	
data test;
	set test;
	KEEP Id LotArea OverallQual OverallCond YearBuilt YearRemodAdd _1stFlrSF GrLivArea BsmtFullBath BsmtHalfBath FullBath HalfBath TotRmsAbvGrd Fireplaces GarageCars;

data dataset;
	set train test;
	KEEP Id SalePrice LotArea OverallQual OverallCond YearBuilt YearRemodAdd _1stFlrSF GrLivArea BsmtFullBath BsmtHalfBath FullBath HalfBath TotRmsAbvGrd Fireplaces GarageCars;
	

data transformed;
	set dataset;
	drop Id;
	drop SalePrice;
	
	array vars _numeric_;
	do over vars;
		vars=log(vars+1);
	end;
	
data dataset;
	merge dataset transformed;
	SalePrice = log10(SalePrice);


/*
 * Output some data
 */
proc print data=dataset (obs=10);
proc means data=dataset;
proc means data=dataset N NMISS;
proc means data=test N NMISS;


/*
 * Get cooks'd for all continious vars
 * influance will contain the result
 */
proc reg data=dataset plots=diagnostics;
	model SalePrice=LotArea OverallQual OverallCond YearBuilt YearRemodAdd _1stFlrSF GrLivArea BsmtFullBath BsmtHalfBath FullBath HalfBath TotRmsAbvGrd Fireplaces GarageCars
	/ noprint;
	output out=influance cookd=cookd NOPRINT;

/*
 * Remove all columns but cookd
 * Just to keep the dataset clean
 */
data influance;
	set influance;
	keep cookd;

/*
 * Merge the two datasets
 * dataset will now have a variable cookd
 * Remove all very large cooks'd
 * A rule of thumb cutoff is 4/N (N - obs)
 */
data dataset;
	merge dataset influance;
	
data dataset;
	set dataset;
	where cookd < 4/1460;
	drop cookd;

proc print data=dataset (obs=10);
proc means data=dataset;

/*
 * Get PCA analysis
 */
proc princomp data=dataset;
	var LotArea OverallQual OverallCond YearBuilt YearRemodAdd _1stFlrSF GrLivArea BsmtFullBath BsmtHalfBath FullBath HalfBath TotRmsAbvGrd Fireplaces GarageCars;
run;

/*
 * create regression with PCA
 */
proc pls data=dataset cv=SPLIT(5) nfac=8;
	class 
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
 * Kaggle score: 0.14264
 */
run;