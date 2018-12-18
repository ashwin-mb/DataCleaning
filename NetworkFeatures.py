import pandas as pd
import matplotlib.pyplot as plt
import numpy as np
from numpy import *
import h2o
import graphlab
from graphlab import SGraph, Vertex, Edge, SFrame, degree_counting,kcore

Returns = pd.read_stata("H:\Ashwin\dta\features\FeatureReturns.dta", convert_categoricals=False)
SaleNetwork = pd.read_stata("H:\Ashwin\dta\bogusdealers\SalesTaxAmount_AllQuarters.dta", convert_categoricals=False)
SaleNetwork = pd.read_stata("H:\Ashwin\dta\bogusdealers\PurchaseTaxAmount_AllQuarters.dta", convert_categoricals=False)
# edge_data = SFrame(data=SaleNetwork)
def create_network_features(Returns,Network,name='Sales'):
    for quarter in xrange(9,28):
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
        g.vertices.export_csv('H:\Ashwin\dta\bogusdealersNetworkFeatures{}{}.csv'.format(name,quarter))
create_network_features(Returns,SaleNetwork,'Sales')
create_network_features(Returns,PurchaseNetwork,'Purchases')




