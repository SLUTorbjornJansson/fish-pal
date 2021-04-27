$ONTEXT

    @purpose: Compute descriptive statistics of estimates, based on criterion

    @author: Torbjörn Jansson

    @date: 2019-12-12

    @calledby: estimate_parameters.gms

$OFFTEXT

scalar p_dollar_per_sek "Exchange rate for reporting in dollar" /0.147592762/;

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
    sdEst   Standard deviation from mean of estimates
    sdObs   Standard deviation from mean of observations
    msd     Mean Squared Deviation
    rmsd    Root MSD
    mswd    Mean Squared Weighted Deviation
    rmswd   Root mswd
    nrmsd   Normalized RMSD
    var     Variance of deviations from mean
    cov     Covariance of estimates with observations
    sxy     Sum of cross product of errors
    ssx     Sum of squared deviations
    PCC   Pearson correlation of estimates with observations
    /;

parameter p_statReport(param,allStats) "Statistics of estimates";
parameter p_statReportD(param,allStats) "Statistics of estimates in dollar";

set f_s_cur(fishery,species) "Fisheries and species to consider";
set f_cur(fishery) "Fisheries to consider in some current computation";

parameter x(fisheryDomain) Some data to compute statistics for;
parameter y(fisheryDomain) Some data to compute statistics for;
parameter u(fishery,species) Some 2 dimensional parameter to compute stats for;
parameter v(fishery,species) Some 2 dimensional parameter to compute stats for;

*-------------------------------------------------------------------------------
* --- Some statistical formulae will be repeated for several symbols.
*     Simplify coding by working with macro-statements

* MACRO for arithmetic mean
$macro g_mean(i,x) sum(i, x(i))/card(i)

* MACRO for Pearson correlation coefficient
$macro g_PCC(i,x,mx,y,my) sum(i, (x(i)-mx)*(y(i)-my))  \
                           /sqrt(sum(i, sqr(x(i)-mx)))   \
                           /sqrt(sum(i, sqr(y(i)-my)))

$macro g_var(i,x,mx) sum(i, sqr(x(i)-mx))/(card(i)-1)
$macro g_sd(i,x,mx) sqrt(g_var(i,x,mx))

* MACRO for mean squared deviations,
*  assuming u is the vector of deviations indexed by i
$macro g_msd(i,u) sum(i, sqr(u(i)))/card(i)
$macro g_rmsd(i,u) sqrt(g_msd(i,u))

* MACRO for mean squared weighted deviations,
*   assuming u is the vector of deviations, w weights = 1/VAR(y), both indexed by i
$macro g_mswd(i,u,w) sum(i, w(i)*sqr(u(i)))/card(i)
$macro g_rmswd(i,u,w) sqrt(g_mswd(i,u,w))


* MACRO for (mean) normalized mean squared deviations,
*   assuming u is the vector of deviations, y the "observations" to normailze by,
*   both indexed by i

$macro g_nrmsd(i,x,y) g_rmsd(i,x)/(g_mean(i,y))
*/( smax[i, y(i)] - smin[i, y(i)] )


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

p_statReport("landings","sdEst") = g_sd(f_s_cur,v_landings.l,p_statReport("landings","meanEst"));
p_statReport("landings","sdObs") = g_sd(f_s_cur,p_landingsOri,p_statReport("landings","meanObs"));

p_statReport("landings","PCC")
  = g_PCC(f_s_cur, v_landings.l, p_statReport("landings","meanEst"), p_landingsOri, p_statReport("landings","meanObs"));

* Compute various mean square errors, using macros.
* u = the errors, v the variance (recall: weight in estimator = 1/(2*var) )
u(f_s_cur) = v_landings.l(f_s_cur) - p_landingsOri(f_s_cur);
v(f_s_cur) = p_weightLandings(f_s_cur)*2;

p_statReport("landings","msd") = g_msd(f_s_cur,u);
p_statReport("landings","rmsd") = g_rmsd(f_s_cur,u);
p_statReport("landings","mswd") = g_mswd(f_s_cur,u,v);
p_statReport("landings","rmswd") = g_rmswd(f_s_cur,u,v);
p_statReport("landings","nrmsd") = g_nrmsd(f_s_cur,u,p_landingsOri);


*-------------------------------------------------------------------------------
* --- For discards

f_s_cur(f,s)
    = yes $ [fishery_species(f,s) and p_priorDiscards(f,s,"priDens")];

p_statReport("discards","n")
    = card(f_s_cur);

p_statReport("discards","meanEst") = g_mean(f_s_cur, v_discards.l);
p_statReport("discards","meanObs") = g_mean(f_s_cur, p_discardsOri);

p_statReport("discards","PCC")
  = g_PCC(f_s_cur, v_discards.l, p_statReport("discards","meanEst"), p_discardsOri, p_statReport("discards","meanObs"));

* Compute various mean square errors, using macros.
* u = the errors
u(f_s_cur) = v_discards.l(f_s_cur) - p_discardsOri(f_s_cur);
v(f_s_cur) = p_weightDiscards(f_s_cur)*2;

p_statReport("discards","msd") = g_msd(f_s_cur,u);
p_statReport("discards","rmsd") = g_rmsd(f_s_cur,u);
p_statReport("discards","mswd") = g_mswd(f_s_cur,u,v);
p_statReport("discards","rmswd") = g_rmswd(f_s_cur,u,v);
p_statReport("discards","nrmsd") = g_nrmsd(f_s_cur,u,p_discardsOri);

*-------------------------------------------------------------------------------
* --- For varCostAve

f_cur(f) = yes $ p_weightvarCostAve(f);

p_statReport("varCostAve","n")
    = card(f_cur);

p_statReport("varCostAve","meanEst") = g_mean(f_cur, v_varCostAve.l);
p_statReport("varCostAve","meanObs") = g_mean(f_cur, p_varCostAveOri);

p_statReport("varCostAve","sdEst") = g_sd(f_cur, v_varCostAve.l, p_statReport("varCostAve","meanEst"));
p_statReport("varCostAve","sdObs") = g_sd(f_cur, p_varCostAveOri, p_statReport("varCostAve","meanObs"));

p_statReport("varCostAve","PCC")
  = g_PCC(f_cur, v_varCostAve.l, p_statReport("varCostAve","meanEst"), p_varCostAveOri, p_statReport("varCostAve","meanObs"));

* Compute various mean square errors, using macros.
* x = the errors, y the variances
x(f_cur) = v_varCostAve.l(f_cur) - p_varCostAveOri(f_cur);
y(f_cur) = p_weightvarCostAve(f_cur)*2;

p_statReport("varCostAve","msd") = g_msd(f_cur,x);
p_statReport("varCostAve","rmsd") = g_rmsd(f_cur,x);
p_statReport("varCostAve","mswd") = g_mswd(f_cur,x,y);
p_statReport("varCostAve","rmswd") = g_rmswd(f_cur,x,y);
p_statReport("varCostAve","nrmsd") = g_nrmsd(f_cur,x,p_varCostAveOri);


* --- Report selected items in dollar

* Compute various mean square errors, using macros.
* x = the errors, y the variances
x(f_cur) = v_varCostAve.l(f_cur)*p_dollar_per_sek;
y(f_cur) = p_varCostAveOri(f_cur)*p_dollar_per_sek;

p_statReportD("varCostAve","meanEst") = g_mean(f_cur, x);
p_statReportD("varCostAve","meanObs") = g_mean(f_cur, y);

p_statReportD("varCostAve","sdEst") = g_sd(f_cur, x, p_statReportD("varCostAve","meanEst"));
p_statReportD("varCostAve","sdObs") = g_sd(f_cur, y, p_statReportD("varCostAve","meanObs"));

p_statReportD("varCostAve","PCC")
  = g_PCC(f_cur, x, p_statReportD("varCostAve","meanEst"), y, p_statReportD("varCostAve","meanObs"));

x(f_cur) = (v_varCostAve.l(f_cur) - p_varCostAveOri(f_cur))*p_dollar_per_sek;
y(f_cur) = p_weightvarCostAve(f_cur)*2/sqr(p_dollar_per_sek);

p_statReportD("varCostAve","msd") = g_msd(f_cur,x);
p_statReportD("varCostAve","rmsd") = g_rmsd(f_cur,x);
p_statReportD("varCostAve","mswd") = g_mswd(f_cur,x,y);
p_statReportD("varCostAve","rmswd") = g_rmswd(f_cur,x,y);
p_statReportD("varCostAve","nrmsd") = g_nrmsd(f_cur,x,p_varCostAveOri);



*-------------------------------------------------------------------------------
* --- For PMP-terms

f_cur(f) = yes $ p_weightPMP(f);

p_statReport("PMPterms","n")
    = card(f_cur);

x(f_cur) = pv_PMPconst.l(f_cur) + 1/2*pv_PMPslope.l(f_cur)*v_effortAnnual.l(f_cur);
p_statReport("PMPterms","meanEst") = g_mean(f_cur, x);
p_statReport("PMPterms","var") = g_var(f_cur, x, p_statReport("PMPterms","meanEst"));
p_statReport("PMPterms","sdEst") = g_sd(f_cur, x, p_statReport("PMPterms","meanEst"));

* Compute various mean square errors, using macros.
* x = the errors (marginal PMP = error in FOC, the square of which is minimized)
* y = the prior variances
y(f_cur) = p_weightPMP(f_cur)*2;

p_statReport("PMPterms","msd") = g_msd(f_cur,x);
p_statReport("PMPterms","rmsd") = g_rmsd(f_cur,x);
p_statReport("PMPterms","mswd") = g_mswd(f_cur,x,y);
p_statReport("PMPterms","rmswd") = g_rmswd(f_cur,x,y);

* compute normalized rmsd normalized by the mean of estimated marginal revenues
y(f) = p_subsidyPerDAS(f)
 + SUM(s $ fishery_species(f,s), v_lambdaCatch.l(f,s)*pv_delta.l(f,s)*[p_catchElasticity(f)*v_effortAnnual.l(f)**(p_catchElasticity(f)-1)]);

p_statReport("PMPterms","nrmsd") = g_nrmsd(f_cur,x,y);

* --- report selected items in dollars
y(f_cur) = p_weightPMP(f_cur)*2/sqr(p_dollar_per_sek);
x(f_cur) = (pv_PMPconst.l(f_cur) + 1/2*pv_PMPslope.l(f_cur)*v_effortAnnual.l(f_cur))*p_dollar_per_sek;

p_statReportD("PMPterms","meanEst") = g_mean(f_cur, x);
p_statReportD("PMPterms","var") = g_var(f_cur, x, p_statReportD("PMPterms","meanEst"));
p_statReportD("PMPterms","sdEst") = g_sd(f_cur, x, p_statReportD("PMPterms","meanEst"));
p_statReportD("PMPterms","msd") = g_msd(f_cur,x);
p_statReportD("PMPterms","rmsd") = g_rmsd(f_cur,x);
p_statReportD("PMPterms","mswd") = g_mswd(f_cur,x,y);
p_statReportD("PMPterms","rmswd") = g_rmswd(f_cur,x,y);

y(f) = (p_subsidyPerDAS(f)
 + SUM(s $ fishery_species(f,s), v_lambdaCatch.l(f,s)*pv_delta.l(f,s)*[p_catchElasticity(f)*v_effortAnnual.l(f)**(p_catchElasticity(f)-1)])
    )*p_dollar_per_sek;

p_statReportD("PMPterms","nrmsd") = g_nrmsd(f_cur,x,y);

*-------------------------------------------------------------------------------
* --- For kwh per segment
set seg_cur(segment) Current set of segments;
seg_cur(seg) = yes $ p_weightKwh(seg);

p_statReport("kwh","n")
    = card(seg_cur);

p_statReport("kwh","meanEst") = g_mean(seg_cur, pv_kwh.l);
p_statReport("kwh","meanObs") = g_mean(seg_cur, p_kwhOri);

p_statReport("kwh","PCC")
  = g_PCC(seg_cur, pv_kwh.l, p_statReport("kwh","meanEst"), p_kwhOri, p_statReport("kwh","meanObs"));

* Compute various mean square errors, using macros.
* x = the errors
x(seg_cur) = pv_kwh.l(seg_cur) - p_kwhOri(seg_cur);
y(seg_cur) = p_weightKwh(seg_cur)*2;

p_statReport("kwh","msd") = g_msd(seg_cur,x);
p_statReport("kwh","rmsd") = g_rmsd(seg_cur,x);
p_statReport("kwh","mswd") = g_mswd(seg_cur,x,y);
p_statReport("kwh","rmswd") = g_rmswd(seg_cur,x,y);
p_statReport("kwh","nrmsd") = g_nrmsd(seg_cur,x,p_kwhOri);


*-------------------------------------------------------------------------------
* --- For annual fishing effort
f_cur(f) = yes $ p_weightEffortAnnual(f);
p_statReport("effortAnnual","n")
    = card(f_cur);

p_statReport("effortAnnual","meanEst") = g_mean(f_cur, v_effortAnnual.l);
p_statReport("effortAnnual","meanObs") = g_mean(f_cur, p_effortOri);

p_statReport("effortAnnual","PCC")
  = g_PCC(f_cur, v_effortAnnual.l, p_statReport("effortAnnual","meanEst"), p_effortOri, p_statReport("effortAnnual","meanObs"));

* Compute various mean square errors, using macros.
* x = the errors, y the prior variances
x(f_cur) = v_effortAnnual.l(f_cur) - p_effortOri(f_cur);
y(f_cur) = p_weightEffortAnnual(f_cur);

p_statReport("effortAnnual","msd") = g_msd(f_cur,x);
p_statReport("effortAnnual","rmsd") = g_rmsd(f_cur,x);
p_statReport("effortAnnual","mswd") = g_mswd(f_cur,x,y);
p_statReport("effortAnnual","rmswd") = g_rmswd(f_cur,x,y);
p_statReport("effortAnnual","nrmsd") = g_nrmsd(f_cur,x,p_effortOri);



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

p_statReport("maxEffFishery","sdEst") = g_sd(f_cur, x, p_statReport("maxEffFishery","meanEst"));
p_statReport("maxEffFishery","sdObs") = g_sd(f_cur, y, p_statReport("maxEffFishery","meanObs"));

p_statReport("maxEffFishery","PCC")
  = g_PCC(f_cur, x, p_statReport("maxEffFishery","meanEst"), y, p_statReport("maxEffFishery","meanObs"));

* Compute various mean square errors, using macros.
* x = the errors, y the weights, computed based on prior standard deviations
x(f_cur) = pv_maxEffFishery.l(f_cur) - p_priMaxEffFishery("priMode",f_cur);
*   This is now a beta density. Accuracy = mode/sdev, leads to
*   weight = 1 / (sqr(mode/accuracy))
y(f_cur) = 1/[sqr(p_priMaxEffFishery("priMode",f_cur)/p_priMaxEffFishery("priAcc",f_cur))];

p_statReport("maxEffFishery","msd") = g_msd(f_cur,x);
p_statReport("maxEffFishery","rmsd") = g_rmsd(f_cur,x);
p_statReport("maxEffFishery","mswd") = g_mswd(f_cur,x,y);
p_statReport("maxEffFishery","rmswd") = g_rmswd(f_cur,x,y);

y(f_cur) = p_priMaxEffFishery("priMode",f_cur);
p_statReport("maxEffFishery","nrmsd") = g_nrmsd(f_cur,x,y);



EXECUTE_UNLOAD "%resdir%\estimation\stats_%parFileName%.gdx" p_statReport p_statReportD;
