
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
