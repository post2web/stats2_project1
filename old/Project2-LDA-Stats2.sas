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
		
		
* imputing datafile into test data set and adding saleprice to test dataset;
data test;
set test;
drop foundation;
run;

*using proc stepdisc to remove some of the many variables, making the model simpler;
proc stepdisc data=train method=stepwise;
class foundation;
var MSsubclass lotarea overallqual overallcond yearbuilt yearremodadd masvnrarea bsmtfinsf1 bsmtfinsf2 bsmtunfsf 
totalbsmtsf _1stflrsf _2ndflrSF lowqualfinsf grlivarea bsmtfullbath bsmthalfbath bedroomabvgr totrmsabvgrd 
fireplaces garageyrblt garagecars garagearea wooddecksf openporchsf enclosedporch _3ssnporch poolarea miscval;
run;
*variables chosen are MSsubClass LotArea BsmtfinSF1 -2ndflrSF lowQualfinSF BsmtHalfBath TotrmsAbvGrd GarageCars 
WooddeckSF OpenporchSF PoolArea MiscVal;


*Running final linear discriminate analysis on the training data with crossvalidation and on the test data.
The output is sent to a set called final;
proc discrim data=train crossvalidate testdata=test out=final;
class foundation;
var MSsubClass LotArea BsmtfinSF1 _2ndflrSF lowQualfinSF BsmtHalfBath TotrmsAbvGrd 
GarageCars WooddeckSF OpenporchSF PoolArea MiscVal;
run;