import os
import configparser
import pandas as pd
import numpy as np
from pandas import ExcelWriter
from functools import wraps
from pathlib import Path
from utility_scripts.pandas_utilities import one_product_only
from utility_scripts.acct_module_score import PointScore, ColorScore, weighted_score, total_score
 
def merge_summary_accounts(accounts, summary):  
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
 
    def load_accounts():
        """
        returns a df from a pickled file
        """
        
        df = pd.read_pickle(accounts)
        df = df.reset_index()
        
        if 'index' in df.columns:
            del df['index']
           
        return df
        
    def load_summary():
        """
        returns a df from csv file file
        """
        
        df = pd.read_csv(summary)
        return df 
        
     
    df_accounts_col =[
                    'FAMILY_ID'
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
     
    df_summary_col = load_summary().columns.tolist()[:-5]
     
    #only merge certain columns from the accounts df
    df = pd.merge(load_summary()[df_summary_col]
                            , load_accounts()[df_accounts_col]
                            , how = 'left'
                            , left_on = ['FAMILY_ID']
                            , right_on =['FAMILY_ID'] )
    
    # filter out the familys with less than 500 te
    df = df[df.FAMILY_SPEND_EST_FOR_EVAL > 500]
   
    return df
    
   

def df_add_ind(df):
    """
    Creating additional indicator columns in the df
    
    Parameters
    ----------
    df : DataFrame
       The dataframe we want to add columns to 

    Returns
    -------
    df: DataFrame
        modifies the exisiting df with new IND 
        columns
    """

    url = 'https://comcast.my.salesforce.com/'

    #flag if row has any opportunity exlusion
    df['SFDC_OPPORTUNITY_IND'] = ((df['OPPORTUNITY_EXCL_IND']
                                    .str.contains('Locked -')) | (df['OPPORTUNITY_EXCL_IND']
                                    .isnull()).astype(int))

    #flag if row has any SP owner
    df['SFDC_SP_IND'] = ((df['SP_IND']
                            .str.contains('Y')) | (df['SP_IND']
                            .isnull())).astype(int)
                            
    #flag if row has a CAGE or AM Module owner
    df['SFDC_MODULE_IND'] = ((~df['AM_MODULE__C'].isnull()) | (~df['CAGE_NUMBER__C'].isnull())
                                    .astype(int))
    
    
    #flag if row has a single product
    df['ONE_PRODUCT_IND'] = df.apply(one_product_only, axis=1)
    
    df['SFDC_ACCOUNT_URL'] = (np.where(~df['ACCOUNT__C'].isnull(), url 
                                            + df['ACCOUNT__C'].astype(str)
                                            , df['ACCOUNT__C']))
                                            
    #flag if any of these columns is > 0 
    df['ANY_EXCL_IND'] = (df[['SV_EXCL_IND_CNT',
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
                             'SFDC_MODULE_IND']].sum(axis=1))
                             
    return df
 
 
def account_module_score(filepath, df, *columns):
    """
    Nested function that generates the score columns
    
    Nested Functions
    ----------------
    point_score
        Loops over the PointScore class to create score
        all columns with a numerical score (skips color
        scores). Is then passed into decorator: 
        total_score to sum all weighted scores
        
    color_score
        takes the point_score returned value to create
        a color score by using the ColorScore class
      
    
    Decorated Functions
    -------------------
    total_score
        sums the scores from the indicated *column 
        arguments
        
        i.e.
 
    Parameters
    ----------
    filepath : str
        filepath of the score_feature.csv file
    
    df : DataFrame
        the account module dataframe

    Returns
    -------
        df: DataFrame
            returns a modified df with point score and 
            color score columns
    """
 
    @total_score(*columns)
    def point_score():

        for feature in PointScore(filepath, df).get_features:
            new_col = (feature + '_score').upper()
            df[new_col] = PointScore(filepath, df).apply_score(feature)
            
        return df
        
        
    def color_score(func):
        colors = ColorScore(filepath, func)
        new_col = 'COLOR_SCORE'
        df[new_col] = colors.apply_color('FINAL_SCORE')
        
        return df
    
    df = color_score(point_score())
    return df
    
    
  
def df_excel_tabs(df):
    """
    Filters to only subset of columns for the 
    customer view. Split df into 3:
    
    df_no_excl : accounts that have no exclusions
    df_excl: accounts that have >= 1 exclusions
    df_no_sfdc: accounts with no sfdc link
    
    the data in the 3 df will be transformed into
    separate tabs in Excel
    
    Parameters
    ----------
    df : DataFrame
       The dataframe we want to add columns to 
        
    Returns
    -------
    unnamed dict : dict
        key: Name of excel tab
        value: the dataframe with corresponding
               data   
    """

    columns = [
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
    df_no_excl = df[(df['ANY_EXCL_IND'] == 0) & (~df['ACCOUNT__C'].isnull()) ][columns]
    
    df_excl = df[(df['ANY_EXCL_IND'] >= 1)  & (~df['ACCOUNT__C'].isnull())][columns]
    
    df_no_sfdc = df[(df['ACCOUNT__C'].isnull())][columns]
    
    return {'assigned' : df_no_excl
           ,'excluded' : df_excl
           ,'no_sfdc' : df_no_sfdc}

   
def region_names(df):
    """
    Getting the unique family_regions there are in the excel
    spreadsheet. Each family region will eventually be
    its own spreadsheet
    
    Parameters
    ----------
    df : DataFrame
       The dataframe we want to add columns to 
          
    Returns
    -------
    region_dict : dict
        key: name of region 
        value: name of region as it appears in the df
    
    """
    
    region_dict = {}
    family_region = (df.FAMILY_ID_REGION.dropna()
                                        .unique()
                                        .tolist())
    
    for names in family_region:
        key = names.replace(" ", "_").lower()
        region_dict[key] = names
        
    return region_dict
    
    
    
def to_excel(tabs, region, filepath):
    """
    Nested function which encapsulates the details
    of the inner function. Calling to_excel() will
    create the spreadsheets in one step.
    
    Parameters
    ----------
    tabs : dict
       Takes the output from df_excel_tabs() 
       
    
    region : dict
        Takes the output from region_names()
        
    filepath : str
        the output filepath of the excel files      
       
    Nested Functions
    ----------------
    to_excel
        creates the excel spreadsheet
     
    tab_categories
        returns structured dict that will be 
        decorated by to_excel
    """
    
    def to_excel(filepath):
        """
        Decorated function that creates Excel files for
        each region

        Parameters
        ----------
        filepath : str
            the directory where the excel files will be 
            stored
                
        func: function
            takes the output of the child function
            (which is tab_categories)
            
        Returns
        -------
        None : None object
            Writes files to specified directory

        """
        def inner_function(func):
            @wraps(func)
            def wrapper(*args, **kwargs):
                dict_tabs = func(*args, **kwargs)
                
                for df_name, df in dict_tabs.items():
                    writer = ExcelWriter(os.path.join(filepath
                                                + df_name 
                                                + '.xlsx')
                                                , engine='xlsxwriter')
                    for sheet_name, sheets in df.items():
                        sheets.to_excel(writer
                                    ,sheet_name = sheet_name
                                    ,index =False)
                    writer.save()
            return wrapper
        return inner_function
    

    @to_excel(filepath)
    def tab_categories():
        """
        Creates a dictionary of dataframes to easily 
        iterate through and create multiple spreadsheets 
        with multiple tabs. 


        Parameters
        ----------
        tabs : dict
            key: the name of the excel tab
            value: the dataframe 
        region : dictionary
            key: name of the excel file
            value: name of region for column FAMILY_ID_REGION 
            to filter the df on
            
        Returns 
        -------
        outer_dict : dict
            
            i.e:
            
                {'portland' :
                    {'assigned' : portland_assigned, 
                     'excluded: : portland_excluded,
                     'no_sfdc: : portland_no_sfdc
                     },
        
                 'houston' :
                    { 'assigned' : houston_assigned,
                       ...
                    }
                }         
        """

        inner_dict = {}
        outer_dict = {}

        for df_name, region_name in region.items():
            for name, category in tabs.items():
                df_region =  category.loc[category.FAMILY_ID_REGION == region_name]
                inner_dict[df_name + '_' + name] = df_region
            outer_dict[df_name] = inner_dict

            #empty the inner dict so we can load the next region in the loop
            inner_dict = {}        
        return outer_dict
    
    tab_categories()           


def summary_main(pkl_path, csv_path, score_path, excel_path):
    df = merge_summary_accounts(pkl_path, csv_path)
    df = df_add_ind(df)
    df = account_module_score(score_path
                            , df
                            ,'FAMILY_SPEND_EST_FOR_EVAL_SCORE'
                            ,'CSG_TENURE_MNTHS_SCORE'
                            ,'CSG_AND_SV_TOTAL_MRC_SCORE'
                            ,'ONE_PRODUCT_IND_SCORE'
                            ,'TOTAL_LOC_CNT_SCORE')
    region_dictionary, df_dict = region_names(df), df_excel_tabs(df)
    to_excel(df_dict, region_dictionary, excel_path)    


    

    
    
    
    
