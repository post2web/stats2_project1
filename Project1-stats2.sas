*Data download and cleaning;
*importing train.CSV;
Proc import datafile = "/home/sgozdzialski0/train.csv"
out = train
replace;
delimiter=',';
getnames=yes;
run;
*importing the test data;
Proc import datafile = "/home/sgozdzialski0/train.csv"
out = train
replace;
delimiter=',';
getnames=yes;
run;
	
	
*Square root transformaiton on saleprice. To fix the none normality;
data train2;
set train;
where saleprice > 100;
Transprice = sqrt(saleprice);
run;
	
	
* imputing datafile into test data set and adding saleprice to test dataset;
proc import datafile = "/home/sgozdzialski0/test.csv"
out= test
replace;
delimiter = ',';
getnames = yes;
run;
data test;

set test;
saleprice =.;
run;

proc sort data=train2;
by neighborhood;
run; 


proc means data= train2;
by neighborhood;
var  saleprice;
run;


data Train3;
set train2 test;
Transprice = sqrt(saleprice);
run;

*EDA for all numeric variables vs Sqrtprice.  Selecting the one that best fit all the assumptions;
 proc sgscatter data = train2;
 matrix SalePrice logprice logarea MSsubclass GrLivArea lotarea overallqual overallcond;
 run;
 
 proc sgscatter data=train2;
 matrix SalePrice logprice yearbuilt yearremodadd MasVnrArea BSMTfinSF1 BSMTfinSF2;
 run;
 
 Proc sgscatter data = train2;
 matrix Saleprice logprice BSMTUnfSF TotalBSMTSF _1stFlrSF _2ndFlrSF lowqualFINSF;
 run;
 
 Proc sgscatter data= train2;
 matrix Saleprice logprice BSMTFullbath BSMThalfbath BedroomABVGR KitchenAbvGr TotRmsAbvGrd;
 run;
 
 proc sgscatter data= train2;
 matrix saleprice logprice fireplaces garageyrblt garagecars garagearea wooddeckSF OpenporchSF;
 run;
 
 proc sgscatter data= train2;
 matrix saleprice logprice Enclosedporch _3ssnPorch PoolArea MiscVal Mosold Yrsold;
 run;

*Running glmselect on variables that look good from the EDA, adding neighborhood and buildingtype
because different nieghborhoods have different price ranges and differnet building type affect the 
cost;
*Using Cross validation level 5 on the training data;
proc glmselect data = train2 plot =all;
class Neighborhood housestyle bldgtype;
model Transprice = overallcond Grlivarea Neighborhood TotalBsmtSF Overallqual bsmtfullbath 
garagecars yearbuilt bldgtype housestyle lotarea YearRemodAdd TotalBsmtSF
/selection=stepwise(stop=cv) cvmethod=random(5) hierarchy=single showpvalues;
run;


*Running proc reg with VIF on all numeric variable to check for multicollinearity.  
All variables look good.;
proc reg data= train2;
model Transprice = overallqual grLivArea BsmtFullbath  GarageCars Overallcond 
TotalBsmtSF  Yearbuilt LotArea yearRemodAdd/VIF;
run;

*Running GLM on the training data one last time to chekc all of the F scores and P-values to see
if any of the slopes are zero.  All variables look good.
proc GLM data = train2 plot = all;
class Neighborhood bldgtype;
model Transprice = overallqual grLivArea Neighborhood BsmtFullbath  GarageCars Overallcond 
TotalBsmtSF bldgType Yearbuilt LotArea yearRemodAdd/Cli solution;
run;

*Running final GLM on test data to get predictions;
proc GLM data = train3 plot = all;
class Neighborhood bldgtype;
model Transprice = overallqual grLivArea Neighborhood BsmtFullbath  GarageCars Overallcond 
TotalBsmtSF bldgType Yearbuilt LotArea yearRemodAdd/Cli solution;
output out = result p = predict;
run;

*Cleaning all unneed records of the front of the results.;
data results;
set result;
predict = predict*predict;
if Predict > 0 then SalePrice = Predict;
if Predict < 0 then SalePrice = 195000;
keep id SalePrice;
where id > 1460;
;

*Final model Kaggle score was 0.13919;

