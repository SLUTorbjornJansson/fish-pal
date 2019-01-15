$ONTEXT

    @purpose: Compute subsidy payment per day for each fishery

    @author: Torbjörn Jansson, Staffan Waldo

    @date: 2018-09-24

    @calledby: FishPAL.gms

$OFFTEXT

*  p_subsidyPerDAS(f) = 1.00;
*$exit
* --- Subsidy that is proportional to the share in total seal damage

* --- Assume that the seal damage on the fishery (revenue foregone) is equal to
*     observed revenues whenever there is a seal flag in the log book

    p_sealDamage(f) =
    SUM(s $ fishery_species(f,s), p_pricesA(f,s)*p_shareA(f,s)*pv_delta.l(f,s) * v_effortAnnual.L(f)**p_catchElasticity(f)
                                + p_pricesB(s)*  p_shareB(f,s)*pv_delta.l(f,s) * v_effortAnnual.L(f)**p_catchElasticity(f)*p_landingObligation(f,s))
    * p_ShareDASseal(f);


* --- Each fishery gets a share in the total budget that equals its
*     share in total seal damage, divided by number of days at sea

    p_subsidyPerDAS(f) = p_subsidyBudget
                 * p_sealDamage(f) / sum(fishery, p_sealDamage(fishery))
                 / v_effortAnnual.L(f);

    p_subsidyBudgetSpent = sum(f, p_subsidyPerDAS(f)*v_effortAnnual.L(f));

    display "In %system.fn%:", p_subsidyPerDAS;

