
*##############################################################################
* This file loads and merges output for different scenarios in Fish-PAL
*##############################################################################



* --- Define a unique name to be used for the results of the comparisons (name of the gdx-file)
$set comparisonFileName fuel_tax


*##############################################################################
* Define manually the scenarios to be compared
*##############################################################################

set scenario /
    fuel_tax_reference          "Simulation of the calibration point"
    fuel_tax_s1_lp_tax          "S1"
    fuel_tax_s2_lp_tax_ets2019  "S2"
    fuel_tax_s3_lp_tax_ets2022  "S3"
    fuel_tax_s4_hp              "S4"
    fuel_tax_s5_hp_tax          "S5"
    fuel_tax_s6_hp_tax_ets2019  "S6"
    fuel_tax_s7_hp_tax_ets2022  "S7"
/;

set refscen(scenario) The referencescenarios /
    fuel_tax_reference  "Simulation of the calibration point"
    fuel_tax_s4_hp      "S4 as reference but with high fuel prices"
/;

set scen_ref(scenario,refscen) Association of scenario with reference /
    fuel_tax_reference          .fuel_tax_reference
    fuel_tax_s1_lp_tax          .fuel_tax_reference
    fuel_tax_s2_lp_tax_ets2019  .fuel_tax_reference
    fuel_tax_s3_lp_tax_ets2022  .fuel_tax_reference
    fuel_tax_s4_hp              .fuel_tax_reference
    fuel_tax_s5_hp_tax          .fuel_tax_s4_hp
    fuel_tax_s6_hp_tax_ets2019  .fuel_tax_s4_hp
    fuel_tax_s7_hp_tax_ets2022  .fuel_tax_s4_hp    /;
    
 

$set reference_scenario fuel_tax_reference


*##############################################################################
*   Ange var resultat ska sparas
*##############################################################################

$SETGLOBAL resDir %SYSTEM.FP%output
$SETGLOBAL datDir %SYSTEM.FP%inputFiles

*##############################################################################
* DECLARE SETS AND LOAD THEM FROM THE DATABASE
*##############################################################################

$set fileNameForSetDefnitions %datDir%\inData.gdx

$include "include_files\define_sets.gms"

$include "include_files\declare_parameters.gms"


*###############################################################################
*   Declare parameters that contain reports of several simulations (having scenario dimension)
*###############################################################################

$set p1 p_fiskResultat

set type /abs,rel/;
parameter %p1%M(fisheryDomain,speciesDomain,resLabel,statItem,scenario) "Merged main results parameter";
parameter %p1%Diff(fisheryDomain,speciesDomain,resLabel,statItem,scenario,type) "Diff to reference scen";

set s_%p1%M /fisheryDomain,speciesDomain,resLabel,statItem,scenario,value/;
set s_%p1%Diff /fisheryDomain,speciesDomain,resLabel,statItem,scenario,type,value/;

*###############################################################################
*   Do the report for each of the scenarios in the list - a loop
*###############################################################################

file myPutFile "Define a temporary file for the put utility to use" /batch.txt/;
myPutFile.lw = 0;
put myPutFile;
loop(scenario,

*   --- L�s in data f�r nuvarande scenario fr�n en gdx-fil med samma namn som scenariot
    put_utility "gdxin" / "%resDir%\simulation\sim_"scenario.tl".gdx";
    execute_load %p1%;

*   --- Add current scenario result to comparison parameters

    %p1%M(fisheryDomain,speciesDomain,resLabel,statItem,scenario) = %p1%(fisheryDomain,speciesDomain,resLabel,statItem);
);

*%p1%Diff(fisheryDomain,speciesDomain,resLabel,statItem,scenario,"val")
*    = %p1%M(fisheryDomain,speciesDomain,resLabel,statItem,scenario);
    
*   --- Compute diff to reference
loop(scen_ref(scenario,refscen),
    %p1%Diff(fisheryDomain,speciesDomain,resLabel,statItem,scenario,"abs")
        = %p1%M(fisheryDomain,speciesDomain,resLabel,statItem,scenario)
        - %p1%M(fisheryDomain,speciesDomain,resLabel,statItem,refscen);
        
    %p1%Diff(fisheryDomain,speciesDomain,resLabel,statItem,scenario,"rel")
        $ (%p1%M(fisheryDomain,speciesDomain,resLabel,statItem,refscen) gt eps)
        = %p1%M(fisheryDomain,speciesDomain,resLabel,statItem,scenario)
        / %p1%M(fisheryDomain,speciesDomain,resLabel,statItem,refscen)
        - 1;

);

*###############################################################################
*   Write out results to gdx and Excel
*###############################################################################

* --- Store results in GDX

execute_unload "%resDir%\reports\%comparisonFileName%.gdx" %p1%M %p1%Diff s_%p1%M s_%p1%Diff;

* --- Make Excel file with selected results

$set fileName %resDir%\reports\%comparisonFileName%

* --- Write a sheet of profits
execute "GDXXRW i=%fileName%.gdx o=%fileName%.xlsx set=s_%p1%M rng=%p1%!A1 rdim=0 par=%p1%M rng=%p1%!A2 rdim=5 set=s_%p1%Diff rng=%p1%Diff!A1 rdim=0 par=%p1%Diff rng=%p1%Diff!A2 rdim=6";

