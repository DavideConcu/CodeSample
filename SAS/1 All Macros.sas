

***************************************;
* MACRO PER DISCRETIZZARE VAR NUMERICHE;
***************************************;

* Inserire dataset, variabile da discretizzare (var), 
  valore iniziale (start) valore finale (end) 
	e larghezza intervalli (by).

es %binning(data=prova, var= kmday, start = 0, end = 125, by = 25);
	




%MACRO BINNING(data  =  , 
				var   =  , 
				start = 0, 
				end   = 100,
				by    = 10 );

*numero di categorie;
 %LET NUMCAT = %SYSFUNC( CEIL ( %SYSFUNC( ABS( (&END-&START.)/ &BY.) ) ) )  ;



* PROC FORMAT;
%PUT PROC FORMAT;

proc format;

 value &var._catform 
 .  = "NULL"
 -1 = "< &start."
 0  = "= &start."

%PUT  VALORI CATEGORIA = .,  VALORI = "NULL";
%PUT  VALORI CATEGORIA = -1,  VALORI = "< &start.";
%PUT  VALORI CATEGORIA = 0,  VALORI = "= &start.";


%LET INF = &START.;
%DO i = 1 %TO &NUMCAT.;

	%LET SUP = %EVAL(&INF. + &by.);

			%IF %EVAL(&SUP. <= &END.) %THEN %DO;

	 			&i. = "(&inf.  --  &sup.]"

	 			%PUT  VALORI CATEGORIA = &i.,  VALORI = "(&inf.  --  &sup.]";
			
			%END;
			%ELSE %DO;

	 			&i. = "(&inf.  --  &END.]"

	 			%PUT VALORI CATEGORIA = &i.,  VALORI = "(&inf.  --  &END.]";

			%END;

	%LET INF = %EVAL(&INF. + &by.);
	
%END;

	%LET LASTCAT = %EVAL(&NUMCAT. + 1);
	&LASTCAT. = "> &END."
	%PUT VALORI CATEGORIA = &i.,  VALORI = "> &END.";

 ;
RUN;

*DATASTEP;
%PUT DATASTEP;

	DATA &data.;
	SET  &data. ;
	FORMAT &var._cat &var._catform.;

		%LET INF = &START.;
		%DO i = 1 %TO &NUMCAT.;

			%LET SUP = %EVAL(&INF. + &by.);

			%IF %EVAL(&SUP. <= &END.) %THEN %DO;

				if (&inf.< &var. <= &sup.) then do;
			
					&var._cat =  &i.;

				end;

	 			%PUT  VALORI CATEGORIA = &i.,  VALORI = (&inf.< &var. <= &end.);
			
			%END;
			%ELSE %DO;

				if (&inf.< &var. <= &end.) then do;
			
					&var._cat =  &i.;

				end;

	 			%PUT VALORI CATEGORIA = &i.,  VALORI = (&inf.< &var. <= &end.);

			%END;

	%LET INF = %EVAL(&INF. + &by.);
	
%END;
	
			if (&var. > &end.) then do;
			
			&var._cat =  &LASTCAT.;

			end;
	
	%PUT VALORI CATEGORIA = &LASTCAT.,  VALORI = (&var. > &end.);

RUN;

%MEND BINNING;




%PUT PARAMETRI BINNING: BINNING(data  =  , 
				var   =  , 
				start = 0, 
				end   = 100,
				by    = 10 );





* MACRO QUARTILI ;


*DOD MACROS;
%MACRO QUARTILI(VAR,DATA, where = 1);
%GLOBAL q1 q2 q3;

proc means data= &DATA. q1 mean q3 noprint ;
var &VAR.; 
where &where. ;
output out= h q1=q1 mean=q2 q3=q3;
run;

proc sql noprint;
select round(q1,0.01) as q1, round(q2,0.01) as q2,  round(q3,0.01) as q3
into :q1 , :q2, :q3 
from h;
quit;
%put &VAR: Q1=&q1 Q2=&q2 Q3=&q3;

proc datasets noprint;
delete h;
run;

%MEND QUARTILI;









************************************;
* Var char: drop vuote e conversione;
************************************;



*%let data = ;





****************************;
%macro MAX(data=);
	data _null_ ;
	set &data.;
	%global max;
	call symput("max", _n_);
	run;
	%let max= &max.;
%mend MAX;
%macro VARNAME(data= , varlist=_name_ );
	data _null_ ;
	set &data.(firstobs= &i.  obs = &i.);
	%global varname;
	call symput("varname", &varlist.);
	run;
	%let varname = &varname. ;
%mend VARNAME;
****************************;








***********************************;
* Conversione char in numeriche    ;
***********************************;
	
	

%macro char_conversion(data= );

	*Trasp delle var NUMERICHE;
	proc transpose data=&data.(obs=0) out=trnum  ;
	run;
	proc sort data=trnum;
	by _name_;
	run;
	
	*Trasp di TUTTE le variabili;
	proc transpose data=&data.(obs=0) out=trall ;
	var _all_;
	run;
	proc sort data=trall;
	by _name_;
	run;
	
	*Tengo solo le variabili CHAR;
	data char;
	merge trall (in=a) trnum (in=b);
	by _name_;
	if  a=1 and b=1 then delete;
	run;
	
%max(data=char);
	
%do i = 1 %to &max. ;
	
%varname(data=char);

	proc sort data= &data. (keep=&varname.) out= sort;
	by descending &varname. ;
	run;
	
	*Trasformo solo le var carattere che hanno numeri;
	data c&i.(keep=list_convert) o&i.(keep=list_ok) e&i.(keep=list_empty);
	
	set sort (keep=&varname. obs=1 firstobs=1);
	
	length list_convert $ 32 ;
	length list_ok $ 32 ;
	length list_empty $ 32 ;

	if  &varname. ne " " then do;
	
		a = input(&varname., 15.);
		
			if a  ne . then do;
				list_convert = "&varname";
				output c&i.;
			end;
		
			else if a  = . then do;
				list_ok = "&varname";	
				output o&i.;
			end;
	
	end;
	
	else if  &varname. = " " then do;
		list_empty = "&varname.";
		output e&i.;
	end;

	run;
	
%end;

	* Append dei dataset;
	data list_convert;
	set c1-c&max.;
	run;
	data list_ok;
	set o1-o&max.;
	run;
	data list_empty;
	set e1-e&max.;
	run;
	
	*delete dataset;
	proc delete data=trall sort trnum char ;
	run;
	proc delete data=  c1-c&max. o1-o&max. e1-e&max.;
	run;
	

%MAX(data=list_convert);

%do i = 1 %to &max.;

%VARNAME(data=list_convert , varlist = list_convert);
	
	data &data.;
	set &data. ;
	
	a = 1 * &varname.;	
	
	drop &varname. ; 
	
	rename a = &varname. ;
	run;
	
%end;

%mend char_conversion;


%macro empty_char_drop (data = );
	
	%MAX(data=list_empty);
	
	%do i = 1 %to &max.;
	
	%VARNAME(data=list_empty , varlist = list_empty);
		
		data &data.;
		set &data. ;
		
		drop &varname. ;
		
		run;
		
	%end;

%mend empty_char_drop;



%char_conversion(data = &data. );

%empty_char_drop(data = &data. );



	
	proc means data=&data.  n  nmiss  ;
	run;




******* AVG MEAN *******;
%MACRO MEDIAPONDERATA(
		DATA   = , 
		VAR = ,
		PESO   = , 
		GRUPPO = );


data &data.;
set  &data.;
drop SOMMA_PESI_&var. &VAR._AVG;
run;

* CALCOLO DEI PESI TOTALI;
PROC SQL;
CREATE TABLE &DATA. AS
SELECT 	*,	
			SUM(&PESO.) AS SOMMA_PESI_&var.,
			(&VAR. * &PESO. )/ CALCULATED SOMMA_PESI_&var. AS TO_BE_SUMMED
FROM &DATA.

GROUP BY &GRUPPO.
HAVING CALCULATED SOMMA_PESI_&var. >0
ORDER BY &GRUPPO.
;
QUIT;

PROC SQL;
CREATE TABLE &DATA. AS
SELECT  *, SUM(TO_BE_SUMMED) AS &VAR._AVG
FROM &DATA.
GROUP BY &GRUPPO.
ORDER BY &GRUPPO.
;
QUIT;

PROC SQL;
ALTER TABLE &DATA.
DROP  TO_BE_SUMMED
;
QUIT;

PROC SQL;
CREATE TABLE &DATA. AS
SELECT DISTINCT * 
FROM &DATA.
ORDER BY &GRUPPO.
;
QUIT;


%MEND;


%PUT PARAMETRI: MEDIAPONDERATA(
		DATA   = , 
		VAR = ,
		PESO   = , 
		GRUPPO = );








* AGGIUNGE VARIABILE NUMERICA CON FORMATO UGUALE ALLA VARIABILE RANGE DI PARTENZA;

%MACRO VAR_RANGE(DATA = , VAR = );


PROC SQL;
CREATE TABLE &VAR._CAT AS 
SELECT DISTINCT &VAR.,&VAR. AS LABEL, INPUT(SCAN(TRIM(&VAR.),1) , BEST12.)  AS INF , 
						INPUT(SCAN(TRIM(&VAR.),-1), BEST12.)  AS SUP ,
						(CALCULATED INF + CALCULATED SUP) / 2 AS &VAR._CENTRAL
FROM &DATA.
ORDER BY CALCULATED INF;
QUIT;

DATA &VAR._CAT;
LENGTH FMTNAME $ 35;
SET &VAR._CAT ;
START = _N_;
FMTNAME = "&VAR._FMT";
RUN;

PROC SQL;
INSERT INTO &VAR._CAT
SET FMTNAME = "&VAR._FMT",
	LABEL = "NULL",
	START = 0
	;
QUIT;

PROC FORMAT CNTLIN=&VAR._CAT ;
RUN;

PROC SQL;
CREATE TABLE &DATA. AS
SELECT D.* , F.START AS &VAR._CAT FORMAT = &VAR._FMT.,
			&VAR._CENTRAL
FROM &DATA. D
	LEFT JOIN &VAR._CAT F
	ON D.&VAR. = F.&VAR.
;
QUIT;

proc datasets noprint;
delete &VAR._CAT;
run;

%MEND VAR_RANGE;

%PUT PARAMETRI VAR_RANGE(DATA = , VAR = );







*******************************************************;
*** MACRO PER CALCOLARE IL VALORE SUCCESSIVO (LEAD) ***;
*******************************************************;

* IL DATASET DEVE ESSERE GIA' ORDINATO;

%MACRO LEAD( Data = , Var = , By = );

proc sort data = &data. ;
by &by.;
run;

	data &data.;
	set &data.;
	n = _N_;
	run;

	data lead;
	set &data. ( keep = &var. firstobs = 2);
	n = _N_;
	rename &var. = LEAD_&var.;
	run;

	data &data.;
	merge &data. lead;
	by N;
	drop n;
	run;

	data &data.;
	set &data.;
	by &by.;

	IF last.&by. then LEAD_&var. = . ;

	run;

	proc datasets noprint;
	delete lead;
	run;

%MEND LEAD;

