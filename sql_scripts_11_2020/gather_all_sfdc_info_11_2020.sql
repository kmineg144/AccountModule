---Create a copy of my Stage RptCB.Rpt.SCA_MODULE_STAGE1X_DYAO table

---------------------

--select [name], id,id,  Parent_Account__c, account,ParentId, CSGBillingAccountNumber__c, topMostParentId__c, Billing_Account__c, Billing_Account_Id__c,SavilleAccountNumber__c,SavilleBillingAccountNumber__c, AM_Module__c, id , Account_ID__c, AccountNumber
--from externaluser.sfdc.account
--where Billing_Account_Id__c = '900007769' and AM_Module__c is not NULL





--drop table #ModuleAccts
select
s.Site__c,--null
s.Location_Id__c,--null
s.Location_Number__c,--null
s.Owner_Username__c,
RecordTypeId,
CreditBusinessName__c,
Parent_Account_Name__c,
s.id,
s.ParentId,
s.AM_Module__c,
s.CAGE_Number__c,
CASE WHEN s.Billing_Account__c IS NULL 
		  AND LEFT(s.SavilleBillingAccountNumber__c,1) = '8' AND LEN(s.SavilleBillingAccountNumber__c) = 16 
	THEN s.SavilleBillingAccountNumber__c 
	ELSE s.Billing_Account__c  
	END Billing_Account__c,
s.SavilleAccountNumber__c,
CASE WHEN s.Billing_Account__c IS NULL AND LEFT(s.SavilleBillingAccountNumber__c,1) = '8' AND LEN(s.SavilleBillingAccountNumber__c) = 16 
		THEN NULL
	 WHEN SavilleBillingAccountNumber__c is NULL and SavilleAccountNumber__c is NULL
		THEN left(AccountNumber,9)
	ELSE s.SavilleBillingAccountNumber__c
	END SavilleBillingAccountNumber__c,
s.Division__c,
s.OwnerID,
'HAVE MODULE' MODULE_ASSIGNMENT_TO_PARENT
into #ModuleAccts
from externaluser.sfdc.Account as s
where AM_Module__c is not null


--select count(SavilleBillingAccountNumber__c) from #ModuleAccts where SavilleBillingAccountNumber__c is not null SavilleBillingAccountNumber__c = '900007769'
--1339 normal
--DELETE FROM #ModuleAccts WHERE MODULE_ASSIGNMENT_TO_PARENT = 'NEED MODULE'
 


insert into #ModuleAccts
select
s.Site__c,--null
Location_Id__c,--null
Location_Number__c,--null
s.Owner_Username__c,
RecordTypeId,
CreditBusinessName__c,
Parent_Account_Name__c,
s.id,
s.ParentId,
p.AM_Module__c,
s.CAGE_Number__c,
CASE WHEN s.Billing_Account__c IS NULL 
		  AND LEFT(s.SavilleBillingAccountNumber__c,1) = '8' AND LEN(s.SavilleBillingAccountNumber__c) = 16 
	THEN s.SavilleBillingAccountNumber__c 
	ELSE s.Billing_Account__c  
	END Billing_Account__c,
s.SavilleAccountNumber__c,
CASE WHEN s.Billing_Account__c IS NULL AND LEFT(s.SavilleBillingAccountNumber__c,1) = '8' AND LEN(s.SavilleBillingAccountNumber__c) = 16 
		THEN NULL
	 WHEN SavilleBillingAccountNumber__c is NULL and SavilleAccountNumber__c is NULL
		THEN left(AccountNumber,9)
	ELSE s.SavilleBillingAccountNumber__c
	END SavilleBillingAccountNumber__c,
s.Division__c,
s.OwnerID,
'NEED MODULE' MODULE_ASSIGNMENT_TO_PARENT
from externaluser.sfdc.Account as s
join (select distinct ParentID,AM_Module__c from #ModuleAccts where parentid not in (select id from #ModuleAccts) ) as p
on s.id = p.ParentID




insert into #ModuleAccts
select
s.Site__c,--null
Location_Id__c,--null
Location_Number__c,--
s.Owner_Username__c,
RecordTypeId,
CreditBusinessName__c,
Parent_Account_Name__c,
s.id,
s.ParentId,
s.AM_Module__c,
s.CAGE_Number__c,
CASE WHEN s.Billing_Account__c IS NULL 
		  AND LEFT(s.SavilleBillingAccountNumber__c,1) = '8' AND LEN(s.SavilleBillingAccountNumber__c) = 16 
	THEN s.SavilleBillingAccountNumber__c 
	ELSE s.Billing_Account__c  
	END Billing_Account__c,
s.SavilleAccountNumber__c,
CASE WHEN s.Billing_Account__c IS NULL AND LEFT(s.SavilleBillingAccountNumber__c,1) = '8' AND LEN(s.SavilleBillingAccountNumber__c) = 16 
		THEN NULL
	 WHEN SavilleBillingAccountNumber__c is NULL and SavilleAccountNumber__c is NULL
		THEN left(AccountNumber,9)
	ELSE s.SavilleBillingAccountNumber__c
	END SavilleBillingAccountNumber__c,
s.Division__c,
s.OwnerID,
'NO MODULE' MODULE_ASSIGNMENT_TO_PARENT
from externaluser.sfdc.Account as s
where AM_Module__c is null


--select * from RPTCB.RPT.ModuleAccts where id ='0011H00001ZL09xQAD'


select 
	a.*
	,r.name,
	r.SobjectType 
into
	rptcb.rpt.ModuleAccts_11_2020
from 
	#ModuleAccts a
join 
	EXTERNALUSER.SFDC.RECORDTYPE as r 
	on a.RecordTypeId = r.id and r.SobjectType = 'Account'
--WHERE  
	--ltrim(rtrim(len(concat(isnull(Parent_Account_Name__c,''),isnull(CreditBusinessName__c,''))))) >0

--select * from rptcb.rpt.ModuleAccts_11_2020 where SavilleBillingAccountNumber__c = '939023198'



create nonclustered index ix_tempModuleAccts1 on rptcb.rpt.ModuleAccts_11_2020 (ParentId)
create nonclustered index ix_tempModuleAccts2 on rptcb.rpt.ModuleAccts_11_2020 (id)
create nonclustered index ix_tempModuleAccts3 on rptcb.rpt.ModuleAccts_11_2020(Site__c)
create nonclustered index ix_tempModuleAccts4 on rptcb.rpt.ModuleAccts_11_2020 (Location_Id__c)

--drop table rptcb.rpt.gotem_dyao_11_2020

SELECT 
ACCOUNT__C,
COALESCE(CSG_Account_Number__c,Billing_Account__c) CSG1,
case when COALESCE(CSG_Account_Number__c,Billing_Account__c)  <> Billing_Account__c then Billing_Account__c else ''  end CSG2,
case when mBAN = Billing_Account__c or mBAN = CSG_Account_Number__c  then ' '  
	 WHEN LEFT(mBAN,1) = '8' THEN mBAN else ' '  end CSG3, 
Site_Account__c,
A.ParentID,
oDiv,
SFDC_ACCOUNT_TYPE,
SFDC_OWNER_USERNAME,
SFDC_OBJECT_TYPE,
Parent_BAN__c SV1,
case when ISNULL(Parent_BAN__c,'NOPE') <> ISNULL(mSVBAN,ISNULL(Parent_BAN__c,'NOPE')) then mSVBAN else ''  end SV2,
case when Parent_BAN__c  = ISNULL(mSVAN,'NEVER') or mSVBAN = ISNULL(mSVAN,'NEVER') then ''  
	 WHEN LEFT(ISNULL(ltrim(mSVAN),'B'),1) = '9' THEN mSVAN else ' '  end SV3,
mDiv,OwnerID,mNOTE, 
AM_Module__c,CAGE_Number__c 
into rptcb.rpt.gotem_dyao_11_2020
FROM (
		select distinct
		o.ACCOUNT__C,
		p.ParentID,
		SobjectType as SFDC_OBJECT_TYPE,
		Owner_Username__c as SFDC_OWNER_USERNAME,
		p.[name] as SFDC_ACCOUNT_TYPE,
		CASE WHEN LEN(o.CSG_Account_Number__c) = 16 THEN COALESCE(o.CSG_Account_Number__c,o.Billing_Account__c) ELSE NULL END CSG_Account_Number__c,
		CASE WHEN LEN(o.Billing_Account__c) = 16 THEN o.Billing_Account__c ELSE NULL END Billing_Account__c,
		Site_Account__c,
		COALESCE(o.Parent_BAN__c,p.SavilleBillingAccountNumber__c) Parent_BAN__c,
		o.Division__c oDiv,
		p.AM_Module__c,p.CAGE_Number__c,p.Billing_Account__c mBAN,
		p.SavilleAccountNumber__c mSVAN,
		case when isnumeric(p.SavilleBillingAccountNumber__c) = 0 then null 
			 when left(p.SavilleBillingAccountNumber__c,1) = '8' and len(p.SavilleBillingAccountNumber__c) < 16 then null
			 else p.SavilleBillingAccountNumber__c end  mSVBAN,
			p.Division__c mDiv,p.OwnerID,P.MODULE_ASSIGNMENT_TO_PARENT mNOTE
		from EXTERNALUSER.SFDC.ORDER__c  as o -- 29914 in 50 sec of 37342 (WITHOUT WEST 30094 IN 1MIN 41)
		join rptcb.rpt.ModuleAccts_11_2020 as p
		on p.id = o.account__c
		and( o.Status__c = 'Complete' and Canceled__c is NULL) 
		--and o.Order_Status_in_opp__c	= 'Order Complete' and o.Order_Complete__c = 'Complete'
		
		) AS A
WHERE COALESCE(CSG_Account_Number__c,Billing_Account__c,Parent_BAN__c,mBAN,mSVAN,mSVBAN) IS NOT NULL




-------------------------------scratch work--------------------------------------

select * from rptcb.rpt.gotem_dyao_11_2020  where Billing_Account__c = '900007769'
select count(*) from rptcb.rpt.ModuleAccts_11_2020
select count(*) from rptcb.rpt.gotem_dyao_11_2020

--select * from rptcb.rpt.gotem_dyao_11_2020 where ACCOUNT__C ='0011H00001ZL09yQAD'
----------------------------------------------------------------------------------


--select * from rptcb.rpt.gotem_dyao_11_2020 where ACCOUNT__C ='0011H00001ZL09yQAD'



drop table rptcb.rpt.needem_dyao_11_2020  

select 
	* 
into 
	rptcb.rpt.needem_dyao_11_2020  
from 
	rptcb.rpt.ModuleAccts_11_2020
where 
	id not in ( select distinct ACCOUNT__C FROM rptcb.rpt.gotem_dyao_11_2020 )

--select top 100 * from rptcb.rpt.needem_dyao  




--drop table #gotEm2

SELECT 
ACCOUNT__C,
CSGBilling_Account__c CSG1,' ' CSG2,' ' CSG3, 
ACCOUNT__C Site_Account__c,
Division__c oDiv,
Saville_Account__c SV1,' ' SV2,' ' SV3,
' ' mDiv,OwnerID,mNOTE, 
AM_Module__c,CAGE_Number__c,
SFDC_ACCOUNT_TYPE,
SFDC_OBJECT_TYPE,
SFDC_OWNER_USERNAME,
ParentID
INTO #gotEm2 
FROM (
	select distinct 
	M.id ACCOUNT__C,
	CASE WHEN LEN(L.CSGBilling_Account__c) = 16 THEN L.CSGBilling_Account__c ELSE NULL END CSGBilling_Account__c,
	L.Saville_Account__c,
	Division__c,m.ParentId,m.AM_Module__c,m.OwnerID,m.CAGE_Number__c,M.MODULE_ASSIGNMENT_TO_PARENT mNOTE, m.[name] as SFDC_ACCOUNT_TYPE, 
	SobjectType as SFDC_OBJECT_TYPE, Owner_Username__c as SFDC_OWNER_USERNAME
	FROM ExternalUser.SFDC.LocationLookup__c L
	JOIN rptcb.rpt.needem_dyao_11_2020  AS M ON M.id = L.Account__c AND  l.account__C is not null 
	where Stage__c IN ('Closed Won','Closed-Won') and coalesce(CSGBilling_Account__c,Saville_Account__c) is not null
	) as c




--drop table BI_MIP.dbo.sfdc_to_biller_dyao

;with butWaitTheresMore as (
select ParentID, ACCOUNT__C,CSG1,CSG2,CSG3,Site_Account__c,coalesce(oDiv,mDiv) mDiv,SV1,SV2,SV3
,OwnerID,AM_Module__c,CAGE_Number__c,SFDC_ACCOUNT_TYPE,SFDC_OBJECT_TYPE,SFDC_OWNER_USERNAME 
from rptcb.rpt.gotem_dyao_11_2020

union all 

select ParentID, ACCOUNT__C,CSG1,CSG2,CSG3,ACCOUNT__C Site_Account__c,coalesce(oDiv,mDiv) mDiv,SV1,SV2,SV3
,OwnerID,AM_Module__c,CAGE_Number__c,SFDC_ACCOUNT_TYPE,SFDC_OBJECT_TYPE,SFDC_OWNER_USERNAME 
from #gotEm2
)
,StillNeedEm as(
select * from rptcb.rpt.ModuleAccts_11_2020 
where id not in (select ACCOUNT__C from butWaitTheresMore)
)
select  
*,
CASE WHEN SFDC_OWNER_USERNAME = 'national_otm@cable.comcast.com.smb' THEN 'Y'
		WHEN SFDC_OBJECT_TYPE = 'national_otm@cable.comcast.com.smb' THEN 'Y'
		ELSE NULL END AS SFDC_NAT_IND
,CASE WHEN
		SFDC_ACCOUNT_TYPE = 'National Indirect sales' THEN 'Y'
		ELSE NULL END AS SFDC_NAT_SP_IND
into rptcb.rpt.sfdc_to_biller_dyao_11_2020
from
(select 
	*
from butWaitTheresMore
union all
select ParentID, id ACCOUNT__C,Billing_Account__c CSG1,' 'CSG2,' 'CSG3,id Site_Account__c,Division__c oDiv,SavilleAccountNumber__c SV1,SavilleBillingAccountNumber__c SV2,' ' SV3,OwnerID,AM_Module__c,CAGE_Number__c
,SobjectType as SFDC_OBJECT_TYPE, Owner_Username__c as SFDC_OWNER_USERNAME,[name] as SFDC_ACCOUNT_TYPE
from StillNeedEm where coalesce(Billing_Account__c,SavilleAccountNumber__c,SavilleBillingAccountNumber__c) is not null
) a



select top 1000 * from rptcb.rpt.sfdc_to_biller_dyao_11_2020



/*
--old rptcb.rpt.sfdc_to_biller_dyao count:
--new 7/21: 516,2941
--new: 5144337
--old: 5100049
select count(*) from rptcb.rpt.sfdc_to_biller_dyao_11_2020 where csg3 <> ''--where SV2 = '900007769'







---------------------------------------------------------------
SELECT 'UPDATE rptcb.rpt.sfdc_to_biller_dyao SET ' + name + ' = NULL WHERE ' + name + ' = '''';'
FROM syscolumns
WHERE id = object_id('rptcb.rpt.sfdc_to_biller_dyao' )
  AND isnullable = 1;

UPDATE rptcb.rpt.sfdc_to_biller_dyao SET CSG1 = NULL WHERE CSG1 = '';
UPDATE rptcb.rpt.sfdc_to_biller_dyao SET CSG2 = NULL WHERE CSG2 = '';
UPDATE rptcb.rpt.sfdc_to_biller_dyao SET CSG3 = NULL WHERE CSG3 = '';
UPDATE rptcb.rpt.sfdc_to_biller_dyao SET SV1 = NULL WHERE SV1 = '';
UPDATE rptcb.rpt.sfdc_to_biller_dyao SET SV2 = NULL WHERE SV2 = '';
UPDATE rptcb.rpt.sfdc_to_biller_dyao SET SV3 = NULL WHERE SV3 = '';

create nonclustered index ix_sfdc_to_biller_dyao_1 on rptcb.rpt.sfdc_to_biller_dyao (ACCOUNT__C)

DROP INDEX IF EXISTS ix_sfdc_to_biller_dyao_2 ON rptcb.rpt.sfdc_to_biller_dyao 
--create nonclustered index ix_sfdc_to_biller_dyao_2 on rptcb.rpt.sfdc_to_biller_dyao (SV1)

--select top 1000 * from rptcb.rpt.sfdc_to_biller_dyao where sv1 in (
--'912066187') or sv2 in ('912066187') or sv3 in ('912066187')


