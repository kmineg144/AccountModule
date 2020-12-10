import os
import pandas as pd
import numpy as np
import hashlib
from statistics import mode
import re

# csv_file = 'accounts_11_2020.csv'
# output_filepath = 'outputs'


class FamilyIdAdjuster:
    def __init__(self, csv_file,
                 varname_family_id='family_id',
                 family_id_default_val = 0,
                 family_id_current_max = 10e7,
                 varname_family_id_region='family_id_region'):
        df = pd.read_csv(csv_file)
        df = swap_varnames(df, varname_family_id, '_FAMILY_ID', 'FAMILY_ID')
        self.df = swap_varnames(df, varname_family_id_region, '_FAMILY_ID_REGION', 'FAMILY_ID_REGION')
        self.family_id_default_val = family_id_default_val
        self.family_id_current_max = family_id_current_max

    def fill_family_id(self, 
                      varname_parent_id = 'ParentID',
                      varname_sv_bus_name = 'sv_root_account_name',
                      varname_csg_bus_name = 'csg_busn_name'):
        # The following will apply series of updates on df['FAMILY_ID', 'FAMILY_ID_REGION']
        df = self.df

        # If ParentID match is found, apply parent's family_id 
        df_assign_var2_when_matched_on_var1(df, var1=varname_parent_id, var2='FAMILY_ID', 
                                    new_varname='FAMILY_ID',  func='max')

        # If ParentID match is found, apply parent's family_id_region 
        df_assign_var2_when_matched_on_var1(df, var1=varname_parent_id, var2='FAMILY_ID_REGION', 
                                    new_varname='FAMILY_ID_REGION', func=mode)

        # Combine sv and csg business names
        df['_csg_bus_name'] = ': ' + df[varname_csg_bus_name]
        df['_bus_name'] = df.apply(assign_var2_when_var1_is_null, axis=1, 
                                  var1= varname_sv_bus_name, var2='_csg_bus_name')

        # If combined bus name match is found, apply its family_id
        # This may not identify any additional match beyond ParentID match 
        df_assign_var2_when_matched_on_var1(df, var1='_bus_name', var2='FAMILY_ID', 
            new_varname='FAMILY_ID',  func='max')

        # Generate hash numbers larger than family_id_current_max
        df['_HASH_NAME'] = df['_bus_name'].apply(
            lambda s: int(hashlib.sha256(s.encode('utf-8')).hexdigest(), 16) % 10**8 + self.family_id_current_max)

        # Fill remaining family_id_default_val with HASH_NAME value
        df['_FAMILY_ID_WITH_NULL'] = df['FAMILY_ID'].where(
            df['FAMILY_ID'] != self.family_id_default_val)
        
        # Final update
        df['FAMILY_ID'] = df.apply(assign_var2_when_var1_is_null, axis=1, 
                                          var1='_FAMILY_ID_WITH_NULL', var2='_HASH_NAME').astype('int64')

        self.df = df.drop(['_csg_bus_name','_bus_name','_HASH_NAME','_FAMILY_ID_WITH_NULL'], axis=1)

    def output_to_file(self, filepath, filename):
        self.df.to_csv(os.path.join(filepath, filename), index=False)

    def consolidate(self):
        # Used for consolidating summary_acct into summary data at the FAMILY_ID level
        df = self.df
        df.columns = [str.upper(col) for col in df.columns]

        # lists of variables sorted by type of aggregation function 
        consolidate_max = ['FILE_GROUP', 'SV_ROOT_ACCOUNT', 'CSG_ACCOUNT', 'SV_ACCT_ZIP', 
                           'PARENT_ID', 'SFDC_ACCOUNT', 'AM_MODULE', 'OWNER_ID', 'CAGE_NUMBER', 'ATHENA_LEGAL_NAME1',
                           'SV_ROOT_ACCOUNT_NAME', 'CSG_BUSN_NAME', 'CSG_TENURE_MNTHS']

        consolidate_mode = ['FAMILY_ID_REGION']

        consolidate_sum = ['SRC_ROW_CNT', 'CSG_TOTAL_MRC', 'SV_TOTAL_MRC', 'CSG_VOICE_MRC', 'CSG_DATA_MRC',
                           'CSG_VIDEO_MRC', 'CSG_CONNPRO_MRC', 'CSG_WIFIPRO_MRC', 'CSG_SECEDGE_MRC',
                           'SV_MRC_METROE', 'SV_MRC_AV_TOTAL', 
                           'SV_MRCSUBSET_AV_PRI', 'SV_MRCSUBSET_AV_SIP', 'SV_MRCSUBSET_AV_BVE', 'ATHENA_EST_EMP_CNT',
                           'ATHENA_FAMILY_TELCO_SPEND', 'CSG_AND_SV_TOTAL_MRC']

        consolidate_cnt = ['TOTAL_LOC_CNT', 'SV_SITE_CNT', 'CSG_SITE_CNT', 
                           'SV_EXCL_IND_CNT', 'CSG_EXCL_IND_CNT', 'SFDC_NAT_IND_CNT','SFDC_NAT_SP_IND_CNT',
                           'COAX_GREENISH_CNT', 'FIBER_GREENISH_CNT', 'COAX_YELLOW_CNT', 'FIBER_YELLOW_CNT',
                           'SV_ROOT_ACCOUNT_CNT', 'SV_ACCOUNT_CNT', 'SV_AAN_CNT', 'CSG_WD_SITE_CNT',
                           'CSG_ACCOUNT_CNT', 'SV_WD_SITE_CNT', 'CSG_REGION_CNT', 
                           'SV_METROE_IND', 'SV_AV_IND', 'CSG_VOICE_IND', 'CSG_DATA_IND', 'CSG_VIDEO_IND',
                           'CSG_WIFIPRO_IND', 'CSG_CONNPRO_IND', 'CSG_TW_IND', 'HBB_IND', 
                           'HSPY_IND', 'NAT_IND', 'GOV_IND', 'AGGR_IND','MES_IND', 'EDU_IND', 'CAR_IND', 'TWKR_IND', 'CBH_IND'
                          ] 

        # prep for consolidate_max
        df['FILE_GROUP'] = df['FILE_GROUP'].apply(lambda x: 'SV&CSG' if len(re.findall('SV', x))>0 else 'CSG')
        df['SV_ACCT_ZIP'] = df.SV_ACCT_ZIP.apply(convert_to_int).astype('Int32')
        df['PARENT_ID'] = df['PARENT_ID'].astype("string")

        # prep for consolidate_sum
        df['SRC_ROW_CNT'] = 1
        df['CSG_TOTAL_MRC'] = df['CSG_TOTAL_MRC_BCS_WD']
        df['CSG_WIFIPRO_MRC'] = df['CSG_WIFIPRO_MRC_WD']
        df['CSG_SECEDGE_MRC'] = df['CSG_SECEDGE_MRC_WD']
        df['CSG_CONNPRO_MRC'] = df['CSG_CONNPRO_MRC_BCS'] + df['CSG_CONNPRO_MRC_WD'] 
        df['SV_TOTAL_MRC'] = df['SV_MRC_TOTAL']
        df['ATHENA_FAMILY_TELCO_SPEND'] = df['ATHENA_SITE_TELCO_MOM1']
        df['CSG_AND_SV_TOTAL_MRC'] = df['SITE_TOTAL_MRC']
        df['ATHENA_EST_EMP_CNT'] = df.ATHENA_EMP_COUNT1.fillna(2)

        df['should_be_excluded'] = df.apply(should_be_excluded, 1)
        df['should_be_excluded2'] = df.apply(should_be_excluded2, 1)

        zero_when_excluded = ['CSG_TOTAL_MRC', 'SV_TOTAL_MRC', 'CSG_VOICE_MRC', 'CSG_DATA_MRC',
                           'CSG_VIDEO_MRC', 'CSG_CONNPRO_MRC', 'CSG_WIFIPRO_MRC', 'CSG_SECEDGE_MRC',
                           'SV_MRC_METROE', 'SV_MRC_AV_TOTAL', 
                           'SV_MRCSUBSET_AV_PRI', 'SV_MRCSUBSET_AV_SIP', 'SV_MRCSUBSET_AV_BVE']

        zero_when_excluded2 = ['ATHENA_FAMILY_TELCO_SPEND', 'CSG_AND_SV_TOTAL_MRC']

        df[zero_when_excluded] = df[zero_when_excluded].where(~df['should_be_excluded'], 0)
        df[zero_when_excluded2] = df[zero_when_excluded2].where(~df['should_be_excluded2'], 0)

        # prep for consolidate_cnt
        df['TOTAL_LOC_CNT'] = df['DISTINCT_LOC_ID']
        df['SV_SITE_CNT'] = df['SV_ROOT_ACCOUNT']
        df['CSG_SITE_CNT'] = df['CSG_HOUSEKEY']

        df['SV_EXCL_IND_CNT'] = df['DISTINCT_LOC_ID'].where(df['SV_EXCL_IND']=='Y', np.nan)
        df['CSG_EXCL_IND_CNT'] = df['DISTINCT_LOC_ID'].where(df['CSG_EXCL_IND']=='Y', np.nan)
        df['SFDC_NAT_IND_CNT'] = df['DISTINCT_LOC_ID'].where(df['SFDC_NAT_IND']=='Y', np.nan)
        df['SFDC_NAT_SP_IND_CNT'] = df['DISTINCT_LOC_ID'].where(df['SFDC_NAT_SP_IND']=='Y', np.nan)

        df['COAX_GREENISH_CNT'] = df['DISTINCT_LOC_ID'].where((~df['should_be_excluded2']) & 
                                                                (df['COAX_SELLCOLOR1'].isin(['GREEN', 'LIME GREEN'])))

        df['FIBER_GREENISH_CNT'] = df['DISTINCT_LOC_ID'].where((~df['should_be_excluded2']) & 
                                                                (df['FIBER_SELLCOLOR1'].isin(['GREEN', 'LIME GREEN'])))

        df['COAX_YELLOW_CNT'] = df['DISTINCT_LOC_ID'].where((~df['should_be_excluded2']) & 
                                                                (df['COAX_SELLCOLOR1'].isin(['YELLOW'])))

        df['FIBER_YELLOW_CNT'] = df['DISTINCT_LOC_ID'].where((~df['should_be_excluded2']) & 
                                                                (df['FIBER_SELLCOLOR1'].isin(['YELLOW'])))

        df['SV_ROOT_ACCOUNT_CNT'] = df['SV_ROOT_ACCOUNT']
        df['SV_ACCOUNT_CNT'] = df['SV_ACCOUNT']
        df['SV_AAN_CNT'] = df['SV_AAN']
        df['CSG_ACCOUNT_CNT'] = df['CSG_ACCOUNT']
        df['CSG_WD_SITE_CNT'] = df['DISTINCT_LOC_ID'].where(df['CSG4'].isin(['8155','8777','8497','8498','8772','8778','8495','8512']))
        df['SV_WD_SITE_CNT'] =  df['DISTINCT_LOC_ID'].where(df['SV_WD_SITE']=='Y')
        df['CSG_REGION_CNT'] = df['CSG_REGION_BCS']
        df['SV_METROE_IND'] =  df['DISTINCT_LOC_ID'].where(df['SV_MRC_METROE']>0)
        df['SV_AV_IND'] =  df['DISTINCT_LOC_ID'].where(df['SV_MRC_AV_TOTAL']>0)

        for item in ['VOICE', 'DATA', 'VIDEO', 'WIFIPRO']:
            df['_CSG_'+ item +'_IND'] = df['CSG_'+ item +'_IND'] 
            df['CSG_'+ item +'_IND'] =  df['DISTINCT_LOC_ID'].where((df['_CSG_'+ item +'_IND']==1) | (df['CSG_' +item+'_MRC']>0))

        for item in ['CONNPRO', 'TW']:
            df['_CSG_'+ item +'_IND'] = df['CSG_'+ item +'_IND'] 
            df['CSG_'+ item +'_IND'] =  df['DISTINCT_LOC_ID'].where(df['_CSG_'+ item +'_IND']==1)

        df['HBB_IND'] = df['DISTINCT_LOC_ID'].where(df['CSG_HBB_IND']=='Y')
        df['CSG_DWELL_DESCR_BCS1'] = df['CSG_DWELL_DESCR_BCS1'].apply(lambda x: len(re.findall('HOSPITALITY', str(x)))>0)
        df['_HSPY_IND'] = df['HSPY_IND'] 
        df['HSPY_IND'] = df['DISTINCT_LOC_ID'].where((df['CSG_DWELL_DESCR_BCS1']) | (df['HSPY_IND']=='Y'))
        df['GOV_IND'] = df['DISTINCT_LOC_ID'].where((df['GOV_IND_CSG']=='Y') | (df['GOV_IND'] =='Y'))

        for item in ['NAT', 'AGGR', 'MES', 'EDU', 'CAR', 'TWKR', 'CBH']:
            df[item + '_IND'] = df['DISTINCT_LOC_ID'].where(df[item + '_IND'] =='Y')

        # prep for athena_segment 
        df['SMB'] = df['DISTINCT_LOC_ID'].where(df['ATHENA_SEGMENT1']== 'SMALL-MEDIUM')
        df['MID'] = df['DISTINCT_LOC_ID'].where(df['ATHENA_SEGMENT1']== 'MID-MARKET')
        df['STR'] = df['DISTINCT_LOC_ID'].where(df['ATHENA_SEGMENT1']== 'STRATEGIC')
        df['NAT'] = df['DISTINCT_LOC_ID'].where(df['ATHENA_SEGMENT1']== 'NATIONAL')
        df['GOV'] = df['DISTINCT_LOC_ID'].where(df['ATHENA_SEGMENT1']== 'GOVED')
        df['UNKN'] = df['DISTINCT_LOC_ID'].where(df['ATHENA_SEGMENT1'].isnull())


        # Aggregate data for each function type and join them  
        df_max = df.groupby('FAMILY_ID')[consolidate_max].agg(max_without_null)
        df_mode = df.groupby('FAMILY_ID')[consolidate_mode].agg(mode_without_null)
        df_sum = df.groupby('FAMILY_ID')[consolidate_sum].agg(sum_without_null)
        df_cnt = df.groupby('FAMILY_ID')[consolidate_cnt].agg(lambda x: len(set_without_null(x)))

        df_athena = df.groupby('FAMILY_ID')[['SMB','MID','STR','NAT','GOV','UNKN']].agg(lambda x: len(set_without_null(x)))
        df_athena['ATHENA_SEGMENTS'] = df_athena.apply(concatenate_athena_segments, axis=1)

        df1 = (df_max
               .join(df_mode, how='outer')
               .join(df_sum, how='outer')
               .join(df_cnt, how='outer')
               .join(df_athena, how='outer')
              ).reset_index()

        # Add variables 
        df1['FAMILY_SPEND_EST_FOR_EVAL'] = df1.apply(get_higher_of_var1_var2, 
                                                     var1='ATHENA_FAMILY_TELCO_SPEND', var2='CSG_AND_SV_TOTAL_MRC', axis=1)

        df1['ESTIMATED_FAMILY_MODULE'] = df1.apply(assign_family_module, axis=1)
  
        df1['ESTIMATED_FAMILY_SPEND_RANGE'] = df1.apply(assign_family_spend_range, axis=1)

        self.df = df1 # overwrite data


def swap_varnames(df, varname1, varname2, varname3=None):
    df[varname2] = df[varname1]     # store varname1 under varname2
    df = df.drop(varname1, axis=1)  
    if varname3 is not None: df[varname3] = df[varname2] # make another copy  
    return df

def assign_var2_when_var1_is_null(row, var1, var2):
    return row[var2] if pd.isna(row[var1]) else row[var1]

def df_assign_var2_when_matched_on_var1(df, var1, var2, new_varname='var3', func='max'):
    idx_notnull = df[df[[var1,var2]].notnull().all(axis=1)].index
    df['__tmp'] = np.nan
    df.loc[idx_notnull, '__tmp'] = df.loc[idx_notnull].groupby(var1)[var2].transform(func)
    df[new_varname] = df.apply(assign_var2_when_var1_is_null, axis=1, var1='__tmp', var2=var2)
    df.drop('__tmp',1)


# ----  below are functions used in FamilyIdAdjuster.consolidate ----
def convert_to_int(val):
    if pd.isna(val): return val
    elif type(val)==str: 
        try:
            return int(val.lstrip('0'))
        except:
            return np.nan
    else: return int(val)

def should_be_excluded(row):
    return row['CSG_EXCL_IND']=='Y' or row['SFDC_NAT_SP_IND']=='Y' or row['SFDC_NAT_IND']=='Y'

def should_be_excluded2(row):
    return should_be_excluded(row) or row['SV_EXCL_IND']=='Y'

def max_without_null(x):
    xx = [i for i in x if not pd.isna(i)]
    if len(xx)==0: return np.nan
    return max(xx)

def mode_without_null(x):
    xx = [i for i in x if not pd.isna(i)]
    if len(xx)==0: return np.nan
    return mode(xx)

def sum_without_null(x):
    xx = [i for i in x if not pd.isna(i)]
    return sum(xx)

def set_without_null(x):
    xx = [i for i in x if not pd.isna(i)]
    return set(xx)

def concatenate_athena_segments(row):
    str1 = ''
    for item in ['SMB','MID','STR','NAT','GOV','UNKN']:
        str1 += item +':' + str(row[item]) + ' '
    return str1

def zero_if_pd_na(val):
    return 0 if pd.isna(val) else val 

def get_higher_of_var1_var2(row, var1, var2):
    return max(zero_if_pd_na(row[var1]), zero_if_pd_na(row[var2]))

def assign_family_module(row):
    if family_module_exclude(row): return 'EXCL'
    elif eam_family_spend(row): return 'EAM'
    elif eam_lot_cnt(row):  return 'EAM'
    elif am1_family_spend(row):  return 'AM1'
    elif am1_lot_cnt(row):  return 'AM1'
    elif center_family_spend(row): return 'CENTER'
    else: return 'UNDEFINED'
    
def eam_family_spend(row):
    return row['FAMILY_SPEND_EST_FOR_EVAL'] >= 2000
   
def am1_family_spend(row):
    return row['FAMILY_SPEND_EST_FOR_EVAL'] >= 500

def center_family_spend(row):
    return not pd.isna(row['FAMILY_SPEND_EST_FOR_EVAL'])

def eam_lot_cnt(row):
    return row['TOTAL_LOC_CNT'] > 9

def am1_lot_cnt(row):
    return row['TOTAL_LOC_CNT'] > 3

def family_module_exclude(row):
    excl_sum = sum([row[var] for var in ['SV_EXCL_IND_CNT','CSG_EXCL_IND_CNT','SFDC_NAT_IND_CNT','SFDC_NAT_SP_IND_CNT']])
    return excl_sum > 0

# ESTIMATED_FAMILY_SPEND_RANGE bins 
bins = [100, 200, 250, 300, 400, 500, 750, 1000, 2000, 3000, 4000, float('inf')]
labels = [str(val) + ' to ' for val in bins]
labels = [lab + str(val) for lab, val in zip(labels, bins[1:]+[''])]
labels = [str(bins[0]) + ' or less'] + labels[:len(bins)-2] + [str(bins[len(bins)-2])+'+']

def assign_family_spend_range(row):
    ref = np.digitize(zero_if_pd_na(row['FAMILY_SPEND_EST_FOR_EVAL']), bins, right=True)
    return labels[ref]

