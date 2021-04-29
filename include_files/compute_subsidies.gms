$ONTEXT

    @purpose: Compute subsidy payment per day for each fishery

    @author: Torbjörn Jansson, Staffan Waldo

    @date: 2018-09-24

    @calledby: FishPAL.gms

$OFFTEXT

*   --- Make a somewhat conservative forecast of the fishery effort to use
*       in the computation of subsidies. If we use the efforts of the last
*       iteration, we may have "cycling".

    if(card(iterUsed) eq 0,
*       If we have no iterations so far, use baseline data
        p_projectedEffort(f) = p_effortOri(f);
    else
*       If we do have iterations, use weighted average of last iteration and
*       of the last projected effort.
        p_projectedEffort(f)
            = (1*v_effortAnnual.L(f) + 1*p_projectedEffort(f)) / 2;

    );

*  p_subsidyPerDAS(f) = 1.00;
*$exit
* --- Subsidy that is proportional to the share in total seal damage

* --- Assume that the seal damage on the fishery (revenue foregone) is equal to
*     observed revenues whenever there is a seal flag in the log book

    p_sealDamage(f) =
    SUM(s $ fishery_species(f,s), p_pricesA(f,s)*p_shareA(f,s)*pv_delta.l(f,s) * p_projectedEffort(f)**p_catchElasticity(f)
                                + p_pricesB(s)*  p_shareB(f,s)*pv_delta.l(f,s) * p_projectedEffort(f)**p_catchElasticity(f)*p_landingObligation(f,s))
    * p_ShareDASseal(f);


* --- Each fishery gets a share in the total budget that equals its
*     share in total seal damage, divided by number of days at sea

    p_subsidyPerDAS(f) = p_subsidyBudget
                 * p_sealDamage(f) / sum(fishery, p_sealDamage(fishery))
                 / p_projectedEffort(f);

    p_subsidyBudgetSpent = sum(f, p_subsidyPerDAS(f)*p_projectedEffort(f));

    display "In %system.fn%:", p_subsidyPerDAS;

