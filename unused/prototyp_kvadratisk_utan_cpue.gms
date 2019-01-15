$EOLCOM //
$SETLOCAL datDir %SYSTEM.FP%inputfiles

DISPLAY "datDir = %datDir%";

*#############################################################
*           CONVERT EXCEL DATA FILE TO GAMS GDX FORMAT
*#############################################################

$CALL gdxxrw %datDir%\data_gams_TJ_121113.xlsx o=%datDir%\inData.gdx index=index!A1

* Öppna GDX-filen vi skapade från Excel ovan
$GDXIN %datDir%\inData.gdx



*##############################################################################
* GET THE BASELINE DATA FROM THE DATABASE
*##############################################################################


* Definiera primära set, som är byggstenar för alla andra set i modellen
SETS
    segment     "Fartygstyp"
    metier      "Redskap, målart och maskstorlek"
    area        "Geografisk"
    species     "Fiskart och användning"
    period      "Del av kalenderår"

*   Convenient subsets and tuples (combinations of elements belonging together)
    fishery     "Permissible combination of segment, metier and area"
    quotaArea   "Catch quota regions"
    quotaSpecies "Species used in quota definition, which are sometimes aggregates of species"

*   Cost items
    varCost     "Variable cost items"
    fixCost     "Fixed cost items"

*   Distributional statistics for random variables used in estimation
    distStat    "Distributional statistics for random variables used in estimation"
        /mean "Mean", var "Variance", fit "Fitted value"/
;

ALIAS(segment,seg);
ALIAS(metier,m);
ALIAS(area,a);
ALIAS(species,s);
ALIAS(period,p);
*ALIAS(fishery,f);


* Läs in set från GDX-filen
$LOAD segment metier area species fishery quotaArea varCost fixCost period quotaSpecies

SETS
    f_seg_m_a(fishery,segment,metier,area)  "Fiskart och användning"
    quotaArea_area(quotaArea,area)          "Composition of quota regions in terms of geographical regions"
    quotaSpecies_species(quotaSpecies,s)    "Composition of quota regions in terms of geographical regions"
    segment_fishery(segment,fishery)        "Segment to which each fishery belongs"
    fishery_species(fishery,species)        "Species that can be caught within fishery"
    quotaArea_fishery(quotaArea,fishery)    "Quota area in which each fishery is active"
    f(fishery)                              "Fishery to include in model";

* Läs in tuples från GDX-filen
$LOAD f_seg_m_a quotaArea_area quotaSpecies_species

PARAMETERS
    p_prices(fishery,species)   "Price of fish per fishery and species"
    p_varCost(fishery,varCost)  "Variable cost per fishery and cost category"
    p_varCostSumDist(fishery,distStat) "Distributional statistics for sum of variable costs"
    p_fixCost(segment,fixCost)  "Fixed cost per vessel and cost category"
    p_fixCostSum(segment)       "Fixed cost per vessel"
    p_maxEffSegPeriod(seg,p)    "Max effort per segment and period (days per vessel)"
    p_maxEffSeg(seg)            "Maximum possible number of fishing days per segment and year (days per vessel)"
    p_maxEffFishery(fishery)    "Max effort per fishery and period (days per vessel)"
    p_season(fishery,period)    "Fishery season (fishery possible)"
    p_TAC_MOD(quotaSpecies,quotaArea) "Total Allowable Catch per species and area"
    p_catchDistKilograms(fishery,species)"Catch of different species per unit of effort of each fishery (kg/day)"
    p_catchDist(fishery,species)"Catch of different species per unit of effort of each fishery (tons/day)"
    p_catchIntercept(fishery)   "Intercept of marginal catch function"
    p_catchSlope(fishery)       "Slope term of marginal catch function"
    p_effort2009(fishery)       "Total effort per fishery registered in base data"
    p_vessels2009(segment)      "Total number of vessels per segment in base data"
    p_profit2009(fishery,*)     "Average profit per fishery in base data"
    p_mu "Approximation parameter for complementary slackness"

    p_weightVarCostSum(fishery)   "Weight in estimation metric of variable cost errors"
    p_weightEffortAnnual(fishery) "Weight in estimation metric of annual effort deviations"
    p_weightCatch(fishery,species)"Weight in estimation metric of catch deviations"
    ;

* Läs in parametrar
$LOAD p_prices p_varCost p_fixCost p_maxEffSegPeriod p_season p_TAC_MOD
$LOAD p_catchDistKilograms p_effort2009 p_vessels2009


* Stäng GDX-filen genom att anropa GDXIN utan argument
$GDXIN



*##############################################################################
*  DEFINE HANDY SETS THAT FACILITATE MODELLING LATER ON
*##############################################################################

* Limit number of fisheries
f(fishery) = YES;

* Find out which segment carries out which fishery
* (=true if the number of metiers and areas in which the segment carries out the fishery is >0)
segment_fishery(seg,f) = SUM((m,a) $ f_seg_m_a(f,seg,m,a), 1);

* Find out in which quota areas each fishery is active, useful in restrictions
quotaArea_fishery(quotaArea,f) = SUM((m,seg,a) $ (quotaArea_area(quotaArea,a) AND f_seg_m_a(f,seg,m,a)), 1);

* Define which species can be caught within a fishery, based on observed catch and by-catch
fishery_species(fishery,species) = YES $ p_catchDistKilograms(fishery,species);


DISPLAY      segment_fishery   ,  quotaArea_fishery, fishery_species;
*$exit


*##############################################################################
*   CLEANSING OF DATA TO TAKE OUT "OBVIOUS PROBLEMS"
*   This is specific to current data file used!
*##############################################################################

*   If there are no vessels, then there should be no fishing in that segment
LOOP(segment $ [p_vessels2009(segment) EQ 0],
    p_effort2009(fishery) $ segment_fishery(segment,fishery) = 0;
);


*#############################################################
*            DEFINE MODEL VARIABLES AND EQUATIONS
*#############################################################

*$stop

EQUATIONS
*   Primal model equations
    e_objFunc "Objective function"
    e_catch(fishery,species)        "Catch of each fishery of each species"
    e_CPUE(fishery,species)         "Function defining average catch per unit of effort"
    e_effRestrSeg(segment)          "Restriction on fishing effort per segment"
    e_effRestrFishery(fishery)      "Restriction on fishing effort per fishery"
    e_catchQuota(quotaSpecies,quotaArea) "Catch quotas per species and quota area"

*   Equations for calibration and estimation
    e_estimationMetric              "Statistical metric to optimize"
    e_focEffortAnnual(fishery)      "First order conditions w.r.t. effortAnnual"
    e_focCatch(fishery,species)     "First order conditions w.r.t. catch"
    e_focCpue(fishery,species)      "First order conditions w.r.t. cpue"

    e_csEffRestrSeg(segment) "Complementary slackness conditions for effRestrSeg and its dual variable"
    e_csEffRestrFishery(fishery) "Complementary slackness conditions for effRestrFishery and its dual variable"
    e_csCatchQuota(quotaSpecies,quotaArea) "Complementary slackness conditions for catchQuota and its dual variable"
    e_csEffNonNeg(fishery)   "Complementary slackness conditions for lower bound (non-neg) on effort and the associated dual variable"

    e_csEffRestrSegBinLambda(segment) "Binary version of complementary slackness conditions for effRestrSeg and its dual variable: fixing lambda"
    e_csEffRestrFisheryBinLambda(fishery) "Binary version of complementary slackness conditions for effRestrFishery and its dual variable: fixing lambda"
    e_csCatchQuotaBinLambda(quotaSpecies,quotaArea) "Binary version of complementary slackness conditions for catchQuota and its dual variable: fixing lambda"
    e_csEffNonNegBinLambda(fishery)   "Binary version of complementary slackness conditions for lower bound (non-neg) on effort and the associated dual variable: fixing lambda"

    e_csEffRestrSegBinSlack(segment) "Binary version of complementary slackness conditions for effRestrSeg and its dual variable: fixing slack"
    e_csEffRestrFisheryBinSlack(fishery) "Binary version of complementary slackness conditions for effRestrFishery and its dual variable: fixing slack"
    e_csCatchQuotaBinSlack(quotaSpecies,quotaArea) "Binary version of complementary slackness conditions for catchQuota and its dual variable: fixing slack"
    e_csEffNonNegBinSlack(fishery)   "Binary version of complementary slackness conditions for lower bound (non-neg) on effort and the associated dual variable: fixing slack"

    ;


VARIABLES
*   Primal model variables
    v_profit                        "Profits of fishery sector"
    pv_varCostSum(fishery)          "Variable cost"
    v_effortAnnual(fishery)         "Annual fishing effort per fishery"
    v_catch(fishery,species)        "Catch per fishery and species"
    v_CPUE(fishery,species)         "Average catch per unit of effort (annual)"
    v_vessels(segment)              "Number of vessels per segment, determining fixed costs"
    pv_TACAdjustment(quotaSpecies,quotaArea) "Adjustment of quotas needed to fit to catches from observed fishing efforts"
    pv_delta(fishery,species)       "Scale of Cobb-Douglas production function, or rather: if catch=a*E^b1*S^b2, then delta=a*S^b2"

*   Variables used in calibration / estimation
    v_estimationMetric "Statistical metric to optimize"
    v_lambdaCpue(fishery,species) "Dual value of e_cpue"
    v_lambdaCatch(fishery,species) "Dual value of e_catch"
    v_lambdaEffRestrSeg(segment) "Dual value of e_effRestrSeg"
    v_lambdaEffRestrFishery(fishery) "Dual value of e_effRestrFishery"
    v_lambdaCatchQuota(quotaSpecies,quotaArea) "Dual value of e_catchQuota"
    v_lambdaEffNonNeg(fishery) "Dual value of lower bound on effort (non-negativity)"

    v_effRestrSegIsBinding(segment) "Binary variable that determines if the effort restriction per segment is binding or not"
    v_effRestrFisheryIsBinding(Fishery) "Binary variable that determines if the effort restriction per fishery is binding or not"
    v_catchQuotaIsBinding(quotaSpecies,quotaArea) "Binary variable that determines if the quota restriction is binding or not"
    v_effNonNegIsBinding(fishery) "Binary variable that determines if effort is binding at zero level or not"
    ;

*   Effort and all dual values associated with inequality restrictions must be positive
POSITIVE VARIABLES v_effort,v_lambdaEffRestrSeg,v_lambdaEffRestrFishery,v_lambdaCatchQuota,v_lambdaEffNonNeg;

BINARY VARIABLES v_effRestrSegIsBinding, v_effRestrFisheryIsBinding, v_catchQuotaIsBinding, v_effNonNegIsBinding;

*v_lambdaEffSeason

*-------------------------------------------------------------------------------
*   Primal model implementation
*-------------------------------------------------------------------------------

e_objFunc ..
    v_profit =E=
*       Revenues
        SUM((f,s) $ fishery_species(f,s), p_prices(f,s)*v_catch(f,s))

*       minus variable costs
       -SUM(f, pv_varCostSum(f)*v_effortAnnual(f))

*       minus fixed costs
       -SUM(seg, p_fixCostSum(seg)*v_vessels(seg));


e_CPUE(f,s) $ fishery_species(f,s) ..

*   Average catch per unit of effort (in tons per day) is...
    v_CPUE(f,s) =E=

*   the fixed proportions of different species caught
*    p_catchDist(f,s)
    pv_delta(f,s)

*   times how catch changes (of all species) if effort changes
    *[p_catchIntercept(f) + 0.5*p_catchSlope(f)*v_effortAnnual(f)];


e_catch(f,s) $ fishery_species(f,s) ..
    v_catch(f,s) =E=

*   times how catch changes (of all species) if effort changes
    pv_delta(f,s)*p_catchIntercept(f)*v_effortAnnual(f) + 0.5*p_catchDist(f,s)*p_catchSlope(f)*SQR(v_effortAnnual(f)) ;


e_effRestrSeg(seg) ..

*   Sum of fishery efforts carried out by this segment
    SUM(f $ segment_fishery(seg,f), v_effortAnnual(f))
    =L=
*   Number of vessels in fleet times max effort per vessel
    v_vessels(seg)*p_maxEffSeg(seg);


e_effRestrFishery(f) ..

*   Begränsning på hur många fiskedagar varje fishery kan göra i varje period
*   Begränsningen beräknas utifrån säsong (månadsbasis) och antal fartyg och
*   fiskedagar hos flottan som gör detta fishery

    v_effortAnnual(f) =L= SUM(seg $ segment_fishery(seg,f), v_vessels(seg))*p_maxEffFishery(f);


*   Om fiske ska förbjudas helt, sätt kvoten till ngt litet positivt tal
*   Om ingen begränsning ska finnas, sätt kvoten till "0" (ingen kvot).
e_catchQuota(quotaSpecies,quotaArea) $ (p_TAC_MOD(quotaSpecies,quotaArea) GT 0) ..


*   Sum of catch for fishery active in the present area,
*    and all species caught that belong to this "quota species"
    SUM((f,s) $ (  quotaArea_fishery(quotaArea,f)
               AND quotaSpecies_species(quotaSpecies,s)
               AND fishery_species(f,s)),
            v_catch(f,s))
    =L=
*   Quota for this quota species in this quota area
    p_TAC_MOD(quotaSpecies,quotaArea)*pv_TACAdjustment(quotaSpecies,quotaArea);


*-------------------------------------------------------------------------------
*   Implementation of equations for estimation / calibration
*-------------------------------------------------------------------------------

e_estimationMetric ..
    v_estimationMetric
        =E=
*   Variable cost sum as deviation from distribution mean (observed value)
     SUM(f, SQR(pv_varCostSum(f)-p_varCostSumDist(f,"mean"))*p_weightVarCostSum(f))

*   Annual effort should be "close" to observed effort
    +SUM(f, SQR(v_effortAnnual(f)-p_effort2009(f))*p_weightEffortAnnual(f))

*   Annual catch should be "close" to observed catch
    +SUM((f,s), SQR(v_catch(f,s)-p_effort2009(f)*p_catchDistKilograms(f,s)/1000)*p_weightCatch(f,s))

*   Deviations of quotas from official quotas is governed by the adjustment factor, originally = 1
    +SUM((quotaSpecies,quotaArea) $ (p_TAC_MOD(quotaSpecies,quotaArea) GT 0), SQR(pv_TACAdjustment(quotaSpecies,quotaArea)-1));


e_focEffortAnnual(f) $ [v_effortAnnual.LO(f) LT v_effortAnnual.UP(f)] .. // Don't build this equation if effort is fixed
    -pv_varCostSum(f)
*    + SUM(s $ fishery_species(f,s), v_lambdaCpue(f,s)*pv_delta(f,s)*1/2*p_catchSlope(f))
    + SUM(s $ fishery_species(f,s), v_lambdaCatch(f,s)*[pv_delta(f,s)*p_catchIntercept(f) + p_catchDist(f,s)*p_catchSlope(f)*v_effortAnnual(f)])
    - SUM(seg $ segment_fishery(seg,f), v_lambdaEffRestrSeg(seg))
    + v_lambdaEffNonNeg(f)
    - v_lambdaEffRestrFishery(f)
    =E= 0;

e_focCatch(f,s) $ fishery_species(f,s) .. // Generate this equation for fishery-species combinations that are possible (permissible)
    p_prices(f,s) - v_lambdaCatch(f,s)
*   Consider the cost of quota rent, but only if there is actually a quota for the species and area combination
    - SUM((quotaSpecies,quotaArea) $ (quotaArea_fishery(quotaArea,f)
                                  AND quotaSpecies_species(quotaSpecies,s)
                                  AND (p_TAC_MOD(quotaSpecies,quotaArea) GT 0)), v_lambdaCatchQuota(quotaSpecies,quotaArea))
    =E= 0;

e_focCpue(f,s) $ fishery_species(f,s) .. // Generate this equation for fishery-species combinations that are possible (permissible)
    - v_lambdaCpue(f,s) + v_lambdaCatch(f,s)*v_effortAnnual(f)
     =E= 0;

* --- Complementary slackness conditions are tricky. We make two versions of each,
*     with the first version in the ordinary x*y=0 way, the second version in
*     a binary programming fashion with x < z*M, y < (1-z)*M with z binary and M something big.

e_csEffRestrSeg(seg) ..
    [v_vessels(seg)*p_maxEffSeg(seg) - SUM(f $ segment_fishery(seg,f), v_effortAnnual(f))]*v_lambdaEffRestrSeg(seg)
    =L= p_mu;

*   Binary version of complementary slackness: if <restriction> isBinding (=1),
*   then lambda is allowed to be large and positive, else it is limited to zero.
e_csEffRestrSegBinLambda(seg) ..
    v_lambdaEffRestrSeg(seg) =L= v_effRestrSegIsBinding(seg)*10E6;

e_csEffRestrSegBinSlack(seg) ..
    [v_vessels(seg)*p_maxEffSeg(seg) - SUM(f $ segment_fishery(seg,f), v_effortAnnual(f))] =L= (1-v_effRestrSegIsBinding(seg))*10E6;


* --- Complementary slackness conditions for effort restriction per fishery,
*     in ordinary multiplicative way and also using binary variables

e_csEffRestrFishery(f) ..
    [SUM(seg $ segment_fishery(seg,f), v_vessels(seg))*p_maxEffFishery(f) - v_effortAnnual(f)]*v_lambdaEffRestrFishery(f)
    =L= p_mu;

e_csEffRestrFisheryBinLambda(f) ..
    v_lambdaEffRestrFishery(f) =L= v_effRestrFisheryIsBinding(f)*10E6;

e_csEffRestrFisheryBinSlack(f) ..
    [SUM(seg $ segment_fishery(seg,f), v_vessels(seg))*p_maxEffFishery(f) - v_effortAnnual(f)] =L= (1-v_effRestrFisheryIsBinding(f))*10E6;



e_csCatchQuota(quotaSpecies,quotaArea) $ (p_TAC_MOD(quotaSpecies,quotaArea) GT 0) ..
    [p_TAC_MOD(quotaSpecies,quotaArea)
    - SUM((f,s) $ (quotaArea_fishery(quotaArea,f) AND quotaSpecies_species(quotaSpecies,s) AND fishery_species(f,s)), v_catch(f,s))
    ]*v_lambdaCatchQuota(quotaSpecies,quotaArea)
    =L= p_mu;

e_csCatchQuotaBinLambda(quotaSpecies,quotaArea) $ (p_TAC_MOD(quotaSpecies,quotaArea) GT 0) ..
    v_lambdaCatchQuota(quotaSpecies,quotaArea) =L= v_catchQuotaIsBinding(quotaSpecies,quotaArea)*10E6;

e_csCatchQuotaBinSlack(quotaSpecies,quotaArea) $ (p_TAC_MOD(quotaSpecies,quotaArea) GT 0) ..
    [p_TAC_MOD(quotaSpecies,quotaArea)
    - SUM((f,s) $ (quotaArea_fishery(quotaArea,f) AND quotaSpecies_species(quotaSpecies,s) AND fishery_species(f,s)), v_catch(f,s))]
    =L= (1-v_catchQuotaIsBinding(quotaSpecies,quotaArea))*10E6;



e_csEffNonNeg(f) ..
    v_effortAnnual(f)*v_lambdaEffNonNeg(f)
    =L= p_mu;

e_csEffNonNegBinLambda(f) ..
    v_lambdaEffNonNeg(f) =L= v_effNonNegIsBinding(f)*10E6;

e_csEffNonNegBinSlack(f) ..
    v_effortAnnual(f) =L= (1-v_effNonNegIsBinding(f))*10E6;


*$stop
*#############################################################
*            DEFINE MODEL
*#############################################################


MODEL m_fishSim "Primal simulation model with profit maximization"
*    /e_objFunc,e_CPUE,e_catch,e_effRestrSeg,e_effRestrFishery,e_catchQuota/;
    /e_objFunc,e_catch,e_effRestrSeg,e_effRestrFishery,e_catchQuota/;



m_fishSim.HOLDFIXED = 1;
m_fishSim.LIMROW = 300;

OPTION NLP=CONOPT;

MODEL m_estimateFish "Estimation model used to determine levels of the parameters so that the model calibrates close to observed data" /

*   Objective function
    e_estimationMetric

*   Primal model constraints must be satisfied
*    e_CPUE,e_catch,e_effRestrSeg,e_effRestrFishery,e_catchQuota,
    e_catch,e_effRestrSeg,e_effRestrFishery,e_catchQuota,

*   First order conditions
*    e_focEffortAnnual,e_focCatch,e_focCpue,
    e_focEffortAnnual,e_focCatch,

*   Complementary slackness conditions
    e_csEffRestrFishery,e_csEffRestrSeg,e_csCatchQuota,e_csEffNonNeg/;


m_estimateFish.HOLDFIXED = 1;  // Replace fixed variables with parameters when solving model, reducing problem size (and hiding in list file!)
m_estimateFish.LIMROW = 10000;  // Allow up to 1000 equations to be shown in list file
m_estimateFish.LIMCOL = 10000;  // Allow up to 1000 variables to be shown in list file
m_estimateFish.OPTFILE = 1;  // Include steering info for conopt (conopt.opt), setting e.g. log frequency


MODEL m_estimateFishBinary "Estimation model used to determine levels of the parameters so that the model calibrates close to observed data with binary representation of complementary slackness" /

*   Objective function
    e_estimationMetric

*   Primal model constraints must be satisfied
*    e_CPUE,e_catch,e_effRestrSeg,e_effRestrFishery,e_catchQuota,
    e_catch,e_effRestrSeg,e_effRestrFishery,e_catchQuota,

*   First order conditions
*    e_focEffortAnnual,e_focCatch,e_focCpue,
    e_focEffortAnnual,e_focCatch,

*   Complementary slackness conditions
    e_csEffRestrSegBinLambda,e_csEffRestrFisheryBinLambda,e_csCatchQuotaBinLambda,e_csEffNonNegBinLambda,
    e_csEffRestrSegBinSlack,e_csEffRestrFisheryBinSlack,e_csCatchQuotaBinSlack,e_csEffNonNegBinSlack
/;


m_estimateFishBinary.HOLDFIXED = 1;  // Replace fixed variables with parameters when solving model, reducing problem size (and hiding in list file!)
m_estimateFishBinary.LIMROW = 10000;  // Allow up to 1000 equations to be shown in list file
m_estimateFishBinary.LIMCOL = 10000;  // Allow up to 1000 variables to be shown in list file
m_estimateFishBinary.OPTFILE = 1;  // Use steering file for BARON solver (called baron.opt). In that file, we instruct BARON to use CONOPT for NLP part.

OPTION MINLP=BARON;

*##############################################################################
* CALCULATION OF PARAMETER VALUES FOR MODEL (CALCULATED AFTER POLICY CHANGES!)
*##############################################################################

*   Convert catch per day from kilograms to tons
p_catchDist(f,s) = p_catchDistKilograms(f,s) / 1000;


PARAMETERS
    p_varCostShock(varCost) "Shock to variable costs"
    p_fixCostShock(fixCost) "Shock to fix costs";

* Default: no change to baseline
p_varCostShock(varCost) = 1;
p_fixCostShock(fixCost) = 1;

*  10% increase in fuel price
* p_varCostShock("vc_fuel") = 1.10;

*  Don't use any variable labour cost
p_varCostShock("vc_labour") = 0;
p_varCostShock("vc_altLabour") = 0;


pv_varCostSum.L(fishery) = SUM(varCost, p_varCost(fishery,varCost)*p_varCostShock(varCost));
p_fixCostSum(segment) = SUM(fixCost, p_fixCost(segment,fixCost)*p_fixCostShock(fixCost));

*  If quota exists, initialize adjustment factor to "1"
pv_TACAdjustment.L(quotaSpecies,quotaArea)  $ (p_TAC_MOD(quotaSpecies,quotaArea) GT 0) = 1;

*  Compute maximum possible number of fishing days per vessel and year in each fishery using
*   a) Segment capacity per period (per vessel), and
*   b) fishery season information (1 if period is season, else 0)
p_maxEffFishery(f) = SUM((p,seg) $ segment_fishery(seg,f), p_maxEffSegPeriod(seg,p)*p_season(f,p));

p_maxEffSeg(seg) = SUM(p, SMAX[f $ segment_fishery(seg,f), p_maxEffSegPeriod(seg,p)*p_season(f,p)]);

DISPLAY p_maxEffFishery,p_maxEffSeg;

*###############################################################################
*   SKATTA MODELLPARAMETRARNA
*   Steg 1: hitta en startpunkt (särskilt för komplementaritetsvillkoren!)
*           över huvud taget genom att lösa den primala modellen
*
*   Steg 2: gör en snabb optimering av skattningen, som bara ger en approximation.
*           På så vis går det fortare för MINLP-solvern att köra senare
*
*   Steg 3: lös MINLP-modellen med hjälp av solvern BARON för att försöka förbättra
*           approximationen i steg 2.
*###############################################################################

* STEG 1:

pv_delta.L(f,s) = p_catchDist(f,s);

* Preparatory computations: average and marginal profit per unit of effort for each fishery

p_profit2009(f,"aveReve") = SUM(s, p_prices(f,s)*p_catchDist(f,s));
p_profit2009(f,"varCost") = pv_varCostSum.L(f);
p_profit2009(f,"grossMrg") = p_profit2009(f,"aveReve") - p_profit2009(f,"varCost");

p_profit2009(f,fixCost) $ p_effort2009(f) =

*   Total fixed costs for segments that carries out this fishery "f"
    SUM(seg $ segment_fishery(seg,f), p_fixCost(seg,fixCost)*p_vessels2009(seg)

*   Divided by sum of fishing efforts "fishery" carried out by the segment
       /SUM(fishery $ segment_fishery(seg,fishery), p_effort2009(fishery))
    );

p_profit2009(f,"vc_altlabour") =  p_varCost(f,"vc_altlabour");


p_profit2009(f,"profit") = p_profit2009(f,"grossMrg")
                         - SUM(fixCost, p_profit2009(f,fixCost))
                         - p_profit2009(f,"vc_altlabour");


* Solve the linear model (constant catch)
p_catchSlope(f) $ p_effort2009(f) = -2*(1-0.95)/p_effort2009(f);

p_catchIntercept(f) = 1 - 1/2*p_catchSlope(f)*p_effort2009(f);


*v_effortAnnual.LO(f) = p_effort2009(f)*0.95;
*v_effortAnnual.UP(f) = p_effort2009(f)*1.95;

$INCLUDE "set_bounds_simulation.gms"

*v_effortAnnual.FX(fishery) = p_effort2009(fishery);

*   Quota for this quota species in this quota area
    pv_TACAdjustment.FX(quotaSpecies,quotaArea) $ p_TAC_MOD(quotaSpecies,quotaArea) = 1;


*   Test solve model at observed costs, catches and quotas
SOLVE m_fishSim USING NLP MAXIMIZING v_profit;


* STEG 2:


$INCLUDE "set_bounds_estimation.gms"

*   --- Define prior information for parameters

*       For varCostSum: assume normal distribution with mean "what we observe"...
p_varCostSumDist(fishery,"mean") = pv_varCostSum.L(fishery);
*       ... and variance ASSUMED to be such that 2 standard deviations cover 1/2 of the mean in each direction
p_varCostSumDist(fishery,"var")  = SQR(p_varCostSumDist(fishery,"mean")/4);
p_weightVarCostSum(f) $ p_varCostSumDist(f,"var") = 1/(2*p_varCostSumDist(f,"var"));

p_weightEffortAnnual(f) $ p_effort2009(f) = 1/(2*SQR(p_effort2009(f)/4));
p_weightCatch(f,s) $ [p_effort2009(f)*p_catchDist(f,s)] = 1/(2*SQR(p_effort2009(f)*p_catchDist(f,s)/4));


*   Initialize dual values to the existing solution
*v_lambdaCPUE.L(f,s) $ fishery_species(f,s) = e_CPUE.M(f,s);
v_lambdaCatch.L(f,s) $ fishery_species(f,s) = e_catch.M(f,s);
v_lambdaEffRestrSeg.L(seg) = e_effRestrSeg.M(seg);
v_lambdaEffRestrFishery.L(f) = e_effRestrFishery.M(f);
v_lambdaCatchQuota.L(quotaSpecies,quotaArea) = e_catchQuota.M(quotaSpecies,quotaArea);
v_lambdaEffNonNeg.L(f) = -v_effortAnnual.M(f); // The primal model has a ">" restriction, so the sign must be reversed compared with our dual notation
v_estimationMetric.L = 1;

*   Use the following statement to do just one iteration of the estimation, to see if
*   the model solution above satisfies the optimality conditions (i.e. if we have
*   written the equations correctly and initialized all variables at feasible values)
*m_estimateFish.ITERLIM = 0;


*SET aest(a) "Areas to estimate" /"22-24","25-29+32"/;
SET aest(a) "Areas to estimate" /"22-24","25-29+32","30-31",K,S,N/;
f(fishery) = YES $ SUM((seg,m,aest), f_seg_m_a(fishery,seg,m,aest));
DISPLAY "Fisheries in estimation", f;

EXECUTE_UNLOAD "new.gdx";
*$EXIT

p_mu = 0;
SOLVE m_estimateFish USING NLP MINIMIZING v_estimationMetric;
*$EXIT
m_estimateFish.SOLPRINT = 2;

DISPLAY "Initial try: ", v_estimationMetric.L;

SCALAR n; p_mu = 100;
FOR(n = 1 TO 10,
    SOLVE m_estimateFish USING NLP MINIMIZING v_estimationMetric; //CNS = Constrained Nonlinear System of equations, i.e. no objective
    p_mu = p_mu/3;
);

p_mu = 0;
SOLVE m_estimateFish USING NLP MINIMIZING v_estimationMetric;
DISPLAY "Final try: ", v_estimationMetric.L;


* STEG 3:

*   Initialize binary variables
*   - Icke-negativiteten är bindande om effort är noll
v_effNonNegIsBinding.L(f) $ (v_effortAnnual.L(f) EQ 0) = 1;
*   - Kvoten är bindande OM det finns en kvotränta
v_catchQuotaIsBinding.L(quotaSpecies,quotaArea) $ v_lambdaCatchQuota.L(quotaSpecies,quotaArea) = 1;
*   - Effortrestriktionen är bindande om det finns en Lagrangemultiplikator
v_effRestrSegIsBinding.L(seg) $ v_lambdaEffRestrSeg.L(seg) = 1;
v_effRestrFisheryIsBinding.L(f) $ v_lambdaEffRestrFishery.L(f) = 1;

m_estimateFishBinary.RESLIM = 60*60*5;
SOLVE m_estimateFishBinary USING MINLP MINIMIZING v_estimationMetric; //CNS = Constrained Nonlinear System of equations, i.e. no objective


EXECUTE_UNLOAD "%SYSTEM.FP%allData.gdx";


*###############################################################################
*   TEST SOLUTION
*   Solve model at estimated parameter values to check calibration
*###############################################################################

$INCLUDE "set_bounds_simulation.gms"
SOLVE m_fishSim USING NLP MAXIMIZING v_profit;
