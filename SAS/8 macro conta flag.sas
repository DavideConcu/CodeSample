
************************;
*** MACRO CONTA FLAG ***;
************************;

%MACRO CONTA_FLAG(DATA = , CONDIZIONE = , KEEP =);

data COUNT;
set  &DATA.;
FLAG = 1*(&CONDIZIONE.);
KEEP FLAG &keep.;
run;


data COUNT;
set COUNT;
by FLAG notsorted;
if FIRST.FLAG and FLAG = 1 then COUNT = 0;
COUNT + 1;
if FLAG = 0 then COUNT = .;

if last.flag;

run;

proc sort data = count ;
by count desc;
run;

%MEND CONTA_FLAG;
