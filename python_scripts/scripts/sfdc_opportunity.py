import pandas as pd
from utility_scripts.pandas_utilities import opportunity_excl_ind


def winning_opportunity(csv_file):
    """
    Finds the winning owner for every SFDC
    account in the csv_file.

    Basic concept is the agent who has the most
    recent closed-won opportunity is the winner

    The logic contained in opportunity_excl_ind
    function provides exclusions to that rule

    i.e:
       SBAE can hold onto closed-won accounts
       for 6 months

       National accounts are off limits


    Parameters
    ----------
    csv : str
        filepath of the opportunity csv file
        
        
    Returns
    -------
    df : DataFrame 
        a df that labels the exclusions on opportunity
         level and the winner of the account
    """

    df = pd.read_csv(csv_file)

    df['CreatedDate'] =  pd.to_datetime(df['CreatedDate'], format='%Y/%m/%d')
    df['CloseDate'] =  pd.to_datetime(df['CloseDate'], format='%Y/%m/%d'
                                                     , errors='coerce')  
    
    df['Latest_Created_Date'] = (df.where((df['StageName'].isin(['Closed Won', 'Closed - Won'])) 
                                       & (df['OrderStatus__c'] != 'Cancelled')).groupby('AccountId')
                                        .CreatedDate
                                        .transform('max')
                                )

    df['latest_Closed_Date'] =  (df.where((df['StageName'].isin(['Closed Won', 'Closed - Won'])) 
                                       & (df['OrderStatus__c'] != 'Cancelled')).groupby('AccountId')
                                        .CloseDate
                                        .transform('max')
                                )

    df['OPPORTUNITY_EXCL_IND'] = df.apply(opportunity_excl_ind, axis=1)

    df_max_date_index = (df.loc[df.where((df['StageName'] == 'Closed Won') 
                                      & (df['OrderStatus__c'] != 'Cancelled'))
                                     .groupby("AccountId")["CreatedDate"]
                                     .idxmax()].index
                        )

    df['New_Closed_Won_Owner'] = df.iloc[df_max_date_index, 7]
    
    return df



def filter_df(df):
    """
    Keeps rows with the winner of the account and filters
    everything else


    Parameters
    ----------
    df : DataFrame
        Takes in the dataframe returned from 
        winning_opportunity()
        
        
    Returns
    -------
    df_filtered : DataFrame 
        a shortened df with only the winners and not the 
        LOSERS
   """

    locks = ['Locked - Closed Lost'
            ,'Locked - Open Opportunity'
            ,'Locked - SBAE', 'Locked - EAE'
            ,'Locked - NEAM'
            ,'Locked - SEAE or National'
            ]

    df_filtered = df[~df['New_Closed_Won_Owner'].isnull() | df['OPPORTUNITY_EXCL_IND'].isin(locks)]

    #Tie breaker, in case a group (accountid) has both a Locked-Closed and a non-null row selector,
    #the Locked EXCL will take precedence
    df_filtered = (df_filtered.sort_values('OPPORTUNITY_EXCL_IND')
                              .drop_duplicates(subset=['AccountId'], keep='first'))
    
    #now that non winning rows are filtered out, New_Closed_Won_Owner column
    df_filtered = df_filtered.drop(['New_Closed_Won_Owner'], 1)

    return df_filtered


def opportunity_main(csv_file, output):
    df = winning_opportunity(csv_file)
    df_filtered = filter_df(df)
    df_filtered[[
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
                ]].to_pickle(output)
