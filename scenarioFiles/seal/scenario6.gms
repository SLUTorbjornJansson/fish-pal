*-------------------------------------------------------------------------------
$ontext

   Fish Pal

   GAMS file :

   @purpose  : Change seal costs and catches according to seal scenario 2
   @author   : Torbjörn Jansson, Staffan Waldo
   @date     : 14/09/18
   @since    :
   @refDoc   : C:\Users\waldo\Documents\Staffan\Fiske\Säl\Formas\Manus modellpapper\PMPseals.doc
   @seeAlso  :
   @module   : scenario
   @calledBy :



$offtext
*-------------------------------------------------------------------------------


* --- based on scenario2, set change in seal costs and change in catch

*  the change in catch is modelled as pv_Delta(f,s)= pv_Delta(f,s)*(1+SealDAS(f)*Loss*(-PopChange))
* SealDAS(f) is the share of DAS with seal damage per fishery
* Loss is the share of the landing (obs!) that the seals eat. That is, 1 = eat half of the catch
* pv_Delta is changed in change_catch_by_x_percent.gms


* Scenario assumptions
* Loss = 1 (i.e. 100%)
* SealPop increases with 100%


***** Calculation of change in catch to be used in the batinclude file *****
* Change in catch is Loss*Popchange
* PopChange is +1 (i.e +100%) which leads to batinclude = -100 ( increase in pop means decrease in catch )

***** calculation of change in the cost to be used in batinclude file *****

* This is simply the same as % change in seal population, i.e. 100 %


* sef fisheries with high expected seal population growth (22-24 and 25-29)
set fishery2229(f) fiske i 2224 och 2529+32 / 1*18, 55*68, 74*80, 99*103, 113*115, 118*121  / ;

Parameter SealUpgrade;        // change manually in scenario
SealUpgrade = 4;  // we want to quadruple seal pop in the area (400 %) and increase by 50 % in all other areas





* --- Set base scenario to start with
$include "scenarioFiles\noChange.gms"

* --- change in how much seals add to variable costs compared to present situation, 0 is no change 100 is doubling
$batinclude "scenarioFiles\scenarioComponents\change_costs_by_x_percent.gms"  0

// start with no change (batinclude = 0)
pv_varCostConst.FX(f) $fishery2229(f) =  pv_varCostConst.L(f) + p_SealCostPerDAS(f)*SealUpgrade;
pv_varCostConst.FX(f) $[ not fishery2229(f)] =  pv_varCostConst.L(f) + p_SealCostPerDAS(f)* 1.5;  // change up-grading factor (1.5) manually in scenario!


* --- change in catch for seal affected DAS
*     The "50" after the include shows up in the batinclude file as "%1", used to change catch.

*p_ShareDASseal(f) =   min[p_ShareDASseal(f)*5,1]   ;





p_ShareDASseal(f) $fishery2229(f)   =   min[p_ShareDASseal(f)*SealUpgrade/2,1]   ;              // share of DAS with seals cannot be larger than 1 (100%)!    OBS divide SealUpgrade with 2 since 50 % of the
                                                                                                 // upgrade is from SealUpgrade and 50 % is from -100/100 where we assume seals to double predation from each
                                                                                                    // net with predation
pv_delta.fx(f,s) $fishery2229(f) = pv_delta.l(f,s) * (1 + p_ShareDASseal(f) * (-100/100))  ;  // -100/100 is coding from batinclude where we chose -100 for SEAL_CATCH_CHANGE_RATE
pv_delta.fx(f,s) $[ not fishery2229(f)] = pv_delta.l(f,s) * (1 + p_ShareDASseal(f) * (-50/100))  ;  // 50 % reduction in catches for seal interacted trips

*$batinclude "scenarioFiles\scenarioComponents\change_catch_by_x_percent.gms" -100

* --- Change total budget for seal damage compensation, percent compared to previous value
$batinclude "scenarioFiles\scenarioComponents\change_subsidy_budget_by_x_percent.gms" 0

display pv_delta.l, p_ShareDASseal ;
