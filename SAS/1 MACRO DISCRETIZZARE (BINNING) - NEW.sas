

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




