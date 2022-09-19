*-------------------------------------------------------------------------------
$ontext

   Fish Pal

   GAMS file :

   @purpose  : Simulation of increased fuel tax (fuel tax project)
   @author   : Torbjorn Jansson, Staffan Waldo
   @date     : 2022-06-21
   @since    :
   @refDoc   :
   @seeAlso  :
   @module   : scenario
   @calledBy :

$offtext
*-------------------------------------------------------------------------------

* --- Set base scenario to start with
$include "scenarioFiles\noChange.gms"



p_varCostPriceShift(f,"VC_fuel") = 0.25;




