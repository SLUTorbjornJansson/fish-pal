$ONTEXT

    @purpose: Scenario file for fisk, with no change from calibration point

    @author: Torbjörn Jansson, Staffan Waldo

    @date: 2013-09-23

    @calledby: prototyp.gms

$OFFTEXT

* Do nothing to quotas


* No landing obligation

*p_landingObligation(f,s) = 0;


* Price of sort B is set to "1 SEK/kg"
*p_pricesBOri(s) = 1;




model m_policyEquations /e_effRestrSeg,e_effRestrFishery,e_catchQuota,
     e_effortPerEffortGroup, e_effortRegulation /;
