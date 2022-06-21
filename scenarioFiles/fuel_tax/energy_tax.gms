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


* --- Increase fuel tax by p_fuelTax kr/liter

p_fuelTaxPerLitre(f) = 3;


* --- Re-compute pv_varCostConst(f) to reflect the new tax level

p_fuelUsePerDay("1") = 14;
pv_varCostConst.l(f) = pv_varCostConst.l(f) + p_fuelUsePerDay(f) * p_fuelTaxPerLitre(f)/1000;

