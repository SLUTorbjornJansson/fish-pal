$ONTEXT
    L�s in m�nga resultatfiler och skriv ut de sammanlagda resultaten till excel

    Detta kan anv�ndas p� olika s�tt, men det ursprungliga syftet var att
    sammanst�lla resultat av k�nslighetsanalyser.

    K�nslighetsanalyserna gjordes f�r en svit av scenarier
    genom att kalibrera om modellen till andra parameterv�rden och
    sedan k�ra om samma svit av scenarier.

    T. Jansson, 2021


$OFFTEXT

*-------------------------------------------------------------------------------
*   Kontrollpanelen: Inst�llningar f�r detta program
*-------------------------------------------------------------------------------

* Del av filnamnen som �r likadan i alla scenarier och k�nlighetsanalyser
$set FILENAME_PREFIX sim_seal

* Referens-scenariots namn. Vi antar att det bara finns ETT referensscenario
$set REF_SCEN "reference"

* S�kv�g till resultaten. Borde aldrig �ndras.
$set resdir ".\output\simulation"

* Det blir m�nga resultat. H�r v�ljer vi ut dimensioner att exportera.
* V�lj elementet "*" f�r att v�lja "alla fisken" osv.
set selectFishery "Fisheries or aggregates selected for export" /"*"/;
set selectSpecies "Species or aggregates selected for export" /"allSpecies"/;
set selectResLabel "Results, variables etc selected for export" /"v_effortAnnual"/;
set selectTime "Types of result. Should always be SIM?" /"sim"/;


*   List of scenarios to analyse
set s_scenSens "Scenarios for which there are sensitivity analyses"
    /
*    reference
    scenario2
    scenario3
    scenario4
    scenario5
    scenario6
    /;

set sens "Sensitivity analyses to load"/
    vcL_ceL_pL
    vcM_ceL_pL
    vcH_ceL_pL

    vcL_ceM_pL
    vcM_ceM_pL
    vcH_ceM_pL

    vcL_ceH_pL
    vcM_ceH_pL
    vcH_ceH_pL


    vcL_ceL_pM
    vcM_ceL_pM
    vcH_ceL_pM

    vcL_ceM_pM
    vcM_ceM_pM
    vcH_ceM_pM

    vcL_ceH_pM
    vcM_ceH_pM
    vcH_ceH_pM


    vcL_ceL_pH
    vcM_ceL_pH
    vcH_ceL_pH

    vcL_ceM_pH
    vcM_ceM_pH
    vcH_ceM_pH

    vcL_ceH_pH
    vcM_ceH_pH
    vcH_ceH_pH
    /;

singleton set sensDefault(sens) "The standard variant of any scenario" /vcM_ceM_pM/;


*-------------------------------------------------------------------------------
*   Deklarationer som f�rmodligen inte �ndras
*-------------------------------------------------------------------------------

*   Dimensions of the results in each file
set fisheryDomain;
set speciesDomain;
set resLabel;
set time;

*   Find dimensions of result parameter using "projections" of the gdx-file
$gdxin %resdir%\%FILENAME_PREFIX%_%REF_SCEN%
$load fisheryDomain
$load speciesDomain
$load resLabel<p_fiskResultat.dim3
$load time<p_fiskResultat.dim4
$gdxin



set scenAll "All scenarios" /%REF_SCEN%,#s_scenSens/;
set scenSens(scenAll) "Scenarios with sensitivity analysis" /#s_scenSens/;

singleton set scenRef(scenAll) "The reference scenario" /%REF_SCEN%/


*-------------------------------------------------------------------------------
* V�lj ut endast vissa resultat baserat p� angivelser l�ngst upp i denna fil
*-------------------------------------------------------------------------------
* Nota Bene: Elementet "*" betyder: tag alla resultat!

set selFishery(fisheryDomain) "Fisheries selected for reporting" ;
if(selectFishery("*"),
    selFishery(fisheryDomain) = yes;
else
    selFishery(fisheryDomain) $ selectFishery(fisheryDomain)= yes;
);

set selSpecies(speciesDomain) ;
if(selectSpecies("*"),
    selSpecies(speciesDomain) = yes;
else
    selSpecies(speciesDomain) = yes $ selectSpecies(speciesDomain);
);


set selResLabel(resLabel);
if(selectResLabel("*"),
    selResLabel(resLabel) = yes;
else
    selResLabel(resLabel) = yes $ selectResLabel(resLabel);
);


set selTime(time);
if(selectTime("*"),
    selTime(time) = yes;
else
    selTime(time) = yes $ selectTime(time);
);


*-------------------------------------------------------------------------------
* Loopa �ver alla filnamn och l�s in motsvarande gdx-fil
*-------------------------------------------------------------------------------

parameter p_fiskResultat(fisheryDomain,speciesDomain,resLabel,time);
parameter p_fiskResultatSens(fisheryDomain,speciesDomain,resLabel,time,scenAll,sens);

*   L�s in referensscenariot. Detta g�rs separat eftersom vi inte laddar n�gra
*   k�nslighetsanalyser f�r just det scenariot.
execute_load "%RESDIR%\%FILENAME_PREFIX%_%REF_SCEN%" p_fiskResultat;
p_fiskResultatSens(selFishery,selSpecies,selResLabel,selTime,scenRef,sensDefault)
    = p_fiskResultat(selFishery,selSpecies,selResLabel,selTime);


*   L�s in alla k�nslighetsanalyser f�r vart och ett av de scenarier som finns
*   i m�ngden scenSens.
file f "Any file. Apparently needed for put_utility to work" /".\output\temp\tmp.cmd"/;


loop((scenSens,sens),
    put_utility 'gdxin' / '%RESDIR%\%FILENAME_PREFIX%_', scenSens.tl:0,'_', sens.tl:0;
    execute_load p_fiskResultat;
    p_fiskResultatSens(selFishery,selSpecies,selResLabel,selTime,scenSens,sens)
        = p_fiskResultat(selFishery,selSpecies,selResLabel,selTime);

);


*-------------------------------------------------------------------------------
*   Skriv ut ett exceldokument med alla resultat
*-------------------------------------------------------------------------------

set labels "Labels for the excel sheet" /fishery,species,resLabel,time,scen,sens,value/;
execute_unload "%RESDIR%\chk_merge.gdx";

execute 'gdxxrw i=%RESDIR%\chk_merge.gdx o=%RESDIR%\sens_results.xlsx set=labels rng=sens!A2 rdim=0 cdim=1 par=p_fiskResultatSens rng=sens!A3 rdim=6 cdim=0';