
FILENAME REFFILE '/home/sgozdzialski0/Kobe.csv';

PROC IMPORT DATAFILE=REFFILE
	DBMS=CSV
	OUT=Kobe;
	GETNAMES=YES;
RUN;
/*EDA*/
/*sorting the data based upin shot made flag for boxplots,  
Boxplots work on numeric Variables*/;
proc sort data = Kobe;
by shot_made_flag;
run;

proc boxplot data = Kobe;
plot game_event_id*shot_made_flag;
run;

proc boxplot data = Kobe;
plot Lat*shot_made_flag;
run;

proc boxplot data = Kobe;
plot loc_x*shot_made_flag;
run;

proc boxplot data = Kobe;
plot loc_y*shot_made_flag;
run;

proc boxplot data = Kobe;
plot lon*shot_made_flag;
run;

proc boxplot data = Kobe;
plot minutes_remaining*shot_made_flag;
run;

proc boxplot data = Kobe;
plot period*shot_made_flag;
run;

proc boxplot data = Kobe;
plot playoffs*shot_made_flag;
run;

proc boxplot data = Kobe;
plot seconds_remaining*shot_made_flag;
run;

proc boxplot data = Kobe;
plot shot_distance*shot_made_flag;
run;

proc boxplot data = Kobe;
plot team_id*shot_made_flag;
run;

proc boxplot data = Kobe;
plot game_date*shot_made_flag;
run;
/*Running proc freq on the categroical Variables to see if there is a difference 
in the shots made verse missed.*/;
/*action type.*/
data new_kobe;
set kobe;
keep action_type shot_made_flag;
run;

Proc sort data=new_kobe;
by action_type;
run;

proc freq data =new_kobe;
by action_type;
run;

/*combined shot type*/
data new_kobe;
set kobe;
keep combined_shot_type shot_made_flag;
run;

Proc sort data=new_kobe;
by combined_shot_type;
run;

proc freq data =new_kobe;
by combined_shot_type;
run;

/*Period*/;
data new_kobe;
set kobe;
keep period shot_made_flag;
run;

Proc sort data=new_kobe;
by period;
run;

proc freq data =new_kobe;
by period;
run;

/*playoffs*/;
data new_kobe;
set kobe;
keep playoffs shot_made_flag;
run;

Proc sort data=new_kobe;
by playoffs;
run;

proc freq data =new_kobe;
by playoffs;
run;

/*season*/;
data new_kobe;
set kobe;
keep season shot_made_flag;
run;

Proc sort data=new_kobe;
by season;
run;

proc freq data =new_kobe;
by season;
run;

/*shot_type*/;
data new_kobe;
set kobe;
keep shot_type shot_made_flag;
run;

Proc sort data=new_kobe;
by shot_type;
run;

proc freq data =new_kobe;
by shot_type;
run;

/*shot_zone_area*/;
data new_kobe;
set kobe;
keep shot_zone_area shot_made_flag;
run;

Proc sort data=new_kobe;
by shot_zone_area;
run;

proc freq data =new_kobe;
by shot_zone_area;
run;

/*shot_zone_basic*/;
data new_kobe;
set kobe;
keep shot_zone_basic shot_made_flag;
run;

Proc sort data=new_kobe;
by shot_zone_basic;
run;

proc freq data =new_kobe;
by shot_zone_basic;
run;

/*shot_zone_range*/;
data new_kobe;
set kobe;
keep shot_zone_range shot_made_flag;
run;

Proc sort data=new_kobe;
by shot_zone_range;
run;

proc freq data =new_kobe;
by shot_zone_range;
run;

/*team_name*/;
data new_kobe;
set kobe;
keep team_name shot_made_flag;
run;

Proc sort data=new_kobe;
by team_name;
run;

proc freq data =new_kobe;
by team_name;
run;

/*team_id*/;
data new_kobe;
set kobe;
keep team_id shot_made_flag;
run;

Proc sort data=new_kobe;
by team_id;
run;

proc freq data =new_kobe;
by team_id;
run;

/*matchup*/;
data new_kobe;
set kobe;
keep matchup shot_made_flag;
run;

Proc sort data=new_kobe;
by matchup;
run;

proc freq data =new_kobe;
by matchup;
run;

/*opponent*/;
data new_kobe;
set kobe;
keep opponent shot_made_flag;
run;

Proc sort data=new_kobe;
by opponent;
run;

proc freq data =new_kobe;
by opponent;
run;