$ONTEXT
    Läs in många resultatfiler och skriv ut de sammanlagda resultaten till excel

    Detta kan användas på olika sätt, men det ursprungliga syftet var att
    sammanställa resultat av känslighetsanalyser.

    Känslighetsanalyserna gjordes för en svit av scenarier
    genom att kalibrera om modellen till andra parametervärden och
    sedan köra om samma svit av scenarier.

    T. Jansson, 2021


$OFFTEXT

*-------------------------------------------------------------------------------
*   Kontrollpanelen: Inställningar för detta program
*-------------------------------------------------------------------------------

* Del av filnamnen som är likadan i alla scenarier och känlighetsanalyser
$set FILENAME_PREFIX sim_seal

* Referens-scenariots namn. Vi antar att det bara finns ETT referensscenario
$set REF_SCEN "reference"

* Sökväg till resultaten. Borde aldrig ändras.
$set resdir ".\output\simulation"

* Det blir många resultat. Här väljer vi ut dimensioner att exportera.
* Välj elementet "*" för att välja "alla fisken" osv.
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
*   Deklarationer som förmodligen inte ändras
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
* Välj ut endast vissa resultat baserat på angivelser längst upp i denna fil
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
* Loopa över alla filnamn och läs in motsvarande gdx-fil
*-------------------------------------------------------------------------------

parameter p_fiskResultat(fisheryDomain,speciesDomain,resLabel,time);
parameter p_fiskResultatSens(fisheryDomain,speciesDomain,resLabel,time,scenAll,sens);

*   Läs in referensscenariot. Detta görs separat eftersom vi inte laddar några
*   känslighetsanalyser för just det scenariot.
execute_load "%RESDIR%\%FILENAME_PREFIX%_%REF_SCEN%" p_fiskResultat;
p_fiskResultatSens(selFishery,selSpecies,selResLabel,selTime,scenRef,sensDefault)
    = p_fiskResultat(selFishery,selSpecies,selResLabel,selTime);


*   Läs in alla känslighetsanalyser för vart och ett av de scenarier som finns
*   i mängden scenSens.
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