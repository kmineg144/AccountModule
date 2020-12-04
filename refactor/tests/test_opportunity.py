import os
import unittest
import pandas as pd 
from pandas.testing import assert_frame_equal

import sys
sys.path.append('..')

from params import stage_name_dict, locks, keeping_vars_opp
from utilities import get_date, convert_str_to_date, find_idxmax_by_group
from opportunity import Opportunity 

# note: test validation objects "opportunity_sample.pkl" executed on 11/24/2020 

class TestOpportunity(unittest.TestCase):
        
    @classmethod
    def setUpClass(cls):
        cls.processing_date = '2020-11-24 15:00:00'
        cls.path_fixtures =  os.path.join('tests','fixtures')
        cls.opportunity_csv = os.path.join(cls.path_fixtures, 'sample_data','accounts_to_biller_sample.csv')
        replicate_file = os.path.join(cls.path_fixtures,'results_to_replicate','opportunity_sample.pkl')
        cls.opportunity_sample = pd.read_pickle(replicate_file)

    def test_opportunity(self):
        opp = Opportunity(self.opportunity_csv)
        opp.add_columns(today = self.processing_date)
        opp.filter()
        opp.keep_vars(keeping_vars_opp)
        assert_frame_equal(opp.df, self.opportunity_sample)


if __name__=='__main__':
    unittest.main()

