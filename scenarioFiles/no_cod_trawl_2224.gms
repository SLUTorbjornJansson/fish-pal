*-------------------------------------------------------------------------------
$ontext
    Som referensscenariot 2017, men med trålförbud för torsk i västra östersjön

$offtext
*-------------------------------------------------------------------------------

$include "scenariofiles\ref_2017.gms"

* Flytta kvoten till passiva redskap
p_TACOri('TorskPassiv',"'2224'") = 860 ;
p_TACOri('TorskAktiv',"'2224'") = 10 ;