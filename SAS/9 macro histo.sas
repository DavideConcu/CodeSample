
*MACRO HISTOGRAM;

%include "C:\Users\f08132d\OneDrive - CNH Industrial\Desktop\PROGRAMMI SAS\x MACRO UTILI\2 MACRO QUARTILI.sas";

%MACRO HISTO(data = , var = , start =0 , end =100 , by =10 , byy=  );


%quartili(data=  &data., var = &var.  );

ods graphics on;
title;
proc capability data=&data.  noprint;
specs target = &q2. lsl = &q1. usl = &q3.  
cleft= bgr cright=bgr ctarget=bib clsl=bgr cusl=bgr;

var &var.;

histogram &var./outhistogram=prova midpoints=&start. to &end. by &by. cbarline = black;

inset n min max MEAN / position=ne;
&byy.
run;

%MEND HISTO;

%PUT PARAMETRI HISTOGRAM:   HISTO(data = , var = , start = , end = , by = , byy= );
