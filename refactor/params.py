

# --- Data files --- 
opportunity_csv = ''
account_csv = ''
summary_csv = ''
score_file = 'score_feature.csv'

output_filepath = ''

# --- Misc. --- 
url_salesforce = 'https://comcast.my.salesforce.com/'


# --- Dict  ---
stage_name_dict = {
    'won': ['Closed Won', 'Closed - Won'],
    'accepted': ['Solutions Proposal Accepted', 'Qualified', 'Sales Accepted'],
    'pending': ['Install Complete Pending OC', 'Pending Installation', 'Pending Installation' ,
                'Pending Status' , 'Scheduled'],
    'lost': ['Closed Lost']
    }

# --- Value lists --- 
locks = ['Locked - Closed Lost'
        ,'Locked - Open Opportunity'
        ,'Locked - SBAE', 'Locked - EAE'
        ,'Locked - NEAM'
        ,'Locked - SEAE or National'
        ]


# ---- Lists of variables ---

data_plan_indicators = ['SV_METROE_IND', 'CSG_DATA_IND', 'CSG_WIFIPRO_IND', 
					'CSG_CONNPRO_IND', 'CSG_TW_IND']

voice_plan_indicators = ['CSG_VOICE_IND', 'SV_AV_IND']


keeping_vars_opp = [
                'Site__c',
                'AccountId',
                'Opportunity_Number__c',
                'StageName',
                'OrderStatus__c',
                'OwnerId',
                'Owner_Name__c',
                'Owner_Title_Role__c',
                'CreatedDate',
                'CloseDate',
                'OPPORTUNITY_EXCL_IND'
                ] 

subset_vars_opp = ['AccountId'
                    , 'Opportunity_Number__c'
                    , 'CreatedDate'
                    , 'OPPORTUNITY_EXCL_IND'
                    , 'Owner_Title_Role__c'
                    , 'Owner_Name__c']
       
dropping_vars_acc = ['CSG2', 'SV_EXCL_IND','CSG_EXCL_IND', 
	'SFDC_ACCOUNT_TYPE', 'SFDC_OBJECT_TYPE' ]


subset_vars_acc = ['FAMILY_ID'
                    ,'SFDC_LINK'
                    , 'PARENTID'
                    , 'ACCOUNT__C'
                    , 'FINAL_OWNER_ROLE_NAME'
                    , 'FINAL_OWNERS_NAME'
                    , 'OPPORTUNITY_EXCL_IND'
                    , 'FAMILY_MOST_RECENT_OPPORTUNITY'
                    , 'AM_MODULE__C'
                    , 'CAGE_NUMBER__C'
                    ,'SP_IND'
                    ]

flag_items_EXCL_IND = ['SV_EXCL_IND_CNT',
                     'CSG_EXCL_IND_CNT',
                     'SFDC_NAT_IND_CNT',
                     'SFDC_NAT_SP_IND_CNT',
                     'HBB_IND',
                     'HSPY_IND',
                     'NAT_IND',
                     'GOV_IND',
                     'AGGR_IND',
                     'MES_IND',
                     'EDU_IND',
                     'CAR_IND',
                     'TWKR_IND',
                     'CBH_IND',
                     'SFDC_SP_IND',
                     'SFDC_OPPORTUNITY_IND',
                     'SFDC_MODULE_IND']


score_items = ['FAMILY_SPEND_EST_FOR_EVAL'
                ,'CSG_TENURE_MNTHS'
                ,'CSG_AND_SV_TOTAL_MRC'
                ,'ONE_PRODUCT_IND'
                ,'TOTAL_LOC_CNT']

keeping_vars_sco = [
               'ACCT_MODULE_VERSION',
                'ESTIMATED_FAMILY_MODULE',
                'ESTIMATED_FAMILY_SPEND_RANGE',
                'FAMILY_ID',
                'FAMILY_ID_REGION',
                'BILLING_ZIP_MAX',
                'ATHENA_LEGAL_NAME1',
                'SV_BUSN_NAME_MAX',
                'CSG_BUSN_NAME_MAX',
                'FAMILY_SPEND_EST_FOR_EVAL',
                'ATHENA_FAMILY_TELCO_SPEND',
                'CSG_AND_SV_TOTAL_MRC',
                'TOTAL_LOC_CNT',
                'CSG_TENURE_MNTHS',
                'PARENTID',
                'ACCOUNT__C',
                'CAGE_NUMBER__C',
                'AM_MODULE__C',
                'FINAL_OWNER_ROLE_NAME',
                'FINAL_OWNERS_NAME',
                'OPPORTUNITY_EXCL_IND',
                'FAMILY_MOST_RECENT_OPPORTUNITY',
                'SV_EXCL_IND_CNT',
                'CSG_EXCL_IND_CNT',
                'SFDC_NAT_IND_CNT',
                'SFDC_NAT_SP_IND_CNT',
                'HBB_IND',
                'HSPY_IND',
                'NAT_IND',
                'GOV_IND',
                'AGGR_IND',
                'MES_IND',
                'EDU_IND',
                'CAR_IND',
                'TWKR_IND',
                'CBH_IND',
                'SFDC_SP_IND',
                'SFDC_OPPORTUNITY_IND',
                'SFDC_MODULE_IND',
                'FAMILY_SPEND_EST_FOR_EVAL_SCORE',
                'CSG_TENURE_MNTHS_SCORE',
                'CSG_AND_SV_TOTAL_MRC_SCORE',
                'ONE_PRODUCT_IND_SCORE',
                'TOTAL_LOC_CNT_SCORE',
                'FINAL_SCORE',
                'COLOR_SCORE',
                'ANY_EXCL_IND',
                'SFDC_ACCOUNT_URL'
               ]


