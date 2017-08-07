PROC IMPORT DATAFILE='/home/iangelov0/project3/data.csv' replace
	DBMS=CSV
	OUT=data;
	GETNAMES=YES;
run;

proc sort data=data out=data;
	by game_date;
run;

data data;
	set data;
	date=input(game_date,yymmddd10.);
run;


proc sql;
	create table dates as
	select distinct date
	from data where data.shot_made_flag is null;

data result;
	set data(obs=0);
	logits = 0;
run;

%MACRO LOOP_DATA;
/* 1457 */
%DO i = 1 %TO 1457;
	DATA current_dates;
		SET dates(obs=&i firstobs=&i);

	proc sql;
		create table rolling_data as
		select * from data a
		inner join current_dates b
		on (a.date > (b.date-100) and a.date < b.date and a.shot_made_flag is not null) or (a.date = b.date)
	;

	proc logistic data=rolling_data noprint;
		class action_type combined_shot_type shot_type shot_zone_area shot_zone_basic shot_zone_range;
   		model shot_made_flag = playoffs seconds_remaining shot_distance;
   		output out=predicted(where=(shot_made_flag=.))  p=logits;
	run;

	proc delete data=rolling_data;
	proc append base=result data=predicted force;
%END;
%MEND LOOP_DATA;
%LOOP_DATA;

data result;
	set result;
	shot_made_flag=logits;
	keep shot_id shot_made_flag;

proc print data=result (obs=5);

proc export data=result dbms=csv
	outfile='/home/iangelov0/project3/submition.csv'
	replace;

/* 0.79913 */
