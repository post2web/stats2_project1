*Import train data set csv;
proc import datafile='/home/ldarr1/ExpStats1_HW/train.csv' out=train dbms= csv replace;
getnames=yes;
datarow=2;
run;
*replace overwrites the 'train_data' dataset if it already exists in my environment;
*getnames make the first line in the csv variable names;
*datarow specifies the first row where observations begin;

Data train2;
set train;
logsaleprice= log(SalePrice);
loglotarea=log(LotArea);
if MasVnrArea=NA then MasVnrArea=.;
newlotfrontage = input(LotFrontage, 8.);
run;


*Import test data set csv;
proc import datafile='/home/ldarr1/ExpStats1_HW/test.csv' out=test_data dbms=csv replace;
getnames=yes;
datarow=2;
run;

*Print the test data set to check number of rows;
*Comment out once observed;
*proc print data=test_data;
*run;

*Add a new column called SalePrice;
data test_data;
set test_data;
SalePrice=.;
run;

data train3;
set train2 test_data;
logsaleprice= log(SalePrice);
loglotarea=log(LotArea);
if MasVnrArea=NA then MasVnrArea=.;
newlotfrontage = input(LotFrontage, 8.);
run;

*Model glm;
proc glm data = train3 plot =all;
class Neighborhood(REF='NAmes') OverallQual OverallCond GarageCars Fireplaces;
model logsaleprice = Neighborhood OverallQual OverallCond GarageCars Fireplaces GrLivArea YearBuilt YearRemodAdd loglotarea /CLI solution;
output out = results p = predict;
run; quit;

data results2;
set results;
predict = exp(predict);
if Predict > 0 then SalePrice = predict;
if Predict < 0 then SalePrice = 180000;
keep id SalePrice;
where id > 1460;
run;

