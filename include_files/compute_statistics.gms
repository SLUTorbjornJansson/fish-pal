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
    mse     Mean Squared Error
    rmse    Root MSE
    wmse    Weighted MSE
    rwmse   Root WMSE
    var     Variance of deviations from mean
    cov     Covariance of estimates with observations
    sxy     Sum of cross product of errors
    ssx     Sum of squared deviations
    corrP   Pearson correlation of estimates with observations
    /;

parameter p_statReport(param,allStats) "Statistics of estimates";

set f_s_cur(fishery,species) "Fisheries and species to consider";
set f_cur(fishery) "Fisheries to consider in some current computation";

parameter x(fisheryDomain) Some data to compute statistics for;
parameter y(fisheryDomain) Some data to compute statistics for;
parameter u(fishery,species) Some 2 dimensional parameter to compute stats for;

*-------------------------------------------------------------------------------
* --- Some statistical formulae will be repeated for several symbols.
*     Simplify coding by working with macro-statements

* MACRO for arithmetic mean
$macro g_mean(i,x) sum(i, x(i))/card(i)

* MACRO for Pearson correlation coefficient
$macro g_corrP(i,x,mx,y,my) sum(i, (x(i)-mx)*(y(i)-my))  \
                           /sqrt(sum(i, sqr(x(i)-mx)))   \
                           /sqrt(sum(i, sqr(y(i)-my)))

$macro g_var(i,x,mx) sum(i, sqr(x(i)-mx))/(card(i)-1)
$macro g_sd(i,x,mx) sqrt(g_var(i,x,mx))

* MACRO for mean squared error, assuming u is the vector of errors indexed by i
$macro g_mse(i,u) sum(i, sqr(u(i)))/card(i)
$macro g_rmse(i,u) sqrt(g_mse(i,u))

* MACRO for weighted mean squared error,
*   assuming u is the vector of errors, w weights, both indexed by i
$macro g_wmse(i,u,w) sum(i, w(i)*sqr(u(i)))/card(i)
$macro g_rwmse(i,u,w) sqrt(g_wmse(i,u,w))


*-------------------------------------------------------------------------------
*   Computing the various statistics:
*-------------------------------------------------------------------------------

* --- For landings

f_s_cur(f,s)
    = yes $ [fishery_species(f,s) and p_priorLandings(f,s,"priDens")];

p_statReport("landings","n")
    = card(f_s_cur);


p_statReport("landings","meanEst") = g_mean(f_s_cur, v_landings.l);
p_statReport("landings","meanObs") = g_mean(f_s_cur, p_landingsOri);

p_statReport("landings","corrP")
  = g_corrP(f_s_cur, v_landings.l, p_statReport("landings","meanEst"), p_landingsOri, p_statReport("landings","meanObs"));

* Compute various mean square errors, using macros.
* u = the errors
u(f_s_cur) = v_landings.l(f_s_cur) - p_landingsOri(f_s_cur);

p_statReport("landings","mse") = g_mse(f_s_cur,u);
p_statReport("landings","rmse") = g_rmse(f_s_cur,u);
p_statReport("landings","wmse") = g_wmse(f_s_cur,u,p_weightLandings);
p_statReport("landings","rwmse") = g_rwmse(f_s_cur,u,p_weightLandings);


*-------------------------------------------------------------------------------
* --- For discards

f_s_cur(f,s)
    = yes $ [fishery_species(f,s) and p_priorDiscards(f,s,"priDens")];

p_statReport("discards","n")
    = card(f_s_cur);

p_statReport("discards","meanEst") = g_mean(f_s_cur, v_discards.l);
p_statReport("discards","meanObs") = g_mean(f_s_cur, p_discardsOri);

p_statReport("discards","corrP")
  = g_corrP(f_s_cur, v_discards.l, p_statReport("discards","meanEst"), p_discardsOri, p_statReport("discards","meanObs"));

* Compute various mean square errors, using macros.
* u = the errors
u(f_s_cur) = v_discards.l(f_s_cur) - p_discardsOri(f_s_cur);

p_statReport("discards","mse") = g_mse(f_s_cur,u);
p_statReport("discards","rmse") = g_rmse(f_s_cur,u);
p_statReport("discards","wmse") = g_wmse(f_s_cur,u,p_weightDiscards);
p_statReport("discards","rwmse") = g_rwmse(f_s_cur,u,p_weightDiscards);


*-------------------------------------------------------------------------------
* --- For varCostAve

f_cur(f) = yes $ p_weightvarCostAve(f);

p_statReport("varCostAve","n")
    = card(f_cur);

p_statReport("varCostAve","meanEst") = g_mean(f_cur, v_varCostAve.l);
p_statReport("varCostAve","meanObs") = g_mean(f_cur, p_varCostAveOri);

p_statReport("varCostAve","corrP")
  = g_corrP(f_cur, v_varCostAve.l, p_statReport("varCostAve","meanEst"), p_varCostAveOri, p_statReport("varCostAve","meanObs"));

* Compute various mean square errors, using macros.
* x = the errors
x(f_cur) = v_varCostAve.l(f_cur) - p_varCostAveOri(f_cur);

p_statReport("varCostAve","mse") = g_mse(f_cur,x);
p_statReport("varCostAve","rmse") = g_rmse(f_cur,x);
p_statReport("varCostAve","wmse") = g_wmse(f_cur,x,p_weightvarCostAve);
p_statReport("varCostAve","rwmse") = g_rwmse(f_cur,x,p_weightvarCostAve);


*-------------------------------------------------------------------------------
* --- For PMP-terms

f_cur(f) = yes $ p_weightPMP(f);

p_statReport("PMPterms","n")
    = card(f_cur);

x(f_cur) = pv_PMPconst.l(f_cur) + 1/2*pv_PMPslope.l(f_cur)*v_effortAnnual.l(f_cur);
p_statReport("PMPterms","meanEst") = g_mean(f_cur, x);
p_statReport("PMPterms","var") = g_var(f_cur, x, p_statReport("varCostAve","meanEst"));
p_statReport("PMPterms","sd") = g_sd(f_cur, x, p_statReport("varCostAve","meanEst"));

* Compute various mean square errors, using macros.
* x = the errors (marginal PMP = error in FOC, the square of which is minimized)

p_statReport("PMPterms","mse") = g_mse(f_cur,x);
p_statReport("PMPterms","rmse") = g_rmse(f_cur,x);
p_statReport("PMPterms","wmse") = g_wmse(f_cur,x,p_weightPMP);
p_statReport("PMPterms","rwmse") = g_rwmse(f_cur,x,p_weightPMP);


*-------------------------------------------------------------------------------
* --- For kwh per segment
set seg_cur(segment) Current set of segments;
seg_cur(seg) = yes $ p_weightKwh(seg);

p_statReport("kwh","n")
    = card(seg_cur);

p_statReport("kwh","meanEst") = g_mean(seg_cur, pv_kwh.l);
p_statReport("kwh","meanObs") = g_mean(seg_cur, p_kwhOri);

p_statReport("kwh","corrP")
  = g_corrP(seg_cur, pv_kwh.l, p_statReport("kwh","meanEst"), p_kwhOri, p_statReport("kwh","meanObs"));

* Compute various mean square errors, using macros.
* x = the errors
x(seg_cur) = pv_kwh.l(seg_cur) - p_kwhOri(seg_cur);

p_statReport("kwh","mse") = g_mse(seg_cur,x);
p_statReport("kwh","rmse") = g_rmse(seg_cur,x);
p_statReport("kwh","wmse") = g_wmse(seg_cur,x,p_weightKwh);
p_statReport("kwh","rwmse") = g_rwmse(seg_cur,x,p_weightKwh);



*-------------------------------------------------------------------------------
* --- For annual fishing effort
f_cur(f) = yes $ p_weightEffortAnnual(f);
p_statReport("effortAnnual","n")
    = card(f_cur);

p_statReport("effortAnnual","meanEst") = g_mean(f_cur, v_effortAnnual.l);
p_statReport("effortAnnual","meanObs") = g_mean(f_cur, p_effortOri);

p_statReport("effortAnnual","corrP")
  = g_corrP(f_cur, v_effortAnnual.l, p_statReport("effortAnnual","meanEst"), p_effortOri, p_statReport("effortAnnual","meanObs"));

* Compute various mean square errors, using macros.
* x = the errors
x(f_cur) = v_effortAnnual.l(f_cur) - p_effortOri(f_cur);

p_statReport("effortAnnual","mse") = g_mse(f_cur,x);
p_statReport("effortAnnual","rmse") = g_rmse(f_cur,x);
p_statReport("effortAnnual","wmse") = g_wmse(f_cur,x,p_weightEffortAnnual);
p_statReport("effortAnnual","rwmse") = g_rwmse(f_cur,x,p_weightEffortAnnual);



*-------------------------------------------------------------------------------
* --- For the restriction on fishing season days maxEffFishery
*   Fishery season length is assumed to be beta distributed. Penalty is the log of the beta density.
*    +SUM(f $ (p_priMaxEffFishery("priDens",f) EQ betaDens),
*         (p_priMaxEffFishery("priAlpha",f)-1)*LOG(  (pv_maxEffFishery(f)-p_priMaxEffFishery("priMin",f))/p_priMaxEffFishery("priScale",f))
*        +(p_priMaxEffFishery("priBeta",f) -1)*LOG(1-(pv_maxEffFishery(f)-p_priMaxEffFishery("priMin",f))/p_priMaxEffFishery("priScale",f)))

f_cur(f) = yes $ p_priMaxEffFishery("priDens",f);
p_statReport("maxEffFishery","n")
    = card(f_cur);

*   Copy data to parameters to simplify the use of macros. Let x = estimates, y = prior mode, obs.
x(f_cur) = pv_maxEffFishery.l(f_cur);
y(f_cur) = p_priMaxEffFishery("priMode",f_cur);

p_statReport("maxEffFishery","meanEst") = g_mean(f_cur, x);
p_statReport("maxEffFishery","meanObs") = g_mean(f_cur, y);

p_statReport("maxEffFishery","corrP")
  = g_corrP(f_cur, x, p_statReport("maxEffFishery","meanEst"), y, p_statReport("maxEffFishery","meanObs"));

* Compute various mean square errors, using macros.
* x = the errors, y the weights, computed based on prior standard deviations
x(f_cur) = pv_maxEffFishery.l(f_cur) - p_priMaxEffFishery("priMode",f_cur);
*   This is now a beta density. We still use weights as if it were a normal one,
*   based on weights = 1/(2*variance). Accuracy = mode/sdev, leads to
*   weight = 1 / (2*sqr(mode/accuracy))
y(f_cur) = 1/[2*sqr(p_priMaxEffFishery("priMode",f_cur)/p_priMaxEffFishery("priAcc",f_cur))];

p_statReport("maxEffFishery","mse") = g_mse(f_cur,x);
p_statReport("maxEffFishery","rmse") = g_rmse(f_cur,x);
p_statReport("maxEffFishery","wmse") = g_wmse(f_cur,x,y);
p_statReport("maxEffFishery","rwmse") = g_rwmse(f_cur,x,y);



EXECUTE_UNLOAD "%resdir%\estimation\stats_%parFileName%.gdx" p_statReport;
