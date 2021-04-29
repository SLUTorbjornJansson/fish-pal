$TITLE FishPAL
$ONTEXT
    @about Fisheries Policy AnaLysis tool, for Swedish fisheries.
           This file is used for simulation and also calibration/estimation of parameters

    @author Staffan Waldo, Torbjörn Jansson

$OFFTEXT
$EOLCOM //
$STARS $$$$

*##############################################################################
*   Manuell styrning av modellen:
*##############################################################################

*   Ange var rådata till modellen finns
$SETGLOBAL datDir %SYSTEM.FP%inputfiles

*   Ange var resultat ska sparas
$SETGLOBAL resDir %SYSTEM.FP%output

*   Ange namnet på filen där modellparametrarna från estimation sparas (och läses från vid simulation)
$SETGLOBAL parFileName default

*   Ange vad programmet ska göra (estimation, simulation)
*$SETGLOBAL programMode estimation
$SETGLOBAL programMode simulation

*   Ange vad simulationen heter (var chocken kommer från och vad resultaten ska kallas)
$SETGLOBAL projectDirectory seal

*$SETGLOBAL scenario reference
*$SETGLOBAL scenario scenario2
$SETGLOBAL scenario scenario3
*$SETGLOBAL scenario scenario4
*$SETGLOBAL scenario scenario5
*$SETGLOBAL scenario scenario6


*$SETGLOBAL scenario no_seal_cost
*$SETGLOBAL scenario increase_catch_by_50_percent
*$SETGLOBAL scenario no_seal_cost_and_increase_catch_by_50_percent
*$SETGLOBAL scenario no_seal_cost_and_increase_catch_by_100_percent

*   Vissa scenario-filer ligger inte i en under-katalog, utan i scenario-roten "."
*$SETGLOBAL projectDirectory .
*$SETGLOBAL scenario nochange
*$SETGLOBAL scenario ref_2017
*$SETGLOBAL scenario no_cod_trawl_2224
*$SETGLOBAL scenario TACcut2224
*$SETGLOBAL scenario TACcut2224_noTrawl
*$SETGLOBAL scenario LandingOblKrafta
*$SETGLOBAL scenario prisChockRodtunga
*$SETGLOBAL scenario noDiscard
*$SETGLOBAL scenario noCodInMetier107
*$SETGLOBAL scenario quotaRemovalSillN


*   Ange ett suffix till filnamnet för resultaten, för att t.ex. skilja
*   känslighetsanalysens resultat från originalresultaten i samma scenario
*   Normalt sett är ResId tomt.
$SETGLOBAL ResId


*   Ställ in skift för diverse modellparametrar, för känslighetsanalys.
*   Ange +/- procent, tex +10 för plus tio procent, osv.
*   Dessa parametrar används av filen shift_parameters.gms längre ned.
$SETGLOBAL SHIFT_VARCOST_SLOPE 0
$SETGLOBAL SHIFT_CATCH_ELAS 0
$SETGLOBAL SHIFT_FISH_PRICES 0


** 1 if model equations are changed in simulation scenario, 0 otherwise. OFF is default for estimation! **
$SETGLOBAL SimChangesModelEq off
*$SETGLOBAL SimChangesModelEq on



DISPLAY "datDir = %datDir%";



$setglobal scenario_path %projectDirectory%\%scenario%
$setglobal scenario_path_underScores %projectDirectory%_%scenario%
$if "%projectDirectory%"=="." $setglobal scenario_path_underScores %projectDirectory%_%scenario%



*   Läs in en eventuell styrfil från GUI. Isåfall finns namnet lagrat i
*   globalvariablen scen
$IFI %GGIG%==ON $INCLUDE "%scen%.gms"
*$show
*$stop

*#############################################################
*           CONVERT EXCEL DATA FILE TO GAMS GDX FORMAT
*#############################################################

$CALL gdxxrw %datDir%\data_gams_2012_seal.xlsx o=%datDir%\inData.gdx index=index!A1

* Ange att set ska läsas från indata-filen
$set fileNameForSetDefnitions %datDir%\inData.gdx

*##############################################################################
* DECLARE SETS AND LOAD THEM FROM THE DATABASE
*##############################################################################

$include "include_files\define_sets.gms"


*##############################################################################
* GET THE BASELINE DATA FROM THE DATABASE
*##############################################################################

$include "include_files\declare_parameters.gms"

* Läs in parametrar från Excel (via gdx-filen som tillverkats tidigare)
$GDXIN "%fileNameForSetDefnitions%"

$LOAD p_pricesAOri p_pricesBOri p_costOri p_maxEffSegPeriod p_season p_TACOri
$LOAD p_landingsOri p_discardShareOri p_effortOri p_vesselsOri p_landingObligation p_maxEffortPerEffortGroup p_kwhOri
$LOAD p_catchElasticityPerGearGroup
$LOAD p_subsidyBudget
$LOAD p_ShareDASseal

* Stäng GDX-filen genom att anropa GDXIN utan argument
$GDXIN



*** SW program som jag inte vet var jag ska göra av
*** anger min-level för landings för arter som ska modelleras (ton/år)
*** många små-fångster blåses upp av GAMS och ger dålig estimation

PARAMETER minLevelLandingsOri(f,s) ;
minLevelLandingsOri(f,s) = 0.001 ;
p_landingsOri(f,s)$(p_landingsOri(f,s) < minLevelLandingsOri(f,s))=0 ;


* p_discardsShare  är andel av totala landningar (alla arter) som är utkast (per art)
* p_discardOri är utkast i ton

parameter totalLanding(f) ;
totalLanding(f) =  SUM(s, p_landingsOri(f,s));
p_discardsOri(f,s) = p_discardShareOri(f,s)*totalLanding(f) ;

p_catchOri(f,s) = p_landingsOri(f,s)+p_discardsOri(f,s);
display p_discardShareOri, p_discardsOri ;


*##############################################################################
*  DEFINE HANDY SETS THAT FACILITATE MODELLING LATER ON
*##############################################################################

$include "include_files\define_handy_sets.gms"


*DISPLAY quotaFishery,area,quotaFishery_fishery;     // SW


*##############################################################################
*   CLEANSING OF DATA TO TAKE OUT "OBVIOUS PROBLEMS"
*   This is specific to current data file used!
*##############################################################################

*   If there are no vessels, then there should be no fishing in that segment
LOOP(segment $ [p_vesselsOri(segment) EQ 0],
    p_effortOri(fishery) $ segment_fishery(segment,fishery) = 0;
);


*#############################################################
*            DEFINE MODEL VARIABLES AND EQUATIONS
*#############################################################

$include "include_files\declare_simulation_model.gms"


$IF %programMode%==simulation $INCLUDE "include_files\load_parameters.gms"

*   Sensitivity analysis: optional shift of parameters
$INCLUDE "include_files\shift_parameters.gms"

*   Define what to change in the current scenario
$INCLUDE "scenarioFiles\%scenario_path%.gms"


*$stop
*#############################################################
*            DEFINE MODEL
*#############################################################


MODEL m_fishSim "Primal simulation model with profit maximization"
    /m_coreEquations,
     m_policyEquations,
     m_reportingEquations/;

m_fishSim.HOLDFIXED = 1;
m_fishSim.LIMROW = 10000;
m_fishSim.LIMCOL = 10000;


OPTION NLP=CONOPT;


* If this is an estimation run: include a module that estimates parameters.
* This has to come after the scenario file, where the policy equations are defined
$IF %programMode%==estimation $INCLUDE "include_files\estimate_parameters.gms"


display p_catchElasticity ;


*###############################################################################
*   SIMULATION
*###############################################################################


$INCLUDE "include_files\set_bounds_simulation.gms"

* --- We need to iteratively adjust the subsidy per DAS to hit total budget
*     Therefore, we loop over a set of iterations and compute the mean squared
*     deviation from the previous iteration to determine if it converged.
*     We create an artificial iteration zero containing p_effortOri

p_meanSquaredDeviation = +inf;
p_convergenceTolerance = 0.001;
p_stopSolvingModel = 0;
p_iterEffort(iterations,f) $ (ord(iterations) eq 1) = p_effortOri(f);

* --- Disable solution output during iterations 2 = no output at all.
m_fishSim.solprint = 2;

loop(iterations $ [(not p_stopSolvingModel) and (ord(iterations) gt 1)],
    iterUsed(iterations) = yes;
    $$INCLUDE "include_files\compute_subsidies.gms"
    SOLVE m_fishSim USING NLP MAXIMIZING v_profit;

    p_iterEffort(iterations,f) = v_effortAnnual.l(f);

* --- Compute the average squared deviation relative to previous iterations,
*     to determine if we have convergence.
    if(ord(iterations) gt 1,
        p_meanSquaredDeviation = sum(f, sqr(p_iterEffort(iterations,f)-p_iterEffort(iterations-1,f)))
                                     / card(f);

        p_iterDeviations(iterations) = p_meanSquaredDeviation;
    );

    p_stopSolvingModel $ [p_meanSquaredDeviation lt p_convergenceTolerance] = 1;

    p_stopSolvingModel $ [ord(iterations) eq card(iterations)] = 1;
);

* --- Solve once more with full output and store iteration result under "last" iteration
m_fishSim.solprint = 1;
SOLVE m_fishSim USING NLP MAXIMIZING v_profit;
p_iterEffort("sim",f) = v_effortAnnual.l(f);


* --- Att göra: analysera lösningen för att se att det inte var något
*     uppenbart problem, t.ex. infeasible, icke-konvergerat eller liknande.
p_solutionStats("iterCount") = card(iterUsed);
p_solutionStats("solveStat") = m_fishSim.solvestat;
p_solutionStats("modelStat") = m_fishSim.modelstat;
p_solutionStats("deviation") = p_meanSquaredDeviation;
p_solutionStats("tolerance") = p_convergenceTolerance;
p_solutionStats("stopCode")  = p_stopSolvingModel;



* --- Make a simple report for the listing by converting the effort in each
*     iteration to deviation relative to the previous iteration, and remove all
*     tiny numbers.
p_iterReport(f,iterTot) = p_iterEffort(iterTot,f);

p_iterReport(f,iterations) $ [iterUsed(iterations) and ord(iterations) gt 1]
    = p_iterEffort(iterations,f)/p_iterEffort(iterations-1,f)-1;
p_iterReport(f,iterUsed) $ [abs(p_iterReport(f,iterUsed)) lt 0.001] = 0;
display p_iterDeviations, p_iterReport, p_subsidyBudgetSpent;

*###############################################################################
*   REPORTS (for estimation and simulation alike: estimation also has a
*            separate reporting of statistical properties)
*###############################################################################



*###############################################################################
* --- Skriv parameter för GUI
*###############################################################################

*   Dim 1: Fisheries och aggregat såsom segment, area (fisheryDomain)
*   Dim 2: Species och aggregat såsom catchQuotaName, alla arter osv (speciesDomain)
*   Dim 3: Dataetikett såsom dagar till sjöss, kvot, kostnad, vinst, pris...
*   Dim 4: Etikett för typ av data. Ex. sim, est, ori, LO, UP, M


*   Rapportera värden på variabler, parametrar och ekvationer
p_fiskresultat(f,s,"v_catch","sim")                     = v_catch.L(f,s);
p_fiskResultat(f,s,"v_landings","sim")                  = v_landings.L(f,s);
p_fiskResultat(f,s,"v_discards","sim")                  = v_discards.L(f,s);
p_fiskresultat(f,s,"v_sortA","sim")                     = v_sortA.L(f,s);
p_fiskresultat(f,s,"v_sortB","sim")                     = v_sortB.L(f,s);
p_fiskresultat(f,s,"p_pricesA","sim")                   = p_pricesA(f,s);
p_fiskresultat("total",s,"p_pricesB","sim")             = p_pricesB(s);
p_fiskresultat(f,s,"p_landingObligation","sim")         = p_landingObligation(f,s);
p_fiskresultat(f,"allSpecies","p_subsidyPerDAS","sim")  = p_subsidyPerDAS(f);
p_fiskresultat(f,"allSpecies","v_effortAnnual","sim")   = v_effortAnnual.L(f);
p_fiskresultat(f,"allSpecies","v_effortAnnual","LO")    = v_effortAnnual.LO(f);
p_fiskresultat(f,"allSpecies","v_effortAnnual","UP")    = v_effortAnnual.UP(f);
p_fiskresultat(f,"allSpecies","v_effortAnnual","M")     = v_effortAnnual.M(f);
p_fiskresultat(f,"allSpecies","v_varCostAve","sim")    = v_varCostAve.L(f);
p_fiskResultat(quotaArea,catchQuotaName,"p_TACOri","sim") = p_TACOri(catchQuotaName,quotaArea);
p_fiskResultat(quotaArea,catchQuotaName,"e_catchQuota","M") = e_catchQuota.M(catchQuotaName,quotaArea);
p_fiskResultat(quotaArea,catchQuotaName,"e_catchQuota","sim") = e_catchQuota.L(catchQuotaName,quotaArea);

*   Aggregera fishery till segment, area osv.
p_fiskresultat(fisheryDomain,speciesDomain,resLabel,"sim") $ [(NOT fishery(fisheryDomain)) and (NOT p_fiskresultat(fisheryDomain,speciesDomain,resLabel,"sim"))]
    = SUM(fishery $ fisheryDomain_fishery(fisheryDomain,fishery), p_fiskresultat(fishery,speciesDomain,resLabel,"sim"));

*   Aggregera från fiske och art till kvotområde och kvotnamn (art).
p_fiskresultat(f,catchQuotaName,resLabel,"sim") $ [(NOT p_fiskresultat(f,catchQuotaName,resLabel,"sim"))]
    = SUM(s $ [catchQuotaName_fishery_species(catchQuotaName,f,s)], p_fiskresultat(f,s,resLabel,"sim"));

p_fiskresultat(quotaArea,catchQuotaName,resLabel,"sim") $ [(NOT p_fiskresultat(quotaArea,catchQuotaName,resLabel,"sim")) AND p_TACOri(catchQuotaName,quotaArea)]
    = SUM((f,s) $ [catchQuotaName_fishery_species(catchQuotaName,f,s) AND quotaArea_fishery(quotaArea,f)], p_fiskresultat(f,s,resLabel,"sim"));


*   --- Include the computations of all report items (using the data loaded above)
$include "include_files\compute_reports.gms"

*   Rapportera lönsamhetsmått per fiske
p_fiskResultat(fisheryDomain,"allSpecies",resLabel,"sim") $ p_profitFishery(fisheryDomain,resLabel)
    = p_profitFishery(fisheryDomain,resLabel);

*   Intäkter per fiskart
p_fiskResultat(f,s,"totalSalesRevenues","sim")
    = v_sortA.L(f,s)*p_pricesAOri(f,s) + v_sortB.L(f,s)*p_pricesBOri(s)*p_landingObligation(f,s);

*   Rapportera dualvärden (Lagrange-funktionens partialderivator m.a.p. effortannual)
p_fiskResultat(fisheryDomain,"allSpecies",dualResult,"sim") $ p_reportDualsFishery(fisheryDomain,dualResult)
    = p_reportDualsFishery(fisheryDomain,dualResult);

*   Lägg till lönsamhetsresultaten per fiske
*p_fiskresultat(f,"total","days")

*   Store report. Suffix the file name by "est" if estimation, else by "sim"
$SET runtype sim
$IF %programMode%==estimation $SET runtype est
EXECUTE_UNLOAD "%resDir%\simulation\%runtype%_%scenario_path_underscores%%ResId%.gdx" p_fiskresultat,
                                                      p_reportDualsFishery,
                                                      p_profitFishery,
                                                      p_fixCostSumOri,
                                                      v_vessels,
                                                      p_reportDualsFisheryQuota
                                                      fisheryDomain
                                                      speciesDomain
                                                      p_solutionStats;


* Skriv ut alla resultat för att kolla hur det blev
*EXECUTE_UNLOAD "TEMP_%programMode%%ResId%.GDX";



** SW kod för output till paper mm

$INCLUDE "include_files\outputForPresentation.gms"
$IF %programMode%==estimation $INCLUDE "include_files\easyEstimationOutputSW.gms"
