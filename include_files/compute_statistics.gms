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

set f_s_count(fishery,species) "Fisheries and species to consider";

* --- For landings

f_s_count(f,s)
    = yes $ [fishery_species(f,s) and p_priorLandings(f,s,"priDens")];

p_statReport("landings","n")
    = card(f_s_count);

p_statReport("landings","meanEst")
    = sum(f_s_count, v_landings.l(f_s_count))
    / p_statReport("landings","n");

p_statReport("landings","meanObs")
    = sum(f_s_count, p_landingsOri(f_s_count))
    / p_statReport("landings","n");


EXECUTE_UNLOAD "%resdir%\estimation\stats_%parFileName%.gdx" p_statReport;