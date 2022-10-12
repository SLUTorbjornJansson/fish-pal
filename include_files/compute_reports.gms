*###############################################################################
*   Compute the contents of the various report parameters
*   using the present state of all model variables, equations and parameters
*   This file is used both directly after simulation, but also for comparing
*   several simulations
*###############################################################################



*###############################################################################
*   Rapportera l�nsamhet per fiske
*###############################################################################

p_profitFishery(f,"totalSalesRevenues") = SUM(s $ fishery_species(f,s),v_sortA.L(f,s)*p_pricesAOri(f,s) + v_sortB.L(f,s)*p_pricesBOri(s)*p_landingObligation(f,s));


p_profitFishery(f,"totalVariableCosts") = -v_varCostAve.L(f)*v_effortAnnual.L(f);

*   T�ckningsbidrag (inklusive arbete som r�rlig kostnad)
p_profitFishery(f,"totalContrMarg") = p_profitFishery(f,"totalSalesRevenues")
                                    + p_profitFishery(f,"totalVariableCosts");

*   F�r�dlingsv�rde (value added)

p_VCshareLab(f) = [p_varCostOri(f,"PaidLabour")+ p_varCostOri(f,"UnpaidLabour")] / SUM(VariableInput, p_varCostOri(f,VariableInput)) ;

p_profitFishery(f,"totalGrossVA") = p_profitFishery(f,"totalSalesRevenues")
                                    + p_profitFishery(f,"totalVariableCosts")*(1-p_VCshareLab(f));

p_profitFishery(f,"totalSubsidy") = p_subsidyPerDAS(f)*v_effortAnnual.L(f);

p_profitFishery(f,"totalModifiedGrossVA") = p_profitFishery(f,"totalGrossVA") + p_profitFishery(f,"totalSubsidy");

*   Rapportera �ven PMP-termens storlek
p_profitFishery(f,"totalPMP") = -(pv_PMPconst.L(f)*v_effortAnnual.L(f) + 1/2*pv_PMPslope.L(f)*sqr(v_effortAnnual.L(f)));

*   Aggregera fishery till segment, area osv.
p_profitFishery(fisheryDomain,resLabel) $ [NOT fishery(fisheryDomain)]
    = SUM(fishery $ fisheryDomain_fishery(fisheryDomain,fishery), p_profitFishery(fishery,resLabel));

*   Fasta kostnader finns endast per segment
p_profitFishery(seg,"totalFixCosts") = -p_fixCostSumOri(seg)*v_vessels.L(seg);

*   Vinst per segment
p_profitFishery(seg,"totalProfit") = p_profitFishery(seg,"totalContrMarg")
                                   + p_profitFishery(seg,"totalSubsidy")
                                   + p_profitFishery(seg,"totalFixCosts");

*   Summera hela sektorn
p_profitFishery("total",resLabel) = SUM(seg, p_profitFishery(seg,resLabel));


*   Ber�kna genomsnittliga kostnader och int�kter per DAS
p_profitFishery(fisheryDomain,"aveRevenues")      $ p_fiskresultat(fisheryDomain,"allSpecies","v_effortAnnual","sim")
    = p_profitFishery(fisheryDomain,"totalSalesRevenues")      / p_fiskresultat(fisheryDomain,"allSpecies","v_effortAnnual","sim");

p_profitFishery(fisheryDomain,"aveVariableCosts") $ p_fiskresultat(fisheryDomain,"allSpecies","v_effortAnnual","sim")
    = p_profitFishery(fisheryDomain,"totalVariableCosts") / p_fiskresultat(fisheryDomain,"allSpecies","v_effortAnnual","sim");

p_profitFishery(fisheryDomain,"aveGrossVA")       $ p_fiskresultat(fisheryDomain,"allSpecies","v_effortAnnual","sim")
    = p_profitFishery(fisheryDomain,"totalGrossVA")       / p_fiskresultat(fisheryDomain,"allSpecies","v_effortAnnual","sim");

p_profitFishery(fisheryDomain,"aveFixCosts")      $ p_fiskresultat(fisheryDomain,"allSpecies","v_effortAnnual","sim")
    = p_profitFishery(fisheryDomain,"totalFixCosts")      / p_fiskresultat(fisheryDomain,"allSpecies","v_effortAnnual","sim");

p_profitFishery(fisheryDomain,"aveProfit")        $ p_fiskresultat(fisheryDomain,"allSpecies","v_effortAnnual","sim")
    = p_profitFishery(fisheryDomain,"totalProfit")        / p_fiskresultat(fisheryDomain,"allSpecies","v_effortAnnual","sim");

p_profitFishery(fisheryDomain,"aveContrMarg")     $ p_fiskresultat(fisheryDomain,"allSpecies","v_effortAnnual","sim")
    = p_profitFishery(fisheryDomain,"totalContrMarg")     / p_fiskresultat(fisheryDomain,"allSpecies","v_effortAnnual","sim");

p_profitFishery(fisheryDomain,"aveSubsidy")      $ p_fiskresultat(fisheryDomain,"allSpecies","v_effortAnnual","sim")
    = p_profitFishery(fisheryDomain,"totalSubsidy")      / p_fiskresultat(fisheryDomain,"allSpecies","v_effortAnnual","sim");

p_profitFishery(fisheryDomain,"aveModifiedGrossVA")      $ p_fiskresultat(fisheryDomain,"allSpecies","v_effortAnnual","sim")
    = p_profitFishery(fisheryDomain,"totalModifiedGrossVA")      / p_fiskresultat(fisheryDomain,"allSpecies","v_effortAnnual","sim");

p_profitFishery(fisheryDomain,"avePMP")           $ p_fiskresultat(fisheryDomain,"allSpecies","v_effortAnnual","sim")
    = p_profitFishery(fisheryDomain,"totalPMP")           / p_fiskresultat(fisheryDomain,"allSpecies","v_effortAnnual","sim");


*###############################################################################
*   Rapportera fyllgrad och skuggpris på kvoter, hopplockat från p_fiskresultat
*###############################################################################

set quotaReport_from_fiskResultat(resLabel,resLabel,statItem) "Mapping from fiskresultat to p_quotaReport"/
    p_TACOri.(p_TACOri.sim)     "Quota in regulation"
    TACadj.(TACadj.sim)         "Quota after calibration"
    dualTAC.(e_catchQuota.M)    "Shadow price of the catch quota"
    v_landings.(v_landings.sim) "Landings"
    v_catch.(v_catch.sim)       "Catch"
    /;

*   Copy results from the results parameter as per the mapping above, but only if there is a quota
p_quotaReport(quotaArea,catchQuotaName,resLabel) $ p_TACori(catchQuotaName,quotaArea)
    = sum((resLabel1,statItem) $ quotaReport_from_fiskResultat(resLabel,resLabel1,statItem),
            p_fiskResultat(quotaArea,catchQuotaName,resLabel1,statItem));




*###############################################################################
*   Rapportera effortrestriktioner
*###############################################################################


p_kwhPerEffortGroupOri(effortGroup,area,"ori") $ p_maxEffortPerEffortGroup(effortGroup,area)

  = sum(f $ [fishery_effortGroup(f,effortGroup) and fishery_area(f,area)],
                    p_effortOri(f) * sum(seg $ segment_fishery(seg,f), p_kwhOri(seg)));

p_kwhPerEffortGroupOri(effortGroup,area,"max") = p_maxEffortPerEffortGroup(effortGroup,area);
p_kwhPerEffortGroupOri(effortGroup,area,"sim") = v_effortPerEffortGroup.L(effortGroup,area);


    p_kwhPerFisheryInEffortGroup(f,effortGroup,area,"kwh")
        $ [fishery_effortGroup(f,effortGroup) and fishery_area(f,area)]
        = p_effortOri(f) * sum(seg $ segment_fishery(seg,f), pv_kwh.L(seg));

    p_kwhPerFisheryInEffortGroup(f,effortGroup,area,"days")
        $ [fishery_effortGroup(f,effortGroup) and fishery_area(f,area)]
        = p_effortOri(f);


*###############################################################################
*   Rapportera marginaleffekter - Lagrangefunktionens partialderivator!
*   1) Med detaljerade uppgifter om varje kvot
*   2) Med total kvotr�nta f�r hela fisket
*###############################################################################

*   1: Detaljerade skuggpriser p� kvoter

* --- Rapportera kvotr�ntor per fishery, uppdelat p� kvotomr�de och art,
*     men omr�knat som marginalkostnad per fiskedag

p_reportDualsFisheryQuota(f,quotaArea,catchQuotaName,"shadowPriceQuota") $  quotaArea_fishery(quotaArea,f)
    = - SUM(s $ [catchQuotaName_quotaArea_fishery_species(catchQuotaName,quotaArea,f,s)
                  AND (p_TACori(catchQuotaName,quotaArea) GT 0)], e_catchQuota.M(catchQuotaName,quotaArea));


p_reportDualsFisheryQuota(f,quotaArea,catchQuotaName,"marginalLandingA") $ quotaArea_fishery(quotaArea,f)
    = SUM(s $ [catchQuotaName_quotaArea_fishery_species(catchQuotaName,quotaArea,f,s)],
            p_shareA(f,s) * pv_delta.L(f,s)*[p_catchElasticity(f)*v_effortAnnual.L(f)**(p_catchElasticity(f)-1)]);


p_marginalCatch(f,s) = [p_catchElasticity(f)*v_effortAnnual.L(f)**(p_catchElasticity(f)-1)];

p_reportDualsFisheryQuota(f,quotaArea,catchQuotaName,"marginalLandingB") $ quotaArea_fishery(quotaArea,f)
    = SUM(s $ catchQuotaName_quotaArea_fishery_species(catchQuotaName,quotaArea,f,s),
            p_landingObligation(f,s) * p_shareB(f,s) * pv_delta.L(f,s)*[p_catchElasticity(f)*v_effortAnnual.L(f)**(p_catchElasticity(f)-1)]);

*p_reportDualsFisheryQuota(f,quotaArea,catchQuotaName,"marginalLandingA") $ quotaArea_fishery(quotaArea,f)
*    = p_reportDualsFisheryQuota(f,quotaArea,catchQuotaName,"marginalCatch") * p_shareA(f,s);

*p_reportDualsFisheryQuota(f,quotaArea,catchQuotaName,"marginalLandingB") $ quotaArea_fishery(quotaArea,f)
*    = p_reportDualsFisheryQuota(f,quotaArea,catchQuotaName,"marginalCatch") * p_shareB(f,s) * p_landingObligation(f,s);

*   Compute how much the quota rent costs each fishery on the margin, i.e. the marginal catch times the quota rent of each species landed

p_reportDualsFisheryQuota(f,quotaArea,catchQuotaName,"dualTAC") $ quotaArea_fishery(quotaArea,f)
    = p_reportDualsFisheryQuota(f,quotaArea,catchQuotaName,"shadowPriceQuota")
    * (p_reportDualsFisheryQuota(f,quotaArea,catchQuotaName,"marginalLandingA")
      +p_reportDualsFisheryQuota(f,quotaArea,catchQuotaName,"marginalLandingB"));


*   2: Marginalint�kter och kostnader per fiske, med aggregerad kostnad f�r alla kvotr�ntor

*   Marginalint�kter fr�n f�rs�ljning av fisk (derivatan av f�ngsfnk. g�nger marknadspriset)
p_reportDualsFishery(f,"dualMR")
    = SUM(s $ fishery_species(f,s), (p_pricesAOri(f,s)*p_shareA(f,s)+p_pricesBOri(s)*p_shareB(f,s)*p_landingObligation(f,s))
                                    *pv_delta.L(f,s)*[p_catchElasticity(f)*v_effortAnnual.L(f)**(p_catchElasticity(f)-1)]);

*   Marginalint�kter fr�n st�d
p_reportDualsFishery(f,"dualSubsidy")
    = p_subsidyPerDAS(f);

*   Variabla kostnader
p_reportDualsFishery(f,"dualVarCost") = - (pv_varCostConst.L(f) + pv_varCostSlope.L(f)*v_effortAnnual.L(f));

*   Kalibreringstermen
p_reportDualsFishery(f,"dualPMP") = - (pv_PMPconst.L(f) + pv_PMPslope.L(f)*v_effortAnnual.L(f));

*   Marginella skuggkostnader f�r f�ngstkvoter (kvotpris)
p_reportDualsFishery(f,"dualTAC")
    = SUM((quotaArea,catchQuotaName), p_reportDualsFisheryQuota(f,quotaArea,catchQuotaName,"dualTAC"));

*   Effortrestriktioner per segment: skuggpriset �r detsamma f�r alla ing�ende fisken
*   Genom att summera �ver segment hittar vi det segment till vilket detta fiske h�r.
p_reportDualsFishery(f,"dualEffRestrSeg")
    = - SUM(seg $ segment_fishery(seg,f), e_effRestrSeg.M(seg));

*   Effortrestriktioner per fisketyp
p_reportDualsFishery(f,"dualEffRestrFishery")
    = - e_effRestrFishery.M(f);

*   Effortrestriktioner per fisketyp
p_reportDualsFishery(f,"dualEffortRegulation")
    = sum((effortGroup,area) $ [fishery_effortGroup(f,effortGroup) and fishery_area(f,area) and p_maxEffortPerEffortGroup(effortGroup,area)],
                    -e_effortRegulation.M(effortGroup,area) * sum(seg $ segment_fishery(seg,f), pv_kwh.L(seg)));

*   Ev. skuggpris p� en gr�ns f�r EffortAnnual (t.ex. icke-negativitet)
p_reportDualsFishery(f,"dualBoundEffortAnnual")
    = -v_effortAnnual.M(f);

*   Ber�kna summan av alla partialderivatorna, dvs alla dualResults.
p_reportDualsFishery(f,"sumOfDuals") = sum(dualResult $ (not sameas(dualResult,"sumOfDuals")), p_reportDualsFishery(f,dualResult));

*$macro weightedMean(setMapping, data, weight) \
*         [sum(setMapping, data*weight) / sum(setMapping, weight)] $ sum(setMapping, weight)

*   Aggregera fishery till segment, area osv. genom att vikta med fiskeanstr�ngning, men bara om vikten �r icke-noll
*   Aggregat (tex segment) tolkas d�rf�r som genomsnittligt v�rde per fiskedag f�r alla fisken (f) som ing�r i segmentet, viktat med fiskets fiskedagar
p_reportDualsFishery(fisheryDomain,dualResult)
    $ [(NOT fishery(fisheryDomain))
      AND SUM(fishery $ fisheryDomain_fishery(fisheryDomain,fishery), v_effortAnnual.L(fishery))]
    = SUM(fishery $ fisheryDomain_fishery(fisheryDomain,fishery), p_reportDualsFishery(fishery,dualResult)*v_effortAnnual.L(fishery))
    / SUM(fishery $ fisheryDomain_fishery(fisheryDomain,fishery), v_effortAnnual.L(fishery));
*p_reportDualsFishery(fisheryDomain,dualResult) $ [not fishery(fisheryDomain)]
*         = weightedMean(fisheryDomain_fishery(fisheryDomain,f),p_reportDualsFishery(f,dualResult),v_effortAnnual.L(f));


* Report that reports input and output quantities, prices and revenue/cost (i.e. p*q)

p_InputOutputReport(f, VariableInput, "PQ") =  (pv_varCostConst.L(f)*v_effortAnnual.L(f) + 1/2*pv_varCostSlope.L(f)*sqr(v_effortAnnual.L(f)))
*       ... shifted by an exogenous change in price or quantity of each cost item, weighted with its share in VC
*           In the baseline scenario, the shifters must be zero and the shares add up to 1
               * p_varCostOriShare(f,VariableInput)
                       *(1 + p_varCostPriceShift(f,VariableInput))
                       *(1 + p_varCostQuantShift(f,VariableInput)) ;
                       
p_InputOutputReport(f, VariableInput, "P")  = (p_InputPrice(f, VariableInput) *(1 + p_varCostPriceShift(f,VariableInput))) ;
p_InputOutputReport(f, VariableInput, "Q")  = p_InputOutputReport(f, VariableInput, "PQ") / (p_InputPrice(f, VariableInput) *(1 + p_varCostPriceShift(f,VariableInput))) ;

p_InputOutputReport(fisheryDomain, VariableInput, "Q")$(NOT fishery(fisheryDomain)) = SUM(fishery $ fisheryDomain_fishery(fisheryDomain,fishery), p_InputOutputReport(fishery,VariableInput, "Q")) ;
p_InputOutputReport(fisheryDomain, VariableInput, "PQ")$(NOT fishery(fisheryDomain)) = SUM(fishery $ fisheryDomain_fishery(fisheryDomain,fishery), p_InputOutputReport(fishery,VariableInput, "PQ")) ;
p_InputOutputReport(fisheryDomain, VariableInput, "P")$(sum(f $ fisheryDomain_fishery(fisheryDomain,f), 1) ge 1) = p_InputOutputReport(fisheryDomain,VariableInput, "PQ") / p_InputOutputReport(fisheryDomain,VariableInput, "Q");


