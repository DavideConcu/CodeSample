
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

