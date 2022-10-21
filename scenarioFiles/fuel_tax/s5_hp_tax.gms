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
$include "scenarioFiles\fuel_tax\reference.gms"



p_varCostPriceShift(f,"Fuel_m3") = 0.89;




