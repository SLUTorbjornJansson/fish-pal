$ONTEXT
    Denna fil anv�nds f�r att fixera variablers v�rden s� att de blir till
    parametrar. Fr�mst f�r att fixera resultatet av skattningarna s� att de
    kan anv�ndas i den primala modellen.

$OFFTEXT

* --- Fishing effort: This is the primary choice variable! Release

*   "Annual fishing effort per fishery"
v_effortAnnual.LO(fishery) = p_effortOri(fishery)*0.001;
* Limit effort annual to values that produce a non-negative marginal catch,
* by solving the equation "marginal catch = 0"
v_effortAnnual.UP(fishery) = INF;

* Compute a feasible starting point by solving the non-linear catch function
v_effortAnnual.L(fishery) = p_effortOri(fishery);
v_catch.L(f,s) = pv_delta.L(f,s) * v_effortAnnual.L(f)**p_catchElasticity(f);
v_sortA.L(f,s) = v_catch.L(f,s)*p_shareA(f,s);
v_sortB.L(f,s) = v_catch.L(f,s)*p_shareB(f,s);

* --- "Catch per fishery and species": Determined by the equation e_catch, do nothing
pv_delta.FX(f,s) = pv_delta.L(f,s);

* --- "Number of vessels per segment, determining fixed costs": Fix for short term model
v_vessels.FX(segment) = p_vesselsOri(segment);

* --- Sum of variable costs per fishery: Fix (to result of estimation)
pv_varCostConst.FX(f) = pv_varCostConst.L(f);
pv_varCostSlope.FX(f) = pv_varCostSlope.L(f);

* --- In simulation, quotas need to be fixed. Adjustment factor is kept from estimation (or other initialization)
pv_TACAdjustment.FX(catchQuotaName,quotaArea) = pv_TACAdjustment.L(catchQuotaName,quotaArea);

* --- Fix calibration parameter to current (estimated?) value
pv_PMPconst.FX(f) = pv_PMPconst.L(f);
pv_PMPslope.FX(f) = pv_PMPslope.L(f);

* --- Fix season per fishery to current (estimates?) value
pv_maxEffFishery.FX(f) = pv_maxEffFishery.L(f);

pv_kwh.FX(seg) = pv_kwh.L(seg);


* Expert knowledge *
* Set effortAnnual for "pilk, S" to original data since too large otherwise
* obs m�ste l�ggas in sist i set_bounds_simulation f�r annars skrivs det �ver i den filen
*v_effortAnnual.FX("131") = p_effortOri("131");
*v_effortAnnual.FX("142") = p_effortOri("142");


*v_effortAnnual.fx("48") = p_effortOri("48") ;
*v_effortAnnual.fx("65") = p_effortOri("65") ;
