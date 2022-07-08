

*** ESTRAZIONE SEGNALI GREZZI TERMOSTATO ***;

*** PARAMETRI ***;
%LET DATA 			= ;
%LET OUTPUT 		= ;

%LET item 			=;


%let LISTA_VIN 		= ;
%let nomevar_vin 	= ;


%let by= 50;


%LET WHERE = 								 ( 	CHASSIS IN (&VINS.)
											AND NAMEITEM = "&item."
											AND (	(MONTH>= 10 AND YEAR = 2019) OR YEAR > 2019	)
											AND PROCESSED_SIGNALS > 0
												);

*******************************************************;




%MACRO ESTRAZIONE_TRM;


DATA lista_vin;
SET &lista_VIN.;
N = _n_;
CALL SYMPUT("NUMVIN", _N_);
RUN;
%PUT <<< TOTALE VIN: &NUMVIN >>>;


	
	
	%LET TOTALE_ITERAZIONI = %SYSFUNC( CEIL ( %SYSFUNC( ABS( &NUMVIN. / &BY.) ) ) )  ;
	%PUT <<<  TOTALE ITERAZIONI DA ESEGUIRE:  &TOTALE_ITERAZIONI >>>;
	
	
	%LET LIMITE_INFERIORE = 0 ;
	%LET LIMITE_SUPERIORE = &BY.;

	%DO iterazione_VIN = 1 %TO &TOTALE_ITERAZIONI.;
	

	PROC SQL OUTOBS= NOPRINT;
	SELECT distinct QUOTE(TRIM(&NOMEVAR_vin.))
	INTO 	:VINS SEPARATED BY "," 
	FROM 	LISTA_VIN
	where &LIMITE_INFERIORE. < N <= &LIMITE_SUPERIORE. ;
	QUIT;
	%PUT <<<  VIN TRA &LIMITE_INFERIORE. E &LIMITE_SUPERIORE. >>>;



				PROC SQL;
				CONNECT USING DBRICKS;
				CREATE TABLE &output._vin&iterazione_VIN. AS
				SELECT *
				FROM CONNECTION TO DBRICKS( 
							SELECT DISTINCT
							MissionId, 
							chassis, 
							sum((accumulator*processed_signals/sum_procsign)) as AVG_exttemp
							FROM 	 	(select  
										a., 
										a., 
										a., 
										a., 
										b.
										from &data. as a
												inner join (
															select , , sum() as 
															from &data.
															where &where.
															group by , 
															) as b
												on (a. = b. AND a. = b.)
										where 	(
												a. IN (&VINS.)
												AND a.NAMEITEM = "&item."
												AND (	(a.>= 10 AND a. = 2019) OR a. > 2019	)
												AND a. > 0
												)
										)
							GROUP BY , 
						)
			
				order by ;
				QUIT;
	
	%LET LIMITE_INFERIORE = %EVAL(&LIMITE_INFERIORE. + &BY.);
	%LET LIMITE_SUPERIORE = %EVAL(&LIMITE_SUPERIORE. + &BY.);
			
	%END;

%MEND ESTRAZIONE_TERMOSTATO;


%ESTRAZIONE_TERMOSTATO;



