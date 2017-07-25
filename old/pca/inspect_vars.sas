
proc import
	datafile='/home/iangelov0/kaggle/train.csv'
	out=dataset
	dbms=CSV
 	replace;
	getnames=yes;
	datarow=2;
	guessingrows=2000;


data dataset;
	set dataset;
 	KEEP _numeric_;
 	
 	
proc print data=dataset(obs=10);
 
data transformed;
	set dataset;
	drop Id;
	drop SalePrice;
	
	array vars _numeric_;
	do over vars;
		vars=log(vars+1);
	end;

proc print data=transformed(obs=10);
	
data dataset;
	merge dataset transformed;
	SalePrice = log10(SalePrice);
	
proc print data=dataset(obs=10);

proc means data=dataset;

/* 
 * inspect normality and liniarity
 * will go over every continious variable one by one
 */

/* 
 * MSSubClass	LotArea	OverallQual	OverallCond	YearBuilt	YearRemodAdd	BsmtFinSF1	BsmtFinSF2	BsmtUnfSF	TotalBsmtSF	_1stFlrSF	_2ndFlrSF	LowQualFinSF	GrLivArea	BsmtFullBath	BsmtHalfBath	FullBath	HalfBath	BedroomAbvGr	KitchenAbvGr	TotRmsAbvGrd	Fireplaces	GarageCars	GarageArea	WoodDeckSF	OpenPorchSF	EnclosedPorch	_3SsnPorch	ScreenPorch	PoolArea	MiscVal	MoSold	YrSold	SalePrice
 */


proc sgplot data = dataset;
	scatter x = MSSubClass y = SalePrice;
FOOTNOTE 'NON linear';

proc sgplot data = dataset;
	scatter x = LotArea y = SalePrice;
FOOTNOTE 'linear';

proc sgplot data = dataset;
	scatter x = OverallQual y = SalePrice;
FOOTNOTE 'linear';

proc sgplot data = dataset;
	scatter x = OverallCond y = SalePrice;
FOOTNOTE 'linear';

proc sgplot data = dataset;
	scatter x = YearBuilt y = SalePrice;
FOOTNOTE 'linear';

proc sgplot data = dataset;
	scatter x = YearRemodAdd y = SalePrice;
FOOTNOTE 'linear';

proc sgplot data = dataset;
	scatter x = BsmtFinSF1 y = SalePrice;
FOOTNOTE 'NON linear';

proc sgplot data = dataset;
	scatter x = BsmtFinSF2 y = SalePrice;
FOOTNOTE 'NON linear';

proc sgplot data = dataset;
	scatter x = BsmtUnfSF y = SalePrice;
FOOTNOTE 'NON linear';

proc sgplot data = dataset;
	scatter x = TotalBsmtSF y = SalePrice;
FOOTNOTE 'NON linear';

proc sgplot data = dataset;
	scatter x = _1stFlrSF y = SalePrice;
FOOTNOTE 'linear';

proc sgplot data = dataset;
	scatter x = _2ndFlrSF y = SalePrice;
FOOTNOTE 'NON linear';

proc sgplot data = dataset;
	scatter x = LowQualFinSF y = SalePrice;
FOOTNOTE 'NON linear';

proc sgplot data = dataset;
	scatter x = GrLivArea y = SalePrice;
FOOTNOTE 'linear';
    
proc sgplot data = dataset;
	scatter x = BsmtFullBath y = SalePrice;
FOOTNOTE 'linear';
    
proc sgplot data = dataset;
	scatter x = BsmtHalfBath y = SalePrice;
FOOTNOTE 'linear';
    
proc sgplot data = dataset;
	scatter x = FullBath y = SalePrice;
FOOTNOTE 'linear';
    
proc sgplot data = dataset;
	scatter x = HalfBath y = SalePrice;
FOOTNOTE 'linear';
    
proc sgplot data = dataset;
	scatter x = BedroomAbvGr y = SalePrice;
FOOTNOTE 'NON linear';
    
proc sgplot data = dataset;
	scatter x = KitchenAbvGr y = SalePrice;
FOOTNOTE 'NON linear';
    
proc sgplot data = dataset;
	scatter x = TotRmsAbvGrd y = SalePrice;
FOOTNOTE 'linear';

proc sgplot data = dataset;
	scatter x = Fireplaces y = SalePrice;
FOOTNOTE 'linear';
    
proc sgplot data = dataset;
	scatter x = GarageCars y = SalePrice;
FOOTNOTE 'linear';
    
proc sgplot data = dataset;
	scatter x = GarageArea y = SalePrice;
FOOTNOTE 'NON linear';
    
proc sgplot data = dataset;
	scatter x = WoodDeckSF y = SalePrice;
FOOTNOTE 'NON linear';
    
proc sgplot data = dataset;
	scatter x = OpenPorchSF y = SalePrice;
FOOTNOTE 'NON linear';
    
proc sgplot data = dataset;
	scatter x = EnclosedPorch y = SalePrice;
FOOTNOTE 'NON linear';
    
proc sgplot data = dataset;
	scatter x = _3SsnPorch y = SalePrice;
FOOTNOTE 'NON linear';
    
proc sgplot data = dataset;
	scatter x = ScreenPorch y = SalePrice;
FOOTNOTE 'NON linear';
    
proc sgplot data = dataset;
	scatter x = PoolArea y = SalePrice;
FOOTNOTE 'NON linear';
    
proc sgplot data = dataset;
	scatter x = MiscVal y = SalePrice;
FOOTNOTE 'NON linear';
    
proc sgplot data = dataset;
	scatter x = MoSold y = SalePrice;
FOOTNOTE 'NON linear';
    
proc sgplot data = dataset;
	scatter x = YrSold y = SalePrice;
FOOTNOTE 'NON linear';
    
proc sgplot data = dataset;
	scatter x = YrSold y = SalePrice;
FOOTNOTE 'NON linear';