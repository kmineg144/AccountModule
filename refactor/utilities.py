import pandas as pd 

# date and time 
def get_date(date=None, format='%Y/%m/%d'):
    if date is None: date = 'today'
    return pd.to_datetime(pd.to_datetime(date), format='%Y/%m/%d')


# variable conversions
def convert_index_to_str(df):
    df.index = df.index.astype(str)
    return None

def convert_str_to_date(df, var, format='%Y/%m/%d', errors='coerce'):
    df[var] =  pd.to_datetime(df[var], format=format, errors=errors)
    return None


def find_idxmax_by_group(df, var, group_var):
    return df.groupby(group_var)[var].idxmax().to_list()


def varlist_sum(x, varlist):
    return sum([item for item in x[varlist]])

def weighted_varlist_sum(x, varlist, weights):
    return sum([item * wgt for item, wgt in zip(x[varlist], weights)])

    