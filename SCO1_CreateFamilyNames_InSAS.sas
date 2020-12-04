LIBNAME testing sqlsvr user='cable\rannam253' password='' dsn='BI_MIP' SCHEMA='Rpt' qualifier=RptCB;
Libname tes "/app/sasdata/Public/users/rannam253";
LIBNAME mip sqlsvr user='cable\rannam253' password='' dsn='BI_MIP' SCHEMA='MIP3';


/* Create ID only table */
PROC SQL;
   CREATE TABLE SCA1 AS 
   SELECT t1.FILE_GROUP, 
          t1.CSG_BUSN_ID, 
          t1.CSG_HQ_ID, 
          t1.SVM_BUSN_ID, 
          t1.SVM_HQ_ID, 
          t1.SVAN_BUSN_ID, 
          t1.SVAN_HQ_ID, 
          t1.SV_ROOT_ACCOUNT, 
          t1.SV_ACCOUNT, 
          t1.SV_WD_SITE, 
          t1.DISTINCT_LOC_ID, 
          t1.CSG4, 
          t1.CSG_ACCOUNT
		  
		  
	FILE_GROUP
     CSG_BUSN_ID, 
     CSG_HQ_ID, 
     SVM_BUSN_ID, 
     SVM_HQ_ID, 
     SVAN_BUSN_ID, 
     SVAN_HQ_ID, 
     SV_ROOT_ACCOUNT, 
     SV_ACCOUNT, 
     SV_WD_SITE, 
     DISTINCT_LOC_ID, 
     CSG4, 
     CSG_ACCOUNT
      FROM TES.SCA_MODULE_STAGE1X t1;
QUIT;

/* Create SV or SV assiciated CSG accounts */
PROC SQL;
   CREATE TABLE SCA2 AS 
   SELECT *
      FROM SCA1 
where compress(file_group) not in  ("CSG");
QUIT;

/* Create CSG only accounts */
PROC SQL;
   CREATE TABLE SCA22 AS 
   SELECT *
      FROM SCA1 
where compress(file_group)  in  ("CSG");
QUIT;



/* validation step
proc sql;
create table test as select count(distinct(SV_ROOT_ACCOUNT)) from stage1;
quit;
*/

/* 1st waterfall - Consolidate SV Root account and SV sub account to create household id 1 */
Data stage1;
set sca2 (keep= SV_ROOT_ACCOUNT SV_ACCOUNT);
run;

data full;
  set stage1 end=last;
  if _n_ eq 1 then do;
   declare hash h();
    h.definekey('node');
     h.definedata('node');
     h.definedone();
  end;
  output;
  node=SV_ROOT_ACCOUNT; h.replace();
  SV_ROOT_ACCOUNT=SV_ACCOUNT; SV_ACCOUNT=node; output;
  node=SV_ROOT_ACCOUNT; h.replace();
  if last then h.output(dataset:'node');
  drop node;
run;


data want(keep=node household);
declare hash ha(ordered:'a');
declare hiter hi('ha');
ha.definekey('count');
ha.definedata('last');
ha.definedone();
declare hash _ha(hashexp: 16);
_ha.definekey('key');
_ha.definedone();

if 0 then set full;
declare hash from_to(dataset:'full',hashexp:20,multidata:'y');
from_to.definekey('SV_ROOT_ACCOUNT');
from_to.definedata('SV_ACCOUNT');
from_to.definedone();

if 0 then set node;
declare hash no(dataset:'node');
declare hiter hi_no('no');
no.definekey('node');
no.definedata('node');
no.definedone();


do while(hi_no.next()=0);
household+1; output;
count=1;
key=node;_ha.add();
last=node;ha.add();
rc=hi.first();
do while(rc=0);
   SV_ROOT_ACCOUNT=last;rx=from_to.find();
   do while(rx=0);
     key=SV_ACCOUNT;ry=_ha.check();
      if ry ne 0 then do;
       node=SV_ACCOUNT;output;rr=no.remove(key:node);
       key=SV_ACCOUNT;_ha.add();
       count+1;
       last=SV_ACCOUNT;ha.add();
      end;
      rx=from_to.find_next();
   end;
   rc=hi.next();
end;
ha.clear();_ha.clear();
end;
stop;
run;

proc sort data=want out=want_1 nodupkey;
by node;
run;

data want_2 (drop= node); set want_1;
node1=input(node,16.);
run;

/* 2nd waterfall - Consolidate above with SV HQ ID to create household id 2 */

PROC SQL;
   CREATE TABLE SCA3 AS 
   SELECT a.*,b.household
      FROM SCA2 as a left join want_1 as b on a.SV_ROOT_ACCOUNT = b.node;

QUIT;


data SCA4; set SCA3;
if SVM_HQ_ID=. then SVM_HQ_ID= household;


run;



Data stage3;
set sca4 (keep= SVM_HQ_ID household);
run;


data full;
  set stage3 end=last;
  if _n_ eq 1 then do;
   declare hash h();
    h.definekey('node');
     h.definedata('node');
     h.definedone();
  end;
  output;
  node=SVM_HQ_ID; h.replace();
  SVM_HQ_ID=household; household=node; output;
  node=SVM_HQ_ID; h.replace();
  if last then h.output(dataset:'node');
  drop node;
run;


data want(keep=node householdd);
declare hash ha(ordered:'a');
declare hiter hi('ha');
ha.definekey('count');
ha.definedata('last');
ha.definedone();
declare hash _ha(hashexp: 16);
_ha.definekey('key');
_ha.definedone();

if 0 then set full;
declare hash from_to(dataset:'full',hashexp:20,multidata:'y');
from_to.definekey('SVM_HQ_ID');
from_to.definedata('household');
from_to.definedone();

if 0 then set node;
declare hash no(dataset:'node');
declare hiter hi_no('no');
no.definekey('node');
no.definedata('node');
no.definedone();


do while(hi_no.next()=0);
householdd+1; output;
count=1;
key=node;_ha.add();
last=node;ha.add();
rc=hi.first();
do while(rc=0);
   SVM_HQ_ID=last;rx=from_to.find();
   do while(rx=0);
     key=household;ry=_ha.check();
      if ry ne 0 then do;
       node=household;output;rr=no.remove(key:node);
       key=household;_ha.add();
       count+1;
       last=household;ha.add();
      end;
      rx=from_to.find_next();
   end;
   rc=hi.next();
end;
ha.clear();_ha.clear();
end;
stop;
run;


proc sort data=want out=want_1 nodupkey;
by node;
run;

data want_2 (drop= node); set want_1;
node1=input(node,16.);
run;
/* 3rd waterfall - Consolidate above with SV AN HQ ID to create household id 3 */

PROC SQL;
   CREATE TABLE SCA5 AS 
   SELECT a.*,b.householdd
      FROM SCA4 as a left join want_1 as b on a.SVM_HQ_ID = b.node;

QUIT;

proc sort data=SCA5;
by householdd;
run;

data SCA6; set SCA5;
if SVAN_HQ_ID=. then SVAN_HQ_ID= householdd;
run;




Data stage5;
set sca6 (keep= SVAN_HQ_ID householdd);
run;


data full;
  set stage5 end=last;
  if _n_ eq 1 then do;
   declare hash h();
    h.definekey('node');
     h.definedata('node');
     h.definedone();
  end;
  output;
  node=SVAN_HQ_ID; h.replace();
  SVAN_HQ_ID=householdd; householdd=node; output;
  node=SVAN_HQ_ID; h.replace();
  if last then h.output(dataset:'node');
  drop node;
run;


data want(keep=node householddd);
declare hash ha(ordered:'a');
declare hiter hi('ha');
ha.definekey('count');
ha.definedata('last');
ha.definedone();
declare hash _ha(hashexp: 16);
_ha.definekey('key');
_ha.definedone();

if 0 then set full;
declare hash from_to(dataset:'full',hashexp:20,multidata:'y');
from_to.definekey('SVAN_HQ_ID');
from_to.definedata('householdd');
from_to.definedone();

if 0 then set node;
declare hash no(dataset:'node');
declare hiter hi_no('no');
no.definekey('node');
no.definedata('node');
no.definedone();


do while(hi_no.next()=0);
householddd+1; output;
count=1;
key=node;_ha.add();
last=node;ha.add();
rc=hi.first();
do while(rc=0);
   SVAN_HQ_ID=last;rx=from_to.find();
   do while(rx=0);
     key=householdd;ry=_ha.check();
      if ry ne 0 then do;
       node=householdd;output;rr=no.remove(key:node);
       key=householdd;_ha.add();
       count+1;
       last=householdd;ha.add();
      end;
      rx=from_to.find_next();
   end;
   rc=hi.next();
end;
ha.clear();_ha.clear();
end;
stop;
run;


proc sort data=want out=want_1 nodupkey;
by node;
run;

data want_2 (drop= node); set want_1;
node1=input(node,16.);
run;

PROC SQL;
   CREATE TABLE SCA7 AS 
   SELECT a.*,b.householddd
      FROM sca6 as a left join want_1 as b on a.SVAN_HQ_ID = b.node;

QUIT;

proc sort data=SCA7;
by householddd;
run;



proc append base=SCA7 data=SCA22 force;
run;


data sca222;set sca22;
if CSG_HQ_ID=. then CSG_HQ_ID= CSG_ACCOUNT;
run;

proc sql;
create table wf1 as
select a.SVAN_HQ_ID,a.householddd
from SCA7 as a where 
a.SVAN_HQ_ID in ( select CSG_HQ_ID from sca222) and 
SVAN_HQ_ID >10000
;
quit;

proc sort data=wf1 nodukey;
by SVAN_HQ_ID;
run;
/* Append SV/SV+CSG  with CSG only */
proc append base=SCA7 data=SCA22 force;
run;

data sca7; set sca7;
if CSG_HQ_ID=. then CSG_HQ_ID= CSG_ACCOUNT;
run;

/* Consolidate CSG only account with SV.SV+CSG using SV HQ or SV AN HQ matching */
proc sql;
create table wf2 as
select a.SVM_HQ_ID,a.householddd
from SCA7 as a where 
((a.SVAN_HQ_ID  not in ( select CSG_HQ_ID from sca222)) and SVAN_HQ_ID >10000)
and 
((( a.SVM_HQ_ID  in ( select CSG_HQ_ID from sca222))) and SVM_HQ_ID >10000)
;
quit;

proc sort data=wf2 nodukey;
by SVM_HQ_ID;
run;


proc sql; 
create table sca8 as
select a.*,b.householddd as h1,c.householddd as h2
FROM sca7 as a 
left join wf1 as b on b.SVAN_HQ_ID = a.CSG_HQ_ID 
left join wf2 as c on c.SVM_HQ_ID = a.CSG_HQ_ID 
            ;
	 quit;



proc sql; 
create table tes.sca9 as
select a.*,coalesce(householddd,h1,h2) as FamilyID
FROM sca8 as a
           ;
	 quit;

/* Consolidate CSG only using CSG HQ ID */ 
Data sca10 sca11; set tes.sca9;
if compress(file_group) in  ("CSG") and family =. then output sca10;
else output sca11;
run;

proc sort data=sca10 (where=(csg_hq_id ne .));
by CSG_HQ_ID ;
run;

data sca12 ;
set sca10 ;
by CSG_HQ_ID;
retain order 35869;
if first.CSG_HQ_ID then order=order+1;
run;

proc append base=SCA12 data=SCA11 force;
run;

proc sql; 
create table tes.sca13 as
select a.*,coalesce(FamilyID,order) as FinalFamilyID
FROM sca12 as a;
	 quit;


proc sort data=tes.sca_module_stage1x out=testing nodukey;
by distinct_loc_id;
run;

data tes.sca14; set tes.sca13 (keep= distinct_loc_id FinalFamilyID);run;


proc sql;
create table test as select count(distinct(FinalFamilyID)) from tes.sca14;
quit;
/* move to BI_MIP from SAS cloud */
data testing.sca14 ; set tes.sca14; run;
