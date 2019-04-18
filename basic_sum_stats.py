# -*- coding: utf-8 -*-
"""
Created on Tue Mar 12 06:58:01 2019

@author: Administrator
"""


features = ['VatRatio','LocalVatRatio','TurnoverGross','TotalReturnCount','RefundClaimed', 'ZeroTaxCredit'] 
added_features=['MoneyDeposited','MoneyGroup', 'AllCentral', 'AllLocal', 'ZeroTax', 'ZeroTurnover']
model_improvement_check(rf_v1,train,valid,features,added_features,more_features=None)


ashwin1 = firm_period_predictions_alltime.groupby('Mtin')['TaxQuarter'].agg(['min','max']).groupby(['min','max']).size()
ashwin1.to_csv("H:/Ashwin/tax_period_all_firms.csv")

firm_period_predictions_alltime_old = pd.read_csv(r"D:\Ofir\output_data\firm_period_predictions20171225.csv")
bogus_predictions = firm_period_predictions_alltime_old[(firm_period_predictions_alltime_old.bogus_online == 1)]
ashwin1 =bogus_predictions.groupby('DealerTIN')['TaxQuarter'].agg(['min','max']).groupby(['min','max']).size(bogus_predictions = firm_period_predictions_alltime[(firm_period_predictions_alltime.bogus_flag == 1)]
ashwin1 =bogus_predictions.groupby('Mtin')['TaxQuarter'].agg(['min','max']).groupby(['min','max']).size()
ashwin1.to_csv("H:/Ashwin/tax_period_bogus_firms.csv")
)
ashwin1.to_csv("H:/Ashwin/tax_period_bogus_firms_old.csv")

ashwin1 = firm_period_predictions_alltime_old.groupby('DealerTIN')['TaxQuarter'].agg(['min','max']).groupby(['min','max']).size()
ashwin1.to_csv("H:/Ashwin/tax_period_all_firms.csv")