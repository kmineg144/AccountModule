from sfdc_opportunity import opportunity_main 
from sfdc_account import account_main
from sfdc_summary import summary_main
import configparser
from pathlib import Path


if __name__ == "__main__":
    CONFIG_PATH = Path(__file__).parent / "..\\ini\\acct_module.ini" 

    config = configparser.ConfigParser()
    config.read(CONFIG_PATH)
    
    #paths for sfdc_opportunity.py
    opp_csv_path = config['opportunity']['csv_file']
    opp_pkl_path = config['opportunity']['pkl_file']

    #paths for sfdc_account.py
    acc_input_pkl = config['account']['input_pkl']
    acc_csv_file = config['account']['csv_file']
    acc_output_pkl = config['account']['output_pkl']

    #paths for sfdc_summary.py
    sum_csv_path = config['summary']['csv_file']
    sum_pkl_path = config['summary']['pkl_file']
    sum_score_path = config['summary']['score_file']
    sum_excel_path = config['summary']['excel_folder']

    opportunity_main(opp_csv_path, opp_pkl_path)
    account_main(acc_input_pkl, acc_csv_file, acc_output_pkl)
    summary_main(sum_pkl_path, sum_csv_path, sum_score_path, sum_excel_path)