*-------------------------------------------------------------------------------
$ontext

   Fish Pal

   GAMS file :

   @purpose  : Shift stocks of herring in some area by 10%
   @author   : Torbjorn Jansson, Staffan Waldo
   @date     : 2024-11-15
   @since    :
   @refDoc   :
   @seeAlso  :
   @module   : scenario
   @calledBy :

$offtext
*-------------------------------------------------------------------------------

* --- Set base scenario to start with
$include "scenarioFiles\HeatWaves\reference.gms"

* --- Shift herring stock
p_stock("sill_stor","'3031'") = p_stock("sill_stor","'3031'") * 1.10;


