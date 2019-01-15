
PARAMETER minLanding "landing in ton below which the species is excluded from the fishery (f)" ;

minLanding = 0.1           ;

pv_delta(f,s)$(p_landingsOri(f,s)< 0.1) = 0 ;