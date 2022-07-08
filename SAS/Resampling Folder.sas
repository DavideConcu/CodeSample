
**********************************************************;
		*** RESAMPLING DI UNA CARTELLA DI CSV ***;
**********************************************************;


*** RESAMPLING VELOCE ***;



********************* SET **********************************;
%LET DATA_PATH_CSV 	   = ;
%LET OUT_PATH	 	   = ;
%LET LISTACSV_PATH	   = ;

* file csv da ricampionare (senza "csv" alla fine);
%LET LISTAFILECSV = ;

* Choose between "sec" , "min", "hr", "day";
%LET RESAMPLE_FREQUENCY = hr;

%LET FUNCTION = MEAN;
************************************************************;



libname inlib  "&data_path_csv.";
libname outlib "&out_path.";

*import Csv;
proc import 
datafile = "&data_path_csv.\&NomeFile..csv"
dbms = csv
out = &NomeFile.
replace;
run;


data &NomeFile.;
set  &NomeFile.;
drop time;
run;
%let data = &NomeFile.;







*prendere le medie;
%MACRO RESAMPLE;

proc transpose 
data = &data.(obs=0) 
out = varList
name = var;
var _all_;
run;

data varlist;
set varlist;
where upcase(var) not in ("", "");
run;


data &data.;
set  &data.;
datetime = floor(datetime);
format date ddmmyy10.;
date = (datepart(datetime));
run;


	
	
	
	%IF %UPCASE(&RESAMPLE_FREQUENCY.) = SEC
		%THEN %LET GROUP = vehicleId, datetime;
	%ELSE %DO;
			
			%IF %UPCASE(&RESAMPLE_FREQUENCY.) = MIN %THEN %DO;
				%LET GROUP = vehicleId, date, time;
				data &data.;
				set  &data.;
				length time_char $5;
				hour   = hour(timepart(datetime));
				minute = minute(timepart(datetime));
				time_char = strip(hour)||":"||strip(minute);
				time	  = input(time_char , time5.);
				format time time5.;
				drop datetime time_char hour minute ;
				run;
			%END;
			%ELSE %IF %UPCASE(&RESAMPLE_FREQUENCY.) = HR %THEN %DO;
				%LET GROUP = vehicleId, date, hour;
				data &data.;
				set  &data.;
				hour   = hour(timepart(datetime));
				drop datetime;
				run;
			%END;
			%ELSE %IF %UPCASE(&RESAMPLE_FREQUENCY.) = DAY %THEN %DO;
				%LET GROUP = vehicleId, date;
				data &data.;
				set  &data.;
				drop datetime;
				run;
			%END;
	%END;
	
	data _null_;
	set varlist ;
	call symput("NumVar" , _N_);
	run;
	
	%DO i = 1 %TO &NumVar. ;
	
	
		data _null_;
		set varlist(obs = &i. firstobs = &i.) ;
		call symput("var" , var);
		run;
		%PUT <<<<<<<<<<<< Taking &FUNCTION. for Variable &VAR. >>>>>>>>>>>>>>;
	
		proc sql;
		create table &data. as
		select *, &FUNCTION.(&var.) as &FUNCTION._&var.
		from 	&data.
		group by &group.;
		quit;
	
		data &data.;
		set	&data. ;
		drop &var.;
		rename &FUNCTION._&var. = &var.;
		run;
	
	%END;


proc datasets;
delete varList;
run;


%MEND RESAMPLE;

%RESAMPLE;


proc sql;
create table outlib.&data._&RESAMPLE_FREQUENCY. as 
select distinct * 
from &data.
order by &group.;
quit;

%PUT <<<<<<<<<<<<< END OF PROCESS >>>>>>>>>>>>>>>>>>>;








