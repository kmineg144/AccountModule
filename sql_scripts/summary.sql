drop table BI_MIP.dbo.biller_sfdc_accounts_summary_dyao 

SELECT 
	MIN(ACCT_MODULE_VERSION) ACCT_MODULE_VERSION,
	MAX(CASE WHEN FILE_GROUP LIKE '%SV%' THEN 'SV&CSG' ELSE 'CSG' END) FILE_GROUP,
	'UNDEFINED' ESTIMATED_FAMILY_MODULE,
	'TBD       TBD' ESTIMATED_FAMILY_SPEND_RANGE,
	SUM(1) SRC_ROW_CNT,
	FAMILY_ID,
	max(FAMILY_ID_REGION) FAMILY_ID_REGION,
	max(SV_ROOT_ACCOUNT) as SV_ROOT_ACCOUNT,
	max(CSG_ACCOUNT) as CSG_ACCOUNT ,
	max(TRY_CAST(BILLING_ZIP AS INT)) as BILLING_ZIP_MAX,
	CONCAT( 'SMB:',COUNT(DISTINCT CASE WHEN ATHENA_SEGMENT1 = 'SMALL-MEDIUM' THEN DISTINCT_LOC_ID ELSE NULL END )
			,'  MID:',COUNT(DISTINCT CASE WHEN ATHENA_SEGMENT1 = 'MID-MARKET' THEN DISTINCT_LOC_ID ELSE NULL END ) 
			,'  NAT:',COUNT(DISTINCT CASE WHEN ATHENA_SEGMENT1 = 'NATIONAL' THEN DISTINCT_LOC_ID ELSE NULL END ) 
			,'  UNKN:',COUNT(DISTINCT CASE WHEN ATHENA_SEGMENT1 IS NULL THEN DISTINCT_LOC_ID ELSE NULL END )
			) ATHENA_SEGMENTS,
	MAX(ATHENA_LEGAL_NAME1) ATHENA_LEGAL_NAME1,
	MAX(SV_ROOT_ACCOUNT_NAME) SV_BUSN_NAME_MAX,
	MAX(CSG_BUSN_NAME) CSG_BUSN_NAME_MAX,
	9999999.99 FAMILY_SPEND_EST_FOR_EVAL,
	SUM(case when concat(ISNULL(sv_excl_ind,''),ISNULL(csg_excl_ind,''),ISNULL(sfdc_nat_ind,''),ISNULL(sfdc_nat_sp_ind,'')) like '%y%' then 0 else ATHENA_SITE_TELCO_MOM1 end) ATHENA_FAMILY_TELCO_SPEND,
	SUM(case when concat(ISNULL(sv_excl_ind,''),ISNULL(csg_excl_ind,''),ISNULL(sfdc_nat_ind,''),ISNULL(sfdc_nat_sp_ind,'')) like '%y%' then 0 else SITE_TOTAL_MRC END) CSG_AND_SV_TOTAL_MRC,
	COUNT(DISTINCT DISTINCT_LOC_ID) TOTAL_LOC_CNT,
	COUNT(DISTINCT CASE WHEN SV_ROOT_ACCOUNT IS NOT NULL THEN DISTINCT_LOC_ID ELSE NULL END) SV_SITE_CNT,
	COUNT(DISTINCT CSG_HOUSEKEY) CSG_SITE_CNT,
	COUNT(DISTINCT CASE WHEN SV_EXCL_IND = 'Y' THEN DISTINCT_LOC_ID ELSE NULL END) SV_EXCL_IND_CNT,
	COUNT(DISTINCT CASE WHEN CSG_EXCL_IND = 'Y' THEN DISTINCT_LOC_ID ELSE NULL END) CSG_EXCL_IND_CNT,
	COUNT(DISTINCT CASE WHEN sfdc_nat_ind = 'Y' THEN DISTINCT_LOC_ID ELSE NULL END) SFDC_NAT_IND_CNT,
	COUNT(DISTINCT CASE WHEN sfdc_nat_sp_ind = 'Y' THEN DISTINCT_LOC_ID ELSE NULL END) SFDC_NAT_SP_IND_CNT,
	COUNT(DISTINCT CASE WHEN CONCAT(ISNULL(SV_EXCL_IND,''),ISNULL(CSG_EXCL_IND,''),ISNULL(sfdc_nat_ind,''),ISNULL(sfdc_nat_sp_ind,'')) NOT LIKE '%Y%' 
					AND ISNULL(COAX_SELLCOLOR1,'') IN ('GREEN','LIME GREEN') THEN NULL ELSE DISTINCT_LOC_ID END) COAX_GREENISH_CNT,
	COUNT(DISTINCT CASE WHEN CONCAT(ISNULL(SV_EXCL_IND,''),ISNULL(CSG_EXCL_IND,''),ISNULL(sfdc_nat_ind,''),ISNULL(sfdc_nat_sp_ind,'')) NOT LIKE '%Y%' 
					AND ISNULL(FIBER_SELLCOLOR1,'') IN ('GREEN','LIME GREEN') THEN NULL ELSE DISTINCT_LOC_ID END) FIBER_GREENISH_CNT,
	COUNT(DISTINCT CASE WHEN CONCAT(ISNULL(SV_EXCL_IND,''),ISNULL(CSG_EXCL_IND,''),ISNULL(sfdc_nat_ind,''),ISNULL(sfdc_nat_sp_ind,'')) NOT LIKE '%Y%' 
					AND ISNULL(COAX_SELLCOLOR1,'') IN ('YELLOW') THEN NULL ELSE DISTINCT_LOC_ID END) COAX_YELLOW_CNT,
	COUNT(DISTINCT CASE WHEN CONCAT(ISNULL(SV_EXCL_IND,''),ISNULL(CSG_EXCL_IND,''),ISNULL(sfdc_nat_ind,''),ISNULL(sfdc_nat_sp_ind,'')) NOT LIKE '%Y%' 
					AND ISNULL(FIBER_SELLCOLOR1,'') IN ('YELLOW') THEN NULL ELSE DISTINCT_LOC_ID END) FIBER_YELLOW_CNT,
	COUNT(DISTINCT SV_ROOT_ACCOUNT) SV_ROOT_ACCOUNT_CNT,
	COUNT(DISTINCT SV_ACCOUNT) SV_ACCOUNT_CNT,
	COUNT(DISTINCT SV_AAN) SV_AAN_CNT,
	COUNT(DISTINCT CASE WHEN CSG4 IN ('8155','8777','8497','8498','8772','8778','8495','8512') THEN DISTINCT_LOC_ID ELSE NULL END) CSG_WD_SITE_CNT,
	COUNT(DISTINCT CSG_ACCOUNT) CSG_ACCOUNT_CNT,
	COUNT(DISTINCT CASE WHEN SV_WD_SITE = 'Y' THEN DISTINCT_LOC_ID ELSE NULL END) SV_WD_SITE_CNT,
	COUNT(DISTINCT CSG_REGION_BCS) CSG_REGIONS_CNT,
	COUNT(DISTINCT CASE WHEN SV_MRC_METROE > 0	 THEN DISTINCT_LOC_ID ELSE NULL END) SV_METROE_IND,
	COUNT(DISTINCT CASE WHEN SV_MRC_AV_TOTAL > 0 THEN DISTINCT_LOC_ID ELSE NULL END)  SV_AV_IND,
	COUNT(DISTINCT CASE WHEN CSG_VOICE_IND	= 1	OR CSG_VIDEO_MRC > 0	THEN DISTINCT_LOC_ID ELSE NULL END) CSG_VOICE_IND,
	COUNT(DISTINCT CASE WHEN CSG_DATA_IND	= 1
		OR CSG_DATA_MRC > 0 	THEN DISTINCT_LOC_ID ELSE NULL END) CSG_DATA_IND,
	COUNT(DISTINCT CASE WHEN CSG_VIDEO_IND	= 1	OR CSG_VIDEO_MRC > 0	THEN DISTINCT_LOC_ID ELSE NULL END) CSG_VIDEO_IND,
	COUNT(DISTINCT CASE WHEN CSG_WIFIPRO_IND = 1 OR CSG_WIFIPRO_MRC_WD > 0	THEN DISTINCT_LOC_ID ELSE NULL END) CSG_WIFIPRO_IND,
	COUNT(DISTINCT CASE WHEN CSG_CONNPRO_IND = 1	THEN DISTINCT_LOC_ID ELSE NULL END) CSG_CONNPRO_IND,
	COUNT(DISTINCT CASE WHEN CSG_TW_IND		= 1		THEN DISTINCT_LOC_ID ELSE NULL END) CSG_TW_IND,
	SUM(case when csg_excl_ind like '%y%' or sfdc_nat_ind = 'Y' or sfdc_nat_sp_ind = 'Y' then 0 else CSG_TOTAL_MRC_BCS_WD end) CSG_TOTAL_MRC,
	SUM(case when csg_excl_ind like '%y%' or sfdc_nat_ind = 'Y' or sfdc_nat_sp_ind = 'Y'  then 0 else SV_MRC_TOTAL	end) SV_TOTAL_MRC,
	SUM(case when csg_excl_ind like '%y%' or sfdc_nat_ind = 'Y' or sfdc_nat_sp_ind = 'Y'  then 0 else CSG_VOICE_MRC end)	CSG_VOICE_MRC,
	SUM(case when csg_excl_ind like '%y%' or sfdc_nat_ind = 'Y' or sfdc_nat_sp_ind = 'Y'  then 0 else CSG_DATA_MRC end)		CSG_DATA_MRC,
	SUM(case when csg_excl_ind like '%y%' or sfdc_nat_ind = 'Y' or sfdc_nat_sp_ind = 'Y'  then 0 else CSG_VIDEO_MRC end)	CSG_VIDEO_MRC,
	SUM(case when csg_excl_ind like '%y%' or sfdc_nat_ind = 'Y' or sfdc_nat_sp_ind = 'Y'  then 0 else CSG_CONNPRO_MRC_BCS + CSG_CONNPRO_MRC_WD  end) CSG_CONNPRO_MRC,
	SUM(case when csg_excl_ind like '%y%' or sfdc_nat_ind = 'Y' or sfdc_nat_sp_ind = 'Y'  then 0 else CSG_WIFIPRO_MRC_WD end)	CSG_WIFIPRO_MRC,
	SUM(case when csg_excl_ind like '%y%' or sfdc_nat_ind = 'Y' or sfdc_nat_sp_ind = 'Y'  then 0 else CSG_SECEDGE_MRC_WD end)	CSG_SECEDGE_MRC,
	SUM(case when sv_excl_ind like '%y%' or sfdc_nat_ind = 'Y' or sfdc_nat_sp_ind = 'Y' then 0 else SV_MRC_METROE			end) SV_MRC_METROE,
	SUM(case when sv_excl_ind like '%y%' or sfdc_nat_ind = 'Y' or sfdc_nat_sp_ind = 'Y'  then 0 else SV_MRC_AV_TOTAL	end) SV_MRC_AV_TOTAL,
	SUM(case when sv_excl_ind like '%y%' or sfdc_nat_ind = 'Y' or sfdc_nat_sp_ind = 'Y'  then 0 else SV_MRCsubset_AV_PRI		end) SV_MRCsubset_AV_PRI,
	SUM(case when sv_excl_ind like '%y%' or sfdc_nat_ind = 'Y' or sfdc_nat_sp_ind = 'Y'  then 0 else SV_MRCsubset_AV_SIP		end) SV_MRCsubset_AV_SIP,
	SUM(case when sv_excl_ind like '%y%' or sfdc_nat_ind = 'Y' or sfdc_nat_sp_ind = 'Y'  then 0 else SV_MRCsubset_AV_BVE		end) SV_MRCsubset_AV_BVE,
	--MIN(CSG_ORIG_CONN_DT) CSG_ORIG_CONN_DT,
	--MIN(CSG_VOICE_CONN_DT) CSG_VOICE_CONN,
	--MIN(CSG_DATA_CONN_DT) CSG_DATA_CONN_DT,
	SUM(ISNULL(ATHENA_EMP_COUNT1,2)) ATHENA_EST_EMP_CNT,
	MAX(CSG_TENURE_MNTHS) CSG_TENURE_MNTHS,
	COUNT(DISTINCT CASE WHEN CSG_HBB_IND = 'Y' THEN DISTINCT_LOC_ID ELSE NULL END) HBB_IND, 
	COUNT(DISTINCT CASE WHEN CSG_DWELL_DESCR_BCS1 LIKE '%HOSPITALITY%' OR HSPY_IND = 'Y' THEN DISTINCT_LOC_ID ELSE NULL END) HSPY_IND, 
	COUNT(DISTINCT CASE WHEN GOV_IND_CSG = 'Y' OR NAT_IND = 'Y' THEN DISTINCT_LOC_ID ELSE NULL END) NAT_IND, 
	COUNT(DISTINCT CASE WHEN GOV_IND_CSG = 'Y' OR GOV_IND = 'Y' THEN DISTINCT_LOC_ID ELSE NULL END) GOV_IND, 
	COUNT(DISTINCT CASE WHEN AGGR_IND = 'Y' THEN DISTINCT_LOC_ID ELSE NULL END) AGGR_IND, 
	COUNT(DISTINCT CASE WHEN MES_IND = 'Y' THEN DISTINCT_LOC_ID ELSE NULL END) MES_IND, 
	COUNT(DISTINCT CASE WHEN EDU_IND_CSG = 'Y' OR EDU_IND = 'Y' THEN DISTINCT_LOC_ID ELSE NULL END) EDU_IND, 
	COUNT(DISTINCT CASE WHEN CAR_IND = 'Y' THEN DISTINCT_LOC_ID ELSE NULL END) CAR_IND, 
	COUNT(DISTINCT CASE WHEN TWKR_IND = 'Y' THEN DISTINCT_LOC_ID ELSE NULL END) TWKR_IND, 
	COUNT(DISTINCT CASE WHEN CBH_IND = 'Y' THEN DISTINCT_LOC_ID ELSE NULL END) CBH_IND
	,MAX(PARENT_ID) as PARENT_ID_MAX
	,MAX(SFDC_ACCOUNT) as SFDC_ACCOUNT_MAX
	,MAX(AM_MODULE) as AM_MODULE_MAX
	,MAX(OWNER_ID) as OWNER_ID_MAX
	,MAX(CAGE_NUMBER) as CAGE_NUMBER_MAX
into
	BI_MIP.dbo.biller_sfdc_accounts_summary_dyao 
from 
	BI_MIP.dbo.biller_sfdc_accounts_dyao 
GROUP BY 
	FAMILY_ID


UPDATE A
SET FAMILY_SPEND_EST_FOR_EVAL = (SELECT MAX( DOLLARS ) FROM ( VALUES(ISNULL(ATHENA_FAMILY_TELCO_SPEND,0)) ,(ISNULL(CSG_AND_SV_TOTAL_MRC,0))) AS E(DOLLARS)  )
FROM BI_MIP.dbo.biller_sfdc_accounts_summary_dyao AS A --601395


UPDATE A
SET ESTIMATED_FAMILY_MODULE =
		CASE 
			WHEN COALESCE(FAMILY_SPEND_EST_FOR_EVAL,0) >= 2000 THEN 'EAM'
			WHEN (TOTAL_LOC_CNT >9 ) THEN 'EAM'
			WHEN (COALESCE(FAMILY_SPEND_EST_FOR_EVAL,0) > 500 AND COALESCE(FAMILY_SPEND_EST_FOR_EVAL,0) < 2000 and COALESCE(CSG_AND_SV_TOTAL_MRC,0) < 2000) THEN 'AM1'
			WHEN (COALESCE(CSG_AND_SV_TOTAL_MRC,0) > 500 AND COALESCE(CSG_AND_SV_TOTAL_MRC,0) < 2000) THEN 'AM1'
			when TOTAL_LOC_CNT >3 and  CSG_AND_SV_TOTAL_MRC < 2000 then 'AM1'
			WHEN (TOTAL_LOC_CNT >3 AND TOTAL_LOC_CNT <=9 ) THEN 'AM1'
			WHEN COALESCE(FAMILY_SPEND_EST_FOR_EVAL,0) <= 500 THEN 'CENTER' 
			WHEN COALESCE(CSG_AND_SV_TOTAL_MRC,0) <= 500 THEN 'CENTER' 
			WHEN TOTAL_LOC_CNT <= 3 THEN 'CENTER'
			ELSE 'UNDEFINED' END ,
ESTIMATED_FAMILY_SPEND_RANGE = 
			CASE WHEN COALESCE(FAMILY_SPEND_EST_FOR_EVAL,0) BETWEEN   -1 AND  100 THEN  '100 OR LESS'
				 WHEN COALESCE(FAMILY_SPEND_EST_FOR_EVAL,0) BETWEEN  100 AND  200 THEN   '100 TO 200'
				 WHEN COALESCE(FAMILY_SPEND_EST_FOR_EVAL,0) BETWEEN  200 AND  250 THEN   '200 TO 250'
				 WHEN COALESCE(FAMILY_SPEND_EST_FOR_EVAL,0) BETWEEN  250 AND  300 THEN   '250 TO 300'
				 WHEN COALESCE(FAMILY_SPEND_EST_FOR_EVAL,0) BETWEEN  300 AND  400 THEN   '300 TO 400'
				 WHEN COALESCE(FAMILY_SPEND_EST_FOR_EVAL,0) BETWEEN  400 AND  500 THEN   '400 TO 500'
				 WHEN COALESCE(FAMILY_SPEND_EST_FOR_EVAL,0) BETWEEN  500 AND  750 THEN   '500 TO 750'
				 WHEN COALESCE(FAMILY_SPEND_EST_FOR_EVAL,0) BETWEEN  750 AND 1000 THEN  '750 TO 1000'
				 WHEN COALESCE(FAMILY_SPEND_EST_FOR_EVAL,0) BETWEEN 1000 AND 2000 THEN '1000 TO 2000'
				 WHEN COALESCE(FAMILY_SPEND_EST_FOR_EVAL,0) BETWEEN 2000 AND 3000 THEN '2000 TO 3000'
				 WHEN COALESCE(FAMILY_SPEND_EST_FOR_EVAL,0) BETWEEN 3000 AND 4000 THEN '3000 TO 4000'
				 ELSE '4000+' END
FROM BI_MIP.dbo.biller_sfdc_accounts_summary_dyao AS A

update a
set ESTIMATED_FAMILY_MODULE = 'EXCLD'--- SELECT COUNT(*) CNT
from BI_MIP.dbo.biller_sfdc_accounts_summary_dyao as a where --family_id = 35161	AND --- 10658
(SV_EXCL_IND_CNT + CSG_EXCL_IND_CNT + SFDC_NAT_IND_CNT + SFDC_NAT_SP_IND_CNT )> 0


select * from BI_MIP.dbo.biller_sfdc_accounts_summary_dyao  order by family_id


----------------------------------TEST QUERIES-----------------------------------------

 select * from 	BI_MIP.dbo.biller_sfdc_accounts_summary_dyao where family_id = 21009--CSG_AND_SV_TOTAL_MRC = 0  order by family_id asc

 select 
count(*)
,sum(case when sfdc_account_max is NULL then 0 else 1 end)
from BI_MIP.dbo.biller_sfdc_accounts_summary_dyao 


 select 
count(*)
,sum(case when sfdc_account_max is NULL then 0 else 1 end)
from rptcb.rpt.biller_sfdc_accounts_summary_dyao 