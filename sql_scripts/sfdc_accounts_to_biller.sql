drop table #yao1;



 select DISTINCT_LOC_ID
	 ,family_id
	,family_id_region
	,sv_root_account_name
	,SV_ROOT_ACCOUNT
	,SV_ACCOUNT
	,csg_account
	,csg_busn_name
	,SV_EXCL_IND
	,CSG_EXCL_IND
	,ACCT_MODULE_VERSION
into
	#yao1
from
	BI_MIP.dbo.SCA_MODULE_NEW_ACCOUNTS_DYAO
WHERE
	SV_EXCL_IND is NULL and CSG_EXCL_IND = ''

create nonclustered index ix_temp_1 on #yao1 (family_id)


drop table #temp


--------------- SV w/CSG using CSG_ACCOUNT CSG1---------------


select DISTINCT_LOC_ID
	,family_id
	,family_id_region
	,'SV + CSG ACCOUNT' AS sfdc_link
	,sv_root_account_name
	,SV_ROOT_ACCOUNT
	,SV_ACCOUNT
	,csg_account
	,csg_busn_name
	, b.*
	,SV_EXCL_IND
	,CSG_EXCL_IND
	,ACCT_MODULE_VERSION
into
	#temp
from
	BI_MIP.dbo.sfdc_to_biller_dyao b
join(
	select 
		*
	from
		#yao1
	where 
		SV_ROOT_ACCOUNT IS NOT NULL and CSG_ACCOUNT is NOT NULL 
	 ) a
	on a.CSG_ACCOUNT = b.CSG1
--(43351 rows affected) 9 seconds


--------------- SV w/CSG using CSG_ACCOUNT CSG3---------------

insert into #temp
select DISTINCT_LOC_ID
	,family_id
	,family_id_region
	,'SV + CSG ACCOUNT' AS sfdc_link
	,sv_root_account_name
	,SV_ROOT_ACCOUNT
	,SV_ACCOUNT
	,csg_account
	,csg_busn_name
	, b.*
	,SV_EXCL_IND
	,CSG_EXCL_IND
	,ACCT_MODULE_VERSION

from
	BI_MIP.dbo.sfdc_to_biller_dyao b
join(
	select 
		*
	from
		#yao1
	where 
		SV_ROOT_ACCOUNT IS NOT NULL and CSG_ACCOUNT is NOT NULL 
	 ) a
	on a.CSG_ACCOUNT = b.CSG3
--21 rows in 4 seconds



-------- SV1 (ROOT) w/CSG using ROOT_ACCOUNT_NUMBER---------

insert into #temp
select DISTINCT_LOC_ID
	,family_id
	,family_id_region
	,'SV + CSG ACCOUNT' AS sfdc_link
	,sv_root_account_name
	,SV_ROOT_ACCOUNT
	,SV_ACCOUNT
	,csg_account
	,csg_busn_name
	, b.*
	,SV_EXCL_IND
	,CSG_EXCL_IND
	,ACCT_MODULE_VERSION

from
	BI_MIP.dbo.sfdc_to_biller_dyao b
join(
	select 
		*
	from
		#yao1
	where 
		SV_ROOT_ACCOUNT IS NOT NULL and CSG_ACCOUNT is NOT NULL 
	 ) a
	on a.SV_ROOT_ACCOUNT = b.SV1

--(90781 rows affected) 3 seconds, need to delete dupes

-------- SV2 (ROOT) w/CSG using ROOT_ACCOUNT_NUMBER---------


insert into #temp
select DISTINCT_LOC_ID
	,family_id
	,family_id_region
	,'SV + CSG ACCOUNT' AS sfdc_link
	,sv_root_account_name
	,SV_ROOT_ACCOUNT
	,SV_ACCOUNT
	,csg_account
	,csg_busn_name
	, b.*
	,SV_EXCL_IND
	,CSG_EXCL_IND
	,ACCT_MODULE_VERSION

from
	BI_MIP.dbo.sfdc_to_biller_dyao b
join(
	select 
		*
	from
		#yao1
	where 
		SV_ROOT_ACCOUNT IS NOT NULL and CSG_ACCOUNT is NOT NULL 
	 ) a
	on a.SV_ROOT_ACCOUNT = b.SV2
--(32311 rows affected) 2 seconds


-------- SV3 (ROOT) w/CSG using ROOT_ACCOUNT_NUMBER---------

insert into #temp
select DISTINCT_LOC_ID
	,family_id
	,family_id_region
	,'SV + CSG ACCOUNT' AS sfdc_link
	,sv_root_account_name
	,SV_ROOT_ACCOUNT
	,SV_ACCOUNT
	,csg_account
	,csg_busn_name
	, b.*
	,SV_EXCL_IND
	,CSG_EXCL_IND
	,ACCT_MODULE_VERSION
from
	BI_MIP.dbo.sfdc_to_biller_dyao b
join(
	select 
		*
	from
		#yao1
	where 
		SV_ROOT_ACCOUNT IS NOT NULL and CSG_ACCOUNT is NOT NULL 
	 ) a
	on a.SV_ROOT_ACCOUNT = b.SV3

--(1648 rows affected) 2 seconds


---------CSG ACCOUNTS ONLY CSG1
insert into #temp
select DISTINCT_LOC_ID
	,family_id
	,family_id_region
	,'CSG ACCOUNT' AS sfdc_link
	,sv_root_account_name
	,SV_ROOT_ACCOUNT
	,SV_ACCOUNT
	,csg_account
	,csg_busn_name
	, b.*
	,SV_EXCL_IND
	,CSG_EXCL_IND
	,ACCT_MODULE_VERSION
from
	BI_MIP.dbo.sfdc_to_biller_dyao b
join(
	select 
		*
	from
		#yao1
	where 
		SV_ROOT_ACCOUNT is NULL
	 ) a
	on a.csg_account = b.csg1 --and CSG3 is NULL
--(745,687 rows affected) 29 seconds


---------CSG ACCOUNTS ONLY CSG3
insert into #temp
select DISTINCT_LOC_ID
	,family_id
	,family_id_region
	,'CSG ACCOUNT' AS sfdc_link
	,sv_root_account_name
	,SV_ROOT_ACCOUNT
	,SV_ACCOUNT
	,csg_account
	,csg_busn_name
	, b.*
	,SV_EXCL_IND
	,CSG_EXCL_IND
	,ACCT_MODULE_VERSION
from
	BI_MIP.dbo.sfdc_to_biller_dyao b
join(
	select 
		*
	from
		#yao1
	where 
		SV_ROOT_ACCOUNT is NULL
	 ) a
	on a.csg_account = b.csg3  --CSG1 is NULL
--(606 rows affected) 4 seconds



-----------SV ROOT ACCOUNT ONLY SV1------------
insert into #temp
select DISTINCT_LOC_ID
	,family_id
	,family_id_region
	,'SV ROOT ACCOUNT' AS sfdc_link
	,sv_root_account_name
	,SV_ROOT_ACCOUNT
	,SV_ACCOUNT
	,csg_account
	,csg_busn_name
	, b.*
	,SV_EXCL_IND
	,CSG_EXCL_IND
	,ACCT_MODULE_VERSION
from
	BI_MIP.dbo.sfdc_to_biller_dyao b
join(
	select 
		*
	from
		#yao1
	where 
		CSG_ACCOUNT is NULL
	 ) a
	on a.SV_ROOT_ACCOUNT = b.sv1 
--3039 records 12 seconds


-----------SV ROOT ACCOUNT ONLY SV2------------

insert into #temp
select DISTINCT_LOC_ID
	,family_id
	,family_id_region
	,'SV ROOT ACCOUNT' AS sfdc_link
	,sv_root_account_name
	,SV_ROOT_ACCOUNT
	,SV_ACCOUNT
	,csg_account
	,csg_busn_name
	, b.*
	,SV_EXCL_IND
	,CSG_EXCL_IND
	,ACCT_MODULE_VERSION
from
	BI_MIP.dbo.sfdc_to_biller_dyao b
join(
	select 
		*
	from
		#yao1
	where 
		CSG_ACCOUNT is NULL
	 ) a
	on a.SV_ROOT_ACCOUNT = b.sv2 
--453 rows affected


-----------SV ROOT ACCOUNT ONLY SV3------------

insert into #temp
select DISTINCT_LOC_ID
	,family_id
	,family_id_region
	,'SV ROOT ACCOUNT' AS sfdc_link
	,sv_root_account_name
	,SV_ROOT_ACCOUNT
	,SV_ACCOUNT
	,csg_account
	,csg_busn_name
	, b.*
	,SV_EXCL_IND
	,CSG_EXCL_IND
	,ACCT_MODULE_VERSION
from
	BI_MIP.dbo.sfdc_to_biller_dyao b
join(
	select 
		*
	from
		#yao1
	where 
		CSG_ACCOUNT is NULL
	 ) a
	on a.SV_ROOT_ACCOUNT = b.sv3
--(154 rows affected)




-----------SV ACCOUNT ONLY SV1------------
insert into #temp
select DISTINCT_LOC_ID
	,family_id
	,family_id_region
	,'SV ACCOUNT' AS sfdc_link
	,sv_root_account_name
	,SV_ROOT_ACCOUNT
	,SV_ACCOUNT
	,csg_account
	,csg_busn_name
	, b.*
	,SV_EXCL_IND
	,CSG_EXCL_IND
	,ACCT_MODULE_VERSION
from
	BI_MIP.dbo.sfdc_to_biller_dyao b
join(
	select 
		*
	from
		#yao1
	where 
		CSG_ACCOUNT is NULL
	 ) a
	on a.SV_ACCOUNT = b.sv1 
--983 records 5 seconds


-----------SV ACCOUNT ONLY SV2------------

insert into #temp
select DISTINCT_LOC_ID
	,family_id
	,family_id_region
	,'SV ACCOUNT' AS sfdc_link
	,sv_root_account_name
	,SV_ROOT_ACCOUNT
	,SV_ACCOUNT
	,csg_account
	,csg_busn_name
	, b.*
	,SV_EXCL_IND
	,CSG_EXCL_IND
	,ACCT_MODULE_VERSION
from
	BI_MIP.dbo.sfdc_to_biller_dyao b
join(
	select 
		*
	from
		#yao1
	where 
		CSG_ACCOUNT is NULL
	 ) a
	on a.SV_ACCOUNT = b.sv2 
--461 rows affected 5 seconds


-----------SV ACCOUNT ONLY SV3------------

insert into #temp
select DISTINCT_LOC_ID
	,family_id
	,family_id_region
	,'SV ACCOUNT' AS sfdc_link
	,sv_root_account_name
	,SV_ROOT_ACCOUNT
	,SV_ACCOUNT
	,csg_account
	,csg_busn_name
	, b.*
	,SV_EXCL_IND
	,CSG_EXCL_IND
	,ACCT_MODULE_VERSION
from
	BI_MIP.dbo.sfdc_to_biller_dyao b
join(
	select 
		*
	from
		#yao1
	where 
		CSG_ACCOUNT is NULL
	 ) a
	on a.SV_ACCOUNT = b.sv3
--116 rows affected 6 seconds



-----------------------------Remove Duplicates-----------------------------------

drop table bi_mip.dbo.biller_to_sfdc_mapping_dyao_new_accounts


select distinct
	DISTINCT_LOC_ID
	,family_id	
	,family_id_region	
	,sfdc_link	
	,sv_root_account_name	
	,SV_ROOT_ACCOUNT
	,SV_ACCOUNT	
	,csg_account	
	,csg_busn_name	
	,ParentID	
	,ACCOUNT__C	
	,CSG1	
	,CSG2	
	,CSG3	
	,Site_Account__c
	,mDiv	
	,SV1	
	,SV2	
	,SV3	
	,OwnerID	
	,a.Owner_name
	,a.title
	,a.Title_Role__c
	,AM_Module__c	
	,CAGE_Number__c	
	,SFDC_ACCOUNT_TYPE	
	,SFDC_OBJECT_TYPE	
	,SFDC_OWNER_USERNAME	
	,SFDC_NAT_IND	
	,SFDC_NAT_SP_IND	
	,SV_EXCL_IND	
	,CSG_EXCL_IND
	,ACCT_MODULE_VERSION
into 
	
from (
	select 
		row_number() over (partition by family_id, sv_root_account, sv_account, csg_account, 
										account__c, site_account__c, sfdc_owner_username 
										order by family_id) as rnk
		,* 
	from 
		#temp 
	join
		(select 
			id
			,[name] as owner_name
			,title
			,title_role__c
		 from
			externaluser.sfdc.[user]
		) x on OwnerID = x.id
)a
where
	a.rnk = 1
order by 
	family_id, SV_ACCOUNT, account__c

--94,119 rows


----------------------------------------scratch work ---------------------------------------------------------
select * from  bi_mip.dbo.biller_to_sfdc_mapping_dyao_new_accounts order by csg_account desc
select count (distinct csg_account) from  rptcb.rpt.biller_to_sfdc_mapping_dyao_new_accounts --order by csg_account desc

select count(*) from #temp


-----------------------------Linking Accounts, Sites to Opportunities---------------------------------------------


select 
	Site__c,
	AccountId,
	Opportunity_Number__c,
	StageName,
	OrderStatus__c,
	OwnerId,
	x.Owner_name as Owner_Name__c,
	x.Title_Role__c as Owner_Title_Role__c,
	CONVERT(DATE, CreatedDate) as  CreatedDate,
	CONVERT(DATE, CloseDate) as CloseDate
--into
	--#opportunity_temp 
from
	EXTERNALUSER.[SFDC].Opportunity
join
	(select 
		 id
		,[name] as owner_name
		,title
		,title_role__c
	  from
		externaluser.sfdc.[user]
	 ) x on OwnerId = x.id
where
	 accountid in 
(select 
	distinct ACCOUNT__C
 from 
	bi_mip.dbo.biller_to_sfdc_mapping_dyao_new_accounts) 
--and AccountId = '0011H00001vxiltQAA'