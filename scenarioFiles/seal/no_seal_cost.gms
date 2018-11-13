*-------------------------------------------------------------------------------
$ontext

   Fish Pal

   GAMS file :

   @purpose  : Remove costs for seal damage based on estimates of cost per DAS
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


