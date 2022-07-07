
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

