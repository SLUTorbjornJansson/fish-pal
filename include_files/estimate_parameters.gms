$ONTEXT

    @purpose: Perform estimations of behavioural and economic parameters of the fishery model.

    @author: Torbjörn Jansson, Staffan Waldo

    @date: 2013-09-23

    @calledby: prototyp.gms

$OFFTEXT

DISPLAY "Starting estimation of parameters";

ACRONYMS betaDens "Beta density", gammaDensity "Gamma density", normalDensity "Normal density";

PARAMETERS
    p_mu "Approximation parameter for complementary slackness" /0/
    n "Sequence number for smooth approximation"
    usePenalty "Flag if penalty function is to be used" /0/
    p_useApproximation1 "Set to 1 if the first approximation algorith is to be used" /0/
    p_useApproximation2 "Set to 1 if the second approximation algorith is to be used" /1/
    p_initialFree "Initial solution without any complementary slackness" /0/
    p_weightvarCostAve(fishery)   "Weight in estimation metric of variable cost errors"
    p_weightEffortAnnual(fishery) "Weight in estimation metric of annual effort deviations"
    p_weightLandings(fishery,species)"Weight in estimation metric of landing deviations"
    p_weightDiscards(fishery,species)"Weight in estimation metric of discard deviations"
    p_weightKwh(segment) "Weight of kwh errors in normal density"
    p_priMaxEffFishery(*,f) "Prior density function items for the fishery effort restriction"
    p_priorLandings(fishery,species,*) "Prior statistics for Landings"
    p_priorDiscards(fishery,species,*) "Prior statistics for Discards"
    p_priorKwh(segment,*) "Prior statistics for kwh per vessel"
    ;

EQUATIONS
*   Equations for calibration and estimation
    e_estimationMetric              "Statistical metric to optimize"
    e_focEffortAnnual(fishery)      "First order conditions w.r.t. effortAnnual"
    e_focCatch(fishery,species)     "First order conditions w.r.t. catch"
    e_focCpue(fishery,species)      "First order conditions w.r.t. cpue"
    e_focSortA(fishery,species)     "First order conditions w.r.t. sortA"
    e_focSortB(fishery,species)     "First order conditions w.r.t. sortB"

    e_variableCostSumSeg(seg)       "Require that the estimated total variable cost per segment exactly matches the observed total variable cost"

    e_csEffRestrSeg(segment) "Complementary slackness conditions for effRestrSeg and its dual variable"
    e_csEffRestrFishery(fishery) "Complementary slackness conditions for effRestrFishery and its dual variable"
    e_csCatchQuota(catchQuotaName,quotaArea) "Complementary slackness conditions for catchQuota and its dual variable"
    e_csEffNonNeg(fishery)   "Complementary slackness conditions for lower bound (non-neg) on effort and the associated dual variable"
    e_csSortANonNeg(fishery,species) "Complementary slackness conditions for lower bound (non-neg) on sortA"
    e_csSortBNonNeg(fishery,species) "Complementary slackness conditions for lower bound (non-neg) on sortB"
    e_csEffortRegulation(effortGroup,area) "Compl slackness for effort regulation"

    e_penalty "Penalty function used in smooth approximation to complementary slackness"
;

VARIABLES

*   Variables used in calibration / estimation
    v_estimationMetric "Statistical metric to optimize"
    v_lambdaCpue(fishery,species) "Dual value of e_cpue"
    v_lambdaCatch(fishery,species) "Dual value of e_catch"
    v_lambdaEffRestrSeg(segment) "Dual value of e_effRestrSeg"
    v_lambdaEffRestrFishery(fishery) "Dual value of e_effRestrFishery"
    v_lambdaCatchQuota(catchQuotaName,quotaArea) "Dual value of e_catchQuota"
    v_lambdaSortA(fishery,species) "Dual value of e_sortA (marginal value of this sort)"
    v_lambdaSortB(fishery,species) "Dual value of e_sortB (marginal value of this sort)"
    v_lambdaEffNonNeg(fishery) "Dual value of lower bound on effort (non-negativity)"
    v_lambdaEffortRegulation(effortGroup,area) "Dual value of effort regulation"

    v_csCatchQuota(catchQuotaName,quotaArea) Violation of quota complementary slackness
    v_csEffNonNeg(fishery) Violation of non-negativity compl slackness
    v_csEffRestrFishery(fishery) Violation of fishery effort restriction compl slackness
    v_csEffRestrSeg(segment) Violation of segment effort restriction compl slackess
    v_csEffortRegulation(effortGroup,area) "Violation of effort regulation compl slackness"
    v_penalty

;

POSITIVE VARIABLES v_lambdaEffRestrSeg,v_lambdaEffRestrFishery,v_lambdaCatchQuota,
                  v_lambdaEffNonNeg,v_lambdaSortANonNeg,v_lambdaSortBNonNeg,v_lambdaEffortRegulation;



*-------------------------------------------------------------------------------
*   Implementation of equations for estimation / calibration
*-------------------------------------------------------------------------------

e_estimationMetric ..
    v_estimationMetric*[CARD(f)+CARD(f)+SUM(fishery_species(f,s),1)]
        =E=
*   Variable cost sum as deviation from distribution mean (observed value)
    -SUM(f, SQR(v_varCostAve(f)-p_varCostAveOri(f))*p_weightvarCostAve(f))

    -SUM(seg, SQR(pv_kwh(seg)-p_kwhOri(seg))*p_weightKwh(seg))

*   Hårdkodat antagande om att variansen av PMP-kostnaden/intäkten är sådan att en standardavvikelse är ca 100 kr/dag (0.1 tkr)
    -SUM(f, SQR(pv_PMPconst(f) + 1/2*pv_PMPslope(f)*v_effortAnnual(f)))/2*sqr(0.1)

*   Annual effort should be "close" to observed effort
    -SUM(f, SQR(v_effortAnnual(f)-p_effortOri(f))*p_weightEffortAnnual(f))

*   Estimated landings should be "close" to observed landings
    -SUM((f,s) $ [fishery_species(f,s) and (p_priorLandings(f,s,"priDens") eq normalDensity)],
        SQR[v_landings(f,s) - p_landingsOri(f,s)] * p_weightLandings(f,s))

    +SUM((f,s) $ [fishery_species(f,s) and (p_priorLandings(f,s,"priDens") eq gammaDensity)],
          +(p_priorLandings(f,s,"priAlpha")-1)*LOG( v_landings(f,s))
          - p_priorLandings(f,s,"priBeta")*(v_landings(f,s))
          )

*   Estimated discards close to observed (or rather, exogenously estimated) discards
    -SUM((f,s) $ [fishery_species(f,s) and (p_priorDiscards(f,s,"priDens") eq normalDensity) and (not p_landingObligation(f,s))],
        SQR[v_discards(f,s)- p_discardsOri(f,s)] * p_weightDiscards(f,s))

    +SUM((f,s) $ [fishery_species(f,s) and (p_priorDiscards(f,s,"priDens") eq gammaDensity) and (not p_landingObligation(f,s))],
          +(p_priorDiscards(f,s,"priAlpha")-1)*LOG(v_discards(f,s))
          - p_priorDiscards(f,s,"priBeta")*v_discards(f,s)
          )

*   Estimated discards should be "close" to observed discards
*    -SUM((f,s) $ fishery_species(f,s), SQR[(1-p_landingObligation(f,s))*v_sortB(f,s)
*                                           -p_discardsOri(f,s)] * p_weightDiscards(f,s))

*   Deviations of quotas from official quotas is governed by the adjustment factor, originally = 1
    -SUM((catchQuotaName,quotaArea) $ (p_TACOri(catchQuotaName,quotaArea) GT 0), SQR(pv_TACAdjustment(catchQuotaName,quotaArea)-1))

*   Fishery season length is assumed to be beta distributed. Penalty is the log of the beta density.
    +SUM(f $ (p_priMaxEffFishery("priDens",f) EQ betaDens),
         (p_priMaxEffFishery("priAlpha",f)-1)*LOG(  (pv_maxEffFishery(f)-p_priMaxEffFishery("priMin",f))/p_priMaxEffFishery("priScale",f))
        +(p_priMaxEffFishery("priBeta",f) -1)*LOG(1-(pv_maxEffFishery(f)-p_priMaxEffFishery("priMin",f))/p_priMaxEffFishery("priScale",f)))

*   Add penalty for violating complementary slackness (if this feature is activated)
    - v_penalty $ [usePenalty AND (p_mu GT 0) AND (p_initialFree NE 1)]
;

e_penalty $ usePenalty ..
    v_penalty*p_mu =E=

*   Total violation of quota compl. slackness
    SUM((catchQuotaName,quotaArea) $ (p_TACOri(catchQuotaName,quotaArea) GT 0), v_csCatchQuota(catchQuotaName,quotaArea))

*   Total violation of non-negativity compl. slackness
    +SUM(f, v_csEffNonNeg(f))

*   Total violation of effort restriction per fishery compl. slackness
    +SUM(f, v_csEffRestrFishery(f))

*   Total violation of effort restriction per segment compl. slackness
    +SUM(seg, v_csEffRestrSeg(seg))

*   Total violation of effort regulation compl slackness
    +SUM((effortGroup,area) $ p_maxEffortPerEffortGroup(effortGroup,area), v_csEffortRegulation(effortGroup,area))


;

e_focEffortAnnual(f) $ [p_effortOri(f) GT 0] .. // Only build this equation if effort is nonzero in the data
    + p_subsidyPerDAS(f)
    - (pv_varCostConst(f) + pv_varCostSlope(f)*v_effortAnnual(f))
    - (pv_PMPconst(f) + pv_PMPslope(f)*v_effortAnnual(f))
    + SUM(s $ fishery_species(f,s), v_lambdaCatch(f,s)*pv_delta(f,s)*[p_catchElasticity(f)*v_effortAnnual(f)**(p_catchElasticity(f)-1)])
    - SUM(seg $ segment_fishery(seg,f), v_lambdaEffRestrSeg(seg))
    + v_lambdaEffNonNeg(f)
    - v_lambdaEffRestrFishery(f)
    - SUM((effortGroup,area) $ [fishery_effortGroup(f,effortGroup) and fishery_area(f,area) and p_maxEffortPerEffortGroup(effortGroup,area)],
        v_lambdaEffortRegulation(effortGroup,area) * sum(seg $ segment_fishery(seg,f), pv_kwh(seg)))

    =E= 0;

e_focCatch(f,s) $ fishery_species(f,s) .. // Generate this equation for fishery-species combinations that are possible (permissible)
    - v_lambdaCatch(f,s) + v_lambdaSortA(f,s)*p_shareA(f,s) + v_lambdaSortB(f,s)*p_shareB(f,s) =E= 0;

e_focSortA(f,s) $ fishery_species(f,s) .. // Generate this equation for fishery-species combinations that are possible (permissible)
    p_pricesAOri(f,s) - v_lambdaSortA(f,s)
*   Consider the cost of quota rent, but only if there is actually a quota for the species and area combination
    - SUM((catchQuotaName,quotaArea) $ (catchQuotaName_quotaArea_fishery_species(catchQuotaName,quotaArea,f,s)
                                  AND (p_TACOri(catchQuotaName,quotaArea) GT 0)), v_lambdaCatchQuota(catchQuotaName,quotaArea))
    =E= 0;

e_focSortB(f,s) $ fishery_species(f,s) .. // Generate this equation for fishery-species combinations that are possible (permissible)
    p_pricesBOri(s)*p_landingObligation(f,s) - v_lambdaSortB(f,s)
*   Consider the cost of quota rent, but only if there is actually a quota for the species and area combination
    - SUM((catchQuotaName,quotaArea) $ (catchQuotaName_quotaArea_fishery_species(catchQuotaName,quotaArea,f,s)
                                  AND (p_TACOri(catchQuotaName,quotaArea) GT 0)), p_landingObligation(f,s)*v_lambdaCatchQuota(catchQuotaName,quotaArea))
    =E= 0;


* --- Require that the estimated total variable cost per segment exactly matches the observed total variable cost
*     This equation is only needed when estimating; afterwards, variable costs are fixed.
e_variableCostSumSeg(seg) ..
    SUM(f $ segment_fishery(seg,f), v_varCostAve(f)*v_effortAnnual(f))
    =E=
    SUM(f $ segment_fishery(seg,f), p_varCostAveOri(f)*p_effortOri(f));


* --- Complementary slackness conditions follow below.

e_csEffRestrSeg(seg) ..
    [v_vessels(seg)*p_maxEffSeg(seg) - SUM(f $ segment_fishery(seg,f), v_effortAnnual(f))]*v_lambdaEffRestrSeg(seg)
    =L= v_csEffRestrSeg(seg);


e_csEffRestrFishery(f) ..
    [SUM(seg $ segment_fishery(seg,f), v_vessels(seg))*pv_maxEffFishery(f) - v_effortAnnual(f)]*v_lambdaEffRestrFishery(f)
    =L= v_csEffRestrFishery(f);

e_csEffortRegulation(effortGroup,area) $ p_maxEffortPerEffortGroup(effortGroup,area) ..
    (p_maxEffortPerEffortGroup(effortGroup,area) - v_effortPerEffortGroup(effortGroup,area))
    *v_lambdaEffortRegulation(effortGroup,area)
        =L=
    v_csEffortRegulation(effortGroup,area);


e_csCatchQuota(catchQuotaName,quotaArea) $ (p_TACOri(catchQuotaName,quotaArea) GT 0) ..
    [p_TACOri(catchQuotaName,quotaArea)*pv_TACAdjustment(catchQuotaName,quotaArea)
    - SUM((f,s) $ catchQuotaName_quotaArea_fishery_species(catchQuotaName,quotaArea,f,s), v_landings(f,s))
     ]*v_lambdaCatchQuota(catchQuotaName,quotaArea)
    =L= v_csCatchQuota(catchQuotaName,quotaArea);


e_csEffNonNeg(f) ..
    v_effortAnnual(f)*v_lambdaEffNonNeg(f)
    =L= v_csEffNonNeg(f);



*-------------------------------------------------------------------------------
*   Declare models
*-------------------------------------------------------------------------------

MODEL m_estimateFish "Estimation model used to determine levels of the parameters so that the model calibrates close to observed data " /

*   Objective function
    e_estimationMetric
    e_penalty

*   Primal model constraints must be satisfied
    e_catch,e_sortA,e_sortB,e_landings,e_discards,e_effRestrSeg,e_effRestrFishery,e_catchQuota,e_effortPerEffortGroup,e_effortRegulation,

*   First order conditions
    e_focEffortAnnual,e_focCatch,e_focSortA,e_focSortB,

*   Consistency of costs
*    e_variableCostSumSeg,

*   Complementary slackness conditions
    e_csEffRestrFishery,e_csEffRestrSeg,e_csCatchQuota,
    e_csEffNonNeg,e_csEffortRegulation

*   Reporting equations are also needed
    m_reportingEquations
    /;


m_estimateFish.HOLDFIXED = 1;  // Replace fixed variables with parameters when solving model, reducing problem size (and hiding in list file!)
m_estimateFish.LIMROW = 10000;  // Allow up to 1000 equations to be shown in list file
m_estimateFish.LIMCOL = 10000;  // Allow up to 1000 variables to be shown in list file
m_estimateFish.OPTFILE = 1;  // Include steering info for conopt (conopt.opt), setting e.g. log frequency


*##############################################################################
* CALCULATION OF PARAMETER VALUES FOR MODEL
*##############################################################################


*   Add up effort per fishery to efforts per segments
p_effortOri(seg) = SUM(f $ segment_fishery(seg,f), p_effortOri(f));

*   Each fishery assumed to have the same variable cost as the segment average
p_varCostOri(f,varCost) = SUM(seg $ segment_fishery(seg,f), p_costOri(seg,varCost)/p_effortOri(seg));
p_varCostAveOri(f) = SUM(varCost, p_varCostOri(f,varCost));


*  Fix costs are in annual totals in the database, but we need per vessel cost
p_fixCostOri(seg,fixCost) = p_costOri(seg,fixCost)/p_vesselsOri(seg);
p_fixCostSumOri(seg) = SUM(fixCost, p_fixCostOri(seg,fixCost));


*  Compute maximum possible number of fishing days per vessel and year in each fishery using
*   a) Segment capacity per period (per vessel), and
*   b) fishery season information (1 if period is season, else 0)

p_maxEffSeg(seg) = SUM(p, SMAX[f $ segment_fishery(seg,f), p_maxEffSegPeriod(seg,p)*p_season(f,p)]);


*  Define shares of sortA and sortB depending on discards, landings and landingObligation

if(sum((f,s), p_landingObligation(f,s)) ne 0,
    display "No data is available to distinguish between sortA and sortB with landingObligation.";
    abort "It is presently not possible to estimate the model with landingobligation";
else
    p_shareA(f,s) $ p_catchOri(f,s) = p_landingsOri(f,s)/p_catchOri(f,s);
    p_shareB(f,s) $ p_catchOri(f,s) = p_discardsOri(f,s)/p_catchOri(f,s);
);


*###############################################################################
*   Define priors
*###############################################################################

set fsTemp(f,s) "Permissible combinations in current computation";

* --- Define priors for landings
fsTemp(fishery_species) = no;
fsTemp(fishery_species) $ p_landingsOri(fishery_species) = yes;
p_priorLandings(fsTemp,"priMode") = p_landingsOri(fsTemp);
p_priorLandings(fsTemp,"priAcc") = 5;
p_priorLandings(fsTemp,"priDens") = normalDensity;

p_priorLandings(f,s,"priStdev") $ fsTemp(f,s)
    = p_landingsOri(f,s)
*    = sum(fishery, p_landingsOri(fishery,s))
*    / sum(fishery $ p_landingsOri(fishery,s), 1)
    / p_priorLandings(f,s,"priAcc");
p_priorLandings(fsTemp,"priVar") = SQR(p_priorLandings(fsTemp,"priStdev"));
p_priorLandings(fsTemp,"priTemp") $ [p_priorLandings(fsTemp,"priDens") eq gammaDensity]
        = {sqr(p_priorLandings(fsTemp,"priMode")) +
            sqrt[sqr(p_priorLandings(fsTemp,"priMode"))
                    *( sqr(p_priorLandings(fsTemp,"priMode"))
                       + 4*p_priorLandings(fsTemp,"priVar")) ] }
        /(2*p_priorLandings(fsTemp,"priVar") );
;
    p_priorLandings(fsTemp,"priAlpha") $ [p_priorLandings(fsTemp,"priDens") eq gammaDensity]
        = p_priorLandings(fsTemp,"priTemp") + 1;

    p_priorLandings(fsTemp,"priBeta") $ [p_priorLandings(fsTemp,"priDens") eq gammaDensity]
        = p_priorLandings(fsTemp,"priTemp") / p_priorLandings(fsTemp,"priMode");

p_priorLandings(fsTemp,"priMin") $ [p_priorLandings(fsTemp,"priDens") eq gammaDensity] = p_priorLandings(fsTemp,"priMode")*0.0001;

* --- Define priors for discards
fsTemp(fishery_species) = no;
fsTemp(fishery_species) $ p_discardsOri(fishery_species) = yes;

p_priorDiscards(fsTemp,"priMode") = p_discardsOri(fsTemp);
p_priorDiscards(fsTemp,"priAcc") = 2;
p_priorDiscards(fsTemp,"priDens") = normalDensity;

p_priorDiscards(f,s,"priStdev") $ fsTemp(f,s)
    = sum(fishery, p_discardsOri(fishery,s))
    / sum(fishery $ p_discardsOri(fishery,s), 1)
    / p_priorDiscards(f,s,"priAcc");
p_priorDiscards(fsTemp,"priVar") = SQR(p_priorDiscards(fsTemp,"priStdev"));
p_priorDiscards(fsTemp,"priTemp") $ [p_priorDiscards(fsTemp,"priDens") eq gammaDensity]
        = {sqr(p_priorDiscards(fsTemp,"priMode")) +
            sqrt[sqr(p_priorDiscards(fsTemp,"priMode"))
                    *( sqr(p_priorDiscards(fsTemp,"priMode"))
                       + 4*p_priorDiscards(fsTemp,"priVar")) ] }
        /(2*p_priorDiscards(fsTemp,"priVar") );
;
    p_priorDiscards(fsTemp,"priAlpha") $ [p_priorDiscards(fsTemp,"priDens") eq gammaDensity]
        = p_priorDiscards(fsTemp,"priTemp") + 1;

    p_priorDiscards(fsTemp,"priBeta") $ [p_priorDiscards(fsTemp,"priDens") eq gammaDensity]
        = p_priorDiscards(fsTemp,"priTemp") / p_priorDiscards(fsTemp,"priMode");

p_priorDiscards(fsTemp,"priMin") $ [p_priorDiscards(fsTemp,"priDens") eq gammaDensity] = p_priorDiscards(fsTemp,"priMode")*0.0001;

*   Define prior distribution for fishery effort restriction
*   Compute maximum possible number of fishing days per vessel and year in each fishery using
*   a) Segment capacity per period (per vessel), and
*   b) fishery season information (1 if period is season, else 0)
p_priMaxEffFishery("priMode",f) = SUM((p,seg) $ segment_fishery(seg,f), p_maxEffSegPeriod(seg,p)*p_season(f,p));
p_priMaxEffFishery("priMax",f) = SUM((p,seg) $ segment_fishery(seg,f), 365/12*p_season(f,p));
p_priMaxEffFishery("priMin",f) = SUM((p,seg) $ segment_fishery(seg,f), 0*p_season(f,p));

*   Define a measure of the "peakiness" of the density function. Ideally, we would like to
*   use something like the variance of the actual number of effective fishing days per
*   vessel in season. In the wake of such info, we need one other piece of information instead (namely THIS).
p_priMaxEffFishery("priAcc",f) = 5;
p_priMaxEffFishery("priDens",f) = betaDens;

*       - Compute alpha and beta, see illustrative excel sheet on beta density
*           (assuming "accuracy"+2 = alpha+beta so that accuracy = 0 implies uniform density)
p_priMaxEffFishery("priScale",f) = p_priMaxEffFishery("priMax",f)-p_priMaxEffFishery("priMin",f);

p_priMaxEffFishery("priAlpha",f) = (p_priMaxEffFishery("priMode",f)-p_priMaxEffFishery("priMin",f))/p_priMaxEffFishery("priScale",f)*((2+p_priMaxEffFishery("priAcc",f))-2)+1;
p_priMaxEffFishery("priBeta",f)  = (2+p_priMaxEffFishery("priAcc",f))-p_priMaxEffFishery("priAlpha",f);


p_priorKwh(seg,"priMode") = p_kwhOri(seg);
p_priorKwh(seg,"priAcc") = 3;
p_priorKwh(seg,"priDens") = normalDensity;
p_priorKwh(seg,"priStdev") = p_priorKwh(seg,"priMode")/p_priorKwh(seg,"priAcc");
p_priorKwh(seg,"priVar") = SQR(p_priorKwh(seg,"priStdev"));


*###############################################################################
*   SKATTA MODELLPARAMETRARNA
*   Steg 1: hitta en startpunkt (särskilt för komplementaritetsvillkoren!)
*           över huvud taget genom att lösa den primala modellen
*
*   Steg 2: gör en snabb optimering av skattningen, som bara ger en approximation.
*
*
*###############################################################################

* STEG 1:
*   Prices are original prices
p_pricesA(f,s) = p_pricesAOri(f,s);
p_pricesB(s)   = p_pricesBOri(s);

*   If quota exists, initialize adjustment factor to "1"
pv_TACAdjustment.L(catchQuotaName,quotaArea)  $ (p_TACOri(catchQuotaName,quotaArea) GT 0) = 1;


* --- Definiera parametrar till kostnadsfunktionen. Hur det går till beror på funktionsform.
*     Nedan antar vi en kvadratisk totalkostnad, dvs linjär marginalkostnad, och låter skattningen
*     bestämma intercept men inte lutning.
*     Antagande: interceptet är ungefär halva den observerade genomsnittskostnaden.
*     om MC = a + b*E så innebär det att b = AC/E

*   Grundantagande: MC = AC (dvs interceptet = AC)
pv_varCostConst.l(f) = p_varCostAveOri(f)*1.0;
*   Här kan man prova att sätta t.ex. minskande MC för pelagiker, genom att sätta interceptet ÖVER AC
*   Genom att sätta inteceptet UNDER AC blir MC ökande
*pv_varCostConst.l(f) $ [segment_fishery("'pel_24XX'",f)
*                     or segment_fishery("'pel_0018'",f)
*                     or segment_fishery("'pel_1824'",f)]
*    = p_varCostAveOri(f)*1.1;
*   Räkna ut lutningen residualt
pv_varCostSlope.l(f) $ p_effortOri(f) = (p_varCostAveOri(f) - pv_varCostConst.l(f))*2 / p_effortOri(f);
v_varCostAve.l(f) = pv_varCostConst.l(f) + 1/2*p_effortOri(f)*pv_varCostSlope.l(f);


*   Assign catch elasticities of each fishery depending on the type of gear used
loop(gearGroup $ p_catchElasticityPerGearGroup(gearGroup),
    loop(gear $ gearGroup_gear(gearGroup,gear),
        p_catchElasticity(f) $ fishery_gear(f,gear) = p_catchElasticityPerGearGroup(gearGroup);
    );
);


*   Starting point for catch function scale is average CPUE.
pv_delta.L(f,s) = p_catchOri(f,s)*p_effortOri(f)**(-p_catchElasticity(f));


*   Set calibration term intercept to zero for a start
pv_PMPconst.L(f) = 0;

*   Slope has to be upward sloping
pv_PMPslope.L(f) = 1;

*   Initialize season length
pv_maxEffFishery.L(f) = p_priMaxEffFishery("priMode",f);

pv_kwh.L(seg) = p_kwhOri(seg);


*   Fix parameters for simulation
$INCLUDE "include_files\set_bounds_simulation.gms"

* --- Compute subsidy payments at initial point, to use in calibration
*     The computation depends on "effortAnnual", which is initialized in
*     set_bounds_simulation.gms
$INCLUDE "include_files\compute_subsidies.gms"


*   Test solve model at observed costs, catches and quotas
m_fishSim.iterlim = 10000;
m_fishSim.holdfixed = 0;
SOLVE m_fishSim USING NLP MAXIMIZING v_profit;
m_fishSim.iterlim = 100000;

* STEG 2:

*   Release parameters to estimate
$INCLUDE "include_files\set_bounds_estimation.gms"

*   --- Scale variables for solver to use internally. Does not require changing any equations!

*   Small catches get scaled up, large catches scaled down.
pv_delta.SCALE(f,s) $ p_catchOri(f,s) = p_catchOri(f,s)/p_effortOri(f);

*   Similar for fishing effort and catch
v_effortAnnual.SCALE(f) $ p_effortOri(f) = p_effortOri(f);
v_catch.SCALE(f,s) $ [p_effortOri(f)*p_catchOri(f,s)] = p_catchOri(f,s);

*   Tell solver that scaling is to be used
m_estimateFish.SCALEOPT = 1;



*   --- Define prior information for parameters (set weights to use in estimation metric)

*       For variable costs: assume normal distribution with mean "what we observe"...
*       ... and variance ASSUMED to be such that 2 standard deviations cover 1/2 of the mean in each direction
p_weightvarCostAve(f) $ p_varCostAveOri(f) = 1/(2*SQR(p_varCostAveOri(f)/4));

*   Similar for effort annual (but in this version it is not allowed to change in estimation)
p_weightEffortAnnual(f) $ p_effortOri(f) = 1/(2*SQR(p_effortOri(f)/4));

*   Landningar: Vikten för normalfördelningen är 1/(2*variansen). Här har vi ökat vikten med en faktor tio.
*p_weightLandings(f,s) $ p_landingsOri(f,s) = 10/(2*SQR(sum(fishery, p_landingsOri(f,s))/sum(fishery $ p_landingsOri(f,s), 1)/4));
p_weightLandings(f,s) $ p_landingsOri(f,s) = 10/(2*p_priorLandings(f,s,"priVar"));

*   Utkast: Vikten för normalfördelningen är 1/(2*variansen). Här har vi ökat vikten med en faktor tio.
p_weightDiscards(f,s) $ p_discardsOri(f,s) = 10/(2*p_priorDiscards(f,s,"priVar"));

p_weightKwh(seg) $ [p_priorKwh(seg,"priDens") EQ normalDensity]
    = 1/(2*p_priorKwh(seg,"priVar"));

execute_unload "%resdir%\check\priors_%parFileName%.gdx" p_weightvarCostAve p_weightEffortAnnual p_weightLandings p_weightDiscards p_weightKwh;

*   Oavsett hur tung kavel man har, så finns det lika mycket deg...

*   --- Initialize dual values to the existing solution obtained from the primal model in STEP 1
v_lambdaCatch.L(f,s) $ fishery_species(f,s) = e_catch.M(f,s);
v_lambdaSortA.L(f,s) $ fishery_species(f,s) = p_shareA(f,s)*e_catch.M(f,s);
v_lambdaSortB.L(f,s) $ fishery_species(f,s) = p_shareB(f,s)*e_catch.M(f,s);
v_lambdaEffRestrSeg.L(seg) = e_effRestrSeg.M(seg);
v_lambdaEffRestrFishery.L(f) = e_effRestrFishery.M(f);
v_lambdaCatchQuota.L(catchQuotaName,quotaArea) = e_catchQuota.M(catchQuotaName,quotaArea);
v_lambdaEffNonNeg.L(f) = -v_effortAnnual.M(f); // The primal model has a ">" restriction, so the sign must be reversed compared with our dual notation
v_estimationMetric.L = 1;

*   Use the following statement to do just one iteration of the estimation, to see if
*   the model solution above satisfies the optimality conditions (i.e. if we have
*   written the equations correctly and initialized all variables at feasible values)
*   (This only works if effortAnnual is not fixed to observed values in estimation.)
*m_estimateFish.ITERLIM = 0;
*SOLVE m_estimateFish USING NLP MAXIMIZING v_estimationMetric;
*$stop

*   --- För att hitta en bra startpunkt till MINLP-problemet (som löses med BARON),
*       så gör vi först en approximation, där vi introducerar komplementaritesvillkoren
*       stegvis. Först tillåter vi att x*y < my (om x > 0 och y > 0 är variabler), och låter
*       så my gå från ett stort positivt tal mot noll. När my = 0 så är komplementaritetsvillkoren
*       exakt uppfyllda. Denna algoritm, hur stort my är från början, etc, måste provas in manuellt.


* --- With complementarity constraints and mu
IF(p_useApproximation1,
    m_estimateFish.SOLPRINT = 2;
    p_mu = 100000; usePenalty = 0;
    FOR(n = 1 TO 10,
        SOLVE m_estimateFish USING NLP MAXIMIZING v_estimationMetric; //CNS = Constrained Nonlinear System of equations, i.e. no objective
*       The estimator may change catch. We need to re-compute subsidies in order to get
*       perfect calibration.
        $$INCLUDE "include_files\compute_subsidies.gms"

        p_mu = p_mu/3;
        v_csCatchQuota.UP(catchQuotaName,quotaArea) = p_mu;
        v_csEffNonNeg.UP(fishery)                 = p_mu;

        v_csEffRestrFishery.UP(fishery)           = p_mu;
        v_csEffRestrSeg.UP(segment)               = p_mu;
    );

    p_mu = 0;
    v_csCatchQuota.UP(catchQuotaName,quotaArea) = p_mu;
    v_csEffNonNeg.UP(fishery)                 = p_mu;
    v_csEffRestrFishery.UP(fishery)           = p_mu;
    v_csEffRestrSeg.UP(segment)               = p_mu;
    m_estimateFish.SOLPRINT = 1;

    SOLVE m_estimateFish USING NLP MAXIMIZING v_estimationMetric;
    DISPLAY "Utan penalty, my=0, slutlig: ", v_estimationMetric.L;


* --- Check if we get an identical solution with penalty function and mu=0
    usePenalty = 1;
    m_estimateFish.SOLPRINT = 2;
    SOLVE m_estimateFish USING NLP MAXIMIZING v_estimationMetric;
    DISPLAY "Initial try med penalty, my=0 (initierad av förra lösningen): ", v_estimationMetric.L;
);


* --- With penalty function and mu
if(p_useApproximation2,
* --- With increasingly smaller mu
    p_mu = 1000; usePenalty = 1; p_initialFree = 0;
    v_csCatchQuota.UP(catchQuotaName,quotaArea) = INF;
    v_csEffNonNeg.UP(fishery)                 = INF;
    v_csEffRestrFishery.UP(fishery)           = INF;
    v_csEffRestrSeg.UP(segment)               = INF;

*   No solver output for intermediate smooth approximations
    m_estimateFish.SOLPRINT                   = 2;
    FOR(n = 1 TO 10,
        SOLVE m_estimateFish USING NLP MAXIMIZING v_estimationMetric; //CNS = Constrained Nonlinear System of equations, i.e. no objective

*       The estimator may change catch. We need to re-compute subsidies in order to get
*       perfect calibration.
        $$INCLUDE "include_files\compute_subsidies.gms"

        p_mu = p_mu/2;
        p_initialFree = 0;
        DISPLAY p_mu,v_estimationMetric.L;
    );

*   Final estimation with strict complementarity and full solver output
    p_mu = 0;
    m_estimateFish.SOLPRINT = 1;
    SOLVE m_estimateFish USING NLP MAXIMIZING v_estimationMetric;
    DISPLAY "Final try med penalty, my=0: ", v_estimationMetric.L;
);


* --- Estimated catch may deviate from observed catch. Therefore,
*     spending on subsidy may deviate from allocated budget in the database.
*     To obtain calibration, we adjust subsidy budget accordingly.

p_subsidyBudget = sum(f, p_subsidyPerDAS(f)*v_effortAnnual.L(f));

*$SETGLOBAL scenario %scenario%

*-------------------------------------------------------------------------------
*   Spara parametrarna i en datafil, att använda i simulation
*-------------------------------------------------------------------------------

EXECUTE_UNLOAD "%resdir%\estimation\par_%parFileName%.gdx"
                                                p_pricesA
                                                p_pricesB
                                                p_shareA
                                                p_shareB
                                                pv_varCostConst
                                                pv_varCostSlope
                                                p_fixCostSumOri
                                                pv_PMPconst
                                                pv_PMPslope
                                                pv_delta
                                                p_catchElasticity
                                                p_maxEffSeg
                                                pv_maxEffFishery
                                                p_TACOri
                                                pv_TACAdjustment
                                                pv_kwh
                                                p_landingObligation
                                                p_varCostOri
                                                p_subsidyBudget;


*-------------------------------------------------------------------------------
*   Skapa en rapport med skattningsresultat
*-------------------------------------------------------------------------------

*   Rapportera EFFORT
p_fiskResultat(f,"allSpecies","v_effortAnnual","ori") = p_effortOri(f);
p_fiskResultat(f,"allSpecies","v_effortAnnual","est") = v_effortAnnual.L(f);
p_fiskResultat(f,"allSpecies","v_effortAnnual","M") = v_effortAnnual.M(f);

*   Rapportera catch
p_fiskResultat(f,s,"v_catch","ori") = p_catchOri(f,s);
p_fiskResultat(f,s,"v_catch","est") = v_catch.L(f,s);
p_fiskResultat(f,s,"v_catch","M") = v_catch.M(f,s);

*   Rapportera sortA, sortB, landings och discards
p_fiskResultat(f,s,"v_sortA","est") = v_sortA.L(f,s);
p_fiskResultat(f,s,"v_sortB","est") = v_sortB.L(f,s);
p_fiskResultat(f,s,"v_landings","ori") = p_landingsOri(f,s);
p_fiskResultat(f,s,"v_landings","est") = v_sortA.L(f,s)+p_landingObligation(f,s)*v_sortB.L(f,s);
p_fiskResultat(f,s,"v_discards","ori") = p_discardsOri(f,s);
p_fiskResultat(f,s,"v_discards","est") = (1-p_landingObligation(f,s))*v_sortB.L(f,s);


*   Rapportera catchDist
p_fiskResultat(f,s,"pv_delta","ori") = p_catchOri(f,s)*p_effortOri(f)**(-p_catchElasticity(f));
p_fiskResultat(f,s,"pv_delta","est") = pv_delta.L(f,s);
p_fiskResultat(f,s,"pv_delta","M") = pv_delta.M(f,s);

*   Rapportera målfunktionens värde
p_fiskResultat("total","allSpecies","v_estimationMetric","est") = v_estimationMetric.L;


*   Rapportera kostnader
p_fiskResultat(f,"allSpecies","v_varCostAve","ori") = p_varCostAveOri(f);
p_fiskResultat(f,"allSpecies","v_varCostAve","est") = v_varCostAve.L(f);
p_fiskResultat(f,"allSpecies","v_varCostAve","M") = v_varCostAve.M(f);

*   Rapportera kvoter
p_fiskResultat(quotaArea,catchQuotaName,"p_TACOri","ori") = p_TACOri(catchQuotaName,quotaArea);
p_fiskResultat(quotaArea,catchQuotaName,"p_TACOri","est")
    = p_TACOri(catchQuotaName,quotaArea)*pv_TACAdjustment.L(catchQuotaName,quotaArea);

*   Rapportera efforrestriktion per fishery
p_fiskResultat(f,"allSpecies","pv_maxEffFishery","ori") = p_priMaxEffFishery("priMode",f);
p_fiskResultat(f,"allSpecies","pv_maxEffFishery","est") = pv_maxEffFishery.L(f);

*   Rapportera skattning av effekt per segment (kwh)
p_fiskResultat(seg,"allSpecies","pv_kwh","ori") = p_kwhOri(seg);
p_fiskResultat(seg,"allSpecies","pv_kwh","est") = pv_kwh.L(seg);


*   Rapportera nyttjande av effektreglering
p_fiskResultat(effortGroup,area,"v_effortPerEffortGroup","ori") $ p_maxEffortPerEffortGroup(effortGroup,area)
  = sum(f $ [fishery_effortGroup(f,effortGroup) and fishery_area(f,area)],
                    p_effortOri(f) * sum(seg $ segment_fishery(seg,f), p_kwhOri(seg))) ;
p_fiskResultat(effortGroup,area,"v_effortPerEffortGroup","est") = v_effortPerEffortGroup.L(effortGroup,area);
p_fiskResultat(effortGroup,area,"v_effortPerEffortGroup","M") = e_effortPerEffortGroup.M(effortGroup,area);
p_fiskResultat(effortGroup,area,"v_effortPerEffortGroup","UP") = p_maxEffortPerEffortGroup(effortGroup,area);


*   Aggregera fishery till segment etc, men bara för aggregaten, inte för enskilda fishery
p_fiskResultat(fisheryDomain,speciesDomain,addVars,addStat) $ [NOT p_fiskResultat(fisheryDomain,speciesDomain,addVars,addStat)]
    = SUM(fishery $ fisheryDomain_fishery(fisheryDomain,fishery), p_fiskResultat(fishery,speciesDomain,addVars,addStat));


*   Spara resultaten i en fil

EXECUTE_UNLOAD "%resdir%\estimation\res_estimation.gdx" p_fiskResultat p_priMaxEffFishery;


