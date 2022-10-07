$TITLE FishPAL
$ONTEXT
    @about Fisheries Policy AnaLysis tool, for Swedish fisheries.
           This file is used for simulation and also calibration/estimation of parameters

    @author Staffan Waldo, Torbj�rn Jansson

$OFFTEXT
$EOLCOM //
$STARS $$$$
$SETGLOBAL ERROR_FILE "error_fish_pal.gdx"

*##############################################################################
*   Manuell styrning av modellen:
*##############################################################################

*   Ange var r�data till modellen finns
$SETGLOBAL datDir %SYSTEM.FP%inputfiles

*   Ange var resultat ska sparas
$SETGLOBAL resDir %SYSTEM.FP%output

*   Ange namnet p� filen d�r modellparametrarna fr�n estimation sparas (och l�ses fr�n vid simulation)
$SETGLOBAL parFileName default

*   Ange vad programmet ska g�ra (estimation, simulation)
*$SETGLOBAL programMode estimation
$SETGLOBAL programMode simulation

*   Ange vad simulationen heter (var chocken kommer fr�n och vad resultaten ska kallas)
$SETGLOBAL projectDirectory fuel_tax

*   Ange specifikt vilken scenariofil i ovan nämnda katalog vi vill använda
$SETGLOBAL scenario energy_tax
*$SETGLOBAL scenario reference


*   Ange ett suffix till filnamnet f�r resultaten, f�r att t.ex. skilja
*   k�nslighetsanalysens resultat fr�n originalresultaten i samma scenario
*   Normalt sett �r ResId tomt.
$SETGLOBAL ResId


*   St�ll in skift f�r diverse modellparametrar, f�r k�nslighetsanalys.
*   Ange +/- procent, tex +10 f�r plus tio procent, osv.
*   Dessa parametrar anv�nds av filen shift_parameters.gms l�ngre ned.
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



*   L�s in en eventuell styrfil fr�n GUI. Is�fall finns namnet lagrat i
*   globalvariablen scen
$IFI %GGIG%==ON $INCLUDE "%scen%.gms"
*$show
*$stop

*#############################################################
*           CONVERT EXCEL DATA FILE TO GAMS GDX FORMAT
*#############################################################

$CALL gdxxrw %datDir%\data_gams_2019_fuel.xlsx o=%datDir%\inData.gdx index=index!A1

* Ange att set ska l�sas fr�n indata-filen
$set fileNameForSetDefnitions %datDir%\inData.gdx


*##############################################################################
* DECLARE SETS AND LOAD THEM FROM THE DATABASE
*##############################################################################

$include "include_files\define_sets.gms"


*##############################################################################
* GET THE BASELINE DATA FROM THE DATABASE
*##############################################################################

$include "include_files\declare_parameters.gms"

* L�s in parametrar fr�n Excel (via gdx-filen som tillverkats tidigare)
$GDXIN "%fileNameForSetDefnitions%"

$LOAD p_pricesAOri p_pricesBOri p_costOri p_maxEffSegPeriod p_season p_TACOri
$LOAD p_landingsOri p_discardShareOri p_effortOri p_vesselsOri p_landingObligation p_maxEffortPerEffortGroup p_kwhOri
$LOAD p_catchElasticityPerGearGroup
$LOAD p_subsidyBudget
$LOAD p_ShareDASseal
$LOAD p_inputOri

* St�ng GDX-filen genom att anropa GDXIN utan argument
$GDXIN


*** SW program som jag inte vet var jag ska göra av
*** anger min-level för landings för arter som ska modelleras (ton/år)
*** många små-fångster blåses upp av GAMS och ger dålig estimation

PARAMETER minLevelLandingsOri(f,s) ;
minLevelLandingsOri(f,s) = 0.01 ;
p_landingsOri(f,s)$(p_landingsOri(f,s) < minLevelLandingsOri(f,s))=0 ;


* p_discardsShare  Är andel av totala landningar (alla arter) som är utkast (per art)
* p_discardOri Är utkast i ton

parameter totalLanding(f) ;
totalLanding(f) =  SUM(s, p_landingsOri(f,s));
p_discardsOri(f,s) = p_discardShareOri(f,s)*totalLanding(f) ;

p_catchOri(f,s) = p_landingsOri(f,s)+p_discardsOri(f,s);



*##############################################################################
*  DEFINE HANDY SETS THAT FACILITATE MODELLING LATER ON
*##############################################################################

$include "include_files\define_handy_sets.gms"


*##############################################################################
*  Compute share of each variable cost in total variable cost 
*##############################################################################

alias(varCost,varCost1);
p_varCostOriShare(f,varCost) = sum(seg $ segment_fishery(seg,f), p_costOri(seg,varCost)
                                              / sum(varCost1, p_costOri(seg,varCost1)));


*##############################################################################
*  Compute how much fuel and staff is used per day at sea in each fishery
*  This is kept constant in simulation and used for reporting indicators
*##############################################################################

loop(seg,
    p_inputPerEffort(f,inputItem) $ segment_fishery(seg,f)
        = p_inputOri(seg,inputItem)
          / sum(fishery $ segment_fishery(seg,fishery), p_effortOri(fishery))
    );




*##############################################################################
*   CLEANSING OF DATA TO TAKE OUT "OBVIOUS PROBLEMS"
*   This is specific to current data file used!
*##############################################################################





*#############################################################
*    ASSERT THAT DATA IS COMPLETE ACCORDING TO SOME BASIC RULES
*#############################################################


set problem_segment(seg) "Some problem with this segment";
set problem_fishery(fishery) "Some problem with this fishery";

* --- Assert that there are vessels if we have fishing effort
LOOP(segment,
    problem_segment(segment) $ [sum(f $ segment_fishery(segment,f), p_effortOri(f))
                                and (not p_vesselsOri(segment))] = yes;
);

if(card(problem_segment),
    display "Some segment has effort but no vessels. All data unloaded to %ERROR_FILE%.", problem_segment;
    execute_unload "%ERROR_FILE%";
    abort "Error: fleet is missing";
else
    display "Successfully checked for fleet existence";
);

* --- Assert that cost shares add up to "1" within some tolerance
problem_fishery(f) $ [abs(sum(varCost, p_varCostOriShare(f,varCost)) - 1) gt 0.00001] = yes;

if(card(problem_fishery),
    execute_unload "%ERROR_FILE%";
    abort "For some fishery the sum of variable cost shares do not equal 1. All data unloaded to %ERROR_FILE%.", problem_fishery;
else
    display "Successfully checked for sum of cost shares equalling one.";
);


* --- Assert that each fishery that has effort also has some vessel
problem_fishery(f) $ [p_effortOri(f)
                      and (not sum(seg $ segment_fishery(seg,f), p_vesselsOri(seg)))] = yes;

if(card(problem_fishery),
    display "Some fishery has effort but no vessels. All data unloaded to %ERROR_FILE%.", problem_fishery;
    execute_unload "%ERROR_FILE%";
    abort "Error: fleet is missing for some fishery";
else
    display "Successfully checked for fleet existence for each fishery";
);


* --- Assert that the available season length is at least the observed fishery effort
problem_fishery(f) $ [p_effortOri(f)
                      gt SUM((seg,p) $ segment_fishery(seg,f), p_vesselsOri(seg)*p_maxEffSegPeriod(seg,p)*p_season(f,p))]
                      = yes;

if(card(problem_fishery),
    execute_unload "%ERROR_FILE%";
    abort "Error: Some fishery has less season than observed effort. All data unloaded to %ERROR_FILE%.", problem_fishery;
else
    display "Successfully checked for season length covering observed effort per fishery";
);


*#############################################################
*            DEFINE MODEL VARIABLES AND EQUATIONS
*#############################################################

$include "include_files\declare_simulation_model.gms"

$IF %programMode%==simulation $INCLUDE "include_files\load_parameters.gms"

*   Sensitivity analysis: optional shift of parameters
*$INCLUDE "include_files\shift_parameters.gms"


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


* --- Att g�ra: analysera l�sningen f�r att se att det inte var n�got
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
* --- Skriv parameter f�r GUI
*###############################################################################

*   Dim 1: Fisheries och aggregat s�som segment, area (fisheryDomain)
*   Dim 2: Species och aggregat s�som catchQuotaName, alla arter osv (speciesDomain)
*   Dim 3: Dataetikett s�som dagar till sj�ss, kvot, kostnad, vinst, pris...
*   Dim 4: Etikett f�r typ av data. Ex. sim, est, ori, LO, UP, M


*   Rapportera v�rden p� variabler, parametrar och ekvationer
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
p_fiskresultat(f,"allSpecies","v_varCostAve","sim")     = v_varCostAve.L(f);
p_fiskResultat(quotaArea,catchQuotaName,"p_TACOri","sim") = p_TACOri(catchQuotaName,quotaArea);
p_fiskResultat(quotaArea,catchQuotaName,"e_catchQuota","M") = e_catchQuota.M(catchQuotaName,quotaArea);
p_fiskResultat(quotaArea,catchQuotaName,"e_catchQuota","sim") = e_catchQuota.L(catchQuotaName,quotaArea);


*   Report variable cost of each cost category using total varCost times the cost shares including shift factors
loop((resLabel,varCost) $ sameas(resLabel,varCost),
        p_fiskresultat(f,"allSpecies",resLabel,"sim")
            =   (pv_varCostConst.l(f)*v_effortAnnual.l(f) + 1/2*pv_varCostSlope.l(f)*sqr(v_effortAnnual.l(f)))
*                 ... shifted by an exogenous change in price or quantity of each cost item, weighted with its share in VC
*                     In the baseline scenario, the shifters must be zero and the shares add up to 1
                * p_varCostOriShare(f,varCost)
                * (1 + p_varCostPriceShift(f,varCost))
                * (1 + p_varCostQuantShift(f,varCost));
    );

*   Report input use indirectly by dividing variable cost by the price found in calibration

* to do




*   Aggregera fishery till segment, area osv.
p_fiskresultat(fisheryDomain,speciesDomain,resLabel,addStat) $ [(NOT fishery(fisheryDomain)) and (NOT p_fiskresultat(fisheryDomain,speciesDomain,resLabel,addStat))]
    = SUM(fishery $ fisheryDomain_fishery(fisheryDomain,fishery), p_fiskresultat(fishery,speciesDomain,resLabel,addStat));

*   Aggregera fr�n fiske och art till kvotomr�de och kvotnamn (art).
p_fiskresultat(f,catchQuotaName,resLabel,addStat) $ [(NOT p_fiskresultat(f,catchQuotaName,resLabel,addStat))]
    = SUM(s $ [catchQuotaName_fishery_species(catchQuotaName,f,s)], p_fiskresultat(f,s,resLabel,addStat));

p_fiskresultat(quotaArea,catchQuotaName,resLabel,addStat) $ [(NOT p_fiskresultat(quotaArea,catchQuotaName,resLabel,addStat)) AND p_TACOri(catchQuotaName,quotaArea)]
    = SUM((f,s) $ [catchQuotaName_fishery_species(catchQuotaName,f,s) AND quotaArea_fishery(quotaArea,f)], p_fiskresultat(f,s,resLabel,addStat));

*   Aggregate species to all species, in tons
set aggResLabel(resLabel) /v_catch,v_landings,v_discards,v_sortA,v_sortB/;
p_fiskresultat(fisheryDomain,"allSpecies",aggResLabel,addStat) = sum(s, p_fiskresultat(fisheryDomain,s,aggResLabel,addStat));


*   --- Include the computations of all report items (using the data loaded above)
$include "include_files\compute_reports.gms"

*   Rapportera l�nsamhetsm�tt per fiske
p_fiskResultat(fisheryDomain,"allSpecies",resLabel,"sim") $ p_profitFishery(fisheryDomain,resLabel)
    = p_profitFishery(fisheryDomain,resLabel);

*   Int�kter per fiskart
p_fiskResultat(f,s,"totalSalesRevenues","sim")
    = v_sortA.L(f,s)*p_pricesAOri(f,s) + v_sortB.L(f,s)*p_pricesBOri(s)*p_landingObligation(f,s);

*   Rapportera dualv�rden (Lagrange-funktionens partialderivator m.a.p. effortannual)
p_fiskResultat(fisheryDomain,"allSpecies",dualResult,"sim") $ p_reportDualsFishery(fisheryDomain,dualResult)
    = p_reportDualsFishery(fisheryDomain,dualResult);

*   L�gg till l�nsamhetsresultaten per fiske
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


* Skriv ut alla resultat f�r att kolla hur det blev
*EXECUTE_UNLOAD "TEMP_%programMode%%ResId%.GDX";



** SW kod f�r output till paper mm

$INCLUDE "include_files\outputForPresentation.gms"
$IF %programMode%==estimation $INCLUDE "include_files\easyEstimationOutputSW.gms"
