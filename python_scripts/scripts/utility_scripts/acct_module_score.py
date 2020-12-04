import sys
import pandas as pd
import numpy as np
from functools import wraps

 
def weighted_score(func):
    """
    decorator that calculates the weighted score
    weighted_score = score * weight
    
    Parameters
    ----------
    func : function
       func from the apply_score method
    """

    @wraps(func)
    def wrapper(self, *args, **kwargs):
        results = func(self, *args, **kwargs)
        self.weight_score = results[0] * results[2]
        return self.weight_score
    return wrapper

  
def total_score(*columns):
    """
    decorator that calculates the total_score
    total_score = [w_score1 + w_score2 ...].sum()
    
    Parameters
    ----------
    func : function
       func from the apply_score method
    """
    print (columns)
    if not columns:
        raise ValueError ("Must give columns to sum by")

    def inner_function(func):
        @wraps(func)
        def wrapper(*args, **kwargs):
            df = func(*args, **kwargs)
            df['FINAL_SCORE'] = (df[[*columns]].sum(axis=1))
            return df
        return wrapper
    return inner_function
  
  
        
class PointScore():
    """PointScore reads in the score_feature.csv and the
       Account Module dataframe to create a point score
       for a single column:
       
       i.e:
       
       FAMILY_SPEND_EST_FOR_EVAL = $500. It is between 
       $0-$800 so it is assigned a score of 1
        
       --------
      
       CSG_TENURE_MNTHS = 72. It is between
       50-89 months so it is assigned a score of 3


    Attributes:
        csv_file: filepath of score_feature.csv
        df: the account_module diagram.
    """

    def __init__(self, csv_file, dataset): 
        #filter rows with NULL in score column
        df = pd.read_csv(csv_file)
        df = df[df.score.notnull()]
        
        self.df = df
        self.dataset = dataset

    @property
    def get_features(self):
        return self.df.feature.unique().tolist()
    
    @property
    def get_columns(self):
        return self.dataset.columns.tolist()

    
    @weighted_score
    def apply_score(self, column):
        self.column = column
        
        feature_subset = self.df[self.df['feature'] == self.column]

        self.score = np.dot((self.dataset[column].values[:, None] >= feature_subset['start'].values) &
                            (self.dataset[column].values[:, None] <= feature_subset['stop'].values),
                             feature_subset['score'])                    
        
        return [self.score
                , self.column
                , feature_subset['weight'].unique()]



class ColorScore(PointScore):
    """ColorScore reads in the score_feature.csv and the
       Account Module dataframe to create a color score.
       Subclass of PointScore
       
       i.e:

       FINAL_SCORE = 3.2. It is between
       3-3.5 range so it is assigned a color of Silver
        
        
    Attributes:
        csv_file: filepath of score_feature.csv
        df: the account_module diagram.
    """
    def __init__(self, csv_file, dataset): 
        super().__init__(csv_file, dataset)
        
        #overwriting parent__init__: filterrows with NULL in score column
        df = pd.read_csv(csv_file)
        df = df[df.color.notnull()]
        self.df = df
            
    def apply_score(self, column):
        raise AttributeError( "'ColorScore' has no attribute 'apply_score'" )
        
    def apply_color(self, column):
        self.column = column
        
        feature_subset = self.df[self.df['feature'] == self.column]
        self.color = np.dot((self.dataset[column].values[:, None] >= feature_subset['start'].values) &
                            (self.dataset[column].values[:, None] <= feature_subset['stop'].values),
                             feature_subset['color']) 
                                
        return self.color
    

    
    


    
