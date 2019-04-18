# -*- coding: utf-8 -*-
"""
Created on Fri Feb  1 02:33:53 2019

@author: Administrator
"""


from art import *
ef(r'D:\Ashwin\do\ofir_ml_funcs.py')
ef(r'D:\Ashwin\do\init_new.py')
ef(r'D:\Ashwin\do\init_sm.py')
ef(r'D:\Ashwin\do\ml_funcs.py')
###ef(r'D:\shekhar_code_github\BogusFirmCatching\Graphs\graphsetup.py') # analyze_model, compare_models
# ef(r'D:\shekhar_code_github\BogusFirmCatching\shekhar_bogus_ml.py')

import os
import h2o
from h2o.estimators.glm import H2OGeneralizedLinearEstimator
from h2o.estimators.random_forest import H2ORandomForestEstimator
from h2o.estimators.gbm import H2OGradientBoostingEstimator
from h2o.estimators.naive_bayes import H2ONaiveBayesEstimator
# from h2o.estimators.xgboost import H2OXGBoostEstimator # isn't available for some reason. Maybe h2o version outdated.
import statsmodels.api as sm
import scipy.stats.mstats



def init():
    global sr,fr,share_cols
    # <hack> regarding output to make h2o work in IDLE
    class PseudoTTY(object):
        def __init__(self, underlying):
            underlying.encoding = 'cp437'
            self.__underlying = underlying
        def __getattr__(self, name):
            return getattr(self.__underlying, name)
        def isatty(self):
            return True

    import sys
    sys.stdout = PseudoTTY(sys.stdout)
    # </hack>

    h2o.init(nthreads = -1,max_mem_size="58G")
    h2o.remove_all()

    init()
    femq12 = pd.read_csv(r"H:\Ashwin\dta\features\All_return_features_sample.csv");# femq12['fold'] = (femq12['TIN_hash_byte']/32).astype(int)
 


    fr=h2o.H2OFrame(python_obj=femq12)
    print 'setting factors...'
    fr=set_return_factors(fr)
    fr=set_profile_factors(fr)
    fr=set_match_factors(fr)
    fr=set_transaction_factors(fr)
    fr=set_purchasenetwork_factors(fr)
    fr=set_salenetwork_factors(fr)
    fr=set_downstream_factors(fr)
    return fr

    fr['Missing_SalesDSUnTaxProp']=fr['Missing_SalesDSUnTaxProp'].asfactor()
    fr['Missing_SalesDSCreditRatio']=fr['Missing_SalesDSCreditRatio'].asfactor()
    fr['Missing_SalesDSVatRatio']=fr['Missing_SalesDSVatRatio'].asfactor()
    fr['Missing_MaxSalesProp']=fr['Missing_MaxSalesProp'].asfactor()
    fr['Missing_MaxPurchaseProp']=fr['Missing_MaxPurchaseProp'].asfactor()
    fr['Missing_PurchaseDSUnTaxProp']=fr['Missing_PurchaseDSUnTaxProp'].asfactor()
    fr['Missing_PurchaseDSCreditRatio']=fr['Missing_PurchaseDSCreditRatio'].asfactor()
    fr['Missing_PurchaseDSVatRatio']=fr['Missing_PurchaseDSVatRatio'].asfactor()
    #fr['saleds_merge']=fr['saleds_merge'].asfactor()
    #fr['purchaseds_merge']=fr['purchaseds_merge'].asfactor()
    
