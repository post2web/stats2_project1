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
	drop GarageYrBlt LotFrontage MasVnrArea;
	/*Replace character missing values with 'NA'*/
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

/*
 * Variable transformations of the continious vars
 */
data dataset;
	set dataset;
	SalePriceSqrt=sqrt(SalePrice);
	drop SalePrice;

	LotAreaTrans = log(LotArea);
	OverallQualTrans = log(OverallQual);
	OverallCondTrans = log(OverallCond);
	YearRemodAddTrans = log(YearRemodAdd );

	BsmtFinSF1Flag = 0;
	if BsmtFinSF1 = 0 then do;
		BsmtFinSF1 = 700;
		BsmtFinSF1Flag = 1;
	end;

	TotalBsmtSFTrans = sqrt(TotalBsmtSF);
	TotalBsmtSFFlag = 0;
	if TotalBsmtSFTrans = 0 then do;
		TotalBsmtSFTrans = 30;
		TotalBsmtSFFlag = 1;
	end;

	_1stFlrSFTrans = log(_1stFlrSF);

	_2ndFlrSFFlag = 0;
	if _2ndFlrSF = 0 then do;
		_2ndFlrSF = 750;
		_2ndFlrSFFlag = 1;
	end;

	GrLivAreaTrans = log(GrLivArea);
	BedroomAbvGrTrans = log(BedroomAbvGr+1);

	WoodDeckSFFlag = 0;
	if WoodDeckSF = 0 then do;
		WoodDeckSF = 200;
		WoodDeckSFFlag = 1;
	end;

	keep Id SalePriceSqrt LotAreaTrans OverallQualTrans OverallCondTrans YearRemodAddTrans BsmtFinSF1 BsmtFinSF1Flag TotalBsmtSFTrans TotalBsmtSFFlag _1stFlrSFTrans _2ndFlrSF _2ndFlrSFFlag GrLivAreaTrans BsmtFullBath FullBath HalfBath BedroomAbvGrTrans KitchenAbvGr TotRmsAbvGrd Fireplaces GarageCars GarageArea WoodDeckSF WoodDeckSFFlag Alley BldgType BsmtCond BsmtExposure BsmtFinType1 BsmtFinType2 BsmtQual CentralAir Condition1 Condition2 Electrical ExterCond ExterQual Exterior1st Exterior2nd Fence FireplaceQu Foundation Functional GarageCond GarageFinish GarageQual GarageType Heating HeatingQC HouseStyle KitchenQual LandContour LandSlope LotConfig LotShape MSZoning MasVnrType MiscFeature Neighborhood PavedDrive PoolQC RoofMatl RoofStyle SaleCondition SaleType Street Utilities;

/*
 * Create dummy variables
 */
proc glmmod data=dataset outdesign=dummies noprint;
   class Alley BldgType BsmtCond BsmtExposure BsmtFinType1 BsmtFinType2 BsmtQual CentralAir Condition1 Condition2 Electrical ExterCond ExterQual Exterior1st Exterior2nd Fence FireplaceQu Foundation Functional GarageCond GarageFinish GarageQual GarageType Heating HeatingQC HouseStyle KitchenQual LandContour LandSlope LotConfig LotShape MSZoning MasVnrType MiscFeature Neighborhood PavedDrive PoolQC RoofMatl RoofStyle SaleCondition SaleType Street Utilities;
   model Id = Alley BldgType BsmtCond BsmtExposure BsmtFinType1 BsmtFinType2 BsmtQual CentralAir Condition1 Condition2 Electrical ExterCond ExterQual Exterior1st Exterior2nd Fence FireplaceQu Foundation Functional GarageCond GarageFinish GarageQual GarageType Heating HeatingQC HouseStyle KitchenQual LandContour LandSlope LotConfig LotShape MSZoning MasVnrType MiscFeature Neighborhood PavedDrive PoolQC RoofMatl RoofStyle SaleCondition SaleType Street Utilities;

/*
 * Merge the dummy vars with the dataste
 */
data dataset;
	merge dataset dummies;
 	KEEP _numeric_;

/*
 * Get cooks'd for all continious vars
 * influance will contain the result
 */
proc reg data=dataset plots=diagnostics;
	model SalePriceSqrt=BsmtFinSF1 BsmtFullBath FullBath HalfBath KitchenAbvGr TotRmsAbvGrd Fireplaces GarageCars GarageArea WoodDeckSF LotAreaTrans OverallQualTrans OverallCondTrans YearRemodAddTrans BsmtFinSF1Flag TotalBsmtSFTrans TotalBsmtSFFlag _1stFlrSFTrans _2ndFlrSFFlag GrLivAreaTrans BedroomAbvGrTrans WoodDeckSFFlag
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
	where cookd < 4/1460;
	drop cookd;

proc print data=dataset (obs=10);
proc means data=dataset;

/*
 * Get only train part of the data
 */
data train;
	set dataset;
	where SalePriceSqrt ^= .;

/*
 * Select Variable on second order of polynomio
 * other methods: LASSO stepwise(choose=BIC) selection=LASSO(stop=CV) cvMethod=RANDOM(20)*
 */

proc glmselect data=train  NAMELEN=200;
	model SalePriceSqrt=
LotAreaTrans LotAreaTrans*LotAreaTrans
OverallQualTrans OverallQualTrans*OverallQualTrans
YearRemodAddTrans YearRemodAddTrans*YearRemodAddTrans
BsmtFinSF1 BsmtFinSF1*BsmtFinSF1
BsmtFinSF1Flag
TotalBsmtSFTrans TotalBsmtSFTrans*TotalBsmtSFTrans
TotalBsmtSFFlag
_2ndFlrSF _2ndFlrSF*_2ndFlrSF
_2ndFlrSFFlag
GrLivAreaTrans GrLivAreaTrans*GrLivAreaTrans
BsmtFullBath BsmtFullBath*BsmtFullBath
KitchenAbvGr KitchenAbvGr*KitchenAbvGr
Fireplaces Fireplaces*Fireplaces
GarageCars GarageCars*GarageCars
GarageArea GarageArea*GarageArea

BsmtFinSF1|_2ndFlrSF|BsmtFullBath|FullBath|HalfBath|KitchenAbvGr|TotRmsAbvGrd|Fireplaces|GarageCars|GarageArea|WoodDeckSF|LotAreaTrans|OverallQualTrans|OverallCondTrans|YearRemodAddTrans|BsmtFinSF1Flag|TotalBsmtSFTrans|TotalBsmtSFFlag|_1stFlrSFTrans|_2ndFlrSFFlag|GrLivAreaTrans|BedroomAbvGrTrans|WoodDeckSFFlag|Col1|Col2|Col3|Col4|Col5|Col6|Col7|Col8|Col9|Col10|Col11|Col12|Col13|Col14|Col15|Col16|Col17|Col18|Col19|Col20|Col21|Col22|Col23|Col24|Col25|Col26|Col27|Col28|Col29|Col30|Col31|Col32|Col33|Col34|Col35|Col36|Col37|Col38|Col39|Col40|Col41|Col42|Col43|Col44|Col45|Col46|Col47|Col48|Col49|Col50|Col51|Col52|Col53|Col54|Col55|Col56|Col57|Col58|Col59|Col60|Col61|Col62|Col63|Col64|Col65|Col66|Col67|Col68|Col69|Col70|Col71|Col72|Col73|Col74|Col75|Col76|Col77|Col78|Col79|Col80|Col81|Col82|Col83|Col84|Col85|Col86|Col87|Col88|Col89|Col90|Col91|Col92|Col93|Col94|Col95|Col96|Col97|Col98|Col99|Col100|Col101|Col102|Col103|Col104|Col105|Col106|Col107|Col108|Col109|Col110|Col111|Col112|Col113|Col114|Col115|Col116|Col117|Col118|Col119|Col120|Col121|Col122|Col123|Col124|Col125|Col126|Col127|Col128|Col129|Col130|Col131|Col132|Col133|Col134|Col135|Col136|Col137|Col138|Col139|Col140|Col141|Col142|Col143|Col144|Col145|Col146|Col147|Col148|Col149|Col150|Col151|Col152|Col153|Col154|Col155|Col156|Col157|Col158|Col159|Col160|Col161|Col162|Col163|Col164|Col165|Col166|Col167|Col168|Col169|Col170|Col171|Col172|Col173|Col174|Col175|Col176|Col177|Col178|Col179|Col180|Col181|Col182|Col183|Col184|Col185|Col186|Col187|Col188|Col189|Col190|Col191|Col192|Col193|Col194|Col195|Col196|Col197|Col198|Col199|Col200|Col201|Col202|Col203|Col204|Col205|Col206|Col207|Col208|Col209|Col210|Col211|Col212|Col213|Col214|Col215|Col216|Col217|Col218|Col219|Col220|Col221|Col222|Col223|Col224|Col225|Col226|Col227|Col228|Col229|Col230|Col231|Col232|Col233|Col234|Col235|Col236|Col237|Col238|Col239|Col240|Col241|Col242|Col243|Col244|Col245|Col246|Col247|Col248|Col249|Col250|Col251|Col252|Col253|Col254|Col255|Col256|Col257|Col258|Col259|Col260|Col261|Col262|Col263|Col264|Col265|Col266|Col267|Col268|Col269|Col270|Col271|Col272|Col273|Col274|Col275|Col276
@2
/ selection=lasso(stop=CV steps=200) cvMethod=RANDOM(5);

/*
 * Fit the linear regression
 * and predict SalePriceSqrt for the test part of the dataset
 */
proc glm data=dataset;
	model SalePriceSqrt=
YearRemodAddTrans*YearRemodAddTrans GrLivAreaTrans*GrLivAreaTrans BsmtFinSF1*BsmtFullBath BsmtFullBath*FullBath FullBath*HalfBath _2ndFlrSF*Fireplaces BsmtFinSF1*GarageCars Fireplaces*GarageCars GarageArea*FullBath GarageArea*HalfBath HalfBath*WoodDeckSF GarageCars*WoodDeckSF OverallQualTrans*_2ndFlrSF OverallQualTrans*GarageCars OverallQualTrans*GarageArea LotAreaTrans*OverallQualTrans OverallQualTrans*OverallCondTrans BsmtFinSF1Flag*KitchenAbvGr TotalBsmtSFTrans*_2ndFlrSF OverallQualTrans*TotalBsmtSFTrans TotalBsmtSFTrans*OverallCondTrans LotAreaTrans*GrLivAreaTrans GrLivAreaTrans*_1stFlrSFTrans KitchenAbvGr*BedroomAbvGrTrans KitchenAbvGr*WoodDeckSFFlag BsmtFinSF1Flag*WoodDeckSFFlag GarageCars*Col5 GarageArea*Col7 BsmtFullBath*Col16 GarageArea*Col16 KitchenAbvGr*Col19 _2ndFlrSFFlag*Col19 BsmtFinSF1*Col22 HalfBath*Col22 Col25*Col28 BsmtFinSF1*Col34 TotalBsmtSFTrans*Col34 Col16*Col34 _2ndFlrSF*Col40 Col7*Col40 Col18*Col40 Col5*Col41 Fireplaces*Col43 GarageCars*Col43 Col38*Col45 OverallQualTrans*Col52 Col16*Col68 BsmtFinSF1Flag*Col69 TotalBsmtSFTrans*Col69 Col16*Col71 KitchenAbvGr*Col72 Col20*Col72 TotRmsAbvGrd*Col76 Col36*Col76 WoodDeckSFFlag*Col87 Col4*Col87 GarageArea*Col103 Col39*Col107 Col16*Col113 Col22*Col113 Col69*Col113 KitchenAbvGr*Col114 BsmtFinSF1Flag*Col114 Col87*Col114 Col25*Col115 GarageArea*Col119 Col22*Col119 OverallQualTrans*Col124 _2ndFlrSF*Col130 FullBath*Col130 _2ndFlrSF*Col136 Col43*Col136 BsmtFinSF1*Col137 GarageArea*Col137 KitchenAbvGr*Col140 Col132*Col142 Col7*Col146 Col43*Col146 _2ndFlrSFFlag*Col152 GarageArea*Col160 Col22*Col160 BsmtFinSF1Flag*Col164 Col117*Col164 Col142*Col164 Col103*Col165 FullBath*Col173 TotalBsmtSFTrans*Col173 Col3*Col173 Col22*Col173 Col52*Col173 Col130*Col173 Col146*Col173 KitchenAbvGr*Col177 BsmtFinSF1Flag*Col177 Col76*Col177 KitchenAbvGr*Col182 BsmtFinSF1*Col186 BsmtFullBath*Col186 Col160*Col186 Col41*Col189 Col173*Col189 Col7*Col190 Col38*Col193 Col69*Col193 Col14*Col194 Col19*Col194 Col58*Col194 Col87*Col194 Col190*Col195 _2ndFlrSF*Col199 KitchenAbvGr*Col199 Col170*Col201 Col41*Col206 Col4*Col213 BsmtFullBath*Col214 Col14*Col214 Col203*Col214 HalfBath*Col216 Fireplaces*Col216 Col104*Col216 OverallQualTrans*Col217 Col152*Col217 Col181*Col217 Col81*Col219 Col119*Col221 Col66*Col222 BsmtFinSF1*Col225 TotalBsmtSFTrans*Col225 Col86*Col225 Col137*Col225 Col181*Col225 TotRmsAbvGrd*Col226 Col103*Col226 Col38*Col227 Col117*Col227 FullBath*Col231 Col3*Col231 WoodDeckSF*Col232 Col5*Col232 _2ndFlrSF*Col237 Col10*Col237 Col14*Col237 KitchenAbvGr*Col243 BsmtFinSF1Flag*Col251 Col190*Col253 Col225*Col253 Col3*Col256 Col41*Col256 Col193*Col256 Col221*Col256 Col216*Col260 WoodDeckSF*Col261 Col34*Col261 Col86*Col261 Col226*Col261 Col253*Col261 Col33*Col263 Col204*Col269 Col256*Col271 GrLivAreaTrans*Col274;
	output out=regout(where=(SalePriceSqrt=.)) p=predicted;

/*
 * Create the final dataset
 */
data submission;
	set regout;
	/* since we took square root now have to addjuct back */
	SalePrice = predicted * predicted;
	keep Id SalePrice;

/*
 * Export the result to csv
 */
proc export data=submission dbms=csv
	outfile="/home/iangelov0/kaggle/submission.csv"
	replace;
/*
 * Kaggle score: 0.12360
 */
run;
