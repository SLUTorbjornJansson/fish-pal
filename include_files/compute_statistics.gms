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
    sd      Standard deviation from mean
    var     Variance of deviations from mean
    cov     Covariance of estimates with observations
    sxy     Sum of cross product of errors
    ssx     Sum of squared deviations
    corrP   Pearson correlation of estimates with observations
    /;

parameter p_statReport(param,allStats) "Statistics of estimates";

set f_s_count(fishery,species) "Fisheries and species to consider";
set f_cur(fishery) "Fisheries to consider in some current computation";

*-------------------------------------------------------------------------------
* --- Some statistical formulae will be repeated for several symbols.
*     Simplify coding by working with macro-statements

* MACRO for arithmetic mean
$macro f_mean(i,x) sum(i, x(i))/card(i)

* MACRO for Pearson correlation coefficient
$macro f_corrP(i,x,mx,y,my) sum(i, (x(i)-mx)*(y(i)-my))  \
                           /sqrt(sum(i, sqr(x(i)-mx)))   \
                           /sqrt(sum(i, sqr(y(i)-my)))

$macro f_var(i,x,mx) sum(i, sqr(x(i)-mx))/(card(i)-1)
$macro f_sd(i,x,mx) sqrt(f_var(i,x,mx))

*-------------------------------------------------------------------------------


* --- For landings

f_s_count(f,s)
    = yes $ [fishery_species(f,s) and p_priorLandings(f,s,"priDens")];

p_statReport("landings","n")
    = card(f_s_count);


p_statReport("landings","meanEst") = f_mean(f_s_count, v_landings.l);
p_statReport("landings","meanObs") = f_mean(f_s_count, p_landingsOri);

p_statReport("landings","corrP")
  = f_corrP(f_s_count, v_landings.l, p_statReport("landings","meanEst"), p_landingsOri, p_statReport("landings","meanObs"));


* --- For discards

f_s_count(f,s)
    = yes $ [fishery_species(f,s) and p_priorDiscards(f,s,"priDens")];

p_statReport("discards","n")
    = card(f_s_count);

p_statReport("discards","meanEst") = f_mean(f_s_count, v_discards.l);
p_statReport("discards","meanObs") = f_mean(f_s_count, p_discardsOri);

p_statReport("discards","corrP")
  = f_corrP(f_s_count, v_discards.l, p_statReport("discards","meanEst"), p_discardsOri, p_statReport("discards","meanObs"));


* --- For varCostAve

f_cur(f) = yes $ p_weightvarCostAve(f);

p_statReport("varCostAve","n")
    = card(f_cur);

p_statReport("varCostAve","meanEst") = f_mean(f_cur, v_varCostAve.l);
p_statReport("varCostAve","meanObs") = f_mean(f_cur, p_varCostAveOri);

p_statReport("varCostAve","corrP")
  = f_corrP(f_cur, v_varCostAve.l, p_statReport("varCostAve","meanEst"), p_varCostAveOri, p_statReport("varCostAve","meanObs"));


* --- For PMP-terms

f_cur(f) = yes $ p_weightPMP(f);

p_statReport("PMPterms","n")
    = card(f_cur);

parameter x(f);
x(f) = pv_PMPconst.l(f) + 1/2*pv_PMPslope.l(f)*v_effortAnnual.l(f);
p_statReport("PMPterms","meanEst") = f_mean(f_cur, x);
p_statReport("PMPterms","var") = f_var(f_cur, x, p_statReport("varCostAve","meanEst"));
p_statReport("PMPterms","sd") = f_sd(f_cur, x, p_statReport("varCostAve","meanEst"));




EXECUTE_UNLOAD "%resdir%\estimation\stats_%parFileName%.gdx" p_statReport;
