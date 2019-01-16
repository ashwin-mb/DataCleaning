
*--------------------------------------------------------
** PurchaseTaxAmount_AllQuarters.dta
*--------------------------------------------------------

sum PurchaseTaxAmount if TaxQuarter == 9 | TaxQuarter == 10 | TaxQuarter == 11

/* 
Old data

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
PurchaseTa~t |  3,384,419    42702.25     1494039  -374925.1   1.14e+09

New data 

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
PurchaseTa~t |  3,381,528     42812.8     1485266  -527140.5   1.14e+09

*/

sum PurchaseTaxAmount if TaxQuarter==13|TaxQuarter==14|TaxQuarter==15///
    |TaxQuarter==16

/*
Old data

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
PurchaseTa~t |  4,849,515    49928.27    984812.2     -41047   5.42e+08

New data

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
PurchaseTa~t |  4,852,478    49894.79    984256.1     -41047   5.42e+08


*/

sum PurchaseTaxAmount if TaxQuarter==17|TaxQuarter==19///
	|TaxQuarter==18|TaxQuarter==20

/*
Old data

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
PurchaseTa~t |  4,779,912    49048.69     1025165  -27817.75   9.88e+08

New data

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
PurchaseTa~t |  4,790,823    50181.07     1043068  -22857.13   9.88e+08

*/

*--------------------------------------------------------
** SaleTaxAmount_AllQuarters.dta
*--------------------------------------------------------

sum SalesTaxAmount if TaxQuarter == 9 | TaxQuarter == 10 | TaxQuarter == 11

/*
Old data

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
SalesTaxAm~t |  4,078,973    39240.47     1581536  -404353.5   1.14e+09

New data

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
SalesTaxAm~t |  4,143,540    41793.27     1622811  -404353.5   1.14e+09

*/

sum SalesTaxAmount if TaxQuarter==13|TaxQuarter==14|TaxQuarter==15 ///
	|TaxQuarter ==16

/*
Old data 

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
SalesTaxAm~t |  5,779,881    44607.15     1179705    -719175   8.98e+08

New data

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
SalesTaxAm~t |  5,780,867    44621.69     1179650    -719175   8.98e+08

*/

sum SalesTaxAmount if TaxQuarter==17|TaxQuarter==18|TaxQuarter==19 ///
	|TaxQuarter ==20

/* 
Old data

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
SalesTaxAm~t |  5,563,217    44095.41     1041649  -575088.3   6.92e+08

New data

    Variable |        Obs        Mean    Std. Dev.       Min        Max
-------------+---------------------------------------------------------
SalesTaxAm~t |  5,598,772    44671.69     1044162   -1406786   6.92e+08

*/




