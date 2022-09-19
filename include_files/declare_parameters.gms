PARAMETERS
    p_pricesAOri(fishery,species)  "Original (excel) price of sort A fish per fishery and species"
    p_pricesBOri(species)          "Original (excel) price of sort B fish, for industrial use, same for all fisheries but possibly different per species"
    p_pricesA(fishery,species)     "Simulation price of sort A fish per fishery and species (read from data file)"
    p_pricesB(species)             "Simulation price of sort B fish, for industrial use, same for all fisheries but possibly different per species"
    p_shareA(fishery,species)      "Share of catch that is of sort A"
    p_shareB(fishery,species)      "Share of catch that is of sort B"
    p_costOri(segment,cost)        "Cost structure per segment, in annual totals (tkr/year)"
    p_fuelOri(segment)             "Fuel use in m3 per segment and year"
    p_fuelPerEffort(fishery)       "Fuel use per day at sea for each fishery (for reporting)"
    p_employmentOri(segment,employmentItem) "Employment per segment measured in various ways"
    p_employmentPerEffort(fishery,employmentItem) "Staff use per day at sea for each fishery (for reporting)"
    p_varCostOri(fishery,varCost)  "Variable cost per fishery and cost category per effort (tkr/day)"
    p_varCostAveOri(fishery)       "Sum of variable cost categories per fishery per effort (tkr/day)"
    p_varCostAveDist(fishery,statItem) "Distributional statistics for sum of variable costs, e.g. variance, expected value"
    p_fixCostOri(segment,fixCost)  "Fixed cost per vessel and cost category (tkr/vessel)"
    p_fixCostSumOri(segment)       "Sum of fixed cost categories per vessel (tkr/vessel)"
    p_maxEffSegPeriod(seg,p)    "Max effort per segment and period (days per vessel)"
    p_maxEffSeg(seg)            "Maximum possible number of fishing days per segment and year (days per vessel)"
    p_season(fishery,period)    "Fishery season (fishery possible)"
    p_TACOri(catchQuotaName,quotaArea) "Total Allowable Catch per species, quota type (e.g. Coastal Quota) and area"
    p_TACchange(catchQuotaName,quotaArea) "Change in Total Allowable Catch per species, quota type (e.g. Coastal Quota) and area e.g. trade with DK"
    p_TACnetto(catchQuotaName,quotaArea) "Net Total Allowable Catch per species, quota type (e.g. Coastal Quota) and area after TACchange"
    p_catchOri(fishery,species)     "Catch of different species per unit of effort of each fishery (tons/day)"
    p_landingsOri(fishery,species)  "Landings of different species per unit of effort of each fishery (tons/year)"
    p_discardsOri(fishery,species)  "Discards of different species per unit of effort of each fishery (tons/year)"
    p_discardShareOri(fishery,species)  "Share of discards (share of total catch of all species)"
    p_catchElasticityPerGearGroup(gearGroup)  "Elasticity of catch w.r.t. effort, a.k.a. beta in the cobb-douglas function"
    p_catchElasticity(fishery)  "Elasticity of catch w.r.t. effort, a.k.a. beta in the cobb-douglas function"
    p_effortOri(fisheryDomain)  "Total effort per fishery registered in base data"
    p_vesselsOri(segment)       "Total number of vessels per segment in base data"
    p_landingObligation(fishery,species) "Indication if (1) sort B needs to be landed or if (0) discard is allowed"
    p_maxEffortPerEffortGroup(effortGroup,area) "Maximum kWh-days per effortGroup and area"
    p_kwhOri(segment) "Average kwh per vessel per segment"
    p_fiskResultat(fisheryDomain,*,resLabel,statItem) "Rapport från fiskmodellen för GUI"

*   Seal scenario parameters
    p_ShareDASseal(fishery) "Share of days at sea when seal damage is observed"
    p_subsidyPerDAS(fishery)"Subsidy per fishery (tkr/DAS)"
    p_sealDamage(fishery)   "Total value of seal damage per fishery"

*   Parameters relating to some exogenous shocks such as variable costs
    p_varCostOriShare(fishery,varCost) "Share in total variable cost for each of the variable cost components"
    p_varCostPriceShift(fishery,varCost) "Exogenous shift in the price of each variable cost (relative change, -0.2 means -20%)"
    p_varCostQuantShift(fishery,varCost) "Exogenous shift in the use per day of each variable cost (relative change, -0.2 means -20%)"   


*   Parameters for steering and monitoring convergence behaviour
    p_projectedEffort(fishery) "Projected effort for next iteration. Partial adjustment for subsidy computation"
    p_iterDeviations(iterations) "Sum of squared deviations of effort from previous simulation, used as convergence measure"
    p_iterEffort(iterTot,f) "Effort level in each iteration"
    p_iterReport(f,iterTot) "A report for the list file with relative change from previous iteration"
    p_solutionStats(*) "Some characteristics of the solution"
    ;



SCALARS
*   Items for subsidy computations
    p_subsidyBudgetOri      "Original target amount for subsidy (tkr)"
    p_subsidyBudget         "Target amount for subsidy used in model (tkr)"
    p_subsidyBudgetSpent    "Amount of subsidy spent (tkr)"

*   Items for steering and checking convergense
    p_convergenceTolerance "Mean squared deviation criterion for exit"
    p_meanSquaredDeviation "Mean squared deviation of current iteration"
    p_stopSolvingModel "Signal if we should stop solving the model because (1) it converged, (2) iteration limit was reached"
    ;

*###############################################################################
*   Parameters for reporting
*###############################################################################

PARAMETER p_profitFishery(fisheryDomain,resLabel) "Total profit and profit per day of effort, disaggregated into revenues and costs";
PARAMETER p_VCshareLab(f) "share of VC that is paid and unpaid labour, used for correct GVA calculation" ;
PARAMETER p_reportDualsFisheryQuota(fisheryDomain,quotaArea,catchQuotaName,*) "F�rklaring av marginell kvotr�nta per fiske";
PARAMETER p_marginalCatch(f,s);
PARAMETER p_reportDualsFishery(fisheryDomain,resLabel) "Resultat f�r den marginella l�nsamheten i varje fiske, inklusive skuggpriser";
PARAMETER p_kwhPerEffortGroupOri(effortGroup,area,*);
PARAMETER p_kwhPerFisheryInEffortGroup(fishery,effortGroup,area,*);


*###############################################################################
*   Initialize parameters that can in fact be zero but should be reported anyway
*###############################################################################

OPTION KILL=p_varCostPriceShift;
OPTION KILL=p_varCostQuantShift;

*OPTION KILL=p_fuelUsePerDay;
*OPTION KILL=p_fuelTaxPerLitre;
