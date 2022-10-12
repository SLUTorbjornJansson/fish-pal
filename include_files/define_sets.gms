*###############################################################################
*   Define sets
*   These definitions are used both in simulation and in reporting
*###############################################################################

*   Open the GDX-file where the sets are stored
*   In simulation, it is the converted excel file
*   In reporting, it is one of the result files from the simulation
$GDXIN "%fileNameForSetDefnitions%"

* Definiera prim�ra set, som �r byggstenar f�r alla andra set i modellen
SETS
    segment     "Fartygstyp"
    s_segment   "Anv�nds f�r att skapa en dom�n f�r segment"
    gear      "Redskap, m�lart och maskstorlek"
    s_gear    "Anv�nds f�r att skapa en dom�n f�r gear"
    area        "Fiskeomr�de"
    s_area      "Anv�nds f�r att skapa en dom�n f�r area"
    species     "Fiskart och anv�ndning"
    s_species   "Anv�nds f�r att skapa en dom�n f�r species"
    period      "Del av kalender�r"

*   Convenient subsets and tuples (combinations of elements belonging together)
    fishery     "Permissible combination of segment, gear and area"
    s_fishery   "Anv�nds f�r att skapa en dom�n f�r fishery"
    quotaArea   "Catch quota regions"
    s_quotaArea "Anv�nds f�r att skapa en dom�n f�r quotaArea"
    catchQuotaName "Species used in quota definition, which are sometimes aggregates of species"
    s_catchQuotaName "Anv�nds f�r att skapa en dom�n f�r catchQuotaName"
    s_effortGroup "List of elements for EffortGroup"
    gearGroup   "Groups of gear, for instance fixed gear"

*   Input items (items to use for quantities and costs)
    s_VariableInput   "Variable cost items"
    s_FixInput   "Fixed cost items. Do not have p and q for this so keep as cost"

    
    ;

ALIAS(segment,seg);
ALIAS(gear,g);
ALIAS(area,a);
ALIAS(species,s);
ALIAS(period,p);
ALIAS(fishery,f);


* L�s in set fr�n GDX-filen
$LOAD s_segment=segment s_gear=gear s_area=area s_species=species
$LOAD s_fishery=fishery s_quotaArea=quotaArea s_VariableInput=VariableInput s_FixInput=FixInput period s_catchQuotaName=catchQuotaName
$LOAD s_effortGroup=effortGroup gearGroup 

* Skapa ett set som inneh�ller "species UNION catchQuotaName", att ha som dom�n f�r vissa parametrar (f�r resultatfiler)
* F�r att klara UNIONEN anv�nder vi tricket "$ONMULTI" f�r att l�gga till nya delvis �verlappande element
* P� samma s�tt vill vi ha en dom�n i resultatdatan som inneh�ller fishery UNION segment UNION "andra grejer"


$ONMULTI
* Skapa en dom�n, dvs ett set som kan anv�ndas i deklarationer i GAMS, f�r species, catchQuotaName
* Det kr�vs tv� rader eftersom vissa element i species upprepas i catchQuotaName.
SETS
    s_ioAggregate(*) "Aggregates of inputs and outputs" /allSpecies "Alla arter", none "Nothing", variableInputs "Variable inputs", fixInputs "Fix inputs", inputs "All inputs", TB1 "Revenues minus variable costs", TB2 "TB1 minus fix costs"/
    speciesDomain(*) "Lägg till species" /set.s_ioAggregate,SET.s_species, set.s_FixInput, set.s_VariableInput /
    speciesDomain(*) "Lägg till catchQuotaName" /SET.s_catchQuotaName,SET.s_area /

    fisheryDomain(*) "Lägg till fishery, segment mm" /total "Alla fisketyper", na "Not applicable or not used", SET.s_fishery,SET.s_segment,SET.s_gear,SET.s_area/
    fisheryDomain(*) "Lägg till quotaArea" /SET.s_quotaArea, SET.s_effortGroup/

* Nu kan vi g�ra species och catchQuotaName som delm�ngder av speciesDomain
    species(speciesDomain) "L�gg till element i species" /SET.s_species /
    catchQuotaName(speciesDomain) "L�gg till element i catchQuotaName" /SET.s_catchQuotaName/

* ... och likas� definiera fishery, segment etc som delm�ngder av fisheryDomain
    fishery(fisheryDomain) "Definiera element i fishery" /SET.s_fishery/
    segment(fisheryDomain) "Definiera element i segment" /SET.s_segment/
    gear(fisheryDomain) "Definiera element i gear" /SET.s_gear/
    area(fisheryDomain) "Definiera element i area" /SET.s_area/
    quotaArea(fisheryDomain) "Areas with their own quota regulation" /SET.s_quotaArea/
    effortGroup(fisheryDomain) "Groups of fisheries that are fall under the same effort regulation" /SET.s_effortGroup/

* ... Variabla kostnader plus total variabel kostnad
    Input(speciesDomain)    "Kostnader: fasta, r�rliga, summor" /SET.s_FixInput, SET.s_VariableInput/
    FixInput(Input) "Fasta kostnader" /SET.s_FixInput/
    VariableInput(Input) "Variabla kostnader plus total variabel kostnad " /SET.s_VariableInput/
    ioAggregate(speciesDomain) "Aggregates of individual inputs and outputs" /set.s_ioAggregate/;
    ;
$OFFMULTI

*   H�r f�ljer definitioner av alla "kors-set" a.k.a. "tuples, mappings".
*   Vi g�r det i ett eget block f�r att kunna ha "domain checking":
*   Vi m�ste allst� f�rst definiera alla "enskilda" set, s�som fishery, segment...
*   f�r att kunna anv�nda dessa som dom�n �t kors-setten.

SETS
    f_seg_g_a(fishery,segment,gear,area)  "Fiske kopplat till segment, redskap och fiskeområde"
    quotaArea_area(quotaArea,area)          "Composition of quota regions in terms of geographical regions"
    catchQuotaName_species(catchQuotaName,s)    "Composition of quota regions in terms of geographical regions"
    segment_fishery(segment,fishery)        "Segment to which each fishery belongs"
    fishery_species(fishery,species)        "Species that can be caught within fishery"
    quotaArea_fishery(quotaArea,fishery)    "Quota area in which each fishery is active"
    catchQuotaName_fishery(catchQuotaName,fishery) "Use of catchQuota by fishery"
    fishery_catchQuotaName(fishery,catchQuotaName) "Definition of fisheries allowed to land under different quotas"
    catchQuotaName_fishery_species(catchQuotaName,fishery,species) "Permission to utilize quota for each fishery and species"
    catchQuotaName_quotaArea_fishery_species(catchQuotaName,quotaArea,fishery,species) "Permission to utilize area specific quota for each fishery and species"
    fishery_effortGroup(fishery,effortGroup) "Fisheries adding up to the effortGroups"
    fishery_area(fishery,area) "Fishery active in area"
    fishery_gear(fishery,gear) "Fishery using gear"
    gearGroup_gear(gearGroup,gear) "Gear belonging to each group"

*   Definitioner av olika aggregat som �r smidiga att anv�nda vid rapportering
    fisheryDomain_fishery(fisheryDomain,fishery) "Mapping of fishery to aggregate"
    
    ioAggregate_speciesDomain(ioAggregate,speciesDomain) "Mapping items from speciesDomain to aggregate" /
    allSpecies.(#species)
    variableInputs.(#VariableInput)
    fixInputs.(#FixInput)
    inputs.(#Input)
    /;
;

* L�s in tuples fr�n GDX-filen
$LOAD f_seg_g_a quotaArea_area catchQuotaName_species fishery_catchQuotaName fishery_effortGroup gearGroup_gear

* Close the GDX-file
$GDXIN


*###############################################################################
*   Sets used for reporting
*###############################################################################
sets
*   Distributional statistics for random variables used in estimation
    statItem    "Statistical items to use in reporting and in estimation"
        /mean   "Mean"
         var    "Variance"
         ori    "Original data"
         est    "Estimated value (or fitted value for observable variables)"
         sim    "Simulation outcome or value of parameter in simulation"
         M      "Dual value of bound on variable or equation"
         UP     "Upper bound of variable or equation"
         LO     "Lower bound of variable or equation"/

    s_dualResult(*) "Items for dual report"   /
        dualMR  "Marginal revenues"
        dualSubsidy "Marginal subsidy"
        dualVarCost "Variable costs"
        dualPMP "Marginal effect of PMP"
        dualTAC "Marginal quota rent"
        dualEffRestrSeg "Marginal cost of segment effort restriction"
        dualEffRestrFishery "Marginal cost of effort restriction per fishery, or season"
        dualBoundEffortAnnual "Dual value of bound on effortAnnual"
        dualEffortRegulation "Dual value of Effort Regulation"
        sumOfDuals "Sum of the partials of the Lagrangean function"
        /

    resLabel(*)    "Result label, such as name of parameter, variable, equation or other model item" /
        v_effortAnnual  "Days at sea"
        v_catch         "Catch"
        v_landings
        v_discards
        v_sortA         "High quality product (standard price)"
        v_sortB         "Fish for industrial processing into fish meal (low price)"
        v_estimationMetric

        e_CatchQuota    "Quota equation"
        e_effRestrSeg
        e_effRestrFishery

        pv_PMPconst
        pv_PMPslope
        pv_delta
        v_varCostAve

        p_TACOri        "Original (regulation) catch quota per species and region"
        TACadj          "Effective TAC adjusted in calibration (p_TACori*pv_TACadjustment)"
        p_landingObligation "Landing obligation per fishery and species"
        pv_maxEffFishery
        pv_kwh
        v_effortPerEffortGroup
        p_pricesA "Price of Sort A, used in simulation"
        p_pricesB "Price of Sort B, used in simulation"
        p_subsidyPerDAS "Subsidy per DAS (compensation for seal damage)"
        P "price for input or output"
        Q "quantity for input or output"
        PQ "Cost/Revenue for input or output"

        totalSalesRevenues "Total revenues from fish sales"
        totalVariableCosts "Total variable costs"
        totalContrMarg     "Contribution Margin = revenues minus variable costs"
        totalGrossVA       "Gross Value Added = revenues minus variable costs that are not labour"
        totalSubsidy       "Total subsidy received"
        totalModifiedGrossVA "Modified Gross Value Added = Gross Value Added plus Subsidies"
        totalFixCosts      "Total fixed costs (per vessel)"
        totalProfit        "Revenues minus all costs"
        totalPMP           "Income from PMP term"

        aveRevenues      "Average revenues per DAS"
        aveVariableCosts "Total variable costs per DAS"
        aveContrMarg     "Contribution Margin = revenues minus variable costs per DAS"
        aveGrossVA       "Gross Value Added = revenues minus variable costs that are not labour per DAS"
        aveSubsidy       "Total subsidy received"
        aveModifiedGrossVA "Modified Gross Value Added = Gross Value Added plus Subsidies"
        aveFixCosts      "Total fixed costs (per vessel) per DAS"
        aveProfit        "Revenues minus all costs per DAS"
        avePMP           "Income from PMP term per DAS"

*       Items for input use(employment and fuel)

        set.VariableInput

*       Items for dual report
        set.s_dualResult

        /

    dualResult(resLabel) "Items for dual report" /set.s_dualResult/
    ;

alias(resLabel,resLabel1);

*   Skapa set som underl�ttar aggregeringen
SET addVars(resLabel) "Variabler som kan adderas utan att bli meningsl�sa (kvantiteter)" /v_effortAnnual,v_catch,v_varCostAve/;
SET addStat(statItem) "Datatyper som kan adderas utan att bli meningsl�sa"  /sim,ori,est/;
*set aggregateStatItem(statItem) "Aggregate these items, including for instance est and ori";

*   Skapa set som anv�nds f�r att styra iterativ l�sning av modellen
set iterTot /sim,i0*i100/;
set iterations(iterTot) "Iterations with the model to converge to equilibrium subsidies" /i0*i100/;
set iterUsed(iterations) "Iterations that were used in the process";
alias(iterations,iterations1);

option kill = iterUsed;
