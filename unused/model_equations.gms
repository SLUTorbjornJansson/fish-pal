*#############################################################
*            DEFINE VARIABLES
*#############################################################

FREE VARIABLES
 v_SECT_PROFIT     objective function value is total profit for sector (kr)
;

POSITIVE VARIABLES
 v_CATCH(FISHERY,STOCK,AREA,PERIOD)    catch by species and fishery (kg\per)
 v_EFFORT(FISHERY,PERIOD)          optimal units of effort generated in each fishery and period
* v_CATCH_SG(SEGMENT,STOCK,AREA,PERIOD)  catch by segment and species (kg\per)
* TOT_CATCH(FISHERY)              total catch for fishery (kg)
* DISCARD(SEGMENT,STOCK,PERIOD)   discard by segment and species
*;
 PELMIX_181
*INTEGER VARIABLE
 VESSELS(SEGMENT)        optimal number of vessels in each segment


;


*#############################################################
*            DEFINE EQUATIONS
*#############################################################

EQUATIONS
 OBJFUNC                   objective function
 EFFORT_FISH(FISHERY,P)    effort constraint by fishery and period
 EFFORT_SG(SEGMENT,P)      effort constraint by segment and period
 TAC_STOCK(STOCK,AREA)           constraint to ensure TAC by stock not exceeded
 BIO_MAX(STOCK,AREA)             biological max for species without quota (and other species )
 KS_KOLJA(STOCK)           quota combined for Kattegatt and Skagerrak (K+S)
 KS_KRAFTA(STOCK)
 KS_KUMMEL(STOCK)
 KS_PIGGHAJ(STOCK)
 KS_RAKA(STOCK)
 KS_SILL(STOCK)
 KS_SILL_KONSUM(STOCK)
 KS_SILL_INDUSTRI(STOCK)
 KS_SKARPSILL(STOCK)
 KS_TUNGA(STOCK)
 KS_VITLING(STOCK)
 BALTIC_LAX(STOCK)         combined quotas for the  baltic areas
 BALTIC_RODSPOTTA(STOCK)
 BALTIC_SKARPSILL(STOCK)
 BALTIC_SILL(STOCK)
 BALTIC_EASTERNCOD(STOCK)

 CATCH_FUNC(FISHERY,STOCK,AREA,P) catch function
* CATCH_FISH(FISHERY)       calculates total catch by fishery


 FLEET(SEGMENT)              constraint to ensure max fleet size not exceeded in each segment
 FLEET_KWH                   EU max for Swedish fleet size in kwh
 RATION_PER(SEGMENT,STOCK,P) ration catch per vessel and period  (vecko ransoner)

COD_PASSIVE_25t32           allocating X% of the cod to passive gear
COD_ACTIVE_25t32            allocating (1-X)% of the cod to active gear
COD_PASSIVE_22t24
COD_ACTIVE_22t24
COD_ACTIVE_S                allocating (max) X % of cod catches to active gear in S
COD_PASSIVE_S
COD_ACTIVE_K                allocating (max) X % of cod catches to active gear in K
COD_PASSIVE_K
NORWLOBST_PASSIVE_KS
NORWLOBST_ACTIVE_KS          allocating (max)X % of norwegian lobster catches to active gear in S
NORWLOBST_EJRIST_KS            allocating 50% of norw lobst to grid
NORWLOBST_EJRIST_AP_KS         in activepassive scenario max 30 % of TAC caught without grid
SHRIMP_COASTAL                x% of shrimp catch cannot be caught by small scale coastal trawlers <18 m
NORWLOBST_COASTAL             x% of norwlobst catch cannot be caught by small scale coastal trawlers <12 m
SILL_KONSUM_2529
SILL_KUSTKVOT_2224
SILL_KUSTKVOT_2529
SILL_KUSTKVOT_3031
SILL_KUSTKVOT_KS
CATCH_SPRATQUOTA_2529     forces model to catch entire baltic sprat quota
M181_MIX_SPRAT                 används ej pga funkar inte
M181_MIX_HERRING               används ej pga funkar inte
PELMIX_LOWER                   används ej pga funkar inte
PELMIX_UPPER                   används ej pga funkar inte

BALTIC_EFFORT_2224(FISHERY)
BALTIC_EFFORT_2529(FISHERY)
*SG01_BALTIC_CODNET(V,P)       restricting cod fisheries to vessels with permit
*SG02_BALTIC_CODNET(V,P)
*SG03_BALTIC_CODNET(V,P)
*SG04_BALTIC_CODTRAWL(V,P)
*SG05_BALTIC_CODTRAWL(V,P)
*SG06_BALTIC_CODTRAWL(V,P)

*   Effort restrictions
e_EFFORT_kwh(kwh_group)


LLS_GNS_SEG17_2529
LLS_GNS_SEG18_2224
LLS_GNS_SEG18_2529
LLS_GNS_SEG19_2529

DTS_1012_2529_COD(V)
DTS_1218_2529_COD(V)
DTS_1824_2529_COD(V)
DTS_2440_2529_COD(V)

DTS_1218_2224_COD(V)
DTS_1824_2224_COD(V)
DTS_2440_2224_COD(V)

LOCK_EEL(EEL)       lock eel fisheries to have same effort as 2009

MAX_EFFORTCHANGE(F)
MAX_EFFORTCHANGE_64(F)
MAX_EFFORTCHANGE_65(F)
MAX_EFFORTCHANGE_66(F)

MAX_EFFORTCHANGE_31(F)
MAX_EFFORTCHANGE_43(F)
MAX_EFFORTCHANGE_48(F)
MAX_EFFORTCHANGE_55(F)
MAX_EFFORTCHANGE_56(F)
MAX_EFFORTCHANGE_60(F)
MAX_EFFORTCHANGE_62(F)
MAX_EFFORTCHANGE_63(F)

MAX_EFFORTCHANGE_148(F)
MAX_EFFORTCHANGE_94(F)
MAX_EFFORTCHANGE_178(F)
MAX_EFFORTCHANGE_131(F)
MAX_EFFORTCHANGE_18(F)
MAX_EFFORTCHANGE_28(F)

MAX_EFFORTCHANGE_1(F)
MAX_EFFORTCHANGE_156(F)
MAX_EFFORTCHANGE_157(F)
MAX_EFFORTCHANGE_158(F)
MAX_EFFORTCHANGE_159(F)


FISHINGSEASON(FISHERY,PERIOD)           modelling fishing seasons

TAC_SEG1(STOCK,AREA)                   låser andel av TACn till segment 1 (använd ej i ITQ)
TAC_SEG2(STOCK,AREA)
TAC_SEG3(STOCK,AREA)
TAC_SEG4(STOCK,AREA)
TAC_SEG5(STOCK,AREA)
TAC_SEG6(STOCK,AREA)
TAC_SEG7(STOCK,AREA)
TAC_SEG8(STOCK,AREA)
TAC_SEG9(STOCK,AREA)
TAC_SEG10(STOCK,AREA)
TAC_SEG11(STOCK,AREA)
TAC_SEG12(STOCK,AREA)
TAC_SEG13(STOCK,AREA)
TAC_SEG14(STOCK,AREA)
TAC_SEG15(STOCK,AREA)
TAC_SEG16(STOCK,AREA)
TAC_SEG17(STOCK,AREA)
TAC_SEG18(STOCK,AREA)
TAC_SEG19(STOCK,AREA)
TAC_SEG20(STOCK,AREA)
TAC_SEG21(STOCK,AREA)
TAC_SEG22(STOCK,AREA)
TAC_SEG23(STOCK,AREA)
TAC_SEG24(STOCK,AREA)

TAC_SEG2_KRAFTA(STOCK,AREA)
TAC_SEG3_KRAFTA(STOCK,AREA)
TAC_SEG4_KRAFTA(STOCK,AREA)
TAC_SEG5_KRAFTA(STOCK,AREA)
TAC_SEG6_KRAFTA(STOCK,AREA)
TAC_SEG7_KRAFTA(STOCK,AREA)
TAC_SEG8_KRAFTA(STOCK,AREA)
TAC_SEG9_KRAFTA(STOCK,AREA)
TAC_SEG10_KRAFTA(STOCK,AREA)
TAC_SEG11_KRAFTA(STOCK,AREA)
TAC_SEG12_KRAFTA(STOCK,AREA)
TAC_SEG13_KRAFTA(STOCK,AREA)
TAC_SEG14_KRAFTA(STOCK,AREA)
TAC_SEG15_KRAFTA(STOCK,AREA)
TAC_SEG23_SIKLOJA(STOCK,AREA)
TAC_SEG24_SIKLOJA(STOCK,AREA)
TAC_SEG13_AL(STOCK,AREA)
TAC_SEG14_AL(STOCK,AREA)
TAC_SEG15_AL(STOCK,AREA)
TAC_SEG16_AL(STOCK,AREA)
TAC_SEG17_AL(STOCK,AREA)
TAC_SEG18_AL(STOCK,AREA)
TAC_SEG19_AL(STOCK,AREA)

 EFFORT_SEGMENT_year(V)
;



*#############################################################
*            DEFINE MIP
*#############################################################

* objective is to maximize sector rents
* observe that CPUE is in tonnes per day and price is in kr/kg, but this
* matches since kr/kg equals tkr/ton and thus all calculations are performed
* using tonnes and tkr (VC and FC_VESSEL are both in tkr)

OBJFUNC..
 v_SECT_PROFIT  =E=  sum{(F,S,AREA,P), (PRICES(F,S) * v_CATCH(F,S,AREA,P))*DISCOUNT_RATE(P)}
                - sum{(F,P), VARCOST(F) * v_EFFORT(F,P)}  - sum{V, FC_VESSEL(V)*VESSELS(V)}
 ;


** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** **
** ** ** ** ** EFFORT RESTRICTIONS  ** ** ** ** **

* effort constraint on individual vessels by fishery and period
EFFORT_FISH(FISHERY,P) .. v_EFFORT(FISHERY,P) =L= SUM{SEGMENT $ SEGMENT_FISHERY(SEGMENT,FISHERY), VESSELS(SEGMENT) * MAX_EFF_F(FISHERY,P)};


* segment cannot generate more effort than fleet size allows
EFFORT_SG(SEGMENT,P).. sum{FISHERY $ SEGMENT_FISHERY(SEGMENT,FISHERY), v_EFFORT(FISHERY,P)}
                   =L= VESSELS(SEGMENT) * MAX_EFF_V(SEGMENT,P);

e_EFFORT_kwh(kwh_group) ..
    sum{(FISHERY,P) $ KWH_GROUP_FISHERY(kwh_group,FISHERY), v_EFFORT(FISHERY,P)*KWH_PER_VESSEL(FISHERY)}/1000
        =L=
    MAXEFF_VH(kwh_group)/1000;


* Baltic cod permits -
*SG01_BALTIC_CODNET("SG01",P).. sum{SG01_BALTICCODNET, v_EFFORT(SG01_BALTICCODNET,P)} =L= BALTIC_COD_PERMIT("SG01") *  MAX_EFF_V("SG01",P);
*SG02_BALTIC_CODNET("SG02",P).. sum{SG02_BALTICCODNET, v_EFFORT(SG02_BALTICCODNET,P)} =L= BALTIC_COD_PERMIT("SG02") *  MAX_EFF_V("SG02",P);
*SG03_BALTIC_CODNET("SG03",P).. sum{SG03_BALTICCODNET, v_EFFORT(SG03_BALTICCODNET,P)} =L= BALTIC_COD_PERMIT("SG03") *  MAX_EFF_V("SG03",P);

*SG04_BALTIC_CODTRAWL("SG04",P).. sum{SG04_BALTICCODTRAWL, v_EFFORT(SG04_BALTICCODTRAWL,P)} =L= BALTIC_COD_PERMIT("SG04") *  MAX_EFF_V("SG04",P);
*SG05_BALTIC_CODTRAWL("SG05",P).. sum{SG05_BALTICCODTRAWL, v_EFFORT(SG05_BALTICCODTRAWL,P)} =L= BALTIC_COD_PERMIT("SG05") *  MAX_EFF_V("SG05",P);
*SG06_BALTIC_CODTRAWL("SG06",P).. sum{SG06_BALTICCODTRAWL, v_EFFORT(SG06_BALTICCODTRAWL,P)} =L= BALTIC_COD_PERMIT("SG06") *  MAX_EFF_V("SG06",P);

LLS_GNS_SEG17_2529..
          sum(P, v_EFFORT("132",P))=L=   {EFFORT_2009("132")/(EFFORT_2009("128")+EFFORT_2009("132"))}*{sum(P, v_EFFORT("132",P))+sum(P, v_EFFORT("128",P))}  ;
LLS_GNS_SEG18_2224..
          sum(P, v_EFFORT("141",P))=L=   {EFFORT_2009("141")/(EFFORT_2009("137")+EFFORT_2009("141"))}*{sum(P, v_EFFORT("141",P))+sum(P, v_EFFORT("137",P))}  ;
LLS_GNS_SEG18_2529..
          sum(P, v_EFFORT("147",P))=L=   {EFFORT_2009("147")/(EFFORT_2009("142")+EFFORT_2009("147"))}*{sum(P, v_EFFORT("142",P))+sum(P, v_EFFORT("147",P))}  ;
LLS_GNS_SEG19_2529..
          sum(P, v_EFFORT("155",P))=L=   {EFFORT_2009("155")/(EFFORT_2009("153")+EFFORT_2009("155"))}*{sum(P, v_EFFORT("153",P))+sum(P, v_EFFORT("155",P))}  ;


* Begränsa torskfisket för de segment där det finns ett "permit".
* Om du ska simulera att tillståndets storlek blir noll, så måste det sättas till
* ett litet positivt tal (=EPS) för att restriktionen ska skapas.

*e_EFFORT_cod_permit(SEGMENT) $ BALTIC_COD_PERMIT(SEGMENT) ..
*   sum(P, v_EFFORT("30",P)) =L=  160*BALTIC_COD_PERMIT(SEGMENT)  ;

DTS_1012_2529_COD("DTS_1012").. sum(P, v_EFFORT("30",P)) =L= 160*BALTIC_COD_PERMIT("DTS_1012")  ;
DTS_1218_2529_COD("DTS_1218").. sum(P, v_EFFORT("42",P)) =L= 160*BALTIC_COD_PERMIT("DTS_1218")  ;
DTS_1824_2529_COD("DTS_1824").. sum(P, v_EFFORT("54",P)) =L= 160*BALTIC_COD_PERMIT("DTS_1824")  ;
DTS_2440_2529_COD("DTS_2440").. sum(P, v_EFFORT("61",P)) =L= 160*BALTIC_COD_PERMIT("DTS_2440")  ;

DTS_1218_2224_COD("DTS_1218").. sum(P, v_EFFORT("41",P)) =L= 201*BALTIC_COD_PERMIT("DTS_1218")  ;
DTS_1824_2224_COD("DTS_1824").. sum(P, v_EFFORT("53",P)) =L= 201*BALTIC_COD_PERMIT("DTS_1824")  ;
DTS_2440_2224_COD("DTS_2440").. sum(P, v_EFFORT("59",P)) =L= 201*BALTIC_COD_PERMIT("DTS_2440")  ;



* ANVÄNDS EJ
*EFFORT_LLS_GNS_2224..
*   sum({GNS_2224,P}, v_EFFORT(GNS_2224,P))- sum({LLS_2224,P}, v_EFFORT(LLS_2224,P))  =G= sum(GNS_2224, EFFORT_2009(GNS_2224))- sum(LLS_2224, EFFORT_2009(LLS_2224))  ;
*EFFORT_LLS_GNS_2529..
*   sum({GNS_2529,P}, v_EFFORT(GNS_2529,P))- sum({LLS_2529,P}, v_EFFORT(LLS_2529,P))  =G= sum(GNS_2529, EFFORT_2009(GNS_2529))- sum(LLS_2529, EFFORT_2009(LLS_2529))  ;


** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** **
* catch as a function of effort *


CATCH_FUNC(F,S,AREA,P)  ..
 v_CATCH(F,S,AREA,P) =E=  CPUE(F,S,AREA) * v_EFFORT(F,P) ;



** ** **  ** ** ** ** **  ** ** ** ** ** ** ** ** ** ** ** ** ** **
** ** ** TAC RESTRICTIONS ** ** ** ** ** ** ** ** ** ** ** ** ** **

* annual TAC by species-stock
* unquoted species are modelled with quota = 100 000 tons, constraind below in biological max

TAC_STOCK(S,AREA) ..
 sum{(F,P), v_CATCH(F,S,AREA,P)} =L=  TAC_MOD(S,AREA) ;

* biological max - constrains species that have no quotas (presently set to 2009 years catch)
BIO_MAX(S,AREA)..
 sum{(F,P), v_CATCH(F,S,AREA,P)} =L=  BIOL_MAX(S,AREA) ;

* conatraint ensuring that S+K quotas are not exceeded
* same quota for S and K
* Quota K and quota S set the same in Excel

 KS_KOLJA("kolja")..
  sum{(F,P,KS), v_CATCH(F,"kolja",KS,P)} =L=  TAC_MOD("kolja","K") ;
 KS_KRAFTA("havskrafta")..
  sum{(F,P,KS), v_CATCH(F,"havskrafta",KS,P)} =L=  TAC_MOD("havskrafta","K") ;
 KS_KUMMEL("KUMMEL")..
  sum{(F,P,KS), v_CATCH(F,"KUMMEL",KS,P)} =L= TAC_MOD("kummel","K") ;
 KS_PIGGHAJ("PIGGHAJ")..
  sum{(F,P,KS), v_CATCH(F,"PIGGHAJ",KS,P)} =L=  TAC_MOD("pigghaj","K") ;
 KS_RAKA("RAKA")..
  sum{(F,P,KS), v_CATCH(F,"RAKA",KS,P)} =L=  TAC_MOD("raka","K") ;
 KS_SILL("SILL_INDUSTRI")..
  sum{(F,P,KS), v_CATCH(F,"SILL_INDUSTRI",KS,P)}+ sum{(F,P,KS), v_CATCH(F,"SILL_KONSUM",KS,P)} =L=  TAC_MOD("sill_industri","K") ;
 KS_SILL_INDUSTRI("SILL_INDUSTRI")..
  sum{(F,P,KS), v_CATCH(F,"SILL_INDUSTRI",KS,P)} =L=  TAC_MOD("sill_industri","K") ;
 KS_SILL_KONSUM("SILL_KONSUM")..
  sum{(F,P,KS), v_CATCH(F,"SILL_KONSUM",KS,P)} =L=  TAC_MOD("sill_konsum","K") ;

 KS_SKARPSILL("SKARPSILL_INDUSTRI")..
  sum{(F,P,KS), v_CATCH(F,"SKARPSILL_INDUSTRI",KS,P)}+  sum{(F,P,KS), v_CATCH(F,"SKARPSILL_KONSUM",KS,P)} =L=  TAC_MOD("skarpsill_industri","K") ;
 KS_TUNGA("TUNGA")..
  sum{(F,P,KS), v_CATCH(F,"TUNGA",KS,P)} =L=  TAC_MOD("tunga","K") ;
 KS_VITLING("VITLING")..
  sum{(F,P,KS), v_CATCH(F,"VITLING",KS,P)} =L=  TAC_MOD("vitling","K") ;

* conatraint ensuring that Baltic quotas are not exceeded
 BALTIC_LAX("LAX")..
  sum{(F,P,BALTIC), v_CATCH(F,"LAX",BALTIC,P)} =L=  TAC_MOD("lax","25-29+32") ;
 BALTIC_SKARPSILL("SKARPSILL_INDUSTRI")$(CATCH_SPRATQUOTA_2529_dummy = 0)..
  sum{(F,P,BALTIC), v_CATCH(F,"SKARPSILL_INDUSTRI",BALTIC,P)}+  sum{(F,P,BALTIC), v_CATCH(F,"SKARPSILL_KONSUM",BALTIC,P)} =L=  TAC_MOD("skarpsill_industri","25-29+32") ;
 BALTIC_SILL("SILL_INDUSTRI")..
  sum{(F,P), v_CATCH(F,"SILL_INDUSTRI","25-29+32",P)}+  sum{(F,P), v_CATCH(F,"SILL_KONSUM","25-29+32",P)} =L=  TAC_MOD("sill_industri","25-29+32") ;
 BALTIC_RODSPOTTA("RODSPOTTA")..
  sum{(F,P,BALTIC), v_CATCH(F,"RODSPOTTA",BALTIC,P)} =L=  TAC_MOD("rodspotta","25-29+32") ;

 BALTIC_EASTERNCOD("TORSK")..
  sum{(F,P,BALTIC_EAST), v_CATCH(F,"TORSK",BALTIC_EAST,P)} =L=  TAC_MOD("torsk","25-29+32") ;

CATCH_SPRATQUOTA_2529$(CATCH_SPRATQUOTA_2529_dummy = 1)..
   sum{(F,P,BALTIC), v_CATCH(F,"SKARPSILL_INDUSTRI",BALTIC,P)}+  sum{(F,P,BALTIC), v_CATCH(F,"SKARPSILL_KONSUM",BALTIC,P)} =G=  TAC_MOD("skarpsill_industri","25-29+32") ;



M181_MIX_SPRAT..
 CPUE("181","Skarpsill_industri","25-29+32")  =E=  CPUE("181","Skarpsill_industri","25-29+32")+ CPUE("181","Sill_industri","25-29+32")*PELMIX_181 ;
M181_MIX_HERRING..
 CPUE("181","Sill_industri","25-29+32")  =E=   CPUE("181","Sill_industri","25-29+32")- CPUE("181","Sill_industri","25-29+32")*PELMIX_181 ;
PELMIX_UPPER..
 PELMIX_181 =L= 1 ;
PELMIX_LOWER..
 PELMIX_181 =G= 0.001 ;


* TAC for active and passive gear, BALTIC   and Skagerrack

* cod quota allocation to passive gear in the Baltic OBS not implemented yet in 2009 but included here anyway...
* OBS! check that 40/60 allocation
* 41/61 to make TAC binding and not this restriction


COD_PASSIVE_25t32$(ACTIVEPASSIVE = 1)..
         sum{(PASSIVEGEAR,P),  v_CATCH(PASSIVEGEAR,"Torsk","25-29+32",P)} =L= 0.23*TAC_MOD("Torsk","25-29+32") ;
COD_ACTIVE_25t32$(ACTIVEPASSIVE = 1)..
         sum({ACTIVEGEAR, P},  v_CATCH(ACTIVEGEAR,"Torsk","25-29+32",P)) =L= 0.77*TAC_MOD("Torsk","25-29+32")  ;
COD_PASSIVE_22t24$(ACTIVEPASSIVE = 1)..
         sum({PASSIVEGEAR, P},  v_CATCH(PASSIVEGEAR,"Torsk","22-24",P)) =L= 0.45*TAC_MOD("Torsk","22-24")  ;
COD_ACTIVE_22t24$(ACTIVEPASSIVE = 1)..
         sum({ACTIVEGEAR,P},  v_CATCH(ACTIVEGEAR,"Torsk","22-24",P)) =L= 0.65*TAC_MOD("Torsk","22-24")   ;

* Andelar S o K bygger på uppgifter från Havsfiskelab
* S: cod_active = 75 %, cod passive 25 %   (active tar 403 ton av 537)
* K  cod_active = 85 %, cod passive 15 %   (active tar 60 ton av 70)
*


COD_PASSIVE_S$(ACTIVEPASSIVE = 1)..
         sum{(PASSIVEGEAR,P),  v_CATCH(PASSIVEGEAR,"Torsk","S",P)} =L= 0.25*TAC_MOD("Torsk","S") ;
COD_ACTIVE_S$(ACTIVEPASSIVE = 1)..
         sum{(ACTIVEGEAR,P),  v_CATCH(ACTIVEGEAR,"Torsk","S",P)} =L= 0.75*TAC_MOD("Torsk","S") ;
COD_PASSIVE_K$(ACTIVEPASSIVE = 1)..
         sum{(PASSIVEGEAR,P),  v_CATCH(PASSIVEGEAR,"Torsk","K",P)} =L= 0.15*TAC_MOD("Torsk","K") ;
COD_ACTIVE_K$(ACTIVEPASSIVE = 1)..
         sum{(ACTIVEGEAR,P),  v_CATCH(ACTIVEGEAR,"Torsk","K",P)} =L= 0.85*TAC_MOD("Torsk","K") ;





* uppdelning enligt Havsfiskelab: rist >= 50 %
*                                 passiv = 20 %
*                                 ej rist = 30 %
* obs att kvoten är K + S så restriktionerna följer detta
*   NORWLOBST_EJRIST_AP_KS gör så att ej rist endast tar max 30 % i Active/Passive scenario
* om bas scenario får "ej rist" ta 50 % av fångsten

NORWLOBST_PASSIVE_KS$(ACTIVEPASSIVE = 1)..
           sum{(PASSIVEGEAR,P),  v_CATCH(PASSIVEGEAR,"havskrafta","S",P)} + sum{(PASSIVEGEAR,P),  v_CATCH(PASSIVEGEAR,"havskrafta","K",P)} =L= 0.20*TAC_MOD("havskrafta","S") ;

NORWLOBST_ACTIVE_KS$(ACTIVEPASSIVE = 1)..
           sum{(ACTIVEGEAR,P),  v_CATCH(ACTIVEGEAR,"havskrafta","S",P)} + sum{(ACTIVEGEAR,P),  v_CATCH(ACTIVEGEAR,"havskrafta","K",P)} =L= 0.80*TAC_MOD("havskrafta","S") ;

NORWLOBST_EJRIST_AP_KS$(ACTIVEPASSIVE = 1)..
           sum{(KRAFTA_EJRIST,P),  v_CATCH(KRAFTA_EJRIST,"havskrafta","S",P)} + sum{(KRAFTA_EJRIST,P),  v_CATCH(KRAFTA_EJRIST,"havskrafta","K",P)}=L= 0.3*TAC_MOD("havskrafta","S") ;

NORWLOBST_EJRIST_KS..
           sum{(KRAFTA_EJRIST,P),  v_CATCH(KRAFTA_EJRIST,"havskrafta","S",P)} + sum{(KRAFTA_EJRIST,P),  v_CATCH(KRAFTA_EJRIST,"havskrafta","K",P)}=L= 0.5*TAC_MOD("havskrafta","S") ;

*  dagens fångst 30 %
SHRIMP_COASTAL..
           sum{(SHRIMP_KS_1018,P), v_CATCH(SHRIMP_KS_1018,"Raka","K",P)} + sum{(SHRIMP_KS_1018,P), v_CATCH(SHRIMP_KS_1018,"Raka","S",P)} =L= 0.30*TAC_MOD("Raka","S") ;
* kolla rimlig % med Katja, dagens fångst är 11 %
NORWLOBST_COASTAL..
           sum{(NORWLOBST_0012,P), v_CATCH(NORWLOBST_0012,"havskrafta","K",P)} + sum{(NORWLOBST_0012,P), v_CATCH(NORWLOBST_0012,"havskrafta","S",P)} =L= 0.25*TAC_MOD("havskrafta","S") ;

SILL_KONSUM_2529..
            sum{(F,P),  v_CATCH(F,"sill_konsum","25-29+32",P)} =L= 0.5*TAC_MOD("sill_konsum","25-29+32") ;

* kustfiskekvot = max av kvot och infiskat (det senare ofta över kvot pga extratilldelning som sedan leder till höjd kvot 2010

SILL_KUSTKVOT_2224..
             sum{(PEL_KUSTFISKE,P), v_CATCH(PEL_KUSTFISKE, "sill_konsum", "22-24", P)} =L= 817 ;
SILL_KUSTKVOT_2529..
             sum{(PEL_KUSTFISKE,P), v_CATCH(PEL_KUSTFISKE, "sill_konsum", "25-29+32", P)} =L= 745 ;
SILL_KUSTKVOT_3031..
             sum{(PEL_KUSTFISKE,P), v_CATCH(PEL_KUSTFISKE, "sill_konsum", "30-31", P)} =L= 3000 ;
SILL_KUSTKVOT_KS..
             sum{(PEL_KUSTFISKE,P), v_CATCH(PEL_KUSTFISKE, "sill_konsum", "K", P)} +  sum{(PEL_KUSTFISKE,P), v_CATCH(PEL_KUSTFISKE, "sill_konsum", "S", P)}=L= 250 ;


* ##### restr till att återskapa dagens situation ######
* Låser TAC mellan segmenten
* obs att catchshare avser andel av totfångst som segmentet står för vilket är en genväg eftesom detta kan skilja mellan områden.
* special för kräfta seg 3 och 4 eftersom dessa annars expanderar pga restriktionen gäller gemensam kvot - därför delat med 2

TAC_SEG1(S,A).. sum{(SEG1,P),  v_CATCH(SEG1,S,A,P)} =L= SUM(SEG1, CATCHSHARE_2009(SEG1,S,A)*TAC_MOD(S,A)) ;
TAC_SEG2(S,A).. sum{(SEG2,P),  v_CATCH(SEG2,S,A,P)} =L= SUM(SEG2, CATCHSHARE_2009(SEG2,S,A)*TAC_MOD(S,A)) ;
TAC_SEG3(S,A).. sum{(SEG3,P),  v_CATCH(SEG3,S,A,P)} =L= SUM(SEG3, CATCHSHARE_2009(SEG3,S,A)*TAC_MOD(S,A)) ;
TAC_SEG4(S,A).. sum{(SEG4,P),  v_CATCH(SEG4,S,A,P)} =L= SUM(SEG4, CATCHSHARE_2009(SEG4,S,A)*TAC_MOD(S,A)) ;
TAC_SEG5(S,A).. sum{(SEG5,P),  v_CATCH(SEG5,S,A,P)} =L= SUM(SEG5, CATCHSHARE_2009(SEG5,S,A)*TAC_MOD(S,A)) ;
TAC_SEG6(S,A).. sum{(SEG6,P),  v_CATCH(SEG6,S,A,P)} =L= SUM(SEG6, CATCHSHARE_2009(SEG6,S,A)*TAC_MOD(S,A)) ;
TAC_SEG7(S,A).. sum{(SEG7,P),  v_CATCH(SEG7,S,A,P)} =L= SUM(SEG7, CATCHSHARE_2009(SEG7,S,A)*TAC_MOD(S,A)) ;
TAC_SEG8(S,A).. sum{(SEG8,P),  v_CATCH(SEG8,S,A,P)} =L= SUM(SEG8, CATCHSHARE_2009(SEG8,S,A)*TAC_MOD(S,A)) ;
TAC_SEG9(S,A).. sum{(SEG9,P),  v_CATCH(SEG9,S,A,P)} =L= SUM(SEG9, CATCHSHARE_2009(SEG9,S,A)*TAC_MOD(S,A)) ;
TAC_SEG10(S,A).. sum{(SEG10,P),  v_CATCH(SEG10,S,A,P)} =L= SUM(SEG10, CATCHSHARE_2009(SEG10,S,A)*TAC_MOD(S,A)) ;
TAC_SEG11(S,A).. sum{(SEG11,P),  v_CATCH(SEG11,S,A,P)} =L= SUM(SEG11, CATCHSHARE_2009(SEG11,S,A)*TAC_MOD(S,A)) ;
TAC_SEG12(S,A).. sum{(SEG12,P),  v_CATCH(SEG12,S,A,P)} =L= SUM(SEG12, CATCHSHARE_2009(SEG12,S,A)*TAC_MOD(S,A)) ;
TAC_SEG13(S,A).. sum{(SEG13,P),  v_CATCH(SEG13,S,A,P)} =L= SUM(SEG13, CATCHSHARE_2009(SEG13,S,A)*TAC_MOD(S,A)) ;
TAC_SEG14(S,A).. sum{(SEG14,P),  v_CATCH(SEG14,S,A,P)} =L= SUM(SEG14, CATCHSHARE_2009(SEG14,S,A)*TAC_MOD(S,A)) ;
TAC_SEG15(S,A).. sum{(SEG15,P),  v_CATCH(SEG15,S,A,P)} =L= SUM(SEG15, CATCHSHARE_2009(SEG15,S,A)*TAC_MOD(S,A)) ;
TAC_SEG16(S,A).. sum{(SEG16,P),  v_CATCH(SEG16,S,A,P)} =L= SUM(SEG16, CATCHSHARE_2009(SEG16,S,A)*TAC_MOD(S,A)) ;
TAC_SEG17(S,A).. sum{(SEG17,P),  v_CATCH(SEG17,S,A,P)} =L= SUM(SEG17, CATCHSHARE_2009(SEG17,S,A)*TAC_MOD(S,A)) ;
TAC_SEG18(S,A).. sum{(SEG18,P),  v_CATCH(SEG18,S,A,P)} =L= SUM(SEG18, CATCHSHARE_2009(SEG18,S,A)*TAC_MOD(S,A)) ;
TAC_SEG19(S,A).. sum{(SEG19,P),  v_CATCH(SEG19,S,A,P)} =L= SUM(SEG19, CATCHSHARE_2009(SEG19,S,A)*TAC_MOD(S,A)) ;
TAC_SEG20(S,A).. sum{(SEG20,P),  v_CATCH(SEG20,S,A,P)} =L= SUM(SEG20, CATCHSHARE_2009(SEG20,S,A)*TAC_MOD(S,A)) ;
TAC_SEG21(S,A).. sum{(SEG21,P),  v_CATCH(SEG21,S,A,P)} =L= SUM(SEG21, CATCHSHARE_2009(SEG21,S,A)*TAC_MOD(S,A)) ;
TAC_SEG22(S,A).. sum{(SEG22,P),  v_CATCH(SEG22,S,A,P)} =L= SUM(SEG22, CATCHSHARE_2009(SEG22,S,A)*TAC_MOD(S,A)) ;
TAC_SEG23(S,A).. sum{(SEG23,P),  v_CATCH(SEG23,S,A,P)} =L= SUM(SEG23, CATCHSHARE_2009(SEG23,S,A)*TAC_MOD(S,A)) ;
TAC_SEG24(S,A).. sum{(SEG24,P),  v_CATCH(SEG24,S,A,P)} =L= SUM(SEG24, CATCHSHARE_2009(SEG24,S,A)*TAC_MOD(S,A)) ;

*TAC restriktioner ovan funkar inte på kvoter som täcker två områden, kompletteras för kräfta (ej torsk pga inga fångster i 30-31)
TAC_SEG2_KRAFTA("havskrafta",A).. sum{(SEG2,P),  v_CATCH(SEG2,"havskrafta",A,P)} =L= SUM(SEG2, CATCHSHARE_2009(SEG2,"havskrafta",A))*TAC_MOD("havskrafta",A)/2 ;
TAC_SEG3_KRAFTA("havskrafta",A).. sum{(SEG3,P),  v_CATCH(SEG3,"havskrafta",A,P)} =L= SUM(SEG3, CATCHSHARE_2009(SEG3,"havskrafta",A))*TAC_MOD("havskrafta",A)/2 ;
TAC_SEG4_KRAFTA("havskrafta",A).. sum{(SEG4,P),  v_CATCH(SEG4,"havskrafta",A,P)} =L= SUM(SEG4, CATCHSHARE_2009(SEG4,"havskrafta",A))*TAC_MOD("havskrafta",A)/2 ;
TAC_SEG5_KRAFTA("havskrafta",A).. sum{(SEG5,P),  v_CATCH(SEG5,"havskrafta",A,P)} =L= SUM(SEG5, CATCHSHARE_2009(SEG5,"havskrafta",A))*TAC_MOD("havskrafta",A)/2 ;
TAC_SEG6_KRAFTA("havskrafta",A).. sum{(SEG6,P),  v_CATCH(SEG6,"havskrafta",A,P)} =L= SUM(SEG6, CATCHSHARE_2009(SEG6,"havskrafta",A))*TAC_MOD("havskrafta",A)/2 ;
TAC_SEG7_KRAFTA("havskrafta",A).. sum{(SEG7,P),  v_CATCH(SEG7,"havskrafta",A,P)} =L= SUM(SEG7, CATCHSHARE_2009(SEG7,"havskrafta",A))*TAC_MOD("havskrafta",A)/2 ;
TAC_SEG8_KRAFTA("havskrafta",A).. sum{(SEG8,P),  v_CATCH(SEG8,"havskrafta",A,P)} =L= SUM(SEG8, CATCHSHARE_2009(SEG8,"havskrafta",A))*TAC_MOD("havskrafta",A)/2 ;
TAC_SEG9_KRAFTA("havskrafta",A).. sum{(SEG9,P),  v_CATCH(SEG9,"havskrafta",A,P)} =L= SUM(SEG9, CATCHSHARE_2009(SEG9,"havskrafta",A))*TAC_MOD("havskrafta",A)/2 ;
TAC_SEG10_KRAFTA("havskrafta",A).. sum{(SEG10,P),  v_CATCH(SEG10,"havskrafta",A,P)} =L= SUM(SEG10, CATCHSHARE_2009(SEG10,"havskrafta",A))*TAC_MOD("havskrafta",A)/2 ;
TAC_SEG11_KRAFTA("havskrafta",A).. sum{(SEG11,P),  v_CATCH(SEG11,"havskrafta",A,P)} =L= SUM(SEG11, CATCHSHARE_2009(SEG11,"havskrafta",A))*TAC_MOD("havskrafta",A)/2 ;
TAC_SEG12_KRAFTA("havskrafta",A).. sum{(SEG12,P),  v_CATCH(SEG12,"havskrafta",A,P)} =L= SUM(SEG12, CATCHSHARE_2009(SEG12,"havskrafta",A))*TAC_MOD("havskrafta",A)/2 ;
TAC_SEG13_KRAFTA("havskrafta",A).. sum{(SEG13,P),  v_CATCH(SEG13,"havskrafta",A,P)} =L= SUM(SEG13, CATCHSHARE_2009(SEG13,"havskrafta",A))*TAC_MOD("havskrafta",A)/2 ;
TAC_SEG14_KRAFTA("havskrafta",A).. sum{(SEG14,P),  v_CATCH(SEG14,"havskrafta",A,P)} =L= SUM(SEG14, CATCHSHARE_2009(SEG14,"havskrafta",A))*TAC_MOD("havskrafta",A)/2 ;
TAC_SEG15_KRAFTA("havskrafta",A).. sum{(SEG15,P),  v_CATCH(SEG15,"havskrafta",A,P)} =L= SUM(SEG15, CATCHSHARE_2009(SEG15,"havskrafta",A))*TAC_MOD("havskrafta",A)/2 ;

*TAC restriktioner ovan funkar inte på okvoterade arter, kompletteras för siklöja och ål
TAC_SEG23_SIKLOJA("sikloja",A).. sum{(SEG23,P),  v_CATCH(SEG23,"sikloja",A,P)} =L= SUM(SEG23, CATCHSHARE_2009(SEG23,"sikloja",A))* BIOL_MAX("sikloja",A) ;
TAC_SEG24_SIKLOJA("sikloja",A).. sum{(SEG24,P),  v_CATCH(SEG24,"sikloja",A,P)} =L= SUM(SEG24, CATCHSHARE_2009(SEG24,"sikloja",A))* BIOL_MAX("sikloja",A) ;

TAC_SEG13_AL("al",A).. sum{(SEG13,P),  v_CATCH(SEG13,"al",A,P)} =L= SUM(SEG13, CATCHSHARE_2009(SEG13,"al",A))* BIOL_MAX("al",A) ;
TAC_SEG14_AL("al",A).. sum{(SEG14,P),  v_CATCH(SEG14,"al",A,P)} =L= SUM(SEG14, CATCHSHARE_2009(SEG14,"al",A))* BIOL_MAX("al",A) ;
TAC_SEG15_AL("al",A).. sum{(SEG15,P),  v_CATCH(SEG15,"al",A,P)} =L= SUM(SEG15, CATCHSHARE_2009(SEG15,"al",A))* BIOL_MAX("al",A) ;
TAC_SEG16_AL("al",A).. sum{(SEG16,P),  v_CATCH(SEG16,"al",A,P)} =L= SUM(SEG16, CATCHSHARE_2009(SEG16,"al",A))* BIOL_MAX("al",A) ;
TAC_SEG17_AL("al",A).. sum{(SEG17,P),  v_CATCH(SEG17,"al",A,P)} =L= SUM(SEG17, CATCHSHARE_2009(SEG17,"al",A))* BIOL_MAX("al",A) ;
TAC_SEG18_AL("al",A).. sum{(SEG18,P),  v_CATCH(SEG18,"al",A,P)} =L= SUM(SEG18, CATCHSHARE_2009(SEG18,"al",A))* BIOL_MAX("al",A) ;
TAC_SEG19_AL("al",A).. sum{(SEG19,P),  v_CATCH(SEG19,"al",A,P)} =L= SUM(SEG19, CATCHSHARE_2009(SEG19,"al",A))* BIOL_MAX("al",A) ;



* effort per year based on DAS2009 in model divided by vessels, not same as Hav's DAS per vessel!!
EFFORT_SEGMENT_year(SEGMENT) .. sum{(FISHERY,P) $ SEGMENT_FISHERY(SEGMENT,FISHERY), v_EFFORT(FISHERY,P)} =L= VESSELS(SEGMENT)   *  MAX_FISHING_DAYS(SEGMENT);

* Keep effort in eel fisheries  equal to 2009
LOCK_EEL(EEL)..
  sum{p, v_EFFORT(EEL,P)} =E= EFFORT_2009(EEL)     ;



* effort only possible when seasondummy = 1
FISHINGSEASON(F,P).. v_EFFORT(F,P) =E= v_EFFORT(F,P)*SEASON(F,P) ;


MAX_EFFORTCHANGE(F)..   SUM{P,v_EFFORT(F,P)} =L= (MAX_EFFORTINCREASE)*EFFORT_2009(F)       ;
MAX_EFFORTCHANGE_64("64")..   SUM{P,v_EFFORT("64",P)} =L= (MAX_EFFORTINCREASE_64)*EFFORT_2009("64")       ;
MAX_EFFORTCHANGE_65("65")..   SUM{P,v_EFFORT("65",P)} =L= (MAX_EFFORTINCREASE_65)*EFFORT_2009("65")       ;
MAX_EFFORTCHANGE_66("66")..   SUM{P,v_EFFORT("66",P)} =L= (MAX_EFFORTINCREASE_66)*EFFORT_2009("66")       ;

MAX_EFFORTCHANGE_31("31")..   SUM{P,v_EFFORT("31",P)} =L= (MAX_EFFORTINCREASE_31)*EFFORT_2009("31")       ;
MAX_EFFORTCHANGE_43("43")..   SUM{P,v_EFFORT("43",P)} =L= (MAX_EFFORTINCREASE_43)*EFFORT_2009("43")       ;
MAX_EFFORTCHANGE_48("48")..   SUM{P,v_EFFORT("48",P)} =L= (MAX_EFFORTINCREASE_48)*EFFORT_2009("48")       ;
MAX_EFFORTCHANGE_55("55")..   SUM{P,v_EFFORT("55",P)} =L= (MAX_EFFORTINCREASE_55)*EFFORT_2009("55")       ;
MAX_EFFORTCHANGE_56("56")..   SUM{P,v_EFFORT("56",P)} =L= (MAX_EFFORTINCREASE_56)*EFFORT_2009("56")       ;
MAX_EFFORTCHANGE_60("60")..   SUM{P,v_EFFORT("60",P)} =L= (MAX_EFFORTINCREASE_60)*EFFORT_2009("60")       ;
MAX_EFFORTCHANGE_62("62")..   SUM{P,v_EFFORT("62",P)} =L= (MAX_EFFORTINCREASE_62)*EFFORT_2009("62")       ;
MAX_EFFORTCHANGE_63("63")..   SUM{P,v_EFFORT("63",P)} =L= (MAX_EFFORTINCREASE_63)*EFFORT_2009("63")       ;


MAX_EFFORTCHANGE_148("148")..   SUM{P,v_EFFORT("148",P)} =L= (MAX_EFFORTINCREASE_148)*EFFORT_2009("148")       ;
MAX_EFFORTCHANGE_94("94")..   SUM{P,v_EFFORT("94",P)} =L= (MAX_EFFORTINCREASE_94)*EFFORT_2009("94")       ;
MAX_EFFORTCHANGE_178("178")..   SUM{P,v_EFFORT("178",P)} =L= (MAX_EFFORTINCREASE_178)*EFFORT_2009("178")       ;
MAX_EFFORTCHANGE_131("131")..   SUM{P,v_EFFORT("131",P)} =L= (MAX_EFFORTINCREASE_131)*EFFORT_2009("131")       ;
MAX_EFFORTCHANGE_18("18")..   SUM{P,v_EFFORT("18",P)} =L= (MAX_EFFORTINCREASE_18)*EFFORT_2009("18")       ;
MAX_EFFORTCHANGE_28("28")..   SUM{P,v_EFFORT("28",P)} =L= (MAX_EFFORTINCREASE_28)*EFFORT_2009("28")       ;

MAX_EFFORTCHANGE_1("1")..   SUM{P,v_EFFORT("1",P)} =L= (MAX_EFFORTINCREASE_1)*EFFORT_2009("1")       ;
MAX_EFFORTCHANGE_156("156")..   SUM{P,v_EFFORT("156",P)} =L= (MAX_EFFORTINCREASE_156)*EFFORT_2009("156")       ;
MAX_EFFORTCHANGE_157("157")..   SUM{P,v_EFFORT("157",P)} =L= (MAX_EFFORTINCREASE_157)*EFFORT_2009("157")       ;
MAX_EFFORTCHANGE_158("158")..   SUM{P,v_EFFORT("158",P)} =L= (MAX_EFFORTINCREASE_158)*EFFORT_2009("158")       ;
MAX_EFFORTCHANGE_159("159")..   SUM{P,v_EFFORT("159",P)} =L= (MAX_EFFORTINCREASE_159)*EFFORT_2009("159")       ;




* ####################### Att hantera senare??? #############################


* upper bound on fleet size in each segment = 2009 fleet size
FLEET(V)..
 VESSELS(V) =L= FLEET_MAX(V);

FLEET_KWH..
sum{V, VESSELS(V)*KWH_VESSEL_SEG(V)}  =L= 168446 ;
* 168446 is total kwh in 2009
* vad är kapacitetstaket i praktiken???



** ** ** EFFORT BALTIC ** ** **
* OBS! not correct modelling since not all vessels in VESSELS(V) have effort days in the Baltic, not in use!
* i.e. the model overestimates the maximum possible fishing effort in the Baltic
BALTIC_EFFORT_2224(FISHERY)..
         sum{(BALTIC2224_COD,P), v_EFFORT(BALTIC2224_COD,P)} =L= 201*sum{V, VESSELS(V)}    ;
BALTIC_EFFORT_2529(FISHERY)..
         sum{(BALTIC2529_COD,P), v_EFFORT(BALTIC2529_COD,P)} =L= 160*sum{V, VESSELS(V)}    ;



*#############################################################
*            DEFINE MODEL AND SOLVE STATEMENTS
*#############################################################

MODEL FISH_MOD /ALL/;

OPTION MIP = BDMLP;

*SOLVE FISH_MOD USING MIP MAXIMIZING SECT_PROFIT;


MODEL FISH_MOD_SW / OBJFUNC ,
 EFFORT_FISH,
*$ONTEXT
 EFFORT_SG,
*$OFFTEXT
 TAC_STOCK  ,
 BIO_MAX     ,




 CATCH_FUNC  ,
* FLEET ,
 FLEET_KWH,

 COD_PASSIVE_25t32 ,
 COD_ACTIVE_25t32   ,
 COD_PASSIVE_22t24   ,
 COD_ACTIVE_22t24  ,
 COD_PASSIVE_S,
 COD_ACTIVE_S,
 COD_PASSIVE_K,
 COD_ACTIVE_K,
 NORWLOBST_PASSIVE_KS,
 NORWLOBST_ACTIVE_KS,
 NORWLOBST_EJRIST_KS,
 NORWLOBST_EJRIST_AP_KS,
 SHRIMP_COASTAL,
 NORWLOBST_COASTAL,
 SILL_KONSUM_2529
 SILL_KUSTKVOT_2224,
 SILL_KUSTKVOT_2529,
 SILL_KUSTKVOT_3031,
 SILL_KUSTKVOT_KS,

* BALTIC_EFFORT_2224,
* BALTIC_EFFORT_2529,
* SG01_BALTIC_CODNET,
* SG02_BALTIC_CODNET,
* SG03_BALTIC_CODNET,
* SG04_BALTIC_CODTRAWL,
* SG05_BALTIC_CODTRAWL,
* SG06_BALTIC_CODTRAWL,
LLS_GNS_SEG17_2529,
LLS_GNS_SEG18_2224,
LLS_GNS_SEG18_2529,
LLS_GNS_SEG19_2529,

DTS_1012_2529_COD,
DTS_1218_2529_COD,
DTS_1824_2529_COD,
DTS_2440_2529_COD,

DTS_1218_2224_COD,
DTS_1824_2224_COD,
DTS_2440_2224_COD,



 KS_KOLJA  ,
 KS_KRAFTA,
 KS_KUMMEL,
 KS_PIGGHAJ,
 KS_RAKA,
 KS_SILL,
 KS_SILL_INDUSTRI,
 KS_SILL_KONSUM,
 KS_SKARPSILL,
 KS_TUNGA,
 KS_VITLING ,
 BALTIC_LAX ,
 BALTIC_RODSPOTTA,
 BALTIC_SKARPSILL,
 BALTIC_SILL,
 BALTIC_EASTERNCOD,
 CATCH_SPRATQUOTA_2529,


* M181_MIX_SPRAT,
* M181_MIX_HERRING,
* PELMIX_LOWER,
* PELMIX_UPPER,


* LOCK_EEL,

*   Effort restrictions
e_EFFORT_kwh

 FISHINGSEASON ,
* MAX_EFFORTCHANGE ,

MAX_EFFORTCHANGE_31,
MAX_EFFORTCHANGE_43,
MAX_EFFORTCHANGE_48,
MAX_EFFORTCHANGE_55,
MAX_EFFORTCHANGE_56,
MAX_EFFORTCHANGE_60,
MAX_EFFORTCHANGE_62,
MAX_EFFORTCHANGE_63,
 MAX_EFFORTCHANGE_64  ,
 MAX_EFFORTCHANGE_65 ,
 MAX_EFFORTCHANGE_66  ,

 MAX_EFFORTCHANGE_148   ,
* MAX_EFFORTCHANGE_94
 MAX_EFFORTCHANGE_178,
 MAX_EFFORTCHANGE_131,
 MAX_EFFORTCHANGE_18,
 MAX_EFFORTCHANGE_28,

 MAX_EFFORTCHANGE_1,
 MAX_EFFORTCHANGE_156,
 MAX_EFFORTCHANGE_157,
 MAX_EFFORTCHANGE_158,
 MAX_EFFORTCHANGE_159

* för körning av dagens situation, obs stryk då EFFORT_SG1 etc.
$ONTEXT
, TAC_SEG1  ,
 TAC_SEG2  ,
 TAC_SEG3  ,
 TAC_SEG4  ,
 TAC_SEG5  ,
 TAC_SEG6  ,
 TAC_SEG7  ,
 TAC_SEG8  ,
 TAC_SEG9  ,
 TAC_SEG10  ,
 TAC_SEG11  ,
 TAC_SEG12  ,
 TAC_SEG13  ,
 TAC_SEG14  ,
 TAC_SEG15  ,
 TAC_SEG16  ,
 TAC_SEG17  ,
 TAC_SEG18  ,
 TAC_SEG19  ,
 TAC_SEG20  ,
 TAC_SEG21  ,
 TAC_SEG22  ,
 TAC_SEG23  ,
 TAC_SEG24  ,

 TAC_SEG2_KRAFTA,
 TAC_SEG3_KRAFTA,
 TAC_SEG4_KRAFTA,
 TAC_SEG5_KRAFTA,
 TAC_SEG6_KRAFTA,
 TAC_SEG7_KRAFTA,
 TAC_SEG8_KRAFTA,
 TAC_SEG9_KRAFTA,
 TAC_SEG10_KRAFTA,
 TAC_SEG11_KRAFTA,
 TAC_SEG12_KRAFTA,
 TAC_SEG13_KRAFTA,
 TAC_SEG14_KRAFTA,
 TAC_SEG15_KRAFTA,
 TAC_SEG23_SIKLOJA,
 TAC_SEG24_SIKLOJA,
 TAC_SEG13_AL,
 TAC_SEG14_AL,
 TAC_SEG15_AL,
 TAC_SEG16_AL,
 TAC_SEG17_AL,
 TAC_SEG18_AL,
 TAC_SEG19_AL,

 EFFORT_SEGMENT_year
$OFFTEXT
* MAX_EFFORTCHANGE_100,
* MAX_EFFORTCHANGE_107

  / ;


