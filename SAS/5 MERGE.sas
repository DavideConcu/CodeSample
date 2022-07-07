

*** MACRO PER MERGE ***;


%MACRO LEFTJOIN( 
dataleft = ,
dataright = ,
out= ,
vars = ,
by = 
);

%PUT     I N I Z I O     L E F T J O I N;


proc sort data = &dataleft. nodup;
by &by. ;
run;
proc sort data = &dataright. nodup;
by &by. ;
run;

data &out.;
merge &dataleft.(in = a ) &dataright.(keep = &by. &vars. );
by &by. ;
if a;
run; 

%MEND LEFTJOIN;



%MACRO INNERJOIN( 
dataleft = ,
dataright = ,
out= ,
vars = ,
by = ,
);

%PUT     I N I Z I O     I N N E R J O I N;

proc sort data = &dataleft. nodup;
by &by. ;
run;
proc sort data = &dataright. nodup;
by &by. ;
run;

data &out.;
merge &dataleft. (in = a ) &dataright.(keep = &by. &vars. in = b);
by &by. ;
if a and b;
run; 

%MEND INNERJOIN;






%MACRO UNION( 
dataleft = ,
dataright = ,
out= ,
vars = ,
by = ,
);

%PUT     I N I Z I O     U N I O N;


proc sort data = &dataleft. nodup;
by &by. ;
run;
proc sort data = &dataright. nodup;
by &by. ;
run;

data &out.;
merge &dataleft. &dataright.(keep = &by. &vars. );
by &by. ;
run; 

%MEND UNION;


