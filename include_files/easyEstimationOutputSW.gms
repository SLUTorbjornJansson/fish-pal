
** output to be easily accesible for checking if estimation differs from original data **


** catch  **
PARAMETER p_catchSpecies(s, resLabel,*) "Catch by species in tons/year";
* p_fiskResultat(fisheryDomain,speciesDomain,resLabel,statItem)

p_catchSpecies(s,"v_catch","ori") = sum(f, p_catchOri(f,s));
p_catchSpecies(s,"v_catch","est") = sum(f, v_catch.L(f,s));
p_catchSpecies(s,"v_catch","diff") = p_catchSpecies(s,"v_catch","est") - p_catchSpecies(s,"v_catch","ori") ;
p_catchSpecies(s,"v_catch","diff%") = p_catchSpecies(s,"v_catch","diff")/ p_catchSpecies(s,"v_catch","ori");


PARAMETER p_catchSpeciesFishery(f,s, resLabel,*) "Catch by species in tons/year";


p_catchSpeciesFishery(f,s,"v_catch","ori") = p_catchOri(f,s);
p_catchSpeciesFishery(f,s,"v_catch","est") = v_catch.L(f,s);
p_catchSpeciesFishery(f,s,"v_catch","diff") = p_catchSpeciesFishery(f,s,"v_catch","est")- p_catchSpeciesFishery(f,s,"v_catch","ori") ;
p_catchSpeciesFishery(f,s,"v_catch","diff%") $p_catchSpeciesFishery(f,s,"v_catch","ori")//
                  = p_catchSpeciesFishery(f,s,"v_catch","diff")/ p_catchSpeciesFishery(f,s,"v_catch","ori");


** landings **
PARAMETER p_landingsSpecies(s, resLabel,*) "Catch by species in tons/year";
* p_fiskResultat(fisheryDomain,speciesDomain,resLabel,statItem)

p_landingsSpecies(s,"v_landings","ori") = sum(f, p_landingsOri(f,s));
p_landingsSpecies(s,"v_landings","est") = sum(f, v_sortA.L(f,s)+p_landingObligation(f,s)*v_sortB.L(f,s));
p_landingsSpecies(s,"v_landings","diff") = p_landingsSpecies(s,"v_landings","est") - p_landingsSpecies(s,"v_landings","ori") ;
p_landingsSpecies(s,"v_landings","diff%") = p_landingsSpecies(s,"v_landings","diff")/ p_landingsSpecies(s,"v_landings","ori");


PARAMETER p_landingsSpeciesFishery(f,s, resLabel,*) "Catch by species in tons/year";


p_landingsSpeciesFishery(f,s,"v_landings","ori") = p_landingsOri(f,s);
p_landingsSpeciesFishery(f,s,"v_landings","est") = v_sortA.L(f,s)+p_landingObligation(f,s)*v_sortB.L(f,s);
p_landingsSpeciesFishery(f,s,"v_landings","diff") = p_landingsSpeciesFishery(f,s,"v_landings","est")- p_landingsSpeciesFishery(f,s,"v_landings","ori") ;
p_landingsSpeciesFishery(f,s,"v_landings","diff%") $p_landingsSpeciesFishery(f,s,"v_landings","ori")//
                  = p_landingsSpeciesFishery(f,s,"v_landings","diff")/ p_landingsSpeciesFishery(f,s,"v_landings","ori");

** economics **
PARAMETER outputEconomicsEst(fisheryDomain, resLabel,*) "Economic results in 1000 SEK";

** Economics
SET economicVariablesEst(resLabel) "set with relevant economic variables" / totalSalesRevenues, totalVariableCosts, totalGrossVA, totalContrMarg, totalFixCosts, totalProfit / ;

outputEconomicsEst(segment, economicVariablesEst,"est") =  p_profitFishery(segment,economicVariablesEst) ;
outputEconomicsEst("total", economicVariablesEst,"est") =  sum(segment, p_profitFishery(segment,economicVariablesEst)) ;

** per fishery
outputEconomicsEst(f, "totalVariableCosts","ori") = - p_varCostAveOri(f)*p_effortOri(f);
outputEconomicsEst(f, "totalVariableCosts","est") = p_profitFishery(f,"totalVariableCosts");
outputEconomicsEst(f, "totalSalesRevenues", "ori") = SUM(s, p_landingsOri(f,s)*p_pricesAOri(f,s) + p_discardsOri(f,s)*p_landingObligation(f,s)*p_pricesBOri(s)) ;
outputEconomicsEst(f, "totalSalesRevenues", "est") = SUM(s $ fishery_species(f,s),v_sortA.L(f,s)*p_pricesAOri(f,s) + v_sortB.L(f,s)*p_pricesBOri(s)*p_landingObligation(f,s));
outputEconomicsEst(f, "totalContrMarg", "ori") = outputEconomicsEst(f, "totalSalesRevenues", "ori") + outputEconomicsEst(f, "totalVariableCosts","ori") ;
outputEconomicsEst(f, "totalContrMarg", "est") = outputEconomicsEst(f, "totalSalesRevenues", "est") + outputEconomicsEst(f, "totalVariableCosts","est") ;
outputEconomicsEst(f, "totalGrossVA", "ori") = outputEconomicsEst(f, "totalSalesRevenues", "ori") + outputEconomicsEst(f, "totalVariableCosts","ori")*(1-p_VCshareLab(f)) ;
outputEconomicsEst(f, "totalGrossVA", "est") = outputEconomicsEst(f, "totalSalesRevenues", "est") + outputEconomicsEst(f, "totalVariableCosts","est")*(1-p_VCshareLab(f)) ;


** original data per segment
outputEconomicsEst(seg, "totalVariableCosts","ori") = - sum(f $segment_fishery(seg, f), p_varCostAveOri(f)*p_effortOri(f));
outputEconomicsEst(seg, "totalFixCosts","ori") =  - p_fixCostSumOri(seg)*p_vesselsOri(seg);
outputEconomicsEst(seg, "totalSalesRevenues", "ori") = SUM(f $segment_fishery(seg,f), outputEconomicsEst(f, "totalSalesRevenues", "ori")) ;
outputEconomicsEst(seg, "totalContrMarg", "ori") = outputEconomicsEst(seg, "totalSalesRevenues", "ori") + outputEconomicsEst(seg, "totalVariableCosts","ori") ;
outputEconomicsEst(seg, "totalGrossVA", "ori") = sum(f $segment_fishery(seg,f), outputEconomicsEst(f, "totalGrossVA", "ori")) ;
outputEconomicsEst(seg, "totalProfit", "ori") = outputEconomicsEst(seg, "totalContrMarg", "ori") + outputEconomicsEst(seg, "totalFixCosts","ori") ;

** original data for total (entire fishery)
outputEconomicsEst("total", economicVariablesEst, "ori") = SUM(seg, outputEconomicsEst(seg, economicVariablesEst, "ori"));


EXECUTE_UNLOAD "%resDir%\estimation\easyEstimationOutputSW_%runtype%%scenario%.gdx" p_catchSpecies p_catchSpeciesFishery p_landingsSpecies p_landingsSpeciesFishery //
                                                                                    outputEconomicsEst ;
