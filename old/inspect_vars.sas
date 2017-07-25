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

data dataset;
	set dataset;
 	KEEP _numeric_;


proc print data=dataset (obs=30);

/*
 * inspect normality and liniarity
 * will go over every continious variable one by one
 */



/* MSSubClass not linear */
proc sgplot data=dataset;
  histogram MSSubClass;
  density MSSubClass;
proc sgplot data = dataset;
	scatter x = MSSubClass  y = SalePrice;
data dataset;
	set dataset;
	MSSubClassTrans= log(MSSubClass);
proc sgplot data = dataset;
	scatter x = MSSubClassTrans  y = SalePrice;




/* LotArea  */
proc sgplot data=dataset;
  histogram LotArea;
  density LotArea;
proc sgplot data = dataset;
	scatter x = LotArea  y = SalePrice;
data dataset;
	set dataset;
	LotAreaTrans= log(LotArea);
proc sgplot data = dataset;
	scatter x = LotAreaTrans  y = SalePrice;



/* OverallQual */
proc sgplot data=dataset;
  histogram OverallQual;
  density OverallQual;
proc sgplot data = dataset;
	scatter x = MSSubClass  y = SalePrice;
data dataset;
	set dataset;
	OverallQualTrans= log(OverallQual);
proc sgplot data = dataset;
	scatter x = OverallQualTrans  y = SalePrice;



/* OverallCond */
proc sgplot data=dataset;
  histogram OverallCond;
  density OverallCond;
proc sgplot data = dataset;
	scatter x = OverallCond  y = SalePrice;
data dataset;
	set dataset;
	OverallCondTrans= log(OverallCond);
proc sgplot data = dataset;
	scatter x = OverallCondTrans  y = SalePrice;



/* YearRemodAdd */
proc sgplot data=dataset;
  histogram YearRemodAdd;
  density YearRemodAdd;
proc sgplot data = dataset;
	scatter x = YearRemodAdd  y = SalePrice;
data dataset;
	set dataset;
	YearRemodAddTrans= log(YearRemodAdd );
proc sgplot data = dataset;
	scatter x = YearRemodAddTrans  y = SalePrice;
/*
proc means data=dataset  P25 median P75;
    var YearRemodAdd;
data dataset;
	set dataset;
	if YearRemodAdd <= 1965 then do;
 		YearRemodAddQ1=1;
 		YearRemodAddQ2=0;
 		YearRemodAddQ3=0;
 	end;
 	if YearRemodAdd > 1965 and YearRemodAdd <= 1993 then do;
 		YearRemodAddQ1=0;
 		YearRemodAddQ2=1;
 		YearRemodAddQ3=0;
 	end;
 	if YearRemodAdd > 1993 and YearRemodAdd <= 2004 then do;
 		YearRemodAddQ1=0;
 		YearRemodAddQ2=0;
 		YearRemodAddQ3=1;
 	end;
 	drop YearRemodAdd;
*/

/* BsmtFinSF1 */
proc sgplot data=dataset;
  histogram BsmtFinSF1;
  density BsmtFinSF1;
proc sgplot data = dataset;
	scatter x = BsmtFinSF1  y = SalePrice;
data dataset;
	set dataset;
	BsmtFinSF1Trans= BsmtFinSF1;
	BsmtFinSF1Flag = 0;
	if BsmtFinSF1Trans = 0 then do;
		BsmtFinSF1Trans = 700;
		BsmtFinSF1Flag = 1;
	end;
proc sgplot data = dataset;
	scatter x = BsmtFinSF1Trans  y = SalePrice;


/* BsmtFinSF2 - no, too many zeros */
proc sgplot data=dataset;
  histogram BsmtFinSF2;
  density BsmtFinSF2;
proc sgplot data = dataset;
	scatter x = BsmtFinSF2  y = SalePrice;


/* BsmtUnfSF - not linear */
proc sgplot data=dataset;
	histogram BsmtUnfSF;
	density BsmtUnfSF;
proc sgplot data = dataset;
	scatter x = BsmtUnfSF  y = SalePrice;

/* TotalBsmtSF */
proc sgplot data=dataset;
	histogram TotalBsmtSF;
	density TotalBsmtSF;
proc sgplot data = dataset;
	scatter x = TotalBsmtSF  y = SalePrice;
data dataset;
	set dataset;
	TotalBsmtSFTrans= sqrt(TotalBsmtSF);
	TotalBsmtSFFlag = 0;
	if TotalBsmtSFTrans = 0 then do;
		TotalBsmtSFTrans = 30;
		TotalBsmtSFFlag = 1;
	end;
proc sgplot data = dataset;
	scatter x = TotalBsmtSFTrans  y = SalePrice;


/* _1stFlrSF */
proc sgplot data=dataset;
	histogram _1stFlrSF;
	density _1stFlrSF;
proc sgplot data = dataset;
	scatter x = _1stFlrSF  y = SalePrice;
data dataset;
	set dataset;
	_1stFlrSFTrans = log(_1stFlrSF);
proc sgplot data = dataset;
	scatter x = _1stFlrSFTrans  y = SalePrice;

/* _2ndFlrSF */
proc sgplot data=dataset;
	histogram _2ndFlrSF;
	density _2ndFlrSF;
data dataset;
	set dataset;
	_2ndFlrSFTrans= _2ndFlrSF;
	_2ndFlrSFFlag = 0;
	if _2ndFlrSFTrans = 0 then do;
		_2ndFlrSFTrans = 750;
		_2ndFlrSFFlag = 1;
	end;
proc sgplot data = dataset;
	scatter x = _2ndFlrSFTrans  y = SalePrice;

/* LowQualFinSF no*/
proc sgplot data=dataset;
	histogram LowQualFinSF;
	density LowQualFinSF;
proc sgplot data = dataset;
	scatter x = LowQualFinSF  y = SalePrice;

/* GrLivArea */
data dataset;
	set dataset;
	GrLivAreaTrans = log(GrLivArea);
proc sgplot data=dataset;
	histogram GrLivAreaTrans;
	density GrLivAreaTrans;
proc sgplot data = dataset;
	scatter x = GrLivAreaTrans  y = SalePrice;

/* BsmtFullBath */
proc sgplot data=dataset;
	histogram BsmtFullBath;
	density BsmtFullBath;
proc sgplot data = dataset;
	scatter x = BsmtFullBath  y = SalePrice;

/* BsmtHalfBath no*/
proc sgplot data=dataset;
	histogram BsmtHalfBath;
	density BsmtHalfBath;
proc sgplot data = dataset;
	scatter x = BsmtHalfBath  y = SalePrice;

/* FullBath */
proc sgplot data=dataset;
	histogram FullBath;
	density FullBath;
proc sgplot data = dataset;
	scatter x = FullBath  y = SalePrice;

/* HalfBath */
proc sgplot data=dataset;
	histogram HalfBath;
	density HalfBath;
proc sgplot data = dataset;
	scatter x = HalfBath  y = SalePrice;

/* BedroomAbvGr */
data dataset;
	set dataset;
	BedroomAbvGrTrans = log(BedroomAbvGr);
proc sgplot data=dataset;
	histogram BedroomAbvGrTrans;
	density BedroomAbvGrTrans;
proc sgplot data = dataset;
	scatter x = BedroomAbvGrTrans  y = SalePrice;


/* KitchenAbvGr */
proc sgplot data=dataset;
	histogram KitchenAbvGr;
	density KitchenAbvGr;
proc sgplot data = dataset;
	scatter x = KitchenAbvGr  y = SalePrice;

/* TotRmsAbvGrd */
proc sgplot data=dataset;
	histogram TotRmsAbvGrd;
	density TotRmsAbvGrd;
proc sgplot data = dataset;
	scatter x = TotRmsAbvGrd  y = SalePrice;

/* Fireplaces */
proc sgplot data=dataset;
	histogram Fireplaces;
	density Fireplaces;
proc sgplot data = dataset;
	scatter x = Fireplaces  y = SalePrice;

/* GarageCars */
proc sgplot data=dataset;
	histogram GarageCars;
	density GarageCars;
proc sgplot data = dataset;
	scatter x = GarageCars  y = SalePrice;

/* GarageArea */
proc sgplot data=dataset;
	histogram GarageArea;
	density GarageArea;
proc sgplot data = dataset;
	scatter x = GarageArea  y = SalePrice;

/* WoodDeckSF */
data dataset;
	set dataset;
	WoodDeckSFTrans= WoodDeckSF;
	WoodDeckSFFlag = 0;
	if WoodDeckSFTrans = 0 then do;
		WoodDeckSFTrans = 200;
		WoodDeckSFFlag = 1;
	end;
proc sgplot data=dataset;
	histogram WoodDeckSFTrans;
	density WoodDeckSFTrans;
proc sgplot data = dataset;
	scatter x = WoodDeckSFTrans  y = SalePrice;

/* OpenPorchSF no */
proc sgplot data=dataset;
	histogram OpenPorchSF;
	density OpenPorchSF;
proc sgplot data = dataset;
	scatter x = OpenPorchSF  y = SalePrice;

/* EnclosedPorch no */
proc sgplot data=dataset;
	histogram EnclosedPorch;
	density EnclosedPorch;
proc sgplot data = dataset;
	scatter x = EnclosedPorch  y = SalePrice;

/* _3SsnPorch no*/
proc sgplot data=dataset;
	histogram _3SsnPorch;
	density _3SsnPorch;
proc sgplot data = dataset;
	scatter x = _3SsnPorch  y = SalePrice;

/* ScreenPorch no */
proc sgplot data=dataset;
	histogram ScreenPorch;
	density ScreenPorch;
proc sgplot data = dataset;
	scatter x = ScreenPorch  y = SalePrice;

/* PoolArea no*/
proc sgplot data=dataset;
	histogram PoolArea;
	density PoolArea;
proc sgplot data = dataset;
	scatter x = PoolArea  y = SalePrice;

/* MiscVal no*/
proc sgplot data=dataset;
	histogram MiscVal;
	density MiscVal;
proc sgplot data = dataset;
	scatter x = MiscVal  y = SalePrice;

/* MoSold no*/
proc sgplot data=dataset;
	histogram MoSold;
	density MoSold;
proc sgplot data = dataset;
	scatter x = MoSold  y = SalePrice;

/* YrSold no*/
proc sgplot data=dataset;
	histogram YrSold;
	density YrSold;
proc sgplot data = dataset;
	scatter x = YrSold  y = SalePrice;
