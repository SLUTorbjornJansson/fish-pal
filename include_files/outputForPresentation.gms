
** this is output that should be easily accesible for presenting in papers, ppt, etc **

PARAMETER outputEconomics(fisheryDomain, resLabel,*) "Economic results in 1000 SEK";


** Economics
SET economicVariables(resLabel) "set with relevant economic variables" / totalSalesRevenues, totalVariableCosts, totalGrossVA, totalModifiedGrossVA, totalSubsidy, totalContrMarg, totalFixCosts, totalProfit / ;

outputEconomics(segment, economicVariables,"total") =  p_profitFishery(segment,economicVariables) ;
outputEconomics("total", economicVariables,"total") =  sum(segment, p_profitFishery(segment,economicVariables)) ;

** Effort
PARAMETER effortAnnual(fisheryDomain);
effortAnnual(segment) = sum(f $ segment_fishery(segment,f), v_effortAnnual.L(f)) ;
effortAnnual(gear) = sum(f $ fishery_gear(f,gear), v_effortAnnual.L(f)) ;
effortAnnual("total") = sum(f , v_effortAnnual.L(f)) ;


** Catch, landing and discard
SET catchVariables(resLabel) "set with relevant info about catches and lanings" /v_catch, v_landings, v_discards  / ;
PARAMETER catchInfo(fisheryDomain, species, resLabel, *) ;

catchInfo(segment, s, catchVariables, "sim") = sum(f $ segment_fishery(segment,f),  p_fiskresultat(f,s,catchVariables,"sim"));
catchInfo(gear, s, catchVariables, "sim") = sum(f $ fishery_gear(f,gear),  p_fiskresultat(f,s,catchVariables,"sim"));
catchInfo("total", s, catchVariables, "sim") = sum(f,  p_fiskresultat(f,s,catchVariables,"sim"));

**  Quota uptake
PARAMETER quotaUptake(quotaArea, catchQuotaName);
PARAMETER landingQuotaAreaCatchQuotaName(quotaArea, catchQuotaName) ;

landingQuotaAreaCatchQuotaName(quotaArea, catchQuotaName) = //
    SUM((f,s) $ catchQuotaName_quotaArea_fishery_species(catchQuotaName,quotaArea,f,s), p_fiskResultat(f,s,"v_landings","sim"));



quotaUptake(quotaArea, catchQuotaName) $p_fiskResultat(quotaArea,catchQuotaName,"p_TACOri","sim") = //
    landingQuotaAreaCatchQuotaName(quotaArea, catchQuotaName)/ p_fiskResultat(quotaArea,catchQuotaName,"p_TACOri","sim");






EXECUTE_UNLOAD "%resDir%\simulation\outputForPresentation_%runtype%%scenario%.gdx" outputEconomics effortAnnual catchInfo quotaUptake;


$IF not %scenario% == LandingOblKrafta $goto endLandingOblKrafta

PARAMETER p_margValueIndQuota(catchQuotaName,quotaArea, seg) ;
p_margValueIndQuota(catchQuotaName,quotaArea, seg) = e_indQuota.M(catchQuotaName,quotaArea, seg)    ;
EXECUTE_UNLOAD "%resDir%\simulation\outputForPresentation_%runtype%%scenario%IndQuota.gdx" p_margValueIndQuota ;

$label endLandingOblKrafta
