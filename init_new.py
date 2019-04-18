# -*- coding: utf-8 -*-
"""
Created on Tue Jan 22 10:42:21 2019

@author: Administrator
"""

import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from numpy import *
import seaborn as sns
import md5
_epsilon_for_division = 0.1

def div(numerator,denominator):
    """
    divide (numerator-epsilon / denominator+epsilon) to give a share that survives zero division
    """
    return (numerator+_epsilon_for_division) / (denominator+_epsilon_for_division)

###### MB added - Start #########
def load_returns():
    returns = pd.read_stata(r"H:\Ashwin\dta\bogusdealers\FeatureReturns.dta")
    returns['TIN_hash_byte'] = returns['Mtin'].astype(str).apply(lambda x: ord(md5.new(x).digest()[0]))
    returns['fold'] = (returns['TIN_hash_byte']/32).astype(int)
    returns.groupby("fold").agg([len])
    returns.groupby("TaxQuarter").agg([len])
    returns.to_stata(r"Z:\features\FeatureReturns_TIN_hash_byte.dta")
 #   returns.to_stata(r"H:\Ashwin\dta\bogusdealers\FeatureReturns_TIN_hash_byte.dta")
    return returns
###### MB added - End ######### 

    
# Tags Mtins from the consolidated returns with the bogus infromation from the two source files 
def tag_returns(returns,by_column='Mtin'):
    bogus_cancellation = pd.read_excel(r"H:\Ashwin\ml\ml_data\Bogus_CancellationData_NotPresentInT20_verified.xls") #changed location
    bogus_cancellation['registered'] = bogus_cancellation['Registered?'].apply(lambda x: x.lower() if pd.notnull(x) else nan)
    bogus_cancellation['bogus'] = bogus_cancellation['registered']=='no'
    bogus_online = pd.read_csv(r"H:\Ashwin\ml\ml_data\BogusIdentifiedFromOnlineGovernment.csv") #changed location
    bogus_online['bogus'] = bogus_online['Bogus']=='YES'

    tins_cancellation_bogus = set(bogus_cancellation[bogus_cancellation['bogus']]['Id'].dropna().astype(int64))
    tins_online_bogus = set(bogus_online[bogus_online['bogus']]['Mtin'])

    returns['bogus_cancellation'] = returns[by_column].apply(lambda tin: tin in tins_cancellation_bogus)
    returns['bogus_online'] = returns[by_column].apply(lambda tin: tin in tins_online_bogus)
    returns['bogus_any'] = returns['bogus_online'] | returns['bogus_cancellation']
    return returns

"""
Adds features in the consolidated returns that may be of useful
Features that need to be added - All Local, All Central, ZeroTurnover, PositiveContribution, Import Export(?), 
High Sea Sales/Purchases(?), Exempted Sales/Exempted Purchases
"""

###### C3: Change line 7 to include 2015 2016 2017
def add_features(returns):
    returns['InterStateRatio'] = div(returns['TurnoverCentral'],returns['TurnoverGross'])
    returns['VatRatio'] = div(returns['AmountDepositedByDealer'],returns['TurnoverGross'])
    # returns[returns['VatRatio']<inf].groupby('bogus_online')[['VatRatio']].mean()
    returns['LocalVatRatio'] = returns['AmountDepositedByDealer'] / returns['TurnoverLocal']
    # returns[returns['LocalVatRatio']<inf].groupby('bogus_cancellation')[['LocalVatRatio']].mean()
    returns['Year'] = returns['OriginalTaxPeriod'].apply( lambda x: 2013 if '2013' in x else (2014 if '2014' in x else (2015 if '2015' in x else (2016 if '2016' in x else (2017 if '2017' in x else nan))))) ##changed MB
    returns['Quarter_str'] = returns['TaxPeriod'].apply(lambda x: x.split('-')[0])
    returns['Quarter'] = returns['Quarter_str'].apply({'Fourth Quarter':4, 'Third Quarter':3, 'Second Quarter':2, 'First Quarter':1}.get)
    # returns = pd.merge(returns,features2a2b,'left',['Mtin','Year','Quarter'])
    return returns


"""
Need to understand what is going on here
I have a feeling i dont need it. 

MB: Edited this code - not entirely sure if this is correct
"""
def save_sub_returns(returns):
    for c in ['Name','DealerName', 'DealerAddress', 'DealerTelephone', 'Signatory', 'T312203']:
        if c in returns.columns.tolist():
            del returns[c]
    returns = returns[ returns['Year'].notnull() & returns['TaxQuarter'].notnull() ]
    #sub_returns_selection = returns['bogus_flag'] | (returns['Mtin'].astype(str).apply(lambda tin: ord(md5.new(tin).digest()[-1])<16))
    #sub_returns = returns[sub_returns_selection & (returns['Year']>=2013)].reset_index()
    sub_returns = returns[(returns['Year']>=2013)].reset_index()
    #sub_returns['TIN_hash_byte'] = sub_returns['Mtin'].astype(str).apply(lambda x: ord(md5.new(x).digest()[0]))
    sub_returns.to_csv(r"H:\Ashwin\BogusDealer_analysis\sub_returns.csv",index=False)
    sub_returns[ [c for c in sub_returns.columns if sub_returns[c].dtype != dtype('O')] ].to_csv(r"H:\Ashwin\data\returns\sub_returns_no_strings.csv",index=False) ##changed MB


def create_sub_returns():
    returns = load_returns()
    returns = returns[ returns['Year'].notnull() & returns['TaxQuarter'].notnull() ] # leave only 2013, 2014, valid entries.
    returns = tag_returns(returns)
    returns = add_features(returns)
    save_sub_returns(returns)
    # <><> todo

####### C4: Edit lines 2-5 lines. I am not sure what T312002 column contains. 
def investigate_TIN_scrambling():
    returns['T_hex'] = returns['T312002'].fillna(0).apply(hex) # plain TIN
    returns['TIN_hex'] = returns['Mtin'].apply(hex) # scrambled TIN
    srt = returns.sort('T312002')[['T312002','Mtin','T_hex','TIN_hex']]
    plt.plot(srt['T312002'],srt['Mtin'],'.')
    plt.xlabel('real TIN')
    plt.ylabel('scrambled TIN')
    plt.show()
    # main sequence
    fil = srt[srt['Mtin']<523256]

    lst = array(fil['Mtin'])
    dff = lst[1:] - lst[:-1]
    sum(dff<0)
    # 2 - three strange points at the very end. Other than that perfect.


def feature_stats(returns):
    pd.pivot_table(returns[returns['LocalVatRatio']<inf], values='LocalVatRatio', index=['Year'], columns=['bogus_online'], aggfunc=len)
    pd.pivot_table(returns[returns['LocalVatRatio']<inf], values='LocalVatRatio', index=['Year'], columns=['bogus_online'], aggfunc=np.mean)

    sns.distplot(np.log(returns[ returns['bogus_cancellation'] & (returns['LocalVatRatio']<1)].LocalVatRatio+0.001).dropna(), color='r', norm_hist=True )
    sns.distplot(np.log(returns[~returns['bogus_cancellation'] & (returns['LocalVatRatio']<1)].LocalVatRatio+0.001).dropna(), color='g', norm_hist=True )

    sns.distplot(np.log(returns[ returns['bogus_cancellation']].TurnoverGross+0.001).dropna(), color='r', norm_hist=True )
    sns.distplot(np.log(returns[~returns['bogus_cancellation']].TurnoverGross+0.001).dropna(), color='g', norm_hist=True )