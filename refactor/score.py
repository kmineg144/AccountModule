import os
import pandas as pd
import numpy as np
from pandas import ExcelWriter

from params import url_salesforce, data_plan_indicators,  voice_plan_indicators, \
  flag_items_EXCL_IND, score_file, score_items, keeping_vars_sco

from utilities import varlist_sum, weighted_varlist_sum

sco_table = pd.read_csv(score_file)

sco_weights = sco_table[['feature','weight']].drop_duplicates()
sco_weights = sco_weights[sco_weights['weight'].notnull()]
sco_weights_dict = sco_weights.set_index('feature').to_dict()['weight']

def check_unique_weights_within_features():
    return count_score_features() == len(sco_weights_dict)

def count_score_features():
    return  len(sco_table[sco_table['weight'].notnull()]['feature'].unique()) 

if not check_unique_weights_within_features():
    raise ValueError('Please check the weights in score_file.')


class Score:
    def __init__(self, csv_file):
        self.df = pd.read_csv(csv_file)
        vars_to_drop1 = ['PARENT_ID_MAX', 'SFDC_ACCOUNT_MAX', 'AM_MODULE_MAX', 'OWNER_ID_MAX', 'CAGE_NUMBER_MAX']
        vars_to_drop2 = ['PARENT_ID', 'SFDC_ACCOUNT', 'AM_MODULE', 'OWNER_ID', 'CAGE_NUMBER']
        try:
            self.df = self.df.drop(vars_to_drop1, 1)
        except:
            self.df = self.df.drop(vars_to_drop2, 1)

    def filter(self):
        self.df = self.df[self.df.FAMILY_SPEND_EST_FOR_EVAL > 500]

    def merge_data(self, df_acc):
        self.df = (self.df.set_index('FAMILY_ID')
                    .join(df_acc.set_index('FAMILY_ID'), how = 'left')
                    .reset_index()
                    )

    def add_columns(self):
        self.df['SFDC_OPPORTUNITY_IND'] = self.df.apply(opp_locked,1) 
        self.df['SFDC_SP_IND'] = self.df.apply(sp_ind,1) 
        self.df['SFDC_MODULE_IND'] = self.df.apply(am_or_cage,1)
        self.df['ONE_PRODUCT_IND'] = self.df.apply(having_one_product_only,1)
        self.df['ANY_EXCL_IND'] = self.df[flag_items_EXCL_IND].sum(axis=1)

        self.df['SFDC_ACCOUNT_URL'] = self.df.apply(add_ulr_to_account,1)

        for item in score_items:
            tbl = sco_table[sco_table['feature'] == item]
            self.df[item + '_SCORE'] = self.df.apply(assign_score_to_item, axis=1, 
                score_item = item, score_table=tbl)

        weights = [sco_weights_dict.get(item) for item in score_items]
        self.df['FINAL_SCORE'] = self.df.apply(assign_final_score, axis=1, weights=weights)

        tbl_color = sco_table[sco_table['feature'] == 'FINAL_SCORE']
        self.df['COLOR_SCORE'] = self.df.apply(assign_score_to_item, axis=1,
            score_item = 'FINAL_SCORE', score_table=tbl_color, score_var='color')

    def keep_vars(self, varlist):
        self.df = self.df[varlist]

    @property
    def region_dict(self):
        regions = self.df['FAMILY_ID_REGION'].dropna().unique().tolist()
        region_dict = { region.replace(" ", "_").lower(): region for region in regions }
        return region_dict

    @property
    def excel_tabs(self):
        """Generates 3-way split subsets of data:    
        df_no_excl : accounts that have no exclusions, i.e. further sales effort priority! 
        df_excl: accounts that have >= 1 exclusions, i.e. maybe some sales effort
        df_no_sfdc: accounts with no sfdc link, i.e., manually find salesforce links for big accounts
        """
        df_no_excl = self.df[(self.df['ANY_EXCL_IND'] == 0) & (having_sfdc_link(self.df))]      
        df_excl = self.df[(self.df['ANY_EXCL_IND'] >= 1) & (having_sfdc_link(self.df))]
        df_no_sfdc = self.df[~having_sfdc_link(self.df)]

        return {'assigned' : df_no_excl,
                'excluded' : df_excl,
                'no_sfdc' : df_no_sfdc}

    def output_to_file(self, filepath, filepath_pkl):
        for region_key, region in self.region_dict.items():
            sheet_dict = {}
            filename = os.path.join(filepath, region_key + '.xlsx')
            writer = ExcelWriter(filename, engine='xlsxwriter')

            for tab_key, tab_df in self.excel_tabs.items():
                df_region =  tab_df.loc[tab_df['FAMILY_ID_REGION'] == region]
                sheet_dict[region_key + '_' + tab_key] = df_region

            for sheet_name, sheet_df in sheet_dict.items():
                sheet_df.to_excel(writer, sheet_name = sheet_name, index =False)
            writer.save()

        self.df.to_pickle(os.path.join(filepath_pkl, 'score.pkl'))


# def opp_locked_or_null(row):
#     return ( str(row['OPPORTUNITY_EXCL_IND']).find('Locked -') >= 0 or 
#              pd.isna(row['OPPORTUNITY_EXCL_IND']) )  

# def sp_or_null(row):
#     return str(row['SP_IND']).find('Y') >= 0 or pd.isna(row['SP_IND'])  
def opp_locked(row):
    return str(row['OPPORTUNITY_EXCL_IND']).find('Locked -') >= 0 

def sp_ind(row):
    return str(row['SP_IND']).find('Y') >= 0  

def am_or_cage(row):
    return not pd.isna(row['AM_MODULE__C']) or not pd.isna(row['CAGE_NUMBER__C']) 

def add_ulr_to_account(row):
    return url_salesforce + str(row['ACCOUNT__C']) if not pd.isna(row['ACCOUNT__C']) else ''

def having_one_product_only(row):
    return 1 if having_data_only(row) or having_voice_only(row) else 0

def having_data_only(row):
    return ( varlist_sum(row, data_plan_indicators) > 0 and 
             varlist_sum(row, voice_plan_indicators) == 0 )

def having_voice_only(row):
    return ( varlist_sum(row, data_plan_indicators) == 0 and 
             varlist_sum(row, voice_plan_indicators) > 0 )

def assign_score_to_item(row, score_item, score_table, score_var='score'): 
    bins = score_table['stop']
    if pd.isna(row[score_item]): 
        ref = 0 
    elif row[score_item] > max(bins):
        ref = len(bins) - 1
    else:
        ref = np.digitize(row[score_item], bins, right=True)
    return score_table[score_var].iloc[ref]

def assign_final_score(row, weights):
    score_items_score = [item + '_SCORE' for item in score_items]
    return weighted_varlist_sum(row, score_items_score, weights)

def having_sfdc_link(df):
    return df['ACCOUNT__C'].notnull()


