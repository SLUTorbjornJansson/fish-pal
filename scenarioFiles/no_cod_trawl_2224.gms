*-------------------------------------------------------------------------------
$ontext
    Som referensscenariot 2017, men med tr�lf�rbud f�r torsk i v�stra �stersj�n

$offtext
*-------------------------------------------------------------------------------

$include "scenariofiles\ref_2017.gms"

* Flytta kvoten till passiva redskap
p_TACOri('TorskPassiv',"'2224'") = 860 ;
p_TACOri('TorskAktiv',"'2224'") = 10 ;