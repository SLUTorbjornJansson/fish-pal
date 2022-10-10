$ONTEXT

    @purpose: Loadbehavioural and economic parameters of the fishery model.

    @author: Torbj�rn Jansson, Staffan Waldo

    @calledby: prototyp.gms

$OFFTEXT

DISPLAY "Load parameters";

EXECUTE_LOAD "%resdir%\estimation\par_%parFileName%.gdx"
                                              p_pricesA
                                              p_pricesB
                                              p_shareA
                                              p_shareB
                                              pv_varCostConst
                                              pv_varCostSlope
                                              p_fixCostSumOri
                                              pv_PMPconst
                                              pv_PMPslope
                                              pv_delta
                                              p_catchElasticity
                                              p_maxEffSeg
                                              pv_maxEffFishery
                                              p_TACOri
                                              pv_TACAdjustment
                                              pv_kwh
                                              p_varCostOri
                                              p_subsidyBudget
                                              p_InputPrice;
* p_landingObligation ; "over-writes LO changed in scenario file if unloaded here
