*-------------------------------------------------------------------------------
$ontext
    FishPAL

    Sensitivity analysis:
    Shift selected variables and recalibrate.

    The parameters to shift are defined using $SETGLOBAL in the parent program
    or in the GUI.

    The following parameter shifters are supported (defined in percent diff):
    SHIFT_VARCOST_SLOPE    Slope of variable cost function
    SHIFT_CATCH_ELAS       Catch elasticity parameter BETA
    SHIFT_FISH_PRICES      Prices of all fish


    @author: Torbjörn Jansson, SLU
$offtext
*-------------------------------------------------------------------------------


*   Invent a file name to use if some error is found and data must be unloaded
$set ERROR_FILE %resDir%\chk_%scenario_path_underscores%_%ResId%.gdx


*-------------------------------------------------------------------------------
*   Shift slope of variable cost functions by percent %SHIFT_VARCOST_SLOPE%
*-------------------------------------------------------------------------------

parameter p_oldAC(f) "Average cost before shift";


*   Store old average cost
p_oldAC(f)
    = pv_varCostConst.l(f) + pv_varCostSlope.l(f)*p_effortOri(f)*1/2;

*   Do the shift of slope
pv_varCostSlope.l(f)
    = pv_varCostSlope.l(f)*(1 + (%SHIFT_VARCOST_SLOPE%)/100);

*   Adjust intercept to restore average variable cost
pv_varCostConst.l(f)
    = p_oldAC(f) - pv_varCostSlope.l(f)*p_effortOri(f)*1/2;


*-------------------------------------------------------------------------------
*   Shift catch elasticity by %SHIFT_CATCH_ELAS%
*-------------------------------------------------------------------------------

    parameter p_oldCatch(f,s);
    p_oldCatch(f,s) = pv_delta.l(f,s) * p_effortOri(f)**p_catchElasticity(f);

*   Shift the catch elasticity
    p_catchElasticity(f) = p_catchElasticity(f)*(1 + (%SHIFT_CATCH_ELAS%)/100);

*   Adjust the parameter pv_delta(f,s), indicating some average CPUE, to ensure
*   that the total catch in the baseline is untouched.
*   times how catch changes (of all species) if effort changes

    pv_delta.l(f,s) $ p_oldCatch(f,s) = p_oldCatch(f,s)*p_effortOri(f)**(-p_catchElasticity(f));


*-------------------------------------------------------------------------------
*   Shift fish prices by %SHIFT_FISH_PRICES%
*-------------------------------------------------------------------------------

*   Shift fish prices. This will shift revenues and therefore profits.
*   Should we shift variable costs in a corresponding manner to keep profits constant?

    p_pricesA(f,s) = p_pricesA(f,s)*(1 + (%SHIFT_FISH_PRICES%)/100);

    p_pricesB(s) = p_pricesB(s)*(1 + (%SHIFT_FISH_PRICES%)/100);


*-------------------------------------------------------------------------------
*   Re-calibrate the model by solving it under bounds and then recomputing PMP-terms
*-------------------------------------------------------------------------------

$INCLUDE "include_files\set_bounds_simulation.gms"

*   Fix effortAnnual in order to obtain dual values to use in calibration
    v_effortAnnual.fx(f) = p_effortOri(f);

*   ... but leave a tiny slack in order to be able to identify any binding quotas
    v_effortAnnual.lo(f) = p_effortOri(f)*0.9995;
    v_effortAnnual.up(f) = p_effortOri(f)*1.0005;


MODEL m_fishCal "Primal simulation model with profit maximization"
    /m_coreEquations,
     e_effRestrSeg,
     e_effRestrFishery,
     e_catchQuota,
     e_effortPerEffortGroup,
     e_effortRegulation
     m_reportingEquations/;


*   Solve model to obtain dual values on v_effortAnnual
    $$INCLUDE "include_files\compute_subsidies.gms"
    SOLVE m_fishCal USING NLP MAXIMIZING v_profit;


*   Shift the PMP constant by the dual value of effortannual. Motivation:
*   this is exactly the amount that is missing in order to make the FOC=0.
    pv_PMPconst.l(f) = pv_PMPconst.l(f) + v_effortAnnual.m(f);
    pv_PMPconst.fx(f) = pv_PMPconst.l(f);


*   Solve to verify that v_effortAnnual.m(f) is now zero again,
*   implying that the model is calibrating exactly
    SOLVE m_fishCal USING NLP MAXIMIZING v_profit;

    if(sum(f, v_effortAnnual.m(f)) gt 0.001,
        execute_unload "%ERROR_FILE%";
        display "ERROR in %system.fn%. All data unloaded to %ERROR_FILE%";
        abort "ERROR: The model does not calibrate before the scenario has been loaded";
    );

