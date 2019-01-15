

* Original regulation change: reduce cod quota for 22-24 to 870 ton

*p_TACOri('TorskPassiv',"'2224'") = 870*0.55 ;
*p_TACOri('TorskAktiv',"'2224'") = 870*0.45 ;

* policy senario, zero trawling, all quota to passive fishing





* "star out" options above when running this
* obs TAC zero must be very small number, otherwise the model interprets it as no quota, bad programming...
* Torsk Total = 870 enligt HaVs hemsida, ny TAC 2017
* TorskPassiv = 860 enl samtal med Qamer
* TorskAktiv = 10, "resten" behövs som bifångst för sillfiske med trål
p_TACOri('TorskPassiv',"'2224'") = 860 ;
p_TACOri('TorskAktiv',"'2224'") = 10 ;

MODEL m_policyEquations "Primal simulation model with profit maximization"
    /e_effRestrSeg,e_effRestrFishery,e_catchQuota,
     e_effortPerEffortGroup,e_effortRegulation /;
