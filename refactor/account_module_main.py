
from params import opportunity_csv, account_csv, summary_csv, \
	keeping_vars_opp, dropping_vars_acc,  dropping_vars_sco, \
	subset_vars_opp, subset_vars_acc, output_filepath

from opportunity import Opportunity
from account import Account
from score import Score


if __name__ == "__main__":

    opp = Opportunity(opportunity_csv)
    opp.add_columns()
    opp.filter()
    opp.keep_vars(keeping_vars_opp)
    opp.output_to_file(output_filepath)

    acc = Account(account_csv)
    acc.merge_data(opp.df[subset_vars_opp])
	acc.add_columns()
	acc.filter() 
	acc.drop_vars(dropping_vars_acc)
	acc.output_to_file(output_filepath)

	sco = Score(summary_csv)
	sco.merge_data(acc.df[subset_vars_acc])
	sco.add_columns()
	sco.filter()
	sco.keep_vars(keeping_vars_sco)
	sco.output_to_file(output_filepath)


