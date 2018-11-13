

* reduce cod quota for 22-24 with 55 %
* "star out" options for policy scenario when running this
*p_TACOri('TorskPassiv',"'2224'") = p_TACOri('TorskPassiv',"'2224'")*0.45 ;
*p_TACOri('TorskAktiv',"'2224'") = p_TACOri('TorskAktiv',"'2224'")*0.45 ;


* TAC 2017 = 870, passivt har 55 % enl TAC i inputdatan
p_TACOri('TorskPassiv',"'2224'") = 870*0.55 ;
p_TACOri('TorskAktiv',"'2224'") = 870*0.45 ;



* testar att höja sillkvoten för att se om de börjar fiska sill om
* kvoten inte begränsar
* måste begränsa småskalig trålning, annars tar de allt i detta...
* obs funkar inte att begränsa v_effortAnnual här pga låses upp i
* set_bounds_simulation, jag hårdkodade i prototyp och tog bort igen, men ingen bra lösning
*p_TACOri('SillKust',"'2224'") = p_TACOri('SillKust',"'2224'")*1.5 ;
*v_effortAnnual.UP('132') = 26 ;

MODEL m_policyEquations "Primal simulation model with profit maximization"
    /e_effRestrSeg,e_effRestrFishery,e_catchQuota,
     e_effortPerEffortGroup,e_effortRegulation /;
