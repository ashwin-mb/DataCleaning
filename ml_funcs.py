# -*- coding: utf-8 -*-
"""
Created on Tue Jan 22 10:33:45 2019

@author: Administrator
"""

import pandas as pd
import numpy as np
from numpy import *
import h2o


##### C1: Which are the I/O files?
def set_predictions(model,data):
    X=model.predict(data)
    X=X.as_data_frame(use_pandas=True)
    X=X.drop(['p0','predict'],axis=1)
    return X

def set_prediction_name(data,original,new):
    data.rename(index=str,columns={original:new},inplace=True)
    return data


def generate_predictions(models,ValidationData,FilePath,ColumnTitle):
    PredictionDataModels = []
    for i in xrange(len(models)):
        PredictionDataModels.append(set_predictions(models[i],ValidationData))
        PredictionDataModels[i]=set_prediction_name(PredictionDataModels[i],'p1',\
                            ColumnTitle+'{}'.format(i+1))
    
    Y = pd.concat(PredictionDataModels,axis=1,ignore_index=False)
    Z=ValidationData.as_data_frame(use_pandas=True)
    Z=Z[['Mtin','TaxQuarter','bogus_flag','profile_merge',\
         'transaction_merge','salesmatch_merge','purchasematch_merge','purchasenetwork_merge',\
         'salesnetwork_merge']]
    Z.index=Z.index.map(unicode)
    
    PredictionData=pd.concat([Z,Y],axis=1,ignore_index=False)
    PredictionData.to_csv(path_or_buf=FilePath)# -*- coding: utf-8 -*-

def divide_train_test(fr):
    """ train and test sets - outdated. In future - divide by Mtin """
    b = fr['TIN_hash_byte']
    train = fr[ b < 200 ]
    valid = fr[ (200 <= b) & (b < 232) ]
    test  = fr[ 232 <= b ]
    return train, valid, test


def load_everything():
    #Merging all data into one file
    # load returns data
    ReturnsAll=load_returns()
    ReturnsAll['Mtin']=pd.to_numeric(ReturnsAll['Mtin'])
    ReturnsAll['TaxQuarter']=pd.to_numeric(ReturnsAll['TaxQuarter'])
    
    ReturnsAll=ReturnsAll.drop([u'TotalOutputTax', u'NetTax',u'ExemptedSales',\
                                u'TotalTaxCredit', u'BalanceBroughtForward',u'TDSCertificates',\
                                u'LocalTaxRatio'], axis=1)
    
    # load profiles data
    Profiles=load_profile()
    Profiles['Mtin']=pd.to_numeric(Profiles['Mtin'],errors='coerce')
 
    #Merge returns data with profile data
    ReturnsAllWithProfiles=pd.merge(ReturnsAll, Profiles, how='left', on=['Mtin'],\
                                    indicator='profile_merge')
    
    #save returns only from year 3 onwards (inclusive)
    ReturnsPostY2WithProfiles=ReturnsAllWithProfiles[ReturnsAllWithProfiles['TaxQuarter']>8]
    
    SalesMatch=load_matchsales()
    SalesMatch=SalesMatch.drop(['diff','absdiff','maxSalesTax','OtherDeclarationCount',\
                                'MyDeclarationCount','MatchDeclarationCount','OtherDeclarationTax',\
                                'MyDeclarationTax','MatchDeclarationTax'],axis=1)
    SalesMatch['Mtin']=pd.to_numeric(SalesMatch['Mtin'],errors='coerce')
    SalesMatch['TaxQuarter']=pd.to_numeric(SalesMatch['TaxQuarter'],errors='coerce')
    
    ReturnsPostY2WithProfilesWithMatch=pd.merge(ReturnsPostY2WithProfiles,SalesMatch,\
                                                how='left', on=['Mtin','TaxQuarter'],\
                                                indicator='salesmatch_merge')
    
    PurchaseMatch=load_matchpurchases()
    PurchaseMatch=PurchaseMatch.drop(['OtherDeclarationCount','MyDeclarationCount',\
                                      'MatchDeclarationCount', 'OtherDeclarationTax',\
                                      'MyDeclarationTax', 'MatchDeclarationTax', 'diff',\
                                      'absdiff', 'maxPurchaseTax'],axis=1)
    PurchaseMatch['Mtin']=pd.to_numeric(PurchaseMatch['Mtin'],errors='coerce')
    PurchaseMatch['TaxQuarter']=pd.to_numeric(PurchaseMatch['TaxQuarter'],errors='coerce')
    
    ReturnsPostY2WithProfilesWithMatch=pd.merge(ReturnsPostY2WithProfilesWithMatch,\
                                                PurchaseMatch, how='left', on=['Mtin','TaxQuarter'],\
                                                indicator='purchasematch_merge')
    
    #Importing Network features (sales side)
    #Importing Network features (purchase side)
    SaleNetworkQuarter=load_salenetwork()
    SaleNetworkQuarter['Mtin']=pd.to_numeric(SaleNetworkQuarter['Mtin'],\
                      errors='coerce')
    SaleNetworkQuarter['TaxQuarter']=pd.to_numeric(SaleNetworkQuarter['TaxQuarter'],\
                      errors='coerce')
    ReturnsPostY2WithProfilesWithMatchWithNetwork=pd.merge(ReturnsPostY2WithProfilesWithMatch,\
                                                           SaleNetworkQuarter,how='left',\
                                                           on=['Mtin','TaxQuarter'],\
                                                           indicator='salesnetwork_merge')
    
    PurchaseNetworkQuarter=load_purchasenetwork()
    PurchaseNetworkQuarter['Mtin']=pd.to_numeric(PurchaseNetworkQuarter['Mtin'],\
                          errors='coerce')
    PurchaseNetworkQuarter['TaxQuarter']=pd.to_numeric(PurchaseNetworkQuarter['TaxQuarter'],\
                          errors='coerce')
    ReturnsPostY2WithProfilesWithMatchWithNetwork=pd.merge(ReturnsPostY2WithProfilesWithMatchWithNetwork,PurchaseNetworkQuarter,\
                                                           how='left', on=['Mtin','TaxQuarter'],\
                                                           indicator='purchasenetwork_merge')
    
    ReturnsPostY2WithProfilesWithMatchWithNetwork_minusq12=ReturnsPostY2WithProfilesWithMatchWithNetwork[ReturnsPostY2WithProfilesWithMatchWithNetwork['TaxQuarter']!=12]
    
    PurchaseDS=load_purchasedownstream()
    PurchaseDS['Mtin']=pd.to_numeric(PurchaseDS['Mtin'],errors='coerce')
    PurchaseDS['TaxQuarter']=pd.to_numeric(PurchaseDS['TaxQuarter'],errors='coerce')
    
    FinalEverything_minusq12=pd.merge(ReturnsPostY2WithProfilesWithMatchWithNetwork_minusq12,\
                                      PurchaseDS,how='left', on=['Mtin','TaxQuarter'], indicator='purchaseds_merge')
    
    SaleDS=load_salesdownstream()
    SaleDS['Mtin']=pd.to_numeric(SaleDS['Mtin'],errors='coerce')
    SaleDS['TaxQuarter']=pd.to_numeric(SaleDS['TaxQuarter'],errors='coerce')
    
    FinalEverything_minusq12=pd.merge(FinalEverything_minusq12,SaleDS,how='left',\
                                     on=['Mtin','TaxQuarter'], indicator='salesds_merge')
    
    return FinalEverything_minusq12