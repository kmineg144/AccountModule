import pandas as pd
import numpy as np

class Account:
    def __init__(self, csv_file):
        self.df = pd.read_csv(csv_file)

    def merge_data(self, df_opp):
        self.df = (
            self.df.set_index('ACCOUNT__C')
            .join(df_opp.set_index('AccountId'), how = 'left')
            .reset_index()
            .rename(columns={
                'index': 'ACCOUNT__C',
                'Owner_Title_Role__c': 'Opportunity_Owner_Role',
                'Owner_Name__c': 'Opportunity_Owner_Name'})
            )

    def add_columns(self):
        self.df['Final_Owners_Name'] = self.df['Opportunity_Owner_Name'].fillna(self.df['Owner_name'])
        self.df['Final_Owner_Role_Name'] = self.df['Opportunity_Owner_Role'].fillna(self.df['Title_Role__c'])
        self.df['SP_IND'] = self.df['Opportunity_Owner_Role'].apply(lambda x: 'Y' if x =='SP' else np.nan)        
        
        df_AM_module_null = self.df.where(self.df.apply(is_AM_module_null, 1))
        self.df['Family_Most_Recent_Opportunity'] = df_AM_module_null['CreatedDate']

    def filter(self):
        # keep one observation per family_id by prioritizing 
        # the accounts that must not be pursued for further sales and 
        # then those that can be pursued for sales associated with the latest opportunity
        self.df = (self.df.sort_values([
                'AM_Module__c'
               ,'OPPORTUNITY_EXCL_IND'
               ,'SP_IND'
               ,'CreatedDate'], ascending=[True, True, True, False])
            .drop_duplicates(subset=['family_id'], keep='first')
            )

    def drop_vars(self, dropping_vars):
        self.df.columns = [str.upper(col) for col in self.df] 
        self.df = self.df.drop(dropping_vars, 1)

    def output_to_file(self, filepath):
        self.df.to_pickle(os.path.join(filepath, 'account.pkl'))
                            
def is_AM_module_null(row):
    # When these are not not null, opportunities should not be considered for further sales 
    return row['AM_Module__c'] is np.nan and row['CAGE_Number__c'] is np.nan

