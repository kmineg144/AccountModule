import pandas as pd

def opportunity_excl_ind(df):   
    """
    Logic for determining if an opportunity is locked or is open
    Will be used in conjunction with an apply() function
    
    Parameters
    ----------
    df : DataFrame
        will be a opportunity df 
    """
    
    today_date = pd.to_datetime(pd.to_datetime('today'), format='%Y/%m/%d')
    
    #if opportunity is opened and status isn't cancelled, they can hold onto it for 90 days
    if df['StageName'] in ['Solutions Proposal Accepted', 'Qualified', 'Sales Accepted']  and df['OrderStatus__c'] != 'Cancelled' and (today_date - df['CloseDate']).days < 183:
        return 'Locked - Open Opportunity'
    
    if df['OrderStatus__c'] in ('Install Complete Pending OC', 'Pending Installation', 'Pending Installation' , 'Pending Status' , 'Scheduled') and (today_date - df['CloseDate']).days < 365:
        return 'Locked - Open Opportunity'
    
    if df['StageName'] == 'Closed Lost' and (today_date - df['CloseDate']).days < 183:
        return 'Locked - Closed Lost Last 6 Months' 

    #if opportunity is closed, completed, owned by a SBAE, they have the account for 6 months
    elif df['StageName'] in ['Closed Won', 'Closed - Won'] and df['OrderStatus__c'] != 'Cancelled' and df['Owner_Title_Role__c'] in ('BAE3', 'BAE2')  and  (today_date - df['CloseDate']).days < 183:
        return 'Locked - SBAE'

    elif df['StageName'] in['Closed Won', 'Closed - Won']  and df['OrderStatus__c'] != 'Cancelled' and df['Owner_Title_Role__c'] == 'EAE'  and  (today_date - df['CloseDate']).days < 365:
        return 'Locked - EAE'
    
    elif df['Owner_Title_Role__c'] in ('NEAM', 'SNEAM'):
        return 'Locked - NEAM'

    elif df['Owner_Title_Role__c'] in ('SEAE', 'CAM OBSR') or  df['Owner_Name__c'] == 'National and OTM Data feed': 
        return 'Locked - SEAE or National'
    
    else:
        return 'Not Locked'
        
        

def one_product_only(row):
    """
    Logic for determining if row has a single comcast product
    Will be used in conjunction with an apply() function
    
    Parameters
    ----------
    df : DataFrame
         will be a summary df
    """
    
    #data only
    if ((row['SV_METROE_IND'] + row['CSG_DATA_IND'] + row['CSG_WIFIPRO_IND'] + row['CSG_CONNPRO_IND'] + row['CSG_TW_IND']> 0 ) 
        and (row['CSG_VOICE_IND'] + row['SV_AV_IND'] == 0)):      
            return 1
    
    #voice only
    if ((row['SV_METROE_IND'] + row['CSG_DATA_IND'] + row['CSG_WIFIPRO_IND'] + row['CSG_CONNPRO_IND'] + row['CSG_TW_IND'] == 0 ) 
        and (row['CSG_VOICE_IND'] + row['SV_AV_IND'] > 0)):      
            return 1               
    else:
            return 0
