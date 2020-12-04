import pandas as pd
from functools import reduce
from collections import OrderedDict


class PandasMerge():
    def __init__(self, **kwargs):
        self.__dict__.update(kwargs)

    
    def load_file(self):
        self.dfs = {}

        for attr, value in self.__dict__.items():
            if isinstance(value, str):
                if value.endswith('.csv'):
                    self.dfs[attr] = pd.read_csv(value)

                elif value.endswith('.pkl'):
                    self.dfs[attr] = pd.read_pickle(value)

                else:
                    raise ValueError('''file must be a .pkl
                                            or  .csv file''')

    # @property
    # def ___set_merge_df(self):
    #     return self.df_to_merge


    # @___set_merge_df.setter
    # def set_merge_df(self, df_merge):
    #     self.df_merge = df_merge

    #     for dataframe in self.df_merge:
    #         if dataframe not in self.dfs:
    #             raise ValueError('DataFrame {0} to merge not found'
    #                                              .format(dataframe))
    #         else:
    #             self.df_to_merge = {k : v for (k, v) in self.dfs.items() 
    #                                         if k in self.df_merge}


    def to_be_merged(self, *merge_df):
        self.merge_df = merge_df
        
        for dataframe in self.merge_df:
            if dataframe not in self.dfs:
                raise ValueError('DataFrame {0} to merge not found'
                                                .format(dataframe))
        else:
            self.dict_to_merge = OrderedDict((k, v) for (k, v) in self.dfs.items() 
                                        if k in self.merge_df)
            
                                        
    def df_merge(self, on=None, how='inner'):
            if len(self.dict_to_merge.keys()) < 2:
                    raise ValueError("At least 2 DataFrames are required to merge")
            df_final = reduce(lambda left,right: (pd.merge(left
                                                         ,right
                                                         ,on=on
                                                         ,how=how)
                                                         , self.dict_to_merge.keys()))
            return df_final









A = PandasMerge(csv1='C:\\Users\\DYAO358\\documents_local\\sf_dyao\\sf_stuff\\sfdc_accounts_opportunities_07_16_2020_dyao.csv',
                pkl1 ='C:\\Users\\DYAO358\\documents_local\\sf_dyao\\acct_module_output\\df_opportunities_filtered_test.pkl')
#print (A.csv1)
A.load_file()

A.to_be_merged('csv1', 'pkl1')
A.dict_to_merge['pkl1'] = A.dict_to_merge['csv1'].rename()
A.dict_to_merge['csv1']

#print(A.__dfs_to_merge)
#A.set_dfs_to_merge = ['csv1', 'pkl1']
#print (A.dfs.keys())
#A.df_to_merge['csv1'] = A.df_to_merge['csv1'][['Site__c']]
#print(A.df_to_merge['csv1'].columns)
#A.merge_dfs()
