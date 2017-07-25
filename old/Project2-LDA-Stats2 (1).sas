


*importing train.CSV;
Proc import datafile = "/home/sgozdzialski0/train.csv"
out = train
replace;
delimiter=',';
getnames=yes;
run;

*importing the test data;
proc import datafile = "/home/sgozdzialski0/test.csv"
out= test
replace;
delimiter = ',';
getnames = yes;
run;
		
*using proc stepdisc to remove some of the many variables, making the model simpler;
proc stepdisc data=train method=stepwise;
class foundation;
var MSsubclass lotarea overallqual overallcond yearbuilt yearremodadd masvnrarea bsmtfinsf1 bsmtfinsf2 bsmtunfsf 
totalbsmtsf _1stflrsf _2ndflrSF lowqualfinsf grlivarea bsmtfullbath bsmthalfbath bedroomabvgr totrmsabvgrd 
fireplaces garageyrblt garagecars garagearea wooddecksf openporchsf enclosedporch _3ssnporch poolarea miscval;
run;
*variables chosen are MSsubClass LotArea BsmtfinSF1 lowQualfinSF BsmtHalfBath TotrmsAbvGrd GarageCars 
WooddeckSF OpenporchSF PoolArea MiscVal;

*running plots on variables selected above to see if any transformations are needed;
Proc univariate data=test plots;
var MSsubClass LotArea BsmtfinSF1 lowQualfinSF BsmtHalfBath TotrmsAbvGrd 
GarageCars WooddeckSF OpenporchSF PoolArea MiscVal;
run; 

*running transformations on all variables using sqrt because number of obeservations 
that include zero;
data train;
set train;
transMS = sqrt(MSsubclass);
translot = sqrt(lotarea);
transBsmt = sqrt(BsmtfinSF1);
transfin = sqrt(lowqualSF);
transgar = sqrt(garagecars);
transhalf= sqrt(Bsmthalfbath); 
transtot = sqrt(totrmsabvgrd);
transdeck = sqrt(wooddeckSF);
transporch = sqrt(OpenporchSF);
transpool = sqrt(poolArea);
transMisc = sqrt(MiscVal);
run;


*running EDA on all transformed varaibles;
Proc univariate data=train plots;
var transms transLot transBsmt transfin transHalf transTot transGar transdeck transporch 
transPool transMisc;
run; 

*After EDA finally picked all the original variables excpet transtot.  The number of obs with zero
made even the transf ormed variables very skewed and hard to transform;


* imputing datafile into test data set and adding saleprice to test dataset;
data test2;
set test2;
transtot = sqrt(totrmsabvgrd);
transdeck = sqrt(wooddeckSF);
transporch = sqrt(OpenporchSF);
run;


*Running final linear discriminate analysis on the training data with crossvalidation 
and on the test2 data. The output is sent to a set called final;
proc discrim data=train crossvalidate testdata=test2 out=final;
class foundation;
var MSsubClass LotArea BsmtfinSF1 lowQualfinSF BsmtHalfBath TransTot 
GarageCars Transdeck Transporch PoolArea MiscVal;
run;