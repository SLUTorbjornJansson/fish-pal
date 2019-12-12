$ONTEXT

    @purpose: Compute descriptive statistics of estimates, based on criterion

    @author: Torbjörn Jansson

    @date: 2019-12-12

    @calledby: estimate_parameters.gms

$OFFTEXT

set param(*) "Items in estimation that enter the criterion function" /
    landings
    discards
    varCostAve
    kwh
    maxEffFishery
    PMPterms
    effortAnnual
    /;

set allStats(*) "Statistics computed" /
    n   Number of elements in estimation
    meanEst Mean of estimates
    meanObs Mean of observations
    varEst  Variance of estimates
    varObs  Variance of observations
    sd      Standard deviation of errors
    var     Variance of errors
    cov     Covariance of estimates with observations
    corrP   Pearson correlation of estimates with observations
    /;


parameter p_statReport(param,allStats) "Statistics of estimates";

