# -*- coding: utf-8 -*-
"""
Created on Wed Jan 23 08:42:00 2019

@author: Administrator
"""

from art import *
ef(r'D:\Ashwin\do\ofir_ml_funcs.py')
ef(r'D:\Ashwin\do\init_new.py')
ef(r'D:\Ashwin\do\init_sm.py')
ef(r'D:\Ashwin\do\ml_funcs.py')
####ef(r'D:\shekhar_code_github\BogusFirmCatching_minus_glm_ward\Graphs\graphsetup.py') # analyze_model, compare_models
# ef(r'D:\shekhar_code_github\BogusFirmCatching_minus_glm_ward\shekhar_bogus_ml.py')

import os
import h2o
from h2o.estimators.glm import H2OGeneralizedLinearEstimator
from h2o.estimators.random_forest import H2ORandomForestEstimator
from h2o.estimators.gbm import H2OGradientBoostingEstimator
from h2o.estimators.naive_bayes import H2ONaiveBayesEstimator
# from h2o.estimators.xgboost import H2OXGBoostEstimator # isn't available for some reason. Maybe h2o version outdated.
import statsmodels.api as sm
import scipy.stats.mstats
#h2o.shutdown(prompt=False)
##run this in console - Defining below variables globally
model_score_col='model_score_bogus_flag'
label_var='bogus_flag'
#feature_set = FEATURE_SETS[6]

#date = 20190227, 20190227, 20190227

def do_all():
    init()
    # femq12,ffemq12 = load_feature_label_table()
    pdfemq12 = pd.read_csv(r"H:\Ashwin\dta\features\All_return_features_after_2013.csv")
    pdfemq12['fold'] = (pdfemq12['TIN_hash_byte']/32).astype(int) #run fold command filteration
    pdfemq12.to_csv(r"H:\Ashwin\dta\features\All_return_features_after_2013.csv", index = False)
    #pdfemq12_sample = pd.read_csv(r"H:\Ashwin\dta\features\All_return_features_minus_q12_sample.csv")
#   ffemq12 = h2o.H2OFrame(pdfemq12)
    femq12 = h2o.import_file(r"H:\Ashwin\dta\features\All_return_features_after_2013.csv")
#   femq12 = h2o.H2OFrame(pdfemq12)
    ffemq12 = load_h2odataframe_returns(femq12)#(use_pandas=True, header=False)
    different_feature_sets_save_predictions(ffemq12)
    different_feature_sets_betas_plot()
   
    different_classifiers_save_predictions(ffemq12)
    different_classifiers_performance_plots_files()
    
    point_in_time_simulations() #run this code line by line
    plot_success_on_top_predictions_continuous()
    # example
    firm_period_predictions,cv_model = cv_predictions_each_tax_period(ffemq12) 
    firm_period_predictions.to_csv(r"H:\Ashwin\BogusFirmCatching_minus_glm_2013\output_data\firm_period_predictions20190227.csv",index=False)
    explore_multiple_aggregations(firm_period_predictions,model_score_col)
    avg_predictions = firm_period_predictions.groupby('Mtin').mean()
    performance_on_top_recommendations(avg_predictions,model_score_col,label_var,1,plot=True)
    check_model_calibration(avg_predictions)
    
    ''' Calculating variable importance '''
    cv1_model = h2o.load_model(r"H:\Ashwin\BogusFirmCatching_minus_glm\models\diff_feature_sets\20190227\feature_set_4\rf_cv_all_folds_20190227")
#    cv1_model = h2o.load_model(r"H:\Ashwin\BogusFirmCatching_minus_glm_2013\models\cv_predictions\rf_cv_all_folds_20190313")
    variable_imp =cv1_model._model_json['output']['variable_importances'].as_data_frame()
    variable_imp.to_csv(r"H:\Ashwin\BogusFirmCatching_minus_glm\models\diff_feature_sets\20190227\feature_set_4\features_variable_importance20190227.csv", index=False)
    cv1_model.varimp_plot()
 
    ''' Loading old model and running new data with tax quarters > 20 on it '''
    path = r"H:\Ashwin\dta\features\All_return_features_minus_q20.csv"
    pdfemq20 = pd.read_csv(path)
    pdfemq20 = pdfemq20.drop(['Ward'], axis = 1 )
    ffemq20 = h2o.H2OFrame(pdfemq20)
    
    #training the new data set using old trained model (cv_model is old trained model and dropping Ward )
    train_newdata = cv_model.predict(ffemq20).as_data_frame() 
    train_newdata.to_csv(r"H:\Ashwin\BogusFirmCatching_minus_glm_2013\OldModel_NewData_minus_ward.csv", index=False)
    # merging the results with input new data
    newdata_oldmod = pdfemq20[['Mtin','TaxQuarter','bogus_flag']]
    newdata_oldmod['model_score_bogus_flag'] = train_newdata['p1']
    newdata_oldmod.to_csv(r"H:\Ashwin\BogusFirmCatching_minus_glm_2013\output_data\newdata_oldmod_firm_period_predictions20190227.csv",index=False)
    avg_predictions_newdata_oldmod = newdata_oldmod.groupby('Mtin')[['bogus_flag','model_score_bogus_flag']].mean()
    axes = plot_success_on_top_predictions_continuous(avg_predictions_newdata_oldmod,1000)
    axes.set_title('x-val all-time performance on top 1000'.title())
    perf = performance_on_top_recommendations(avg_predictions_newdata_oldmod,model_score_col,label_var,1,plot=False)
    
    ''' Create table 2 from the paper - Done in Stata (bogus_final_list) '''
#    step = 2
#    table_2_list = []
#    for t in xrange(13+1,28+1,step):
#        print t
#        print time.ctime()
#        print '-'*30
#        save_dir = r"H:\Ashwin\BogusFirmCatching_minus_glm_2013\models\cv_predictions\20190227\point_in_time_q{:02d}".format(t)
#        print 'save_dir'
#        table_2 = pd.read_csv(save_dir+r"\point_in_time_performance.csv")
#        table_2['t']-= 8
#        table_2_list.append(table_2)
#    table_2_consolidated = pd.concat(table_2_list)
#    table_2_consolidated.to_csv(r"H:\Ashwin\BogusFirmCatching_minus_glm_2013\models\cv_predictions\20190227\point_in_time_performance.csv", index = False)


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

    h2o.init(nthreads = -1,max_mem_size="150G")
    h2o.remove_all()

    # sr = read_sub_returns()
    # fr,share_cols = prepare_h2o_frame()

def read_sub_returns():
    # returns.to_csv(r"Z:\tmp.csv",index=False)
    # returns[['VatRatio','LocalVatRatio','TurnoverGross','bogus_any']].to_csv(r"Z:\returns_tagged_subset.csv",index=False)
    sr = pd.read_csv(r"H:\Ashwin\data\returns\sub_returns_no_strings.csv")
    sr = sr[ sr['Year']>=2013 ]
    return sr

def descriptives():
    len(sr[sr.bogus_flag].Mtin.unique())
    # 611
    len(sr[sr.bogus_cancellation].Mtin.unique())
    # 6968
    len(sr[sr.bogus_any].Mtin.unique())
    # 7271
    # out of 336167 total dealers


def prepare_h2o_frame():
    fr = h2o.import_file(path=r"H:\Ashwin\data\returns\sub_returns_no_strings.csv") # r"Z:\sub_returns.csv"
    fr = fr[fr['Year'] >=2013]
    fr['y'] = fr['bogus_flag'].asfactor() # bogus_any
    fr['y2']= fr['bogus_flag'].asfactor()

    share_cols = []
    for column in ['CentralTurnover', 'LocalTurnover', 'TurnoverAt1', 'TurnoverAt5', 'TurnoverAt125', 'TurnoverAt20', 'WCTurnoverAt5', 'WCTurnoverAt125','RefundClaimed','TaxCreditBeforeAdjustment','BalanceCarriedNextTaxPeriod','AdjustCSTLiability']:
        new_col = column+'_share'
        share_cols.append(new_col)
        fr[new_col] = div(fr[column],fr['GrossTurnover'])

    return fr,share_cols

def divide_train_test(fr):
    """ train and test sets - outdated. In future - divide by Mtin """
    b = fr['TIN_hash_byte']
    train = fr[ b < 200 ]
    valid = fr[ (200 <= b) & (b < 232) ]
    test  = fr[ 232 <= b ]
    return train, valid, test

def add_fold_column(fr,fold_col='fold',k_folds=8):
    """
    adds a fold column (0:k_folds) named @fold_col to h2o frame @fr based on TIN_hash_byte
    """
    b = fr['TIN_hash_byte']
    # TODO: can't this be done with division and then casting to int??
    fr[fold_col] = 0
    partitions = np.linspace(0,256,k_folds+1)
    for partition in map(float,partitions[1:-1]):
        fr[fold_col] = fr[fold_col] + (b >= partition)
    return fr

def divide_train_test_k_folds(fr,fold_index,k_folds=8):
    """
    divide frame @fr into @k_folds folds, designate @fold_index fold as test set
    0 <= @fold_index < @k_folds, the specific fold to be returned as test set
    """
    b = fr['TIN_hash_byte']
    partitions = np.linspace(0,256,k_folds+1)
    t_bottom,t_top = map(float,partitions[fold_index:fold_index+2])
    test  = fr[ (t_bottom <= b) & (b < t_top) ]
    train = fr[ ~( (t_bottom <= b) & (b < t_top) ) ]
    # train = fr[ (b < t_bottom) | (b >= t_top) ]
    return train,test

def toy_classifications():
    # train, valid, test = fr.split_frame([0.6, 0.2], seed=1234) # simply subsets of fr
    train, valid, test = divide_train_test(fr)


    m = H2OGeneralizedLinearEstimator(family="binomial")
    features = ['VatRatio','LocalVatRatio','TurnoverGross','TotalReturnCount','RefundClaimedBoolean'] + share_cols
    m.train(x=features, y="y", training_frame=train)
    m.confusion_matrix()
    # or m.model_performance() or simply m


    # m = H2ODeepLearningEstimator()
    m.train(x=features, y="y", training_frame=train, validation_frame=valid)
    m.confusion_matrix(valid=True)
    plt.plot(*m.roc(valid=1))
    # m.model_performance(test_data=test)

    # Random Forest
    var_y = 'y'
    rf_v1 = H2ORandomForestEstimator(
        model_id="rf_v1",
        ntrees=200,
        stopping_rounds=2,
        score_each_iteration=True,
        seed=1000000)

    rf_v1.train(features, var_y, training_frame=train, validation_frame=valid)
    rf_v1.confusion_matrix(valid=1)
    # plt.plot(*rf_v1.roc(valid=1))
    plot_betas(rf_v1.roc(valid=1))

def sanity_check_perfect_prediction():
    # with the class as a feature
    rf_v1.train(features+['y2'], var_y, training_frame=train, validation_frame=valid)
    rf_v1.confusion_matrix(valid=1) # no errors, perfect performance as expected
    plot_betas(rf_v1.roc(valid=1))

def model_improvement_check(model,train,valid,features,added_features,more_features=None):
    roc_list = []
    for model_features in [features, features+added_features] + ([features+added_features+more_features] if more_features is not None else []):
        model.train(model_features, 'y', training_frame=train, validation_frame=valid)
        roc_list.append( model.roc(valid=1) )

    labels = ['base','added features','added + more features']
    for i,roc in enumerate(roc_list):
        plot_betas(roc,label=labels[i])
    plt.legend()
    plt.show()

def yearly_returns_count(sr):
    gr = sr.dropna(subset=turnover_columns).groupby(['Mtin','Year']) # better with "returns"
    sz = gr.size()
    print sz.reset_index(name='size').groupby(['Year','size']).size()
    # 2010-2012: <=4 or 12 predominantly
    # 2012: predominantly 4, some 12
    # 2013-2014: predominantly 4, never >4 (in 2013 5 is very rare but exists)

def check_volatility(sr,time_unit='quarter'):
    """
    Will create and check predictivity of turnover volatility measures
    @sr - sub-returns or returns.
    @time_unit is "quarter" or "year" (case-insensitive)
    """

    if time_unit.lower()=='year':
        time_columns = ["Year"]
    elif time_unit.lower()=='quarter':
        time_columns = ["Year","Quarter"]
    else:
        raise ValueError('invalid time unit {}. Must be "quarter" or "year"'.format(time_unit))
    turnover_columns = ['TurnoverCentral','TurnoverGross','TurnoverLocal','AmountDepositedByDealer','TaxCreditBeforeAdjustment']
    gr = sr.dropna(subset=turnover_columns+time_columns).groupby(['Mtin']+time_columns)
    dealer_time_level = gr.first()
    dealer_time_level[turnover_columns] = gr[turnover_columns].mean() #.sum() # If we used older years, summing turnovers for each year to have constant benchmark
    dealer_level = dealer_time_level.reset_index().drop_duplicates('Mtin')
    for c in turnover_columns:
        dealer_level[c+'_rsd'] = div(dealer_time_level[c].std(level=0),dealer_time_level[c].mean(level=0))
    for c in turnover_columns:
        attr_cumulative(dealer_level,c+'_rsd')

    # these seem to give almost no predictive power

    # Now I can add the results from "red" to the returns DB - but careful, it uses the future.

def turnover_distribution_by_year_plot(dealer_year_level):
    """
    this is to see that I should really sum the returns from each year.
    If I do mean instead of sum for dealer_year_level I get 2012-2014 systematically lower
    """
    aa = dealer_year_level.reset_index()
    for year in sorted(aa.Year.unique()):
        sns.distplot(np.log1p(aa[aa.Year==year]['TurnoverGross']).dropna(),label=str(year))

    # and excluding 0 turnovers:
    for year in sorted(aa.Year.unique()):
        sns.distplot(np.log1p(aa[(aa['TurnoverGross']>0) & (aa.Year==year)]['TurnoverGross']).dropna(),label=str(year),hist=False)


def load_feature_label_table(save_as_csv=False,femq12=None):
    """
    ultimate source of data is D:\data\PreliminaryAnalysis\BogusDealers\<dta & csv files>
    see also funcs from Shekhar's files:
    load_*() in D:\shekhar_code_github\BogusFirmCatching_minus_glm_2013\init_sm.py
    load_everything() in D:\shekhar_code_github\BogusFirmCatching_minus_glm_2013\ml_funcs.py
    """
    if femq12 is None:
        femq12 = load_everything()
    init()
    ffemq12 = load_h2odataframe_returns(femq12)
    if save_as_csv:
        h2o.download_csv(ffemq12,r"Z:\all_returns_features_new.csv")
    # TrainData, ValidData, TestData = divide_train_test(ffemq12)
    return femq12,ffemq12

def create_feature_sets():
    # Features that the Tax Authority uses
    basic_features = ['MoneyDeposited','VatRatio','LocalVatRatio','TurnoverGross',\
                      'TurnoverLocal','OutputTaxBeforeAdjustment','TaxCreditBeforeAdjustment',\
                      'TotalReturnCount']
    # Features that we think can be important
    important_features =  ['PositiveContribution','InterstateRatio','RefundClaimedBoolean',\
                           'MoneyGroup','CreditRatio','LocalCreditRatio']
    # Rest of the features in the the returns
    remaining_features = ['PercPurchaseUnregisteredDealer','PercValueAdded','AllCentral', \
                          'AllLocal', 'ZeroTax', 'ZeroTurnover', 'ZeroTaxCredit','TotalPurchases']

    return_features=basic_features+important_features+remaining_features


    # Dealer Features
    dealer_features=['profile_merge','Ward', 'Constitution','BooleanRegisteredIEC',\
                     'BooleanRegisteredCE','BooleanServiceTax','StartYear',\
                     'DummyManufacturer','DummyRetailer','DummyWholeSaler',\
                     'DummyInterStateSeller','DummyInterStatePurchaser','DummyWorkContractor',\
                     'DummyImporter','DummyExporter','DummyOther','DummyHotel','DummyECommerce',\
                     'DummyTelecom']


    # Transaction Features
    transaction_features=['transaction_merge','UnTaxProp']
    # Match Features
    #match_features=['purchasematch_merge','salesmatch_merge', 'PurchasesAvgMatch', 'PurchasesAvgMatch3', 'PurchasesNameAvgMatch','SalesAvgMatch','SalesAvgMatch3','SalesNameAvgMatch' ]
    match_features=['purchasematch_merge','salesmatch_merge','SaleMyCountDiscrepancy', \
                    'SaleOtherCountDiscrepancy','SaleMyTaxDiscrepancy','SaleOtherTaxDiscrepancy',\
                    'SaleDiscrepancy','absSaleDiscrepancy', '_merge_salediscrepancy', \
                    'PurchaseMyCountDiscrepancy','PurchaseOtherCountDiscrepancy',\
                    'PurchaseMyTaxDiscrepancy','PurchaseOtherTaxDiscrepancy',\
                    'PurchaseDiscrepancy','absPurchaseDiscrepancy' ]

    network_features=[ u'Purchases_pagerank', u'Purchases_triangle_count', u'Purchases_in_degree',\
                      u'Purchases_out_degree', u'purchasenetwork_merge', u'Sales_pagerank',\
                      u'Sales_triangle_count', u'Sales_in_degree', u'Sales_out_degree',\
                      u'salesnetwork_merge']

    ds_features=[u'purchaseds_merge', u'MaxPurchaseProp', u'PurchaseDSUnTaxProp',\
                 u'PurchaseDSCreditRatio', u'PurchaseDSVatRatio',u'Missing_MaxPurchaseProp',\
                 u'Missing_PurchaseDSUnTaxProp', \
                 u'Missing_PurchaseDSCreditRatio', u'Missing_PurchaseDSVatRatio', u'TotalSellers',\
                 u'salesds_merge', u'MaxSalesProp',u'Missing_MaxSalesProp', u'SalesDSUnTaxProp',\
                 u'SalesDSCreditRatio', u'SalesDSVatRatio', u'Missing_SalesDSUnTaxProp', \
                 u'Missing_SalesDSCreditRatio', u'Missing_SalesDSVatRatio', u'TotalBuyers']

    all_network_features=transaction_features+match_features+network_features+ds_features
    feature_sets_basis = {'return':return_features,'dealer':dealer_features,'network':all_network_features}

    # feature_sets = [return_features,dealer_features,all_network_features,return_features+\
    #           dealer_features,return_features+all_network_features,dealer_features+\
    #           all_network_features,return_features+dealer_features+all_network_features]

    feature_set_components = [['return'],
        ['dealer'],
        ['network'],
        ['return', 'dealer'],
        ['return','network'],
        ['dealer', 'network'],
        ['return','dealer','network']]

    feature_sets = [sum_list([feature_sets_basis[component] for component in components]) for components in feature_set_components]

    feature_sets_names = [' + '.join(components) for components in feature_set_components]

    return feature_sets

FEATURE_SETS = create_feature_sets()

def explore_classification(label_var='bogus_flag',create_plots=False):
    """
    see also file shekhar_bogus_ml.py for the source of some of this
    """
    feature_sets = FEATURE_SETS

    rf_models = [H2ORandomForestEstimator(
            model_id="rf_v{}".format(i),
            ntrees=200,
            stopping_rounds=2,
            score_each_iteration=True,
            seed=1000000) \
        for i in xrange(1,8)]

    raw_input('train all models - takes an hour! Are you sure? [Ctrl-C to abort]')
    for i in xrange(len(feature_sets)):
        print "Building Model {}".format(i+1)
        rf_models[i].train(feature_sets[i], label_var, training_frame=TrainData, validation_frame=ValidData)

    if create_plots:
        legends=["Return features","Profile features","Network features","1 + 2","1 + 3","2 + 3","1 + 2 + 3"]
        #legends=["return_features","ds_features","return_features+ds_features"]

        plot=compare_models(rf_models,legends, of=r'H:\shekhar_code_github\BogusFirmCatching_minus_glm_2013\Graphs\{label}_comparison_plot_AllCombinations_minusq12_numericmerge_withds.html'.format(label=label_var),\
                            title='Comparing All Models, {label}'.format(label=label_var))
        show(plot)

        for i in xrange(len(rf_models)):
            h2o.save_model(rf_models[i],path=r'H:\shekhar_code_github\BogusFirmCatching_minus_glm_2013\Models\diff_feature_sets\20190227')

        for i in xrange(7):
            show(analyze_model(rf_models[i],of=r"H:\shekhar_code_github\BogusFirmCatching_minus_glm_2013\Graphs\{}_model{}_v2_numericmerge_withds.html".format(label_var,i+1),n_rows=30))

    file_name = r'Z:\Predictions_{label}_v2_numericmerge_withDS.csv'.format(label=label_var)
    generate_predictions(rf_models,ValidData,file_name,'{label}_Model'.format(label=label_var))
    predictions = pd.read_csv(file_name)

    # todo: Shekhar has other variations on the training and testing there, which I can put into this framework using variables.

def load_models(model_dir_path=r'HH:\shekhar_code_github\BogusFirmCatching_minus_glm_2013\Models\diff_feature_sets\20170515'):
    models = map(h2o.load_model,glob.glob(os.path.join(model_dir_path,'*')))
    return models

def explore_multiple_time_periods(predictions_file=r"HH:\data\PreliminaryAnalysis\BogusDealers\Predictions_bogus_flag_v2_numericmerge_withDS.csv",
                                  label_var='bogus_flag',plot=False):
    predictions = pd.read_csv(predictions_file)
    predictions.sort_values(['Mtin','TaxQuarter'],inplace=True)
    keep_columns = [u'Mtin', u'TaxQuarter', u'bogus_flag',
       u'bogus_cancellation',u'bogus_flag_Model1', u'bogus_flag_Model2',
       u'bogus_flag_Model3', u'bogus_flag_Model4', u'bogus_flag_Model5',
       u'bogus_flag_Model6', u'bogus_flag_Model7']

    model_score_col = u'bogus_flag_Model7'
    explore_multiple_aggregations(predictions,model_score_col,keep_columns=keep_columns)
    ret = performance_on_top_recommendations(pred_dfs['pred_avg'],model_score_col,label_var,plot=plot)
    print ret

def explore_multiple_aggregations(firm_period_predictions,model_score_col,label_var='bogus_flag',plot=True,keep_columns=None):
    """
    @firm_period_predictions has row per firm per tax period
    """
    if keep_columns is None:
        keep_columns = firm_period_predictions.columns
    n_tax_quarters = 11
    grouped_predictions = firm_period_predictions[keep_columns].groupby('Mtin')
    pred_dfs = {}
    pred_dfs['pred_first'] = grouped_predictions.first()
    pred_dfs['pred_last']  = grouped_predictions.last()
    pred_dfs['pred_max']   = grouped_predictions.max()
    pred_dfs['pred_min']   = grouped_predictions.min()
    pred_dfs['pred_avg']   = grouped_predictions.mean()
    # pred_dfs['pred_sum']   = grouped_predictions.sum() / n_tax_quarters
    # pred_dfs['pred_geo_odds'] = grouped_predictions[[model_score_col]].agg(lambda group: np.mean( np.log( (group/(1-group)) )) )
    # pred_dfs['pred_geo_odds']['bogus_flag'] = pred_dfs['pred_first']['bogus_flag']
    if plot:
        plt.figure()
        [ predictions2betas_curve(pred,model_score_col,label_var,return_betas=False,plot_betas=True,label=pred_type) \
            for pred_type,pred in pred_dfs.items() ]
        plt.legend()
        plt.title('betas curve, aggregation of CV predictions')

def explore_multiple_time_period_aggregations_point_in_time(firm_period_predictions,model_score_col='model_score_bogus_flag',label_var='bogus_flag',plot=True):
    grouped_predictions = firm_period_predictions.groupby('Mtin')
    last_appearance = grouped_predictions['TaxQuarter'].max().reset_index()
    # pd.crosstab(last_appearance['TaxQuarter'],last_appearance['bogus_flag'])
    for t in xrange(9,21):
        still_operating_tins = set(last_appearance.query('TaxQuarter>=@t')['Mtin'])
        past_predictions = firm_period_predictions.query('(TaxQuarter<=@t) and Mtin in @still_operating_tins')
        # grouped_predictions = past_predictions.groupby('Mtin')
        # k = grouped_predictions[['TaxQuarter',model_score_col,label_var]].mean()
        explore_multiple_aggregations(past_predictions,model_score_col,label_var,plot)


def performance_on_top_recommendations(pred,model_score_col='bogus_flag_Model7',label_var='bogus_flag',scaling_factor=8,plot=False):
    """
    evaluates expected model performance on top suspected firms (which would be recommended for audits)
    """
    pred.sort_values(model_score_col,ascending=False,inplace=True)
    pred['index_suspicious'] = arange(len(pred))
    pred['inspection_group'] = pd.cut(pred['index_suspicious'],np.array([-1,400-1,800-1,1200-1,2500-1,np.inf])/scaling_factor,labels=['1-400','401-800','801-1200','1201-2500','2501-rest'])
    # ret = pred.groupby('inspection_group')[label_var].mean() # todo: [[label_var,model_score_col]]
    ret = pred.groupby('inspection_group')[label_var].agg(['mean','sum','size'])
    if plot:
        ret['mean'].plot.barh()
        plt.xlabel('fraction bogus')
    return ret

def get_predictions_df(model,test_set,model_score_col='model_score'):
    df = set_predictions(model,test_set)
    df.rename(columns={'p1':model_score_col},inplace=True)
    return df

def train_probabilistic_labels(df,features,prob_label_col='prob_bogus',label_var='is_bogus'):
    """
    convert probabilistic labels to weights, then train a model on that.
    """
    df_weighted = probabilistic_labels2weights(df,prob_label_col,label_var)
    fr = h2o.H2OFrame(df_weighted)
    # train,valid,test = divide_train_test(fr)
    # model = H2ORandomForestEstimator(model_id="rf_model", ntrees=200, stopping_rounds=2, score_each_iteration=True, seed=1000000)
    model = H2ORandomForestEstimator(model_id="rf_model", ntrees=200, nfolds=8, keep_cross_validation_predictions=True, stopping_rounds=2, score_each_iteration=True, seed=1000000)
    model.train(features,label_var,training_frame=fr,weights_column='weight')
    model.cross_validation_holdout_predictions()

# http://docs.h2o.ai/h2o/latest-stable/h2o-docs/data-science/algo-params/keep_cross_validation_predictions.html
# http://docs.h2o.ai/h2o/latest-stable/h2o-docs/cross-validation.html

def probabilistic_labels2weights(df,prob_label_col='prob_bogus',label_var='is_bogus'):
    """
    turns pandas/h2o DataFrame @df with probabilistic labels in @prob_label_col (0-1) to H2OFrame
    with double the rows, where each observation is duplicated into two:
    (label_var=1, weight=prob) and (label_var=0, weight=1-prob)
    """
    if isinstance(df,h2o.H2OFrame):
        df2 = h2o.deep_copy(df,'some_internal_id') # h2o
    elif isinstance(df,pd.DataFrame):
        df2 = df.copy()
    else:
        raise ValueError('not a data frame')
    df[label_var] = 1
    df['weight'] = df[prob_label_col]
    df2[label_var] = 0
    df2['weight'] = 1 - df2[prob_label_col]
    if isinstance(df,h2o.H2OFrame):
        df_weighted = df.concat(df2,axis=0) # h2o
    elif isinstance(df,pd.DataFrame):
        df_weighted = pd.concat([df,df2],axis=0)
    return df_weighted

def cv_predictions_each_tax_period(feature_table,label_var='bogus_flag',k_folds=8,feature_set=None,model_save_dir=r'H:\Ashwin\BogusFirmCatching_minus_glm_2013\models\cv_predictions',save_predictions_as_csv=False,model=None):
    """
    create predictions for the entire dataset (each row is firm X quarter) using cross-validation
    returns a (DataFrame of firm-period predictions, list of models)
    @model_save_dir - if not None, save model there
    @model - if None, RandomForest is used.
    """
    if feature_set is None:
        feature_set = FEATURE_SETS[6]

    feature_table = add_fold_column(feature_table,'fold',k_folds)

    future = False
    if future:
        feature_table = probabilistic_labels2weights(feature_table,'prob_bogus','is_bogus') # or label_var
        weights_column = 'weight'
    else:
        weights_column = None

    if model is None:
        # use RandomForest
        # add date to model id
        dt = pd.to_datetime(time.ctime())
        date_str = '{:%Y%m%d}'.format(dt)
        model = H2ORandomForestEstimator(model_id="rf_cv_all_folds_"+date_str, ntrees=200,
                    keep_cross_validation_predictions=True, stopping_rounds=2, score_each_iteration=True, seed=1000000)
    
    # takes 4 hours or so for RandomForest, less for others.
    model.train(feature_set,label_var,feature_table,fold_column='fold',weights_column=weights_column)
    # docs: http://docs.h2o.ai/h2o/latest-stable/h2o-docs/data-science/algo-params/keep_cross_validation_predictions.html
    predictions = model.cross_validation_holdout_predictions()
    feature_table_cols = ['Mtin','TaxQuarter','TIN_hash_byte','fold',label_var]
    try:
        predictions=predictions[['p1']].as_data_frame(use_pandas=True)
        predictions.rename(columns={'p1':'model_score_'+label_var},inplace=True)
    except Exception as exc:
        print 'something wrong with predictions'
        print exc
        if not isinstance(predictions,pd.DataFrame): # h2o frame -> pandas
            predictions = predictions.as_data_frame(use_pandas=True)
    firm_period_predictions = pd.concat( [feature_table[feature_table_cols].as_data_frame(use_pandas=True), predictions],axis=1,ignore_index=True)
    # rewrite column names
    try:
        firm_period_predictions.columns = feature_table_cols + predictions.columns.tolist()
    except:
        print 'something wrong with predictions 2'

    if model_save_dir is not None:
        h2o.save_model(model,path=model_save_dir,force=True)
    
    #### Ashwin addition start #######
   # feature_table = ffemq12
   # fold_models = []
   # fold_models.append(model)
#    for i in xrange(k_folds):
#          h2o.save_model(fold_models[i],path=model_save_dir,force=True)
    #### Ashwin addition end ######
     
    if save_predictions_as_csv:
        firm_period_predictions.to_csv(r"Z:\firm_period_predictions.csv")
        # D:\shekhar_code_github\BogusFirmCatching_minus_glm_2013\Models\cv_predictions\20170524\

    return firm_period_predictions,model

# def cv_predictions_each_tax_period_k_models(feature_table,label_var='bogus_flag',k_folds=8,feature_set=None,model_save_dir=r'D:\shekhar_code_github\BogusFirmCatching_minus_glm_2013\Models\cv_predictions\20170524',save_predictions_as_csv=False):
#     """
#     create predictions for the entire dataset (each row is firm X quarter) using cross-validation
#     returns a (DataFrame of firm-period predictions, list of models)
#     @model_save_dir - if not None, save models there
#     """
#     if feature_set is None:
#         feature_set = FEATURE_SETS[6]

#     fold_models = []
#     fold_predictions = []

#     for i in xrange(k_folds):
#         model = H2ORandomForestEstimator(
#             model_id="rf_fold_{}".format(i),
#             ntrees=200, stopping_rounds=2, score_each_iteration=True, seed=1000000)
#         train,prediction_fold = divide_train_test_k_folds(feature_table, i, k_folds)
#         model.train(feature_set, label_var, training_frame=train)
#         predictions = get_predictions_df(model,prediction_fold,'model_score_'+label_var)
#         predictions_and_ids = pd.concat( [prediction_fold[['Mtin','TaxQuarter','TIN_hash_byte',label_var]].as_data_frame(use_pandas=True), predictions],axis=1,ignore_index=True)
#         fold_predictions.append(predictions_and_ids)
#         fold_models.append(model)

#     firm_period_predictions = pd.concat(fold_predictions)

#     if model_save_dir is not None:
#       for i in xrange(k_folds):
#           h2o.save_model(fold_models[i],path=model_save_dir,force=True)

#     if save_predictions_as_csv:
#         firm_period_predictions.to_csv(r"Z:\firm_period_predictions.csv")

#     return firm_period_predictions,fold_models

def aggregate_predictions_multiple_time_periods(firm_period_predictions,model_score_col='model_score_bogus_flag',at_t=None,aggfunc=np.mean):
    """
    Point-in-time simulation
    only predict for firms that are currently operating.
    if @at_t is None it would be calculated from the data as the most recent time
    """
    if at_t is None:
        at_t = firm_period_predictions['TaxQuarter'].max()

    grouped_predictions = firm_period_predictions.groupby('Mtin')
    last_appearance = grouped_predictions['TaxQuarter'].max().reset_index()
    still_operating_tins = set(last_appearance.query('TaxQuarter>=@at_t')['Mtin'])
    # TODO: this seems wrong - we use the future predictions for TINs still operating.
    past_predictions = firm_period_predictions.query('Mtin in @still_operating_tins')
    grouped_predictions = past_predictions.groupby('Mtin')
    agg_predictions = grouped_predictions.agg(aggfunc).reset_index()

    return agg_predictions

def get_suspicious(firm_period_predictions,model_score_col='model_score_bogus_flag',at_t=None):
    if at_t is None:
        exactly_at_t = False
        at_t = firm_period_predictions['TaxQuarter'].max()
    else:
        exactly_at_t = True

    grouped_predictions = firm_period_predictions.query('TaxQuarter<=@at_t').groupby('Mtin')
    predictions = grouped_predictions[model_score_col].mean().to_frame(model_score_col)
    predictions['last_quarter'] = grouped_predictions['TaxQuarter'].max()
    predictions['bogus_flag'] = grouped_predictions['bogus_flag'].first()
    if exactly_at_t:
        predictions = predictions.query('last_quarter==@at_t')
    return predictions
    # predictions['last_quarter'].value_counts()

# mean_aggregated = firm_period_predictions.groupby('Mtin')[['model_score_bogus_flag','bogus_flag']].mean()
def check_model_calibration(predictions,model_score_col='model_score_bogus_flag',label=None):
    pred_bin = pd.cut(predictions[model_score_col],[1,0.5,0.1,0.01,0.001,0.0001,0][::-1])
    gr = predictions.groupby(pred_bin)
    red = gr['bogus_flag'].agg({'label_mean':'mean','label_sum':'sum','n':len})
    red['model_score_mean'] = gr[model_score_col].mean()
    plt.loglog(red['model_score_mean'],red['label_mean'],label=label)
    plt.xlabel('model score mean')
    plt.ylabel('label mean')
    plt.title('calibration of models')
    # the unaggregated model rather calibrated. The mean-aggregated model slightly biased towards bogus.
    return red

def point_in_time_simulations():
    pdfemq12['fold'] = (pdfemq12['TIN_hash_byte']/32).astype(int) # h2o.as_list(ffemq12['fold'])['fold']
    last_appearance = pdfemq12.groupby('Mtin')['TaxQuarter'].max().reset_index()
    #last_appearance = femq12.group_by(["Mtin"])["TaxQuarter"].max()#.reset_index()
    pdfemq12 = pdfemq12.merge(last_appearance.rename(columns={'TaxQuarter':'DealerLastTaxQuarter'}),on='Mtin')
    # firm_period_predictions,cv_model = cv_predictions_each_tax_period(ffemq12)
    # avg_predictions = firm_period_predictions.groupby('Mtin').mean()
    assessment_list = []

    step = 2
    for t in xrange(13+1,18+1,step):
        print t
        print time.ctime()
        print '-'*30
        # time t means we only have data until TaxQuarter t, and only know bogus firms that were canceled before time t, i.e. have no return in time t.
        # features until time t
        point_in_time_pdfemq12 = pdfemq12.query('TaxQuarter<=@t').copy()
        # bogus known by time t, so all those canceled after seem legit
        point_in_time_pdfemq12.loc[point_in_time_pdfemq12['DealerLastTaxQuarter']>=t,'bogus_flag'] = 0
        point_in_time_pdfemq12.drop('DealerLastTaxQuarter',axis=1).to_csv(r"Z:\temp.csv")
        #del point_in_time_pdfemq12 ## delete the variable
        point_in_time_h2o = h2o.import_file(r"Z:\temp.csv")
        #point_in_time_h2o = h2o.H2OFrame(point_in_time_pdfemq12.drop('DealerLastTaxQuarter',axis=1))
        print time.ctime()
        save_dir = r"H:\Ashwin\BogusFirmCatching_minus_glm_2013\models\cv_predictions\20190227\point_in_time_q{:02d}".format(t)
        try:
            firm_period_predictions_t,cv_model_t = cv_predictions_each_tax_period(point_in_time_h2o,model_save_dir=save_dir)         
            firm_period_predictions_t.to_csv(save_dir+r"\point_in_time_firm_period_predictions_q{:02d}.csv".format(t),index=False)
           
#            assessment_1 = point_in_time_assess_performance(firm_period_predictions_t,t,pdfemq12,save_dir=save_dir)
#            assessment_list_1.append(assessment_1)
        except Exception as exc:
            print 'something bad 3'
            print exc
        h2o.remove(point_in_time_h2o)
        
            
    for t in xrange(19+1,24+1,step):
        print t
        print time.ctime()
        print '-'*30
        # time t means we only have data until TaxQuarter t, and only know bogus firms that were canceled before time t, i.e. have no return in time t.
        # features until time t
        point_in_time_pdfemq12 = pdfemq12.query('TaxQuarter<=@t').copy()
        # bogus known by time t, so all those canceled after seem legit
        point_in_time_pdfemq12.loc[point_in_time_pdfemq12['DealerLastTaxQuarter']>=t,'bogus_flag'] = 0
        point_in_time_pdfemq12.drop('DealerLastTaxQuarter',axis=1).to_csv(r"Z:\temp.csv")
        #del point_in_time_pdfemq12 ## delete the variable
        point_in_time_h2o = h2o.import_file(r"Z:\temp.csv")
        #point_in_time_h2o = h2o.H2OFrame(point_in_time_pdfemq12.drop('DealerLastTaxQuarter',axis=1))
        print time.ctime()
        save_dir = r"H:\Ashwin\BogusFirmCatching_minus_glm_2013\models\cv_predictions\20190227\point_in_time_q{:02d}".format(t)
        try:
            firm_period_predictions_t,cv_model_t = cv_predictions_each_tax_period(point_in_time_h2o,model_save_dir=save_dir)         
            firm_period_predictions_t.to_csv(save_dir+r"\point_in_time_firm_period_predictions_q{:02d}.csv".format(t),index=False)
           
#            assessment_2 = point_in_time_assess_performance(firm_period_predictions_t,t,pdfemq12,save_dir=save_dir)
#            assessment_list_2.append(assessment_2)
        except Exception as exc:
            print 'something bad 3'
            print exc
        h2o.remove(point_in_time_h2o)
    
    ## Running into memory error 
    ## a) run the first two for loops b) run third for loop c) append all the lists d) run assessments 
    for t in xrange(25+1,28+1,step):
        print t
        print time.ctime()
        print '-'*30
        # time t means we only have data until TaxQuarter t, and only know bogus firms that were canceled before time t, i.e. have no return in time t.
        # features until time t
        point_in_time_pdfemq12 = pdfemq12.query('TaxQuarter<=@t').copy()
        # bogus known by time t, so all those canceled after seem legit
        point_in_time_pdfemq12.loc[point_in_time_pdfemq12['DealerLastTaxQuarter']>=t,'bogus_flag'] = 0
        point_in_time_pdfemq12.drop('DealerLastTaxQuarter',axis=1).to_csv(r"Z:\temp.csv")
        #del point_in_time_pdfemq12 ## delete the variable
        point_in_time_h2o = h2o.import_file(r"Z:\temp.csv")
        #point_in_time_h2o = h2o.H2OFrame(point_in_time_pdfemq12.drop('DealerLastTaxQuarter',axis=1))
        print time.ctime()
        save_dir = r"H:\Ashwin\BogusFirmCatching_minus_glm_2013\models\cv_predictions\20190227\point_in_time_q{:02d}".format(t)
        try:
            firm_period_predictions_t,cv_model_t = cv_predictions_each_tax_period(point_in_time_h2o,model_save_dir=save_dir)         
            firm_period_predictions_t.to_csv(save_dir+r"\point_in_time_firm_period_predictions_q{:02d}.csv".format(t),index=False)
           
#            assessment_3 = point_in_time_assess_performance(firm_period_predictions_t,t,pdfemq12,save_dir=save_dir)
#            assessment_list_3.append(assessment_3)
        except Exception as exc:
            print 'something bad 3'
            print exc
        h2o.remove(point_in_time_h2o)
     
     #since for loop is broken, appending assessments to create a list   
    for t in xrange(13+1,28+1,step):
        print t
        print time.ctime()
        print '-'*30
        save_dir = r"H:\Ashwin\BogusFirmCatching_minus_glm_2013\models\cv_predictions\20190227\point_in_time_q{:02d}".format(t)
        firm_period_predictions_t = pd.read_csv(save_dir+r"\point_in_time_firm_period_predictions_q{:02d}.csv".format(t))
        assessment_1 = point_in_time_assess_performance(firm_period_predictions_t,t,pdfemq12,save_dir=save_dir)
        assessment_list.append(assessment_1)  
    
    assessments = {}
    for criterion in ['performance','revenue','performance_revenue_optimized','revenue_optimized']:
        assessments[criterion] = pd.concat(col(assessment_list,criterion)).reset_index()
        assessments[criterion].to_csv(r'H:\Ashwin\BogusFirmCatching_minus_glm_2013\models\cv_predictions\20190227\point_in_time_{}.csv'.format(criterion),index=False)
    analyze_performances(assessments['performance'])

def get_future_predictions(firm_period_predictions,t,pdfemq12,model_score_col='model_score_bogus_flag',label_var='bogus_flag'):
    dealer_predictions = firm_period_predictions[['Mtin',model_score_col]].groupby('Mtin').mean().reset_index()
    # unblinding - real classes
    dealer_classes = pdfemq12[['Mtin','bogus_flag','DealerLastTaxQuarter']].drop_duplicates(subset=['Mtin'])
    dealer_future_tax = pdfemq12.query('TaxQuarter>@t').groupby('Mtin')['TaxCreditBeforeAdjustment'].sum().reset_index()
    dealer_classes_tax = dealer_classes.merge(dealer_future_tax,how='left',on='Mtin').fillna(0)
    # dealer_predictions_classes = dealer_predictions.merge(dealer_classes,how='left',on='Mtin')
    dealer_predictions_classes_tax = dealer_predictions.merge(dealer_classes_tax,how='left',on='Mtin')
    # only assess on dealers still active at time t.
    future_predictions = dealer_predictions_classes_tax.query('DealerLastTaxQuarter >= @t')
    future_predictions['revenue'] = future_predictions[label_var]*future_predictions['TaxCreditBeforeAdjustment']
    future_predictions['revenue_score'] = future_predictions[model_score_col]*future_predictions['TaxCreditBeforeAdjustment']
    return future_predictions

def point_in_time_assess_performance(firm_period_predictions,t,pdfemq12,model_score_col='model_score_bogus_flag',label_var='bogus_flag',save_dir=None):
    """
    more sophisticated performance evaluation - unblinding ourselves.
    If @save_dir is not None, 4 files will be saved there:
    point_in_time_performance.csv, point_in_time_revenue.csv,
    point_in_time_revenue_optimized.csv, point_in_time_performance_revenue_optimized.csv
    """
    future_predictions = get_future_predictions(firm_period_predictions,t,pdfemq12,model_score_col,label_var)
    results = {}
    results['performance'] = performance_on_top_recommendations(future_predictions,model_score_col,label_var,1,plot=False)
    results['revenue'] = performance_on_top_recommendations(future_predictions,model_score_col,'revenue',1,plot=False)
    results['performance_revenue_optimized'] = performance_on_top_recommendations(future_predictions,'revenue_score',label_var,1,plot=False)
    results['revenue_optimized'] = performance_on_top_recommendations(future_predictions,'revenue_score','revenue',1,plot=False)
    for name,df in results.items():
        df.insert(0,'t',t)
        if save_dir is not None:
            df.to_csv(os.path.join(save_dir,"point_in_time_{}.csv".format(name)))
    return results

def retrieve_predictions():
    all_preds = {}
    for t in xrange(10,21,2):
        print t,
        save_dir = r"H:\shekhar_code_github\BogusFirmCatching_minus_glm_2013\Models\cv_predictions\20171226\point_in_time_q{:02d}".format(t)
        csv_path = save_dir+r"\point_in_time_firm_period_predictions_q{:02d}.csv".format(t)
        firm_period_predictions_t = pd.read_csv(csv_path)
        all_preds[t] = firm_period_predictions_t
    return all_preds

def analyze_performances(performances,fontsize=16):
    """
    Tailored to point-in-time simulation performances.
    """
    performances = assessments['performance']
    performances = performances.copy()
    performances['t']-=8
    piv = performances.pivot_table('sum','t','inspection_group')[performances['inspection_group'][:5]]
    print piv
    # axes = piv.plot.area()
    axes = piv.plot.bar(stacked=True,legend='reverse',rot='horizontal',fontsize=fontsize)
    axes.set_title('point-in-time Simulation: bogus firms in each inspection group'.title(),fontsize=fontsize)
    axes.set_xlabel('Time T',fontsize=fontsize)
    axes.set_ylabel('Number of bogus firms targeted',fontsize=fontsize)
    plt.subplots_adjust(bottom=0.15)

    # fraction of bogus firms caught in top 400 inspected
    print piv.div(piv.sum(1),0)

    # sanity check on sums - number of bogus firms available to be caught - already started and not yet caught.
    performances.groupby('t')['sum'].sum()
    lifespan = pdfemq12.query('bogus_flag==1').groupby('Mtin')['TaxQuarter'].agg(['min','max'])
    [((lifespan['min']<=t) & (t<=lifespan['max'])).sum() for t in xrange(8,28,2)]
    return axes

def stats_for_paper():
    # share to unregistered > 0 is predictive
    qq = femq12[['PercPurchaseUnregisteredDealer','bogus_flag']].copy()
    qq['share_to_unregistered'] = pd.cut(qq['PercPurchaseUnregisteredDealer'],[-inf,0,1])
    qq.groupby('share_to_unregistered')['bogus_flag'].agg(['sum','size','mean'])

    # all revenue lost to bogus firms
    print 'TaxCreditBeforeAdjustment:'
    pdfemq12.groupby('bogus_flag')['TaxCreditBeforeAdjustment'].agg(['mean','sum'])
    print 'number of firms:'
    pdfemq12.groupby('bogus_flag')['Mtin'].nunique()

    # all time CV performance ##############Ashwin Comment: How was this file generated
    firm_period_predictions_alltime = pd.read_csv(r"H:\Ashwin\BogusFirmCatching_minus_glm_2013\output_data\firm_period_predictions20190227.csv")
    avg_predictions = firm_period_predictions_alltime.groupby('Mtin')[['bogus_flag','model_score_bogus_flag']].mean()
    perf = performance_on_top_recommendations(avg_predictions,model_score_col,label_var,1,plot=False)
    print perf
    perf.to_csv(r"H:\Ashwin\BogusFirmCatching_minus_glm_2013\Models\cv_predictions\20190227\alltime_cv_avg_performance.csv")
    all_preds = retrieve_predictions()
    assessment_list = []
    axes = None
    for t in xrange(10,29,2):
        print t,
        # save_dir = r"D:\shekhar_code_github\BogusFirmCatching_minus_glm_2013\Models\cv_predictions\20171226\point_in_time_q{:02d}".format(t)
        firm_period_predictions_t = all_preds[t]
        future_predictions = get_future_predictions(firm_period_predictions_t,t,femq12,model_score_col,label_var)
        axes = plot_success_on_top_predictions_continuous(future_predictions,400,axes=axes,label='t={:02d}'.format(t))
        assessment = point_in_time_assess_performance(firm_period_predictions_t,t,femq12,save_dir=None)
        assessment_list.append(assessment)
    axes.set_title('point-in-time performance on top 400'.title())
    
    axes = plot_success_on_top_predictions_continuous(avg_predictions,1000)
    axes.set_title('x-val all-time performance on top 1000'.title())
    axes = plot_success_on_top_predictions_continuous(avg_predictions,5000)
    axes.set_title('x-val all-time performance on top 5000'.title())
    axes = plot_success_on_top_predictions_continuous(avg_predictions,2500)
    axes.set_title('x-val all-time performance on top 2500'.title())
   
def plot_success_on_top_predictions_continuous(agg_predictions,top_n_predictions=400,label_var='bogus_flag',model_score_col='model_score_bogus_flag',axes=None,label='',save_path=None):
    """
    @agg_predictions is at the dealer level
    """
    top_predictions = agg_predictions.sort_values(model_score_col,ascending=False)[:top_n_predictions]
   
    if axes is None:
        # add dashed line
        axes = plt.subplot(1,1,1)
        axes.plot([0,top_n_predictions],[0,top_n_predictions],linestyle='--',label='perfect performance')[0]
    axes = top_predictions.reset_index()[label_var].cumsum().plot(label='actual performance '+label,ax=axes)
    axes.set_xlabel('Dealers Inspected')
    axes.set_ylabel('Bogus Dealers Caught')
    plt.legend(loc='upper left')
    if save_path is not None:
        plt.savefig(save_path)
    return axes

def different_feature_sets_save_predictions(ffemq12):
    for i,feature_set in enumerate(FEATURE_SETS):
        print i
        print '-'*30
        print time.ctime()
        try:
            model_save_dir=r'H:\Ashwin\BogusFirmCatching_minus_glm_2013\models\diff_feature_sets\20190227\feature_set_{}'.format(i)
            if not os.path.exists(model_save_dir):
                os.mkdir(model_save_dir)
            firm_period_predictions,cv_model = cv_predictions_each_tax_period(ffemq12,feature_set=feature_set,model_save_dir=model_save_dir)
            firm_period_predictions.to_csv(os.path.join(model_save_dir,"firm_period_predictions20190227.csv"),index=False)
            avg_predictions = firm_period_predictions.groupby('Mtin').mean()
            performance_on_top_recommendations(avg_predictions,model_score_col,label_var,1,plot=False).to_csv(os.path.join(model_save_dir,"avg_predictions_performance_20190227.csv"))
        except Exception as exc:
            print 'something wrong'
            print exc

def different_feature_sets_betas_plot():
    axes = None
    for i in lrange(FEATURE_SETS):
        print i,
        model_save_dir=r'H:\Ashwin\BogusFirmCatching_minus_glm_2013\models\diff_feature_sets\20190227\feature_set_{}'.format(i)
        firm_period_predictions = pd.read_csv(os.path.join(model_save_dir,"firm_period_predictions20190227.csv"))
        avg_predictions = firm_period_predictions.groupby('Mtin').mean()
        betas = predictions2betas_curve(avg_predictions,model_score_col,label_var,return_betas=True,plot_betas=False)
        betas.to_csv(os.path.join(model_save_dir,"betas20190227.csv"))
        fs_name = feature_sets_names[i]
        axes = predictions2betas_curve(avg_predictions,model_score_col,label_var,return_betas=False,plot_betas=True,label=fs_name,axes=axes)
    axes.set_title('betas curves for various feature sets'.title())
    plt.legend()

CLASSIFIER_DATE_STR = '20190227'
CLASSIFIERS = {
'RandomForest': H2ORandomForestEstimator(ntrees=200, keep_cross_validation_predictions=True, stopping_rounds=2, score_each_iteration=True, model_id="rf_cv_all_folds_"+CLASSIFIER_DATE_STR, seed=1000000),
'RandomForest_depth6': H2ORandomForestEstimator(ntrees=200, max_depth=6,keep_cross_validation_predictions=True, stopping_rounds=2, score_each_iteration=True, model_id="rf_cv_all_folds_"+CLASSIFIER_DATE_STR, seed=1000000),
#'GLM': H2OGeneralizedLinearEstimator(family= "binomial", lambda_ = 0, compute_p_values = True, remove_collinear_columns=True, keep_cross_validation_predictions=True, model_id="glm_cv_all_folds_"+CLASSIFIER_DATE_STR, seed=1000000), # todo: regularization? http://docs.h2o.ai/h2o/latest-stable/h2o-docs/data-science/glm.html#regularization-parameters-in-glm
#'GLM': H2OGeneralizedLinearEstimator(family= "binomial", lambda_ = 0, compute_p_values = True, remove_collinear_columns=True, keep_cross_validation_predictions=True, model_id="glm_cv_all_folds_"+CLASSIFIER_DATE_STR, seed=1000000, max_iterations=1000000), # todo: regularization? http://docs.h2o.ai/h2o/latest-stable/h2o-docs/data-science/glm.html#regularization-parameters-in-glm
'GBM': H2OGradientBoostingEstimator(ntrees=200, learn_rate=0.2, max_depth=20, stopping_tolerance=0.01, stopping_rounds=2, score_each_iteration=True, keep_cross_validation_predictions=True, model_id="gbm_cv_all_folds_"+CLASSIFIER_DATE_STR, seed=1000000),
'NaiveBayes': H2ONaiveBayesEstimator(keep_cross_validation_predictions=True,model_id="naive_bayes_cv_all_folds_"+CLASSIFIER_DATE_STR, seed=1000000)
#'XGBOOST': H2OXGBoostEstimator(ntrees=200, learn_rate=0.2, max_depth=20, stopping_tolerance=0.01, stopping_rounds=2, score_each_iteration=True, keep_cross_validation_predictions=True, model_id="gbm_cv_all_folds_"+CLASSIFIER_DATE_STR, seed=1000000)
}
# todo: categorical_encoding='one_hot_internal'? No. Works for GLM automatically, impossible for tree methods.

def different_classifiers_save_predictions(ffemq12,model_score_col='model_score_bogus_flag',label_var='bogus_flag'):
    """
    run different classification algorithms on the data and save CV predictions & models
    """
    for algo_name,model in CLASSIFIERS.items():
        print algo_name
        print '-'*30
        print time.ctime()
        try:
            model_save_dir=r'H:\Ashwin\BogusFirmCatching_minus_glm_2013\models\diff_classifiers\{}\classifier_{}'.format(CLASSIFIER_DATE_STR,algo_name)
            if not os.path.exists(model_save_dir):
                os.mkdir(model_save_dir)
            firm_period_predictions,cv_model = cv_predictions_each_tax_period(ffemq12,feature_set=None,model_save_dir=model_save_dir,model=model)
            firm_period_predictions.to_csv(os.path.join(model_save_dir,"firm_period_predictions_{}.csv".format(CLASSIFIER_DATE_STR)),index=False)
            avg_predictions = firm_period_predictions.groupby('Mtin').mean()
            performance_on_top_recommendations(avg_predictions,model_score_col,label_var,1,plot=False).to_csv(os.path.join(model_save_dir,"avg_predictions_performance_{}.csv".format(CLASSIFIER_DATE_STR)))
        except Exception as exc:
            print 'something wrong'
            print exc

def different_classifiers_performance_plots_files(model_score_col='model_score_bogus_flag',label_var='bogus_flag'):
    """
    Load CV predictions of different classification algorithms, calculate betas, save and plot curves.
    """
    parent_dir = r'H:\Ashwin\BogusFirmCatching_minus_glm_2013\models\diff_classifiers\{}'.format(CLASSIFIER_DATE_STR)
    axes = None
    all_top_perfs = []
    for algo_name,model in CLASSIFIERS.items():
        print algo_name
        model_save_dir=os.path.join(parent_dir,'classifier_{}'.format(algo_name))
        firm_period_predictions = pd.read_csv(os.path.join(model_save_dir,"firm_period_predictions_{}.csv".format(CLASSIFIER_DATE_STR)))
        avg_predictions = firm_period_predictions.groupby('Mtin').mean()
        top_perf = performance_on_top_recommendations(avg_predictions,model_score_col,label_var,1,plot=False)
        top_perf.to_csv(os.path.join(model_save_dir,"avg_predictions_performance_{}.csv".format(CLASSIFIER_DATE_STR)))
        top_perf['classifier'] = algo_name
        all_top_perfs.append(top_perf)
        betas = predictions2betas_curve(avg_predictions,model_score_col,label_var,return_betas=True,plot_betas=False)
        betas.to_csv(os.path.join(model_save_dir,"betas_{}.csv".format(CLASSIFIER_DATE_STR)))
        axes = predictions2betas_curve(avg_predictions,model_score_col,label_var,return_betas=False,plot_betas=True,label=algo_name,axes=axes)
    axes.set_title('betas curves for various classifiers'.title())
    plt.legend()
    top_perfs = pd.concat(all_top_perfs)
    top_perfs.to_csv(os.path.join(parent_dir,'avg_predictions_top_performance_all.csv'),index=False)
    piv = top_perfs.pivot_table('sum','classifier','inspection_group')#[perf['inspection_group'][:5]]
    piv.to_csv(os.path.join(parent_dir,'avg_predictions_top_performance_all_pivot.csv'))
    piv.sort_values('1-400',inplace=True,ascending=False)
    fontsize = 16
    ax = piv.rename(index={'RandomForest_depth6':'RandomForest\ndepth6'}).plot.bar(stacked=True,legend='reverse',rot='horizontal',fontsize=fontsize)
    ax.set_title('Different classifiers: bogus firms in each inspection group'.title(),fontsize=fontsize)
    ax.set_xlabel('Classifier',fontsize=fontsize)
    ax.set_ylabel('Number of bogus firms targeted',fontsize=fontsize)
    ax.set_ylim(0,ax.get_ylim()[1]*1.2)
    plt.subplots_adjust(bottom=0.15)
    # plt.savefig(r"D:\Ofir\figures\models\different_classifiers_performance_by_inspection_group_bars.png")
    

