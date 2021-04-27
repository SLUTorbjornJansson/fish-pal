
** this is output that should be easily accesible for presenting in papers, ppt, etc **

PARAMETER outputEconomics(fisheryDomain, resLabel,*) "Economic results in 1000 SEK";


** Economics
SET economicVariables(resLabel) "set with relevant economic variables" / totalSalesRevenues, totalVariableCosts, totalGrossVA, totalModifiedGrossVA, totalSubsidy, totalContrMarg, totalFixCosts, totalProfit / ;

outputEconomics(segment, economicVariables,"total") =  p_profitFishery(segment,economicVariables) ;
outputEconomics(gear, economicVariables,"total") =  sum(f $ fishery_gear(f,gear), p_profitFishery(f,economicVariables)) ;
outputEconomics(area, economicVariables,"total") =  sum(f $ fishery_area(f,area), p_profitFishery(f,economicVariables)) ;
outputEconomics("total", economicVariables,"total") =  sum(segment, p_profitFishery(segment,economicVariables)) ;

** Effort
PARAMETER effortAnnual(fisheryDomain);
effortAnnual(segment) = sum(f $ segment_fishery(segment,f), v_effortAnnual.L(f)) ;
effortAnnual(gear) = sum(f $ fishery_gear(f,gear), v_effortAnnual.L(f)) ;
effortAnnual(area) = sum(f $ fishery_area(f,area), v_effortAnnual.L(f)) ;
effortAnnual("total") = sum(f , v_effortAnnual.L(f)) ;


** Catch, landing and discard
*SET catchVariables(resLabel) "set with relevant info about catches and lanings" /v_catch, v_landings, v_discards  / ;
SET catchVariables(resLabel) "set with relevant info about catches and lanings" /v_catch  / ;
PARAMETER catchInfo(fisheryDomain, species, resLabel, *) ;

catchInfo(segment, s, catchVariables, "sim") = sum(f $ segment_fishery(segment,f),  p_fiskresultat(f,s,catchVariables,"sim"));
catchInfo(gear, s, catchVariables, "sim") = sum(f $ fishery_gear(f,gear),  p_fiskresultat(f,s,catchVariables,"sim"));
catchInfo(area, s, catchVariables, "sim") = sum(f $ fishery_area(f,area),  p_fiskresultat(f,s,catchVariables,"sim"));
catchInfo("total", s, catchVariables, "sim") = sum(f,  p_fiskresultat(f,s,catchVariables,"sim"));

**  Quota uptake
PARAMETER quotaUptake(quotaArea, catchQuotaName);
PARAMETER landingQuotaAreaCatchQuotaName(quotaArea, catchQuotaName) ;

landingQuotaAreaCatchQuotaName(quotaArea, catchQuotaName) = //
    SUM((f,s) $ catchQuotaName_quotaArea_fishery_species(catchQuotaName,quotaArea,f,s), p_fiskResultat(f,s,"v_landings","sim"));



quotaUptake(quotaArea, catchQuotaName) $p_fiskResultat(quotaArea,catchQuotaName,"p_TACOri","sim") = //
    landingQuotaAreaCatchQuotaName(quotaArea, catchQuotaName)/ p_fiskResultat(quotaArea,catchQuotaName,"p_TACOri","sim");




$set fileName %resDir%\simulation\outputForPresentation_%runtype%%scenario%    ;

*EXECUTE_UNLOAD "%resDir%\simulation\outputForPresentation_%runtype%%scenario%.gdx" outputEconomics effortAnnual catchInfo quotaUptake;
EXECUTE_UNLOAD "%resDir%\simulation\outputForPresentation_%runtype%%scenario%%ResId%.gdx" outputEconomics effortAnnual catchInfo quotaUptake;

*$set fileName %outDir%\Output


execute "GDXXRW i=%resDir%\simulation\outputForPresentation_%runtype%%scenario%%ResId%.gdx o=%resDir%\simulation\outputForPresentation_%runtype%%scenario%%ResId%.xlsx par=outputEconomics rng=outputEconomics!A1 cdim=2 rdim=1" ;
execute "GDXXRW i=%resDir%\simulation\outputForPresentation_%runtype%%scenario%%ResId%.gdx o=%resDir%\simulation\outputForPresentation_%runtype%%scenario%%ResId%.xlsx par=effortAnnual rng=effortAnnual!A1 cdim=0 rdim=1" ;
execute "GDXXRW i=%resDir%\simulation\outputForPresentation_%runtype%%scenario%%ResId%.gdx o=%resDir%\simulation\outputForPresentation_%runtype%%scenario%%ResId%.xlsx par=catchInfo rng=catchInfo!A1 cdim=3 rdim=1" ;
execute "GDXXRW i=%resDir%\simulation\outputForPresentation_%runtype%%scenario%%ResId%.gdx o=%resDir%\simulation\outputForPresentation_%runtype%%scenario%%ResId%.xlsx par=quotaUptake rng=quotaUptake!A1 " ;





$IF not %scenario% == LandingOblKrafta $goto endLandingOblKrafta

PARAMETER p_margValueIndQuota(catchQuotaName,quotaArea, seg) ;
p_margValueIndQuota(catchQuotaName,quotaArea, seg) = e_indQuota.M(catchQuotaName,quotaArea, seg)    ;
EXECUTE_UNLOAD "%resDir%\simulation\outputForPresentation_%runtype%%scenario%IndQuota%ResId%.gdx" p_margValueIndQuota ;

$label endLandingOblKrafta
