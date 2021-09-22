*1.1  Explore and describe the dataset briefly. For example, is the acctno unique? What
is the number of accounts activated and deactivated? When is the earliest and
latest activation/deactivation dates available? And so on….;

*BROWSING THE DESCRIPTION PORTION ;
proc contents data = Arun_kum.Sas5;
run;

PROC SQL;
   DESCRIBE TABLE Arun_kum.Sas5;
QUIT;

* BROWSING THE DATA PORTION (VALUES OF YOUR SAS DATA);
*head;
proc print data=Arun_kum.Sas5 (obs=5);
run;

* TAIL OF DATASET ;
proc print DATA = Arun_kum.Sas5 (OBS=5 FIRSTOBS = 102251);
RUN;



* CHECKING WHETHER ACCOUNT NUMBER IS UNIQUE OR NOT AND WILL REMOVE DUPLICATES IF EXISTS;
*REMOVE DUPLICATES;
PROC SORT DATA = Arun_kum.Sas5 OUT = Arun_kum.Sas5_NDUP NODUPKEY;
BY Acctno;
run;

/*NOTE: There were 102255 observations read from the data set WORK.DATA_WX.
NOTE: 0 observations with duplicate key values were deleted.
NOTE: The data set WORK.DATA_WX_NDUP has 102255 observations and 10 variables.*/



proc print data = TABLE_Acctno;run;
proc sql;
SELECT DISTINCT Acctno
from Arun_kum.Sas5 (obs=100)
;

*What is the number of accounts activated and deactivated?;

PROC SQL;
SELECT COUNT(Acctno) AS TOTAL_ACCOUNTS,(COUNT(AcctNO)-COUNT(Deactd)) AS NO_ACTVTD_ACCOUNTS,
COUNT(Deactd) AS NO_DEACTVTD_ACCOUNTS
FROM Arun_kum.Sas5;
QUIT;


*When is the earliest and latest activation/deactivation dates available?;


TITLE "FIRST ACTIVATION DATE";
PROC SQL OUTOBS=1;
SELECT * FROM Arun_kum.Sas5
WHERE Actdt IS NOT NULL
ORDER BY Actdt ASC;
QUIT;
TITLE;

TITLE "LAST ACTIVATION DATE";
PROC SQL OUTOBS=1;
SELECT * FROM Arun_kum.Sas5
WHERE Actdt IS NOT NULL
ORDER BY Actdt DESC;
QUIT;
TITLE;


TITLE "FIRST DEACTIVATION DATE";
PROC SQL OUTOBS=1;
SELECT * FROM Arun_kum.Sas5
WHERE Deactdt IS NOT NULL
ORDER BY Deactdt ASC;
QUIT;
TITLE;

TITLE "LAST DEACTIVATION DATE";
PROC SQL OUTOBS=1;
SELECT * FROM Arun_kum.Sas5
WHERE Deactd IS NOT NULL
ORDER BY Deactd DESC;
QUIT;
TITLE;



=======================================================================================================
========================================================================================================
*1.2  What is the age and province distributions of active and deactivated customers?;

PROC SQL;
SELECT Acctno, Actdt,Deactd,age,province
FROM Arun_kum.Sas5(OBS=100)
where Deactd is not null;
QUIT;


 1) Calculate the tenure in days for each account and give its simple statistics.

 data Sas6 (OBS=100);
 date1='Actdt';
 date2='Deactd';
 days_between=date2 - date1;
* format date1 date2 Date10.;
run;

proc print data=Sas6; run;

==========================================================

*1.1Explore and describe the dataset briefly. For example, is the acctno unique;

proc freq data = Arun_kum.Sas6;
table Actdt Deactd /MISSING list;
run;

======================================================================

======================================================================

*1.2  What is the age and province distributions of active and deactivated customers?;

data Sas6;
set Arun_kum.Sas5;
if Deactd = '' then Customer_Type='Active';
 else Customer_Type='D-active';
 run;
PROC SQL;
 SELECT Acctno, Actdt,Deactd,age,province,Customer_Type
 FROM Sas6(OBS=100)
 ;
 QUIT;

 =======================================================================
/**1.3 Segment the customers based on age, province and sales amount:
Sales segment: < $100, $100---500, $500-$800, $800 and above.
Age segments: < 20, 21-40, 41-60, 60 and above.
Create analysis report **/

proc format;
  value agefmt
        low-<20="=<20"
		21- <40="21-40"
		41- <60="41-60"
		60-high="60 PLUS"
		;
		run;

	PROC FORMAT;
	Value Salesfmt
	    low-<100="100"
		100- <500="100-500"
		500- <800="500-800"
		800-high="800 PLUS"
		;
		run;

		proc print data=Sas6 (OBS=100);
		format age agefmt. 
        Sales Salesfmt.;
		run;
==========================================================================================
*1.4.1 Statistical Analysis:1) Calculate the tenure in days for each account and give its simple 
  statistics.;

data Sas16;
set Arun_kum.Sas5;
IF  MISSING(Deactd) THEN DAYS=INTCK('DAY', Actdt,TODAY());
ELSE
DAYS=INTCK('DAY', Actdt, Deactd);
run;

proc print data=Sas16(obs=100);
run;

========================================================================================================

*1.4 2)Calculate the number of accounts deactivated for each month;
proc SQL;
create table Sas7 as
select Actdt,Deactd,
intck('month',Actdt,Deactd) as Months
from Arun_kum.Sas5(OBS=100)
where Deactd IS NOT MISSING
; 
quit;

proc print data=Sas7(obs=100);
run;

data Sas18;
set Arun_kum.Sas5;
month = intnx('month',Deactd,0,'b');
format month MONNAME3. ;
Sales = SUBSTR(Sales,2,7);
Sales_formatted = input(Sales, best12.);
if month ='' then Account_Status = 'Active     ';
else Account_Status = 'Deactivated';
run;
proc print data=Sas18(obs=100);
run;
=====================================================================================================

====================================================================================================
*1.4.3) Segment the account, first by account status “Active” and “Deactivated”, then by
Tenure: < 30 days, 31---60 days, 61 days--- one year, over one year. Report the
number of accounts of percent of all for each segment;

data Sas17;
set Arun_kum.Sas5;
length tenure_group $20;
if tenure='.' then tenure_group='';
   else if tenure<30 then tenure_group='0-30 days';
   else if tenure<61 then tenure_group='31-60 days';
   else if tenure<366 then tenure_group='61 days--one year';
   else tenure_group='over one year';
   run;
   proc print data=Sas17(OBS=100);
   run;


proc freq data=Sas8;
   table tenure*tenure_group/list;
   run;
   proc freq data=Sas6;
   table Account_status/list;
   run;


data Sas12;
set c;
tenure=intck('day',Actdt,'01FEB2001'd);
RUN;
proc print data=Sas12(obs=100);
run;


proc means data=Sas8; var tenure;
run;


===================================================
*1.4.4) Test the general association between the tenure segments and “Good Credit”
“RatePlan ” and “DealerType.”

PROC FREQ DATA = Sas8;
TITLE "RELATIONSHIP BETWEEN BETWEEN Tenure_group & GoodCredit";
TABLE tenure_group * GoodCredit /CHISQ OUT=OUT_GoodCredit;
RUN;


PROC FREQ DATA = Sas8;
TITLE "RELATIONSHIP BETWEEN BETWEEN Tenure_group & RatePlan";
TABLE tenure_group * RatePlan /CHISQ OUT=OUT_RatePlan;
RUN;

PROC FREQ DATA = Sas8;
TITLE "RELATIONSHIP BETWEEN BETWEEN Tenure_group & DealerType";
TABLE tenure_group * DealerType /CHISQ OUT=OUT_DealerType;
RUN;
===================================================================
=======================================================================
PROC FREQ DATA = Sas8;
TITLE "RELATIONSHIP BETWEEN BETWEEN TENURE_GROUP AND RATEPLAN";
TABLE tenure_group * GoodCredit/CHISQ OUT=OUT_tenure_group;
RUN;

%LET DSN =Sas8 ;
%LET VAR1 =tenure_group;
%LET VAR2 = GoodCredit;

PROC FREQ DATA = &DSN;
TITLE "RELATIONSHIP BETWEEN BETWEEN TENURE_GROUP AND RATEPLAN";
 TABLE &VAR1. * &VAR2. /CHISQ OUT=OUT_&VAR1._&VAR2 ;
RUN;

%MACRO CHSQUARE (DSN = ,VAR1= , VAR2= );
PROC FREQ DATA = &DSN;
TITLE "RELATIONSHIP BETWEEN BETWEEN TENURE_GROUP AND RATEPLAN";
 TABLE &VAR1. * &VAR2. /CHISQ OUT=OUT_&VAR1._&VAR2 ;
RUN;
%MEND CHSQUARE;
%CHSQUARE(DSN = Sas8 , VAR1=tenure_group , VAR2 =GoodCredit);
%CHSQUARE(DSN = Sas8 , VAR1=tenure_group , VAR2 =RatePlan);
%CHSQUARE(DSN = Sas8 , VAR1=tenure_group , VAR2 =DealerType);

======================================================================== 


====================================================================================================
*5) Is there any association between the account status and the tenure segments?
Could you find out a better tenure segmentation strategy that is more associated
with the account status?;

data Sas8;
set Sas8;

   length Account_Status $11.;
   if Deactd=. then Account_Status='Active';
   Else Account_Status='Deactivated';
   run;



%MACRO CHSQUARE (DSN = ,VAR1= , VAR2= );
ods graphics on;
proc freq data=&DSN;
tables (&VAR1.)*(&VAR2) / chisq
 plots=(freqplot(twoway=grouphorizontal
 scale=percent));
run;
ods graphics off
%MEND CHSQUARE;

%CHSQUARE(DSN = Sas8 , VAR1= tenure_group , VAR2 = Account_status);


proc SGPLOT data = Sas8;
vbar Account_Status /group = tenure_Group ;
Title 'Association Between Account_Status & Tenure_Group';
run;
quit;


===================================================================================
PROC FREQ DATA = Sas8;
TITLE "RELATIONSHIP BETWEEN BETWEEN TENURE GROUP AND Account_Status";
TABLE Account_Status* tenure_group/CHISQ OUT=OUT_ Account_Status;
RUN;

%LET DSN =Sas8; ;
%LET VAR1 = Account_Status;
%LET VAR2 = tenure_group;

PROC FREQ DATA = &DSN;
TITLE "RELATIONSHIP BETWEEN BETWEEN TENURE GROUP AND Account_Status";
 TABLE &VAR1. * &VAR2. /CHISQ OUT=OUT_&VAR1._&VAR2 ;
RUN;

%MACRO CHSQUARE (DSN = ,VAR1= , VAR2= );

PROC FREQ DATA = &DSN;
TITLE "RELATIONSHIP BETWEEN BETWEEN TENURE GROUP AND Account_Status";
 TABLE &VAR1. * &VAR2 /CHISQ OUT=OUT_&VAR1._&VAR2 ;

RUN;
%MEND CHSQUARE;



===============================================================================
*6) Does Sales amount differ among different account status, GoodCredit, and
customer age segments?;

Title 'Sales & Account_status';
proc sgplot data=Sas8;
  vbar Account_Status / response= Sales  stat=sum nostatlabel;
  xaxis display=(nolabel);
  yaxis grid;
  run;

  proc ttest data=Sas8;
      class  Account_Status;
      var  Sales;
   run;
Title 'Sales & GoodCredit';
proc ttest data=Sas8;
      class  GoodCredit;
      var  Sales;
   run;

data Sas20;
Set Sas6;
format Age agefmt.;
run;

Title 'Sales & Age Segments ';
proc sgplot data=Sas20;
  vbar  Age / response= Sales  stat=sum nostatlabel;
  xaxis display=(nolabel);
  yaxis grid;
  run;


Title "Sales & Customer Age groups";
proc Anova Data= Sas20;
class Age;
Model Sales = Age;
Means Age/Scheffe;
run;
================================================================================


=========================================================================
