* ------------------------------------------------------------------------------
$ontext
    Referensscenario för 2017, med anpassning av kvoter, priser mm

$offtext
* ------------------------------------------------------------------------------

* Torskkvoter
* TAC 2017 = 870, passivt har 55 % enl TAC i inputdatan
p_TACOri('TorskPassiv',"'2224'") = 870*0.55 ;
p_TACOri('TorskAktiv',"'2224'") = 870*0.45 ;


* Nya priser
p_pricesA(f,s) = p_pricesA(f,s) * 1.10;

* Annat? Antal fartyg?


* Standardekvationer
MODEL m_policyEquations "Primal simulation model with profit maximization"
    /e_effRestrSeg,e_effRestrFishery,e_catchQuota,
     e_effortPerEffortGroup,e_effortRegulation /;
