import os
import pandas as pd

from params import stage_name_dict, locks 
from utilities import get_date, convert_str_to_date, find_idxmax_by_group

# The main data output is the opportunity that's locked or having an owner. 
# This information will be used to exclude accounts later. 

class Opportunity:
    def __init__(self, csv_file):
        self.df = pd.read_csv(csv_file)
        for var in ['CreatedDate', 'CloseDate']:
            convert_str_to_date(self.df, var)

    def add_columns(self, today=None):
        date_today = get_date(date=today)

        self.df['days_from_closing'] = date_today - self.df['CloseDate']
        self.df['OPPORTUNITY_EXCL_IND'] = self.df.apply(assign_opportunity_excl_ind, axis=1)

        df_closed_won = self.df[self.df.apply(won_opp, 1)]
        max_date_idx = find_idxmax_by_group(df_closed_won, 'CreatedDate', 'AccountId')
        self.df['New_Closed_Won_Owner'] = self.df['Owner_Title_Role__c'].loc[max_date_idx] 
         
    def filter(self):
        keep_idx = ~self.df['New_Closed_Won_Owner'].isnull() | self.df['OPPORTUNITY_EXCL_IND'].isin(locks)
        self.df = self.df[keep_idx]
        self.df = (self.df.sort_values('OPPORTUNITY_EXCL_IND')
            .drop_duplicates(subset=['AccountId'], keep='first'))

    def keep_vars(self, varlist):
        self.df = self.df[varlist]

    def output_to_file(self, filepath):
        self.df.to_pickle(os.path.join(filepath, 'opportunity.pkl'))


def assign_opportunity_excl_ind(row):           
    if accepted_opp(row):
        return 'Locked - Open Opportunity'
    if pending_opp(row):
        return 'Locked - Open Opportunity'
    if lost_opp(row):
        return 'Locked - Closed Lost Last 6 Months' 

    #if opportunity is closed, completed, owned by a SBAE, they have the account for 6 months
    if won_opp(row) and within_days_from_closing(row, 183) and owner_SBAE(row):
        return 'Locked - SBAE'
    if won_opp(row) and within_days_from_closing(row, 365) and owner_EAE(row):
        return 'Locked - EAE'
    if owner_NEAM(row):
        return 'Locked - NEAM'
    if owner_SEAE(row): 
        return 'Locked - SEAE or National' 
    return 'Not Locked'


def within_days_from_closing(row, d):
    return row['days_from_closing'].days < d 

def not_cancelled(row):
    return row['OrderStatus__c'] != 'Cancelled'

def accepted_opp(row):
    return (row['StageName'] in stage_name_dict['accepted'] and 
            not_cancelled(row) and 
            within_days_from_closing(row, 183))

def pending_opp(row):
    return (row['OrderStatus__c'] in stage_name_dict['pending'] and 
            within_days_from_closing(row, 365))

def lost_opp(row):
    return (row['StageName'] in stage_name_dict['lost'] and 
             within_days_from_closing(row, 183))

def won_opp(row):
    return (row['StageName'] in stage_name_dict['won'] and 
            not_cancelled(row)) 

def owner_SBAE(row): return row['Owner_Title_Role__c'] in ('BAE3', 'BAE2')
    
def owner_EAE(row): return row['Owner_Title_Role__c'] in ('EAE')

def owner_NEAM(row): return row['Owner_Title_Role__c'] in ('NEAM', 'SNEAM')

def owner_SEAE(row): 
    return (row['Owner_Title_Role__c'] in ('SEAE', 'CAM OBSR') or
            row['Owner_Name__c'] == 'National and OTM Data feed')

