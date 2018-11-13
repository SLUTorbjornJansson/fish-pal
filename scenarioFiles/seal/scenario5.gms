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


* --- based on scenario3, set change in seal costs and change in catch

*  the change in catch is modelled as pv_Delta(f,s)= pv_Delta(f,s)*(1+SealDAS(f)*Loss*(-PopChange))
* SealDAS(f) is the share of DAS with seal damage per fishery
* Loss is the share of the landing (obs!) that the seals eat. That is, 1 = eat half of the catch
* pv_Delta is changed in change_catch_by_x_percent.gms


* Scenario assumptions
* Loss = -0.75 (i.e. seal loss decreases with 75 %)
* SealPop decreases with 75%


***** Calculation of change in catch to be used in the batinclude file *****
* Change in catch is Loss*Popchange
* PopChange is +1 (i.e +100%) which leads to batinclude = -100 ( increase in pop means decrease in catch )

***** calculation of change in the cost to be used in batinclude file *****

* This is simply the same as % change in seal population, i.e. 100 %




* --- Set base scenario to start with
$include "scenarioFiles\noChange.gms"

* --- change in how much seals add to variable costs compared to present situation, 0 is no change 100 is doubling
$batinclude "scenarioFiles\scenarioComponents\change_costs_by_x_percent.gms"  100

* --- change in catch for seal affected DAS
*     The "50" after the include shows up in the batinclude file as "%1", used to change catch.
$batinclude "scenarioFiles\scenarioComponents\change_catch_by_x_percent.gms" (-100)


* --- Change total budget for seal damage compensation, percent compared to previous value
$batinclude "scenarioFiles\scenarioComponents\change_subsidy_budget_by_x_percent.gms" 100

