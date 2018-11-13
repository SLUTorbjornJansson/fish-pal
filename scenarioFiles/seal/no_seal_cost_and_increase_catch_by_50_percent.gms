*-------------------------------------------------------------------------------
$ontext

   Fish Pal

   GAMS file :

   @purpose  : Remove seal cost and increase catch by 50% times the rate of seal interaction
   @author   : Torbjörn Jansson, Staffan Waldo
   @date     : 05/03/18
   @since    :
   @refDoc   :
   @seeAlso  :
   @module   : scenario
   @calledBy :

$offtext
*-------------------------------------------------------------------------------

* --- Set base scenario to start with
$include "scenarioFiles\noChange.gms"

* --- Remove seal cost from variable costs
$include "scenarioFiles\scenarioComponents\remove_seal_costs.gms"

* --- Remove seal cost from variable costs
*     The "50" after the include shows up in the batinclude file as "%1", used to change catch.
$batinclude "scenarioFiles\scenarioComponents\change_catch_by_x_percent.gms" 50


