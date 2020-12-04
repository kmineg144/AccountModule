import pandas as pd
import numpy as np


class EstablishWinner():
    """This class will pit all the winners at the 
       opportunity level for a given account and 
       declare the winning account based on several 
       criteria.

       The hiearchy for determining this in the
       following order. If a winner cannot be 
       determined after going down this waterfall,
       the owner will be the agent who created the 
       original SF account.

       1. AM_MODULE__C and CAGE
            if either of these are filled, the account
            is locked
       2. OPPORTUNITY_EXCL_IND 
            these are defined in the pandas_utilities 
            file
       3. SP_IND
            account is locked if a SP is assigned to it
       4. Family_Most_Recent_Opportunity
            createdate most recent Closed-Won 
            opportunity

    Attributes:
        df: DataFrame
            the merged opportunity and account dataframe
            
    """
    
    def __init__(self, df):
        self.df = df
        self.new_columns_called = False


    def new_columns(self):
        self.new_columns_called = True
    
        self.df['Family_Most_Recent_Opportunity'] = (self.df.loc[(self.df['AM_Module__c'].isnull()) 
                                                    & (self.df['CAGE_Number__c'].isnull())]
                                                        .groupby('family_id')['CreatedDate']
                                                        .transform('max'))

        self.df['Final_Owners_Name'] = self.df['Opportunity_Owner_Name'].fillna(self.df['Owner_name'])

        self.df['Final_Owner_Role_Name'] = self.df['Opportunity_Owner_Role'].fillna(self.df['Title_Role__c'])

        self.df['SP_IND'] = self.df['Opportunity_Owner_Role'].apply(lambda x: 'Y' if x =='SP' else np.nan)


    def module_accounts(self): 
        """
           module_accounts() contains mostly accounts
           with a AM_MODULE__C or CAGE field entered

        """
        
        assert self.new_columns_called,("Error: new_columns() needs to be called first")

        self.df_account_module = (self.df[self.df['Family_Most_Recent_Opportunity'].isnull()
                                                                .groupby(self.df['family_id'])
                                                                .transform('any')])

        self.df_no_dups_account_module = (self.df_account_module.sort_values(['AM_Module__c'
                                                                         ,'OPPORTUNITY_EXCL_IND'
                                                                         ,'SP_IND'
                                                                         ,'Family_Most_Recent_Opportunity'])
                                                                        .drop_duplicates(subset='family_id', keep='first'))

        return self.df_no_dups_account_module

    
    def other_accounts(self): 
        """
           other_accounts() contains all the other accounts
           usually smaller in size
        """
        self.module_accounts()
                
        df_other_account = self.df[~self.df.isin(self.df_account_module)]
        
        df_no_dupes_other_account = (df_other_account.sort_values(['OPPORTUNITY_EXCL_IND'
                                                                 ,'SP_IND'
                                                                 ,'Family_Most_Recent_Opportunity'])
                                                                .drop_duplicates(subset='family_id', keep='first'))
        
        return df_no_dupes_other_account
