
import pandas as pd
#import matplotlib.pyplot as plt
#import numpy as np
#from numpy import *
#import h2o
import graphlab
#from graphlab import SGraph, Vertex, Edge, SFrame, degree_counting,kcore
from graphlab import SGraph, degree_counting

#PurchaseNetwork = pd.read_stata("H:\\Ashwin\\dta\\bogusdealers\\Temp_PurchaseTaxAmount_1415.dta", convert_categoricals=False)
# edge_data = SFrame(data=SaleNetwork)
def create_network_features(Returns,Network,name='Sales',Start=9,End=12):
    for quarter in xrange(Start,End):
        if quarter==12:
            continue
        ReturnsX=Returns[Returns['TaxQuarter']==quarter]
        NetworkX=Network[Network['TaxQuarter']==quarter]
        g = SGraph(vertices=ReturnsX,edges=NetworkX,vid_field='Mtin',src_field='Mtin', dst_field='SellerBuyerTin')
#         cc = graphlab.connected_components.create(g)
#         g.vertices['component_id'] = cc['graph'].vertices['component_id']
        pr = graphlab.pagerank.create(g)
        g.vertices['pagerank'] = pr['graph'].vertices['pagerank']
        tc = graphlab.triangle_counting.create(g)
        g.vertices['triangle_count'] = tc['graph'].vertices['triangle_count']
        deg = degree_counting.create(g)
        deg_graph = deg['graph']
        g.vertices['in_degree'] = deg_graph.vertices['in_degree']
        g.vertices['out_degree'] = deg_graph.vertices['out_degree']
#         kc = kcore.create(g)
#         g.vertices['core_id'] = kc['graph'].vertices['core_id']
#        g.vertices.export_csv('H:\\Ashwin\\dta\\sample_bogusdealersNetworkFeaturesSales17.csv')
        g.vertices.export_csv('H:\\Ashwin\\dta\\bogusdealersNetworkFeatures{}{}.csv'.format(name,quarter))

#Returns = pd.read_stata('H:\\Ashwin\\dta\\features\\Temp_FeatureReturns_1415.dta', convert_categoricals=False)
Returns = pd.read_stata('H:\\Ashwin\\dta\\features\\FeatureReturns.dta', convert_categoricals=False)
Returns['Mtin']=Returns['Mtin'].astype('int64')


PurchaseNetwork = pd.read_stata("H:\\Ashwin\\dta\\bogusdealers\\PurchaseTaxAmount_AllQuarters.dta", convert_categoricals=False)
PurchaseNetwork['Mtin']=PurchaseNetwork['Mtin'].astype('int64')
PurchaseNetwork['SellerBuyerTin']=PurchaseNetwork['SellerBuyerTin'].astype('int64')


create_network_features(Returns,PurchaseNetwork,'Purchases',9,29)



SaleNetwork = pd.read_stata("H:\\Ashwin\\dta\\bogusdealers\\SalesTaxAmount_9_11.dta", convert_categoricals=False)
SaleNetwork['Mtin']=SaleNetwork['Mtin'].astype('int64')
SaleNetwork['SellerBuyerTin']=SaleNetwork['SellerBuyerTin'].astype('int64')
create_network_features(Returns,SaleNetwork,'Sales',9,12)

SaleNetwork = pd.read_stata("H:\\Ashwin\\dta\\bogusdealers\\SalesTaxAmount_13_16.dta", convert_categoricals=False)
SaleNetwork['Mtin']=SaleNetwork['Mtin'].astype('int64')
SaleNetwork['SellerBuyerTin']=SaleNetwork['SellerBuyerTin'].astype('int64')
create_network_features(Returns,SaleNetwork,'Sales',13,17)

SaleNetwork = pd.read_stata("H:\\Ashwin\\dta\\bogusdealers\\SalesTaxAmount_17_20.dta", convert_categoricals=False)
SaleNetwork['Mtin']=SaleNetwork['Mtin'].astype('int64')
SaleNetwork['SellerBuyerTin']=SaleNetwork['SellerBuyerTin'].astype('int64')
create_network_features(Returns,SaleNetwork,'Sales',17,21)

SaleNetwork = pd.read_stata("H:\\Ashwin\\dta\\bogusdealers\\SalesTaxAmount_21_24.dta", convert_categoricals=False)
SaleNetwork['Mtin']=SaleNetwork['Mtin'].astype('int64')
SaleNetwork['SellerBuyerTin']=SaleNetwork['SellerBuyerTin'].astype('int64')
create_network_features(Returns,SaleNetwork,'Sales',21,25)

SaleNetwork = pd.read_stata("H:\\Ashwin\\dta\\bogusdealers\\SalesTaxAmount_25_28.dta", convert_categoricals=False)
SaleNetwork['Mtin']=SaleNetwork['Mtin'].astype('int64')
SaleNetwork['SellerBuyerTin']=SaleNetwork['SellerBuyerTin'].astype('int64')
create_network_features(Returns,SaleNetwork,'Sales',25,29)






