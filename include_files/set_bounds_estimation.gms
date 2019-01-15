$ONTEXT
    Denna fil används för att lösa upp fixerade variabler så att de blir
    tillgängliga för skattningen.

$OFFTEXT

* --- Fishing effort:
*   We observe annual effort only (not per period).
*   Assume that annual effort is known with certainty.

*   "Annual fishing effort per fishery", not allowed to be zero for observed fisheries for numerical reasons (Cobb-Douglas)
*v_effortAnnual.LO(fishery) = p_effort2009(fishery)*0.001;
v_effortAnnual.LO(fishery) = p_effortOri(fishery)*1;
v_effortAnnual.UP(fishery) = p_effortOri(fishery)*1;
*v_effortAnnual.UP(fishery) = INF;


* --- "Catch per fishery and species": Determined by the equation e_catch
* v_catch(fishery,species)

* --- "Average catch per unit of effort (annual)": Determined by effortAnnual
* v_CPUE(fishery,species)


* --- "Number of vessels per segment, determining fixed costs": Fix to observation
v_vessels.FX(segment) = p_vesselsOri(segment);

* --- Marginal cost per fishery: Let estimator choose intercept between 0 and an upper bound,
*     but keep slope fixed
pv_varCostConst.lo(f) = 0;
pv_varCostConst.up(f) = p_varCostAveOri(f)*100;
pv_varCostSlope.FX(f) = pv_varCostSlope.L(f);

* --- Release calibration parameter
* --- Fix calibration parameter to current (estimated?) value
pv_PMPconst.LO(f) = -INF;
pv_PMPconst.UP(f) = +INF;

* --- For now: assume slope corresponding to an a-priori (myopic) elasticity of 2
*   beta = 1/elasticity * AverageCost / EffortOri
*TJ pv_PMPslope.FX(f) $ p_effortOri(f) = 1/1.5 * p_varCostAveOri(f)/p_effortOri(f);
pv_PMPslope.FX(f) = pv_PMPslope.L(f);


* --- "Adjustment of quotas needed to fit to catches from observed fishing efforts"

*   Fixera TAC adjustment nu när vi har endogent skattade fångster
pv_TACAdjustment.LO(catchQuotaName,quotaArea) $ (p_TACOri(catchQuotaName,quotaArea) GT 0) = 1;
pv_TACAdjustment.UP(catchQuotaName,quotaArea) $ (p_TACOri(catchQuotaName,quotaArea) GT 0) = 1;
*pv_TACAdjustment.LO(catchQuotaName,quotaArea) $ (p_TAC_MOD(catchQuotaName,quotaArea) GT 0) = 0;
*pv_TACAdjustment.UP(catchQuotaName,quotaArea) $ (p_TAC_MOD(catchQuotaName,quotaArea) GT 0) = 10;


* --- Catch distribution can be changed only for species-fisheries that are permissible
*pv_delta.FX(f,s) = pv_delta.L(f,s);
*pv_delta.LO(f,s) = p_catchDist(f,s)*0.5;
pv_delta.LO(f,s) = 0;
* delta is approximately catch per unit of effort, so the observed catch distribution indicates scale well
*pv_delta.UP(f,s) = [p_catchDist(f,s)*2] $ fishery_species(f,s);
pv_delta.UP(f,s) = [p_catchOri(f,s)/p_effortOri(f)*1000] $ fishery_species(f,s);


* Allow no sortB if none were observed
v_sortB.UP(f,s) $ [p_landingObligation(f,s) eq 0]
    = [p_discardsOri(f,s)*10000] $ fishery_species(f,s);




* --- For gamma distributed items, we must bound the solution away from zero to prevent math errors.
*     The probability is zero there any way, so it should not affect the solution
*     We choose 1 promille of the modal value as lower bound.

v_landings.LO(f,s) $ [p_priorLandings(f,s,"priDens") eq gammaDensity] = p_priorLandings(f,s,"priMode")*0.001;
v_discards.LO(f,s) $ [p_priorDiscards(f,s,"priDens") eq gammaDensity] = p_priorDiscards(f,s,"priMode")*0.001;


* --- Release season per fishery.
*        Lower bound is prior minimum plus one promille of mode in order to avoid log of zero
*        Analogous for upper bound.
*        Prior is the a-priori distribution of the season length, with
*        -a minimum season priMin (0)
*        -a maximum season priMax (365 days/year)
*        -a most likely season priMode (dictated by biological, meteorological and political considerations in Excel)
pv_maxEffFishery.LO(f) = p_priMaxEffFishery("priMin",f)+ABS(p_priMaxEffFishery("priMode",f))*0.001;
pv_maxEffFishery.UP(f) = p_priMaxEffFishery("priMax",f)-ABS(p_priMaxEffFishery("priMode",f))*0.001;



pv_kwh.lo(seg) = 0;
pv_kwh.up(seg) = p_kwhOri(seg)*100;

