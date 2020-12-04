import pandas as pd
import numpy as np
from utility_scripts.account_winner import EstablishWinner

def merge_accounts(opportunity, accounts, subset_opp_columns=None):  
    """
    Nested function where the inner function loads the df
    and the outer function merges the two df 
    
    Parameters
    ----------
    accounts : str
        filepath of the accounts pickled file
    summary : str
        filepath of the summary csv file
        
        
    Returns
    -------
    df : DataFrame 
        merged dataframe object
    """
 
    def load_opportunity():
        """
        returns a df from a pickled file
        """
        
        df = pd.read_pickle(opportunity)
        df = df.reset_index()
        
        if 'index' in df.columns:
            del df['index']
           
        return df
        
    def load_accounts():
        """
        returns a df from csv file file
        """
        
        df = pd.read_csv(accounts)
        return df 
    
    #if third argument is None, display all columns
    if subset_opp_columns is None:
        subset_opp_columns = (load_opportunity()
                                        .columns
                                        .to_list())
          
    #only merge certain columns from the accounts df
    df = pd.merge(load_accounts() 
                  ,load_opportunity()[subset_opp_columns]
                  ,how = 'left'
                  ,left_on = ['ACCOUNT__C']
                  ,right_on =['AccountId'])

    df = df.rename(columns={'Owner_Title_Role__c': 'Opportunity_Owner_Role'
                           ,'Owner_Name__c': 'Opportunity_Owner_Name'})
    
    return df


def account_main(opportunity, accounts, output):
    subset_opp_columns = ['AccountId'
                        , 'Opportunity_Number__c'
                        , 'CreatedDate'
                        , 'OPPORTUNITY_EXCL_IND'
                        , 'Owner_Title_Role__c'
                        , 'Owner_Name__c']
    df = merge_accounts(opportunity, accounts, subset_opp_columns=subset_opp_columns)

    winning_df = EstablishWinner(df)
    winning_df.new_columns()
    winning_df.module_accounts()

    df_union = pd.concat([winning_df.module_accounts(), winning_df.other_accounts()])
    df_union.columns = map(str.upper, df_union.columns)
    df_union = df_union.drop(['CSG2'
                            , 'SV_EXCL_IND'
                            , 'CSG_EXCL_IND'
                            , 'SFDC_ACCOUNT_TYPE'
                            , 'SFDC_OBJECT_TYPE' ],1)
                            
    df_union.to_pickle(output)

