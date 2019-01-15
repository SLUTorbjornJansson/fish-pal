
*##############################################################################
* This file compares output for different scenarios in Fish-PAL
*##############################################################################



* --- Define a unique name to be used for the results of the comparisons (name of the gdx-file)
$set comparisonFileName baseline_2017


*##############################################################################
* Define manually the scenarios to be compared
*##############################################################################

set scenario /
    noChange  "Simulation of the calibration point"
    ref_2017   "Reference run for 2017"
/;


* The referencescenario is used for reading relevant sets

$set reference_scenario noChange


*##############################################################################
*   Ange var resultat ska sparas
*##############################################################################

$SETGLOBAL resDir %SYSTEM.FP%output

*##############################################################################
* DECLARE SETS AND LOAD THEM FROM THE DATABASE
*##############################################################################

$set fileNameForSetDefnitions %resDir%\simulation\%reference_scenario%.gdx

$include "include_files\define_sets.gms"

$include "include_files\declare_parameters.gms"

$include "include_files\declare_simulation_model.gms"


*###############################################################################
*   Declare parameters that contain reports of several simulations (having scenario dimension)
*###############################################################################

parameter p_compareProfit(fisheryDomain,resLabel,scenario) "Comparison of profit reports across scenarios";


*###############################################################################
*   Do the report for each of the scenarios in the list - a loop
*###############################################################################

file myPutFile "Define a temporary file for the put utility to use" /batch.txt/;
myPutFile.lw = 0;
put myPutFile;
loop(scenario,

*   --- Läs in data för nuvarande scenario från en gdx-fil med samma namn som scenariot
    put_utility "gdxin" / "%resDir%\simulation\"scenario.tl".gdx";
    execute_load p_catchOri, p_varCostOri, p_pricesAOri, p_pricesBOri, v_sortA, v_sortB, p_landingObligation, v_varCostAve, v_effortAnnual, p_fixCostSumOri, v_vessels, p_shareA, p_shareB;
    execute_load pv_delta, p_catchElasticity, pv_PMPconst, pv_PMPslope, e_catchQuota, p_TACori, e_effRestrSeg, e_effRestrFishery, e_effortRegulation, p_maxEffortPerEffortGroup, pv_kwh, p_effortOri, p_kwhOri;
    execute_load v_effortPerEffortGroup;
    $$include "include_files\define_handy_sets.gms"

*   --- Include the computations of all report items (using the data loaded above)
    $$include "include_files\compute_reports.gms"


*   --- Add current scenario result to comparison parameters

    p_compareProfit(fisheryDomain,resLabel,scenario) = p_profitFishery(fisheryDomain,resLabel);

);

*###############################################################################
*   Write out results to gdx and Excel
*###############################################################################

* --- Store results in GDX

execute_unload "%resDir%\reports\%comparisonFileName%.gdx" p_compareProfit;

* --- Make Excel file with selected results

$set fileName %resDir%\reports\%comparisonFileName%

* --- Write a sheet of profits
execute "GDXXRW i=%fileName%.gdx o=%fileName%.xlsx par=p_compareProfit rng=profit!A1";
execute "GDXXRW i=%fileName%.gdx o=%fileName%.xlsx text='fishery' rng=profit!A1 text='scenario' rng=profit!B1";
