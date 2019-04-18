# -*- coding: utf-8 -*-
"""
Created on Wed Apr 10 04:54:19 2019

@author: Administrator
"""
from art import *

bogus_dealers = pd.read_csv(r'H:/Ashwin/dta/bogusdealers/bogus_cancellationquarter.csv')
bogus_min_max_taxq = bogus_dealers.groupby('Mtin')['TaxQuarter'].agg(['min','max'])

bogus_cancellation_q_status = bogus_dealers.drop('TaxQuarter', axis =1)
bogus_registartionstatus = bogus_cancellation_q_status.drop_duplicates()

bogus_stats = bogus_registartionstatus.merge(bogus_min_max_taxq, how='inner', on='Mtin')
bogus_stats['cancellation_time'] = 
bogus_stats.to_csv(r'H:/Ashwin/dta/bogusdealers/bogus_cancellation_info.csv', index=False)