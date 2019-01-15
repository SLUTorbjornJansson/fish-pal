
** viktigt för körning: i 'prototyp.gms' måste man sätta "$SETGLOBAL SimChangesModelEq on" för att köra version med individuella icke-överförbara kvoter
** default är annars "$SETGLOBAL SimChangesModelEq off" som används för ITQ samt i estimering

*** proxy for current landing obligation ***
*** need to check with HaV/SLU!! ***

SET tralSnurrevadVH(f) trål och snurrevad > 100 mm /174, 179   / ;
SET tralFiskKraftaKS(f) trål 70-99 mm / 124, 126, 144, 145, 158, 160, 171, 175, 181, 186, 192, 195, 198, 200, 210, 214, 227, 237 /;
SET garnVH(f) /29, 30, 32, 33, 34, 36, 39, 40, 43, 47, 50, 53, 71, 73, 84, 89, 93, 94, 95, 116, 117, 141 / ;
SET krokVH(f) / 28, 42, 49, 70, 72, 88, 122, 123, 131, 139, 142 / ;
SET rakTral(f) trål 32-69 mm /86, 128, 129, 147, 148, 162, 173, 177, 178, 180, 183, 184, 185, 202, 203, 211, 212, 213, 215, 216, 217 / ;
* endast burar, ej ryssjor etc ingår nedan
SET burVH(f) burfiske i västerhavet /27, 41, 69, 81, 87, 130 / ;


** 2016 Landing Obligation **

p_landingObligation(tralSnurrevadVH,"Kolja")     = 1           ;
p_landingObligation(tralSnurrevadVH,"Rodspotta") = 1           ;
p_landingObligation(tralSnurrevadVH,"Grasej")    = 1           ;

p_landingObligation(tralFiskKraftaKS,"Kolja")    = 1           ;

p_landingObligation(garnVH,"aktaTunga")          = 1           ;

p_landingObligation(krokVH,"Kummel")             = 1           ;

p_landingObligation(fishery,"Nordhavsraka")      = 1           ;

** 2017 Landing Obligation - additional species and fisheries compared to 2016 **
p_landingObligation(tralSnurrevadVH,"Vitling")   = 1           ;
p_landingObligation(tralSnurrevadVH,"Torsk")     = 1           ;
p_landingObligation(tralSnurrevadVH,"aktaTunga") = 1           ;
p_landingObligation(tralSnurrevadVH,"Havskrafta")= 1           ;

p_landingObligation(tralFiskKraftaKS,"Torsk")    = 1           ;
p_landingObligation(tralFiskKraftaKS,"aktaTunga")= 1           ;

p_landingObligation(garnVH,"Havskrafta")         = 1           ;
p_landingObligation(garnVH,"Kolja")              = 1           ;
p_landingObligation(garnVH,"Vitling")            = 1           ;


p_landingObligation(krokVH,"Havskrafta")         = 1           ;
p_landingObligation(krokVH,"aktaTunga")          = 1           ;
p_landingObligation(krokVH,"Kolja")              = 1           ;
p_landingObligation(krokVH,"Vitling")            = 1           ;
p_landingObligation(krokVH,"Torsk")              = 1           ;

p_landingObligation(rakTral,"Havskrafta")         = 1           ;
p_landingObligation(rakTral,"aktaTunga")          = 1           ;
p_landingObligation(rakTral,"Kolja")              = 1           ;
p_landingObligation(rakTral,"Vitling")            = 1           ;

p_landingObligation(burVH,"aktaTunga")          = 1           ;
p_landingObligation(burVH,"Kolja")              = 1           ;
p_landingObligation(burVH,"Vitling")            = 1           ;


*** introduce individual quota based on previous landings (each segment gets share of TAC depending on lanings in 2012 ***

PARAMETER p_landingF(f,catchQuotaName, quotaArea) "landing per fishery in each quota and each quotaArea" ;
PARAMETER p_landingTot(catchQuotaName, quotaArea) "total landing in each quota and each quotaArea" ;
PARAMETER p_landingShareF(f,catchQuotaName, quotaArea)"share of total landed by 'f'" ;

PARAMETER p_landingShareSeg(catchQuotaName, quotaArea, seg)"share of total landings by segment" ;
PARAMETER p_TACSeg(catchQuotaName,quotaArea, seg)          "share of TAC for segment if allcated according to previous landings";

p_landingF(f,catchQuotaName, quotaArea)= sum(s $catchQuotaName_quotaArea_fishery_species(catchQuotaName,quotaArea,f,s),
         p_landingsOri(f,s)) ;
p_landingTot(catchQuotaName, quotaArea)= sum(f, p_landingF(f,catchQuotaName, quotaArea)) ;

p_landingShareF(f,catchQuotaName, quotaArea)$p_landingTot(catchQuotaName, quotaArea)= p_landingF(f,catchQuotaName, quotaArea)
                  / p_landingTot(catchQuotaName, quotaArea)   ;

p_landingShareSeg(catchQuotaName, quotaArea, seg)=  SUM(f $segment_fishery(seg,f), p_landingShareF(f,catchQuotaName, quotaArea))    ;
p_TACSeg(catchQuotaName,quotaArea, seg) = p_TACOri(catchQuotaName,quotaArea)* p_landingShareSeg(catchQuotaName, quotaArea, seg) ;

parameter temp(catchQuotaName, quotaArea);
parameter temp2(catchQuotaName, quotaArea);
parameter temp3(catchQuotaName, quotaArea);
temp(catchQuotaName, quotaArea) = sum(f, p_landingShareF(f,catchQuotaName, quotaArea));
temp2(catchQuotaName, quotaArea) = sum(seg, p_landingShareSeg(catchQuotaName, quotaArea, seg));
temp3(catchQuotaName, quotaArea) = sum(seg, p_TACSeg(catchQuotaName, quotaArea, seg));
display p_landingShareF, temp, p_landingShareSeg, temp2, p_TACSeg, temp3 ;


** equation for individual quota **



EQUATION e_indQuota(catchQuotaName,quotaArea, seg) ;

e_indQuota(catchQuotaName,quotaArea, seg) $( p_TACSeg(catchQuotaName,quotaArea, seg) GT 0)..
         SUM((f,s) $ [segment_fishery(seg,f) AND catchQuotaName_quotaArea_fishery_species(catchQuotaName,quotaArea,f,s)],
            v_landings(f,s))
                =L=
            p_TACSeg(catchQuotaName,quotaArea, seg) ;

MODEL m_policyEquations "Primal simulation model with profit maximization"
    /e_effRestrSeg,e_effRestrFishery,e_catchQuota,
     e_effortPerEffortGroup,e_effortRegulation, e_indQuota /;

** sätt på den i stället för ekvationen i prototyp när man vill ha in e_indQuota
*MODEL m_fishSim "Primal simulation model with profit maximization"
*    /e_objFunc,e_catch,e_sortA,e_sortB,e_landings,e_discards,e_effRestrSeg,e_effRestrFishery,e_catchQuota,
*     e_effortPerEffortGroup,e_effortRegulation, e_indQuota/;








* Expert knowledge *
* Set effortAnnual for "pilk, S" to original data since too large otherwise
* obs måste läggas in sist i set_bounds_simulation för annars skrivs det över i den filen
v_effortAnnual.FX("131") = p_effortOri("131");
v_effortAnnual.FX("142") = p_effortOri("142");








*** add cod
*p_landingObligation(fishery,"Torsk")             = 1           ;

***

*p_TACOri("aktaTunga","'KS'") = 50 ;
*p_TACOri("TorskAktiv","'K'") = 100 ;
*p_TACOri("TorskAktiv","'S'") = 1000 ;
