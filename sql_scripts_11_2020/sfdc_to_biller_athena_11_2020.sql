--drop table #temp1

 select 
	*
into
	#temp1
from
	rptcb.rpt.SCA_MODULE_STAGE1X_DYAO_11_2020

create nonclustered index ix_temp_1 on #temp1 (family_id)


ALTER TABLE  #temp1 ADD sfdc_nat_ind VARCHAR(5) NULL, sfdc_nat_sp_ind VARCHAR(5) NULL, parent_id VARCHAR(30), sfdc_account VARCHAR(100), owner_id VARCHAR(40), am_module VARCHAR(50), cage_number VARCHAR(100)


--Lets get all module accounts first

-- SV Only (ROOT)
UPDATE #temp1
SET parent_id = b.parentid, sfdc_account = b.ACCOUNT__C, owner_id = b.OwnerID, 
	am_module = b.AM_Module__c, cage_number = CAGE_Number__c, sfdc_nat_ind = b.SFDC_NAT_IND,
	sfdc_nat_sp_ind = b.SFDC_NAT_SP_IND
FROM rptcb.rpt.sfdc_to_biller_dyao_11_2020 b
WHERE b.AM_Module__c is NOT NULL and CSG_ACCOUNT IS NULL 
	  and SV_ROOT_ACCOUNT = b.SV1
--1,029 records in 3:00
-- 904 records (with no OR statement) 3 sec

UPDATE #temp1
SET parent_id = b.parentid, sfdc_account = b.ACCOUNT__C, owner_id = b.OwnerID, 
	am_module = b.AM_Module__c, cage_number = CAGE_Number__c, sfdc_nat_ind = b.SFDC_NAT_IND,
	sfdc_nat_sp_ind = b.SFDC_NAT_SP_IND
FROM rptcb.rpt.sfdc_to_biller_dyao_11_2020 b
WHERE b.AM_Module__c is NOT NULL and CSG_ACCOUNT IS NULL 
	  and SV_ROOT_ACCOUNT = b.SV3 
-- 8 records (with no OR statement) 3 sec

UPDATE #temp1
SET parent_id = b.parentid, sfdc_account = b.ACCOUNT__C, owner_id = b.OwnerID, 
	am_module = b.AM_Module__c, cage_number = CAGE_Number__c, sfdc_nat_ind = b.SFDC_NAT_IND,
	sfdc_nat_sp_ind = b.SFDC_NAT_SP_IND
FROM rptcb.rpt.sfdc_to_biller_dyao_11_2020 b
WHERE b.AM_Module__c is NOT NULL and CSG_ACCOUNT IS NULL 
	  and SV_ROOT_ACCOUNT = b.SV2 
-- 120 records (with no OR statement)3 sec



---------------- SV Only----------------
UPDATE #temp1
SET parent_id = b.parentid, sfdc_account = b.ACCOUNT__C, owner_id = b.OwnerID, 
	am_module = b.AM_Module__c, cage_number = CAGE_Number__c, sfdc_nat_ind = b.SFDC_NAT_IND,
	sfdc_nat_sp_ind = b.SFDC_NAT_SP_IND
FROM rptcb.rpt.sfdc_to_biller_dyao_11_2020 b
WHERE b.AM_Module__c is NOT NULL and sfdc_account is NULL and CSG_ACCOUNT IS NULL 
	  and SV_ACCOUNT = b.SV1
--12 records in  2:32
--6 records in 2 sec

UPDATE #temp1
SET parent_id = b.parentid, sfdc_account = b.ACCOUNT__C, owner_id = b.OwnerID, 
	am_module = b.AM_Module__c, cage_number = CAGE_Number__c, sfdc_nat_ind = b.SFDC_NAT_IND,
	sfdc_nat_sp_ind = b.SFDC_NAT_SP_IND
FROM rptcb.rpt.sfdc_to_biller_dyao_11_2020 b
WHERE b.AM_Module__c is NOT NULL and sfdc_account is NULL and CSG_ACCOUNT IS NULL 
	  and SV_ACCOUNT = b.SV3 
--0 records in 2 sec

UPDATE #temp1
SET parent_id = b.parentid, sfdc_account = b.ACCOUNT__C, owner_id = b.OwnerID, 
	am_module = b.AM_Module__c, cage_number = CAGE_Number__c, sfdc_nat_ind = b.SFDC_NAT_IND,
	sfdc_nat_sp_ind = b.SFDC_NAT_SP_IND
FROM rptcb.rpt.sfdc_to_biller_dyao_11_2020 b
WHERE b.AM_Module__c is NOT NULL and sfdc_account is NULL and CSG_ACCOUNT IS NULL 
	  and SV_ACCOUNT = b.SV2 
--6 records in 2 sec



--------- SV (ROOT) w/CSG using CSG_ACCOUNT----------
UPDATE #temp1
SET parent_id = b.parentid, sfdc_account = b.ACCOUNT__C, owner_id = b.OwnerID, 
	am_module = b.AM_Module__c, cage_number = CAGE_Number__c, sfdc_nat_ind = b.SFDC_NAT_IND,
	sfdc_nat_sp_ind = b.SFDC_NAT_SP_IND
FROM rptcb.rpt.sfdc_to_biller_dyao_11_2020 b
WHERE b.AM_Module__c is NOT NULL and SV_ROOT_ACCOUNT IS NOT NULL and CSG_ACCOUNT is NOT NULL 
    and sfdc_account is NULL and CSG_ACCOUNT = b.CSG1

--(9417 rows affected)
--(10915 Using CSG account)

---------- SV w/CSG using CSG_ACCOUNT---------------

UPDATE #temp1
SET parent_id = b.parentid, sfdc_account = b.ACCOUNT__C, owner_id = b.OwnerID, 
	am_module = b.AM_Module__c, cage_number = CAGE_Number__c, sfdc_nat_ind = b.SFDC_NAT_IND,
	sfdc_nat_sp_ind = b.SFDC_NAT_SP_IND
FROM rptcb.rpt.sfdc_to_biller_dyao_11_2020 b
WHERE b.AM_Module__c is NOT NULL and  SV_ROOT_ACCOUNT IS NOT NULL and CSG_ACCOUNT is NOT NULL 
	  and sfdc_account is NULL and CSG_ACCOUNT = b.CSG3 
--(0 rows affected)



-------- SV1 (ROOT) w/CSG using ROOT_ACCOUNT_NUMBER---------

UPDATE #temp1
SET parent_id = b.parentid, sfdc_account = b.ACCOUNT__C, owner_id = b.OwnerID, 
	am_module = b.AM_Module__c, cage_number = CAGE_Number__c, sfdc_nat_ind = b.SFDC_NAT_IND,
	sfdc_nat_sp_ind = b.SFDC_NAT_SP_IND
FROM rptcb.rpt.sfdc_to_biller_dyao_11_2020 b
WHERE b.AM_Module__c is NOT NULL and SV_ROOT_ACCOUNT IS NOT NULL and CSG_ACCOUNT is NOT NULL 
    and sfdc_account is NULL and SV_ROOT_ACCOUNT = b.SV1

--(1644 rows affected)

------- SV2 (ROOT) w/CSG using ROOT_ACCOUNT_NUMBER-----------

UPDATE #temp1
SET parent_id = b.parentid, sfdc_account = b.ACCOUNT__C, owner_id = b.OwnerID, 
	am_module = b.AM_Module__c, cage_number = CAGE_Number__c, sfdc_nat_ind = b.SFDC_NAT_IND,
	sfdc_nat_sp_ind = b.SFDC_NAT_SP_IND
FROM rptcb.rpt.sfdc_to_biller_dyao_11_2020 b
WHERE b.AM_Module__c is NOT NULL and SV_ROOT_ACCOUNT IS NOT NULL and CSG_ACCOUNT is NOT NULL 
    and sfdc_account is NULL and SV_ROOT_ACCOUNT = b.SV2 

--(15 rows affected)

------- SV3 (ROOT) w/CSG using ROOT_ACCOUNT_NUMBER-----------

UPDATE #temp1
SET parent_id = b.parentid, sfdc_account = b.ACCOUNT__C, owner_id = b.OwnerID, 
	am_module = b.AM_Module__c, cage_number = CAGE_Number__c, sfdc_nat_ind = b.SFDC_NAT_IND,
	sfdc_nat_sp_ind = b.SFDC_NAT_SP_IND
FROM 
	rptcb.rpt.sfdc_to_biller_dyao_11_2020 b
WHERE 
	b.AM_Module__c is NOT NULL and SV_ROOT_ACCOUNT IS NOT NULL and CSG_ACCOUNT is NOT NULL 
    and sfdc_account is NULL and SV_ROOT_ACCOUNT = b.SV3 

--(7 rows affected)



-----------------------CSG ONLY ACCOUNTS---------------------

UPDATE #temp1
SET parent_id = b.parentid, sfdc_account = b.ACCOUNT__C, owner_id = b.OwnerID, 
	am_module = b.AM_Module__c, cage_number = CAGE_Number__c, sfdc_nat_ind = b.SFDC_NAT_IND,
	sfdc_nat_sp_ind = b.SFDC_NAT_SP_IND
FROM rptcb.rpt.sfdc_to_biller_dyao_11_2020 b
WHERE b.AM_Module__c is NOT NULL and SV_ROOT_ACCOUNT IS NULL 
	   and sfdc_account is NULL and CSG_ACCOUNT = b.CSG1
--26,155 records in 3 seconds

UPDATE #temp1
SET parent_id = b.parentid, sfdc_account = b.ACCOUNT__C, owner_id = b.OwnerID, 
	am_module = b.AM_Module__c, cage_number = CAGE_Number__c, sfdc_nat_ind = b.SFDC_NAT_IND,
	sfdc_nat_sp_ind = b.SFDC_NAT_SP_IND
FROM rptcb.rpt.sfdc_to_biller_dyao_11_2020 b
WHERE b.AM_Module__c is NOT NULL and SV_ROOT_ACCOUNT IS NULL 
	   and sfdc_account is NULL and CSG_ACCOUNT = b.CSG3 
--5 records in 2 seconds




--select count(*) from #temp1 where sfdc_account is not NULL


/**************************** NO AM ACCOUNT MODULES ********************************************/

--------------- SV Only (ROOT) ------------------
UPDATE #temp1
SET parent_id = b.parentid, sfdc_account = b.ACCOUNT__C, owner_id = b.OwnerID, 
	am_module = b.AM_Module__c, cage_number = CAGE_Number__c, sfdc_nat_ind = b.SFDC_NAT_IND,
	sfdc_nat_sp_ind = b.SFDC_NAT_SP_IND
FROM rptcb.rpt.sfdc_to_biller_dyao_11_2020 b
WHERE b.AM_Module__c is NULL and CSG_ACCOUNT IS NULL and SV_ROOT_ACCOUNT = b.SV1
--(19928 rows affected)


UPDATE #temp1
SET parent_id = b.parentid, sfdc_account = b.ACCOUNT__C, owner_id = b.OwnerID, 
	am_module = b.AM_Module__c, cage_number = CAGE_Number__c, sfdc_nat_ind = b.SFDC_NAT_IND,
	sfdc_nat_sp_ind = b.SFDC_NAT_SP_IND
FROM rptcb.rpt.sfdc_to_biller_dyao_11_2020 b
WHERE b.AM_Module__c is NULL and CSG_ACCOUNT IS NULL and sfdc_account is NULL 
	  and (SV_ROOT_ACCOUNT = b.SV3 ) 
--(1 row affected)


UPDATE #temp1
SET parent_id = b.parentid, sfdc_account = b.ACCOUNT__C, owner_id = b.OwnerID, 
	am_module = b.AM_Module__c, cage_number = CAGE_Number__c, sfdc_nat_ind = b.SFDC_NAT_IND,
	sfdc_nat_sp_ind = b.SFDC_NAT_SP_IND
FROM rptcb.rpt.sfdc_to_biller_dyao_11_2020 b
WHERE b.AM_Module__c is NULL and CSG_ACCOUNT IS NULL and sfdc_account is NULL 
	  and (SV_ROOT_ACCOUNT = b.SV2 )
--(309 rows affected)





---------------- SV Only----------------
UPDATE #temp1
SET parent_id = b.parentid, sfdc_account = b.ACCOUNT__C, owner_id = b.OwnerID, 
	am_module = b.AM_Module__c, cage_number = CAGE_Number__c, sfdc_nat_ind = b.SFDC_NAT_IND,
	sfdc_nat_sp_ind = b.SFDC_NAT_SP_IND
FROM rptcb.rpt.sfdc_to_biller_dyao_11_2020 b
WHERE b.AM_Module__c is NULL and sfdc_account is NULL and CSG_ACCOUNT IS NULL and SV_ACCOUNT = b.SV1
--(66 rows affected)
	  

UPDATE #temp1
SET parent_id = b.parentid, sfdc_account = b.ACCOUNT__C, owner_id = b.OwnerID, 
	am_module = b.AM_Module__c, cage_number = CAGE_Number__c, sfdc_nat_ind = b.SFDC_NAT_IND,
	sfdc_nat_sp_ind = b.SFDC_NAT_SP_IND
FROM rptcb.rpt.sfdc_to_biller_dyao_11_2020 b
WHERE b.AM_Module__c is NULL and sfdc_account is NULL and CSG_ACCOUNT IS NULL 
	  and (SV_ACCOUNT = b.SV3 ) 
--(0 rows affected)
	  

UPDATE #temp1
SET parent_id = b.parentid, sfdc_account = b.ACCOUNT__C, owner_id = b.OwnerID, 
	am_module = b.AM_Module__c, cage_number = CAGE_Number__c, sfdc_nat_ind = b.SFDC_NAT_IND,
	sfdc_nat_sp_ind = b.SFDC_NAT_SP_IND
FROM rptcb.rpt.sfdc_to_biller_dyao_11_2020 b
WHERE b.AM_Module__c is NULL and sfdc_account is NULL and CSG_ACCOUNT IS NULL 
	  and (SV_ACCOUNT = b.SV2 )
--(8 rows affected)
	  	  
	 

--------- SV (ROOT) w/CSG using CSG_ACCOUNT----------
UPDATE #temp1
SET parent_id = b.parentid, sfdc_account = b.ACCOUNT__C, owner_id = b.OwnerID, 
	am_module = b.AM_Module__c, cage_number = CAGE_Number__c, sfdc_nat_ind = b.SFDC_NAT_IND,
	sfdc_nat_sp_ind = b.SFDC_NAT_SP_IND
FROM rptcb.rpt.sfdc_to_biller_dyao_11_2020 b
WHERE b.AM_Module__c is NULL and SV_ROOT_ACCOUNT IS NOT NULL and CSG_ACCOUNT is NOT NULL 
      and sfdc_account is NULL and CSG_ACCOUNT = b.CSG1
--(163,305 rows affected)

---------- SV w/CSG using CSG_ACCOUNT---------------

UPDATE #temp1
SET parent_id = b.parentid, sfdc_account = b.ACCOUNT__C, owner_id = b.OwnerID, 
	am_module = b.AM_Module__c, cage_number = CAGE_Number__c, sfdc_nat_ind = b.SFDC_NAT_IND,
	sfdc_nat_sp_ind = b.SFDC_NAT_SP_IND
FROM rptcb.rpt.sfdc_to_biller_dyao_11_2020 b
WHERE b.AM_Module__c is NULL and  SV_ROOT_ACCOUNT IS NOT NULL and CSG_ACCOUNT is NOT NULL 
	  and sfdc_account is NULL and CSG_ACCOUNT = b.CSG3 
--(4 rows affected)



-------- SV1 (ROOT) w/CSG using ROOT_ACCOUNT_NUMBER---------

UPDATE #temp1
SET parent_id = b.parentid, sfdc_account = b.ACCOUNT__C, owner_id = b.OwnerID, 
	am_module = b.AM_Module__c, cage_number = CAGE_Number__c, sfdc_nat_ind = b.SFDC_NAT_IND,
	sfdc_nat_sp_ind = b.SFDC_NAT_SP_IND
FROM rptcb.rpt.sfdc_to_biller_dyao_11_2020 b
WHERE b.AM_Module__c is NULL and SV_ROOT_ACCOUNT IS NOT NULL and CSG_ACCOUNT is NOT NULL 
    and sfdc_account is NULL and SV_ROOT_ACCOUNT = b.SV1
--(47850 rows affected)

------- SV2 (ROOT) w/CSG using ROOT_ACCOUNT_NUMBER-----------

UPDATE #temp1
SET parent_id = b.parentid, sfdc_account = b.ACCOUNT__C, owner_id = b.OwnerID, 
	am_module = b.AM_Module__c, cage_number = CAGE_Number__c, sfdc_nat_ind = b.SFDC_NAT_IND,
	sfdc_nat_sp_ind = b.SFDC_NAT_SP_IND
FROM rptcb.rpt.sfdc_to_biller_dyao_11_2020 b
WHERE b.AM_Module__c is NULL and SV_ROOT_ACCOUNT IS NOT NULL and CSG_ACCOUNT is NOT NULL 
    and sfdc_account is NULL and SV_ROOT_ACCOUNT = b.SV2 
--(10490 rows affected)


--------- SV3 (ROOT) w/CSG using ROOT_ACCOUNT_NUMBER-----------

UPDATE #temp1
SET parent_id = b.parentid, sfdc_account = b.ACCOUNT__C, owner_id = b.OwnerID, 
	am_module = b.AM_Module__c, cage_number = CAGE_Number__c, sfdc_nat_ind = b.SFDC_NAT_IND,
	sfdc_nat_sp_ind = b.SFDC_NAT_SP_IND
FROM rptcb.rpt.sfdc_to_biller_dyao_11_2020 b
WHERE b.AM_Module__c is NULL and SV_ROOT_ACCOUNT IS NOT NULL and CSG_ACCOUNT is NOT NULL 
    and sfdc_account is NULL and SV_ROOT_ACCOUNT = b.SV3
--(3 rows affected)



-----------------CSG ONLY ACCOUNTS-----------------------

UPDATE #temp1
SET parent_id = b.parentid, sfdc_account = b.ACCOUNT__C, owner_id = b.OwnerID, 
	am_module = b.AM_Module__c, cage_number = CAGE_Number__c, sfdc_nat_ind = b.SFDC_NAT_IND,
	sfdc_nat_sp_ind = b.SFDC_NAT_SP_IND
FROM rptcb.rpt.sfdc_to_biller_dyao_11_2020 b
WHERE b.AM_Module__c is NULL and SV_ROOT_ACCOUNT IS NULL 
	   and sfdc_account is NULL and CSG_ACCOUNT = b.CSG1
--(527297 rows affected)   



UPDATE #temp1
SET parent_id = b.parentid, sfdc_account = b.ACCOUNT__C, owner_id = b.OwnerID, 
	am_module = b.AM_Module__c, cage_number = CAGE_Number__c, sfdc_nat_ind = b.SFDC_NAT_IND,
	sfdc_nat_sp_ind = b.SFDC_NAT_SP_IND
FROM rptcb.rpt.sfdc_to_biller_dyao_11_2020 b
WHERE b.AM_Module__c is NULL and SV_ROOT_ACCOUNT IS NULL 
	   and sfdc_account is NULL and (CSG_ACCOUNT = b.CSG3 )
--(120 rows affected)



--make permanent table
drop table rptcb.rpt.biller_sfdc_accounts_dyao_11_2020;

select
	*
into
	rptcb.rpt.biller_sfdc_accounts_dyao_11_2020
from 
	#temp1 


--select count(distinct family_id) from rptcb.rpt.biller_sfdc_accounts_dyao_11_2020 where sfdc_account is not NULL

	
--find the missing accounts and fill in the blanks as much as possible	
drop table #missing_sfdc_account

select 
	* 
into 
	#missing_sfdc_account
from 
	rptcb.rpt.biller_sfdc_accounts_dyao_11_2020 
where 
	SFDC_ACCOUNT is NULL


drop table #temp2

select
	n.*
	,coalesce(ch.source_id,smh.source_id,sah.source_id ) SFDC_AcctID
into
	#temp2
from 
	#missing_sfdc_account as n
left join 
	BI_MIP.MIP3.ATHENA_BUSINESS_XREF AS ch
	on CAST(ch.athena_business_id as varchar(30)) = CAST(n.CSG_BUSN_ID as varchar(30)) and ch.source_nm in ('SFDC ACCOUNT')
left join
	BI_MIP.MIP3.ATHENA_BUSINESS_XREF AS smh
	on CAST(smh.athena_business_id as varchar(30))= CAST(n.SVAN_BUSN_ID as varchar(30)) and smh.source_nm in ('SFDC ACCOUNT')
left join 
	BI_MIP.MIP3.ATHENA_BUSINESS_XREF AS sah
	on cast(sah.athena_business_id as varchar(30)) = CAST(n.SVM_BUSN_ID as varchar(30)) and sah.source_nm in ('SFDC ACCOUNT')
where 
	coalesce(ch.source_nm,smh.source_nm,sah.source_nm ) is not null --  #firstRunSFDCinfo (may contain dupes needs cleaning)
 -- where coalesce(ch.source_nm,smh.source_nm,sah.source_nm ) is  null -- #firstRunSFDCinfoStillBlank

 --select * from #temp2


 ------------------------------------Filling in Missing Accounts using Athena--------------------------------


UPDATE #temp2
SET parent_id = b.parentid, sfdc_account = b.ACCOUNT__C, owner_id = b.OwnerID, 
	am_module = b.AM_Module__c, cage_number = CAGE_Number__c, sfdc_nat_ind = b.SFDC_NAT_IND,
	sfdc_nat_sp_ind = b.SFDC_NAT_SP_IND
FROM rptcb.rpt.sfdc_to_biller_dyao_11_2020 b
WHERE SFDC_AcctID = ACCOUNT__C
--8028 rows

--select * from rptcb.rpt.sfdc_to_biller_dyao_11_2020 where ACCOUNT__C ='001A000000maROMIA2'


UPDATE #temp2
SET parent_id = b.parentid, sfdc_account = b.ACCOUNT__C, owner_id = b.OwnerID, 
	am_module = b.AM_Module__c, cage_number = CAGE_Number__c, sfdc_nat_ind = b.SFDC_NAT_IND,
	sfdc_nat_sp_ind = b.SFDC_NAT_SP_IND
FROM rptcb.rpt.sfdc_to_biller_dyao_11_2020 b
WHERE SFDC_AcctID = Site_Account__c and sfdc_account is  NULL




--drop table rptcb.rpt.biller_sfdc_accounts_dyao_11_2020 

UPDATE rptcb.rpt.biller_sfdc_accounts_dyao_11_2020 
SET parent_id = b.parent_id, sfdc_account = b.sfdc_account, owner_id = b.owner_id, 
	am_module = b.am_module, cage_number = b.cage_number, sfdc_nat_ind = b.sfdc_nat_ind,
	sfdc_nat_sp_ind = b.sfdc_nat_sp_ind
FROM #temp2 b
WHERE rptcb.rpt.biller_sfdc_accounts_dyao_11_2020 .family_id = b.family_id 
and concat(rptcb.rpt.biller_sfdc_accounts_dyao_11_2020.distinct_loc_id, rptcb.rpt.biller_sfdc_accounts_dyao_11_2020.sv_account, rptcb.rpt.biller_sfdc_accounts_dyao_11_2020.sv_root_account, rptcb.rpt.biller_sfdc_accounts_dyao_11_2020.csg_account) = concat( b.distinct_loc_id, b.sv_account,rptcb.rpt.biller_sfdc_accounts_dyao_11_2020 .sv_root_account, b.csg_account) 
and b.sfdc_account is not NULL and rptcb.rpt.biller_sfdc_accounts_dyao_11_2020.sfdc_account is NULL




/* TEST QUERIES 

select * from  rptcb.rpt.biller_sfdc_accounts_dyao_11_2020 tablesample(1 percent)

select 
count(*)
,sum(case when sfdc_account is NULL then 0 else 1 end)
from rptcb.rpt.biller_sfdc_accounts_dyao_11_2020 

*/

select top 1000 * from rptcb.rpt.biller_sfdc_accounts_dyao_11_2020 