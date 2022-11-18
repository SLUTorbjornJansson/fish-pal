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


* --- Increase output prices too

p_pricesA(f,s) = p_pricesA(f,s) * 1.08;
p_pricesB(s)   = p_pricesB(s) * 1.08;

