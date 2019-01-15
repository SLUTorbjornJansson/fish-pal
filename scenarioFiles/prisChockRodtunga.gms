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
p_pricesAOri(fishery,"Rodtunga") =  p_pricesAOri(fishery,"Rodtunga")*100 ;
p_pricesAOri(fishery,"Bergtunga") =  p_pricesAOri(fishery,"Bergtunga")*100 ;
p_TACOri("Berg_o_Rodtunga","'N'") = 4 ;
