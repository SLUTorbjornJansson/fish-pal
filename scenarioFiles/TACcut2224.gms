

* reduce cod quota for 22-24 with 55 %
* "star out" options for policy scenario when running this
*p_TACOri('TorskPassiv',"'2224'") = p_TACOri('TorskPassiv',"'2224'")*0.45 ;
*p_TACOri('TorskAktiv',"'2224'") = p_TACOri('TorskAktiv',"'2224'")*0.45 ;


* TAC 2017 = 870, passivt har 55 % enl TAC i inputdatan
p_TACOri('TorskPassiv',"'2224'") = 870*0.55 ;
p_TACOri('TorskAktiv',"'2224'") = 870*0.45 ;



* testar att h�ja sillkvoten f�r att se om de b�rjar fiska sill om
* kvoten inte begr�nsar
* m�ste begr�nsa sm�skalig tr�lning, annars tar de allt i detta...
* obs funkar inte att begr�nsa v_effortAnnual h�r pga l�ses upp i
* set_bounds_simulation, jag h�rdkodade i prototyp och tog bort igen, men ingen bra l�sning
*p_TACOri('SillKust',"'2224'") = p_TACOri('SillKust',"'2224'")*1.5 ;
*v_effortAnnual.UP('132') = 26 ;

MODEL m_policyEquations "Primal simulation model with profit maximization"
    /e_effRestrSeg,e_effRestrFishery,e_catchQuota,
     e_effortPerEffortGroup,e_effortRegulation /;
