$TITLE    Swedish Fisheries Sector Model                     (SweFishMod_07.gms)


*##########################################################################
*######################## CHOOSE LABOUR COSTS   #######################

parameters
altcost_labour /1/
* 1 = use alternative cost for labour
* 0 = use labour costs from SNBF's economic statistics
;
abort$(altcost_labour > 1) "!! wrong choice of labour cost parameter !!"     ;

*##########################################################################
*###################### CHOOSE ACTIVEPASSIVE OR BASE CASE   ###############

parameters
ACTIVEPASSIVE /1/                  ;
* 0 = ITQ BASE
* 1 = ACTIVE AND PASSIVE HAVE SEPARATE QUOTAS

*######################################################################
*########################### CHANGE CPUE   ############################
* ################### under user control   0/1 dummy  #########################
* obs cannot change CPUE and still lock pelagic fisheries = infeasible

parameters
CPUE_COD /0/
CPUE_HERRING /0/
CPUE_SPRAT /0/
* 1 = change CPUE for cod  when TAC changes as compared to  (elasticity=0.6)
* 0 = do not change CPUE
* obs! if CPUE_COD is set to one, change "base TAC" manually in the code below
* should be based on "active" metiers as defined in Excel "policy"
;




abort$(CPUE_COD > 1) "!! wrong choice of CPUE_COD !!"
abort$(CPUE_HERRING > 1) "!! wrong choice of CPUE_HERRING !!"
abort$(CPUE_SPRAT > 1) "!! wrong choice of CPUE_SPRAT !!"      ;

parameters
CPUEincrease_sprat_181 /0/
CPUEincrease_herring_181 /1/
CPUEincrease_sprat_199 /0/
CPUEincrease_herring_199 /1/
* "sprat" = share of herring catch transferred to sprat catch, 0.1 means 10 % of herring catches changes to sprat catch
* "herring" = share of sprat catch transferred to herring catch
* metier 181 and 199 are the major pelagic fisheries
* this changes catch composition in order to get catches also when TAC composition changes radically

CPUEincrease_ind_sprat_181 /0/
CPUEincrease_ind_sprat_199 /0/
CPUEincrease_ind_herring_181 /0/
CPUEincrease_ind_herring_199 /0/
*  ind= share of consume catch transferred to industry catch, 0.1 means 10 % of cons catches changes to ind catch

parameters
CATCH_SPRATQUOTA_2529_dummy /0/ ;
* 1 = forces model to catch entire baltic sprat quota


parameters
MAX_EFFORTINCREASE /10/
* 5 :   effort <= 5 times effort in 2009

MAX_EFFORTINCREASE_148    OTB torsk i garnsegment                /1/
MAX_EFFORTINCREASE_94     surströmming                            /2/

MAX_EFFORTINCREASE_64     small scale shrimp                        /1/
MAX_EFFORTINCREASE_65     small scale shrimp                         /1/
MAX_EFFORTINCREASE_66     small scale norw lobst in shrimp segment   /1/


MAX_EFFORTINCREASE_31     pelagiskt fiske ej pel segment         /1/
MAX_EFFORTINCREASE_43     pelagiskt fiske ej pel segment         /1/
MAX_EFFORTINCREASE_48     pelagiskt fiske ej pel segment         /1/
MAX_EFFORTINCREASE_55     pelagiskt fiske ej pel segment         /1/
MAX_EFFORTINCREASE_56     pelagiskt fiske ej pel segment         /1/
MAX_EFFORTINCREASE_60     pelagiskt fiske ej pel segment         /1/
MAX_EFFORTINCREASE_62     pelagiskt fiske ej pel segment         /1/
MAX_EFFORTINCREASE_63     pelagiskt fiske ej pel segment         /1/
MAX_EFFORTINCREASE_178    pelagiskt konsumfiske 2529 extremt lönsamt  /1/
MAX_EFFORTINCREASE_131    trammelnet ål 2529 ej realistisk ökning på bekostnad av stationary poundnet  /1/
MAX_EFFORTINCREASE_18     cod baltic_2529 by nephrops trawler   /1/
MAX_EFFORTINCREASE_28     cod baltic_2529 by nephrops trawler   /1/

MAX_EFFORTINCREASE_1      SEG1 har ej fiske                           /0/
MAX_EFFORTINCREASE_156    SEG20 har ej fiske                          /0/
MAX_EFFORTINCREASE_157    SEG20 har ej fiske                          /0/
MAX_EFFORTINCREASE_158    SEG20 har ej fiske                          /0/
MAX_EFFORTINCREASE_159    SEG20 har ej fiske                          /0/

*old
MAX_EFFORTINCREASE_132     6 K    räka                           /50000/
MAX_EFFORTINCREASE_136     6 S    Crustaceans MIX                /50000/
MAX_EFFORTINCREASE_140     6 S    räka                           /50000/
MAX_EFFORTINCREASE_84      3 K    pots and traps kräfta          /50000/
MAX_EFFORTINCREASE_92      3 S    pots and traps kräfta          /50000/
MAX_EFFORTINCREASE_100      4 K    trål kräfta                   /50000/
MAX_EFFORTINCREASE_107      4 S    trål kräfta                   /50000/


    ;

*###############################################################################
* LP program to annalyze impacts of changes in fisheries policy and*
*###############################################################################


$SETLOCAL datDir %SYSTEM.FP%inputfiles


*#############################################################
*           CONVERT EXCEL DATA FILE TO GAMS FORMAT ***.inc
*#############################################################

** Syntax to read data from Excel to GAMS include files:**
* i= [path\file_name.xls] Excel data file
* r= [sheet_name!range_name] input range from excel
* o= [filename.inc] output range to GAMS-include file
* M mutes or supresses unnecessary output in list file

* Code to read data from Excel and write to GAMS stored in data_gams.xls
* OLD i=C:\GAMS_fishery\inputfiles\data_gams_11.xlsx
$onecho > data_gams.txt

i=%datDir%\data_gams_v1.xlsx


r1=SETS!fishery
o1=fishery.inc

r2=SETS!stock
o2=stock.inc

r3=SETS!area
o3=area.inc

r4=VESSELS!segment;fleet
o4=fleet.inc

r5=VESSELS!fishery;crew
o5=crew.inc

r6=VESSELS!segment;vess_cap
o6=vess_cap.inc

r7=VESSELS!fishery;effort_2009
o7=effort_2009.inc

r8=PRICES!prices
o8=prices.inc

r9=VARCOSTS!fishery;VC_fuel
o9=VC_fuel.inc

r10=VARCOSTS!fishery;VC_labour
o10=VC_labour.inc

r11=VARCOSTS!fishery;vc_repair
o11=vc_repair.inc

r12=VARCOSTS!fishery;vc_other
o12=vc_other.inc


r14=FIXCOSTS!segment;capital_fc
o14=capital_fc.inc

r15=FIXCOSTS!segment;other_fc
o15=other_fc.inc

r16=TAC!stock;tac_2009
o16=tac_2009.inc

r17=TAC!tac_mod
o17=tac_mod.inc

r18=TAC!biol_max
o18=biol_max.inc

r19=CATCH2009!catch_2009
o19=catch_2009.inc

r20=MAX_EFF_V!max_eff_v
o20=max_eff_v.inc

r21=MAX_EFF_F!max_eff_f
o21=max_eff_f.inc

r22=discount_rate!discount_rate
o22=discount_rate.inc


r24=fishingarea!fishingarea
o24=fishingarea.inc

r25=policy!kwH_group
o25=kwH_group.inc

r26=policy!kwH_group;EFFORT_VH
o26=effort_VH.inc

r27=vessels!fishery;kwH_per_vessel
o27=kwH_per_vessel.inc

r28=VARCOSTS!fishery;VC_altlabour
o28=VC_altlabour.inc

r29=vessels!segment;kwH_vessel_seg
o29=kwH_vessel_seg.inc

r30=vessels!segment;BALTIC_COD_PERMIT
o30=BALTIC_COD_PERMIT.inc

r31=SEASON!SEASON
o31=SEASON.inc

r32=SUBSETS!SUBSETS
o32=SUBSETS.inc

r33=SUBSETS!SUBSET_NAMES
o33=SUBSET_NAMES.inc

r34=POLICY!fishery;ON_OFF
o34=ON_OFF.inc

r35=SSB!SSB_2009
o35=SSB_2009.inc

r36=SSB!SSB_MOD
o36=SSB_MOD.inc

M
$offecho



* call below is necessary but do not know why...
* Execute code to create data files
$call =xls2gms @data_gams.txt

*#############################################################
*           DEFINE SETS
*#############################################################

SETS

 PERIOD a fishing year comprises 12 fishing periods
/WK01*WK12/


 FISHERY  fishing activities available to each segment
/
$include fishery.inc
/

 STOCK   fish species by stock
/
$include stock.inc
/

 AREA   fish species by stock
/
$include area.inc
/

kwH_group   Effort regulation group for areas K S N
/
$include kwH_group.inc
/



 SEGMENT  a segment comprises a fleet of relatively homogenous vessels
/
SG01, SG02, SG03, SG04, SG05, SG06, SG07, SG08, SG09, SG10,
SG11, SG12, SG13, SG14, SG15, SG16, SG17, SG18, SG19, SG20,
SG21, SG22, SG23, SG24
/

 SUBSET_NAMES
/
$include SUBSET_NAMES.inc
/
;
PARAMETER

* ON_OFF is not used in optimization,
* but written to outputfile Fishmod_res.xls

 ON_OFF(FISHERY)
/
$include ON_OFF.inc
/
;


*################################
*######### SUBSETS###############
*################################

* SUBSETS is used for defining subsets of fisheries defined in Excel
TABLE
SUBSETS(FISHERY,SUBSET_NAMES)
$include SUBSETS.inc
;

* Define sub-sets of fisheries comprising each segment
SETS
SEG1(FISHERY)  subset of fisheries comprising segment 1
SEG2(FISHERY)
SEG3(FISHERY)
SEG4(FISHERY)
SEG5(FISHERY)
SEG6(FISHERY)
SEG7(FISHERY)
SEG8(FISHERY)
SEG9(FISHERY)
SEG10(FISHERY)
SEG11(FISHERY)
SEG12(FISHERY)
SEG13(FISHERY)
SEG14(FISHERY)
SEG15(FISHERY)
SEG16(FISHERY)
SEG17(FISHERY)
SEG18(FISHERY)
SEG19(FISHERY)
SEG20(FISHERY)
SEG21(FISHERY)
SEG22(FISHERY)
SEG23(FISHERY)
SEG24(FISHERY)   ;



* fill subsets with content, segkod=column in subset matrix, row=fisheries
SEG1(FISHERY)=yes$(SUBSETS(FISHERY,'SEGKOD')=1);
SEG2(FISHERY)=yes$(SUBSETS(FISHERY,'SEGKOD')=2);
SEG3(FISHERY)=yes$(SUBSETS(FISHERY,'SEGKOD')=3);
SEG4(FISHERY)=yes$(SUBSETS(FISHERY,'SEGKOD')=4);
SEG5(FISHERY)=yes$(SUBSETS(FISHERY,'SEGKOD')=5);
SEG6(FISHERY)=yes$(SUBSETS(FISHERY,'SEGKOD')=6);
SEG7(FISHERY)=yes$(SUBSETS(FISHERY,'SEGKOD')=7);
SEG8(FISHERY)=yes$(SUBSETS(FISHERY,'SEGKOD')=8);
SEG9(FISHERY)=yes$(SUBSETS(FISHERY,'SEGKOD')=9);
SEG10(FISHERY)=yes$(SUBSETS(FISHERY,'SEGKOD')=10);
SEG11(FISHERY)=yes$(SUBSETS(FISHERY,'SEGKOD')=11);
SEG12(FISHERY)=yes$(SUBSETS(FISHERY,'SEGKOD')=12);
SEG13(FISHERY)=yes$(SUBSETS(FISHERY,'SEGKOD')=13);
SEG14(FISHERY)=yes$(SUBSETS(FISHERY,'SEGKOD')=14);
SEG15(FISHERY)=yes$(SUBSETS(FISHERY,'SEGKOD')=15);
SEG16(FISHERY)=yes$(SUBSETS(FISHERY,'SEGKOD')=16);
SEG17(FISHERY)=yes$(SUBSETS(FISHERY,'SEGKOD')=17);
SEG18(FISHERY)=yes$(SUBSETS(FISHERY,'SEGKOD')=18);
SEG19(FISHERY)=yes$(SUBSETS(FISHERY,'SEGKOD')=19);
SEG20(FISHERY)=yes$(SUBSETS(FISHERY,'SEGKOD')=20);
SEG21(FISHERY)=yes$(SUBSETS(FISHERY,'SEGKOD')=21);
SEG22(FISHERY)=yes$(SUBSETS(FISHERY,'SEGKOD')=22);
SEG23(FISHERY)=yes$(SUBSETS(FISHERY,'SEGKOD')=23);
SEG24(FISHERY)=yes$(SUBSETS(FISHERY,'SEGKOD')=24);



sets

* Defining subsets of fisheries comprising active and passive gear
* fiske tom 92 passiva, from 93 aktiva


PASSIVEGEAR(FISHERY)  subset of fisheries using passive gear
/
84*147, 149*155
/

 ACTIVEGEAR(FISHERY)  subset of fisheries using active gear
/
1*83, 156*203, 148
/


PELAGIC(FISHERY)
/
29,31,36,43,48,55,56,60,62,63,156*172,174*176,178*203
/


EEL(FISHERY)
/
86, 89, 92, 98, 102, 104*108, 110*112, 131, 145
/

KRAFTA_EJRIST(FISHERY)
/
2,4,5,7,8,9,11,12,13,16,17,19,21,22,23,26,27,32,34,35,39,40,45,46,51,52,
70,72,76,77,82,83
/


PEL_KUSTFISKE(FISHERY)
/ 100,104,105,108,112,118,120,121,123,126,130,134,136,139,144,152 /



** ** ** ** AREAS ** ** ** **
* Defining subsets of fisheries comprising Kattegatt,
* North Sea, Skagerrack, and the Baltic Sea



BALTIC2224(FISHERY)   ICES areas 22-24
BALTIC2529(FISHERY) ICES areas 25-29 + 32
BALTIC3031(FISHERY) ICES areas 30-31
KATTEGATT(FISHERY)
NORTH_SEA(FISHERY)
SKAGERACK(FISHERY)

;



* subsets
* fishery included in subset BALTIC2224 if 'omrade' is equal '2224' etc.
BALTIC2224(FISHERY)=yes$(SUBSETS(FISHERY,'Omrade')=2224);
BALTIC2529(FISHERY)=yes$(SUBSETS(FISHERY,'Omrade')=252932);
BALTIC3031(FISHERY)=yes$(SUBSETS(FISHERY,'Omrade')=3031);
KATTEGATT(FISHERY)=yes$(SUBSETS(FISHERY,'Omrade')=1);
SKAGERACK(FISHERY)=yes$(SUBSETS(FISHERY,'Omrade')=2);
NORTH_SEA(FISHERY)=yes$(SUBSETS(FISHERY,'Omrade')=3);

sets

BALTIC2224_COD(FISHERY)   ICES areas 22-24  and cod fishery  (201 days per vessel in 2009)
/
41, 53, 59, 104, 105, 124, 125, 137, 138, 141, 151, 173
/



BALTIC2529_COD(FISHERY) ICES areas 25-29 + 32  and cod fishery    (160 days per vessel in 2009)
/
18, 28, 30, 42, 54, 61, 107, 114, 128, 132, 142, 147, 148, 153, 155, 163, 177
/

SHRIMP_KS_1018(FISHERY) Shrimpcatches in K+S used for defining large scale shrimp trawlers that can go further out
/
64*70
/

NORWLOBST_0012(FISHERY) Norw. lobster used for defining large scale  trawlers that can go further out
/
2*8
/

* used for restricting cod permits for trawlers and net/hook in baltic sea
*SG01_BALTICCODNET(FISHERY) /  1, 2, 3, 5, 6, 9, 10, 17, 20, 21 /
*SG02_BALTICCODNET(FISHERY) /  50, 51, 56/
*SG03_BALTICCODNET(FISHERY) /  62, 63, 64 /
*SG04_BALTICCODTRAWL(FISHERY) / 95 /
*SG05_BALTICCODTRAWL(FISHERY) / 108, 109, 111 /
*SG06_BALTICCODTRAWL(FISHERY) / 128, 129, 131 /


* Subsets used for TACs that are overlapping areas
KS(AREA) / K, S /
BALTIC(AREA) / 22-24, 25-29+32, 30-31 /
BALTIC_EAST(AREA) / 25-29+32, 30-31 /




** ** ** ** ** ** ** ** **
** EFFORT RESTRICTIONS **
* grid ingår ej i systemet - obs att det e.g. finns separat system för detta
* kolla om aktuellt med körningar med fokus på kräfta

*K_TR1(FISHERY)/ /
K_TR2(FISHERY)/ 2,4,9,11,12,19,21,22, 32, 34, 35,45,46 /

*K_TR3(FISHERY) / /
K_GN1(FISHERY) / 115,116, 117,118,133,149 /
*K_GT1(FISHERY) / /
*K_LL1(FISHERY) / /
S_TR1(FISHERY) / 47, 57,58 /
S_TR2(FISHERY) / 5, 7,8,13, 16,17,23,26,27,39,40,51,52,70,72,76,77,82,83/
*SN_TR3(FISHERY)  / /
S_GN1(FISHERY)  / 122,123,135,136 /
*S_GT1(FISHERY)   / /
S_LL1(FISHERY)    / 150 /
K_RIST(FISHERY)   / 3,10,20,33,44 /
S_RIST(FISHERY)   / 1,6,15,25,38,50,66,69,75 /



ALIAS  (FISHERY,F)
ALIAS  (STOCK,S)
ALIAS  (SEGMENT,V)
ALIAS  (PERIOD,P)
ALIAS  (AREA,A)
;




*#############################################################
*                 EXOGENOUS DATA INPUT
*#############################################################

** Fishery data **


TABLE   MAX_EFF_V(SEGMENT,PERIOD)   maximum effort per vessel and period (e.g. 7 days\week)
$include max_eff_v.inc
;

TABLE   MAX_EFF_F(FISHERY,PERIOD)   maximum effort per vessel and fishery and period
$include max_eff_f.inc
;

TABLE FISHINGAREA(FISHERY,AREA)   possible fishing areas per fishery (dummy 1=fishing possible in the area)
$include fishingarea.inc
;

TABLE SEASON(FISHERY,P)   fishing seasons
$include SEASON.inc
;

TABLE SSB_2009(STOCK,AREA)
$include SSB_2009.inc
;

TABLE SSB_MOD(STOCK,AREA)
$include SSB_MOD.inc
;




** Define vessels and resource endowments  **
Parameters
 FLEET2009(SEGMENT)    current number of vessels in each segment
/
$include fleet.inc
/

 CREW(FISHERY)     crew per vessel and fishery (hands\vessel)
/
$include crew.inc
/

* VESS_CAP(SEGMENT) catch capacity per vessel and day (kg\day\vessel) - not used anymore!
*/
*$include vess_cap.inc
*/

 KWH_PER_VESSEL(FISHERY)   Average Kwh per vessel for each segment used for effort restrictions in VH defined over F
/
$include kwH_per_vessel.inc
/

KWH_VESSEL_SEG(V)           Average Kwh per vessel defined over V
/
$include kwH_vessel_seg.inc
/
;

** Economic data **

* Prices
TABLE PRICES(FISHERY,STOCK)   prices by fishery and species (kr\kg)
$include prices.inc
;

* Variable costs per unit effort generated in each fishery (e.g., per day)
PARAMETERS
 VC_FUEL(FISHERY)      fuel costs (kr per unit effort)
/
$include vc_fuel.inc
/

 VC_LABOUR(FISHERY)   labour costs (kr per unit effort)
/
$include vc_labour.inc
/

 VC_ALTLABOUR(FISHERY)   labour costs (kr per unit effort)
/
$include vc_altlabour.inc
/

 VC_repair(FISHERY)  vessel costs (kr per unit effort)
/
$include vc_repair.inc
/

 VC_other(FISHERY)   miscellaneous costs (kr\kg catch)
/
$include vc_other.inc
/
;

* Fixed costs per vessel and year in each segment
PARAMETERS

CAPITAL_FC(SEGMENT)      vessel fixed capital costs (kr\vessel)
/
$include capital_fc.inc
/

OTHER_FC(SEGMENT)    vessel other fixed costs (kr\vessel)
/
$include other_fc.inc
/
;

** Historical data for comparative analysis **
PARAMETERS
 TAC_2009(STOCK) historical TAC (kg)
/
$include tac_2009.inc
/

 EFFORT_2009(FISHERY) days at sea per vessel per year (days\year\vessel)
/
$include EFFORT_2009.inc
/

 DISCOUNT_RATE(PERIOD) discount rate calc for each period
/
$include discount_rate.inc
/
;


TABLE CATCH_2009(FISHERY,STOCK)  historical catch by species and fishery
$include catch_2009.inc
;



PARAMETERS CATCH_2009_AREA(F,S,A), CATCHSHARE_2009(F,S,A), CATCHTOT_2009(S,A)    ;

***old inputdata *** CATCH_2009_AREA(F,S,A) =   CATCH_2009(F,S)*FISHINGAREA(F,A);
CATCH_2009_AREA(F,S,A) =   CATCH_2009(F,S)*FISHINGAREA(F,A)*EFFORT_2009(F);

CATCHTOT_2009(S,A) = SUM(F, CATCH_2009_AREA(F,S,A))            ;

CATCHSHARE_2009(F,S,A)$(CATCHTOT_2009(S,A)> 0)  =  CATCH_2009_AREA(F,S,A)/ CATCHTOT_2009(S,A) ;

display CATCHSHARE_2009 ;

*#############################################################
*     POLICY PARAMETERS **NB! POLICY SCENARIOS DEFINED HERE**
*#############################################################


** ** CONSTRAINTS ON CATCHES ** **

TABLE
 TAC_MOD(STOCK,AREA)      modelled TAC (kg)

$include tac_mod.inc
;


TABLE
 BIOL_MAX(STOCK,AREA)     biological maximum catch for unregulated species (kg)

$include biol_max.inc
;





** CONSTRAINTS ON EFFORT **

PARAMETERS

 MAXEFF_VH(kwH_group)
/
$include EFFORT_VH.inc
/

BALTIC_COD_PERMIT(SEGMENT)
/
$include BALTIC_COD_PERMIT.inc
/



;

** ** ECONOMICS ** **

PARAMETERS
* Price indeces for variable costs. Default = 1.0
 FUEL_I      index for fuel costs                /1.0/
 LABOUR_I    index for labour costs              /1.0/
 ALTLABOUR_I    index for altlabour costs        /1.0/
 REPAIR_VC_I   index for vessel variable costs   /1.0/
 OTHER_VC_I   index for miscellaneos costs       /1.0/
;



* bounds on variables
PARAMETERS FLEET_MAX(SEGMENT) upper bound on fleet size in each segment;
 FLEET_MAX(V) = FLEET2009(V)
;



*##############################################################################
* CALCULATION OF PARAMETER VALUES FOR MODEL (CALCULATED AFTER POLICY CHANGES!)
*##############################################################################

PARAMETERS
 VARCOST(FISHERY)  vessel variable costs
 VC_LAB_ALTLAB(FISHERY) vessel labour costs labour or altlabour depending on modeller's choice
 FIXCOST(SEGMENT)  vessel fixed costs total per segment
 FC_VESSEL(SEGMENT) fixed costs per vessel
 CPUE(FISHERY,STOCK,AREA) catch per unit effort by fishery and species and area
;

* Calculation of variable costs including policy index (kr per unit effort catch)

 VARCOST(F)$(altcost_labour = 0)= VC_FUEL(F)       * FUEL_I
                 + VC_LABOUR(F)     * LABOUR_I
                 + VC_REPAIR(F)     * REPAIR_VC_I
                 + VC_OTHER(F)      * OTHER_VC_I;

 VARCOST(F)$(altcost_labour = 1) = VC_FUEL(F)       * FUEL_I
            + VC_ALTLABOUR(F)  * ALTLABOUR_I
            + VC_REPAIR(F)     * REPAIR_VC_I
            + VC_OTHER(F)      * OTHER_VC_I;

* create labour cost vector for calculations in Excel
VC_LAB_ALTLAB(F)$(altcost_labour = 0)= VC_LABOUR(F) * LABOUR_I  ;
VC_LAB_ALTLAB(F)$(altcost_labour = 1)= VC_ALTLABOUR(F)  * ALTLABOUR_I    ;

* Calculation of fixed costs capital costs are imported from Excel, FC is total for segment
* FC= 100 is for FC=0 but model needs 1 otherwise no restriction on no of vessels
* FC= 0 allocates many vessels early pga discounting revenues...
* obs that FC_VESSEL is transformed to tkr to match VC since VC is in tkr and 'FIXCOST' is in kr from Input sheet

* FIXCOST(V) =   100   ;
* FIXCOST(V) =   OTHER_FC(V)   ;
 FIXCOST(V) =  CAPITAL_FC(V) + OTHER_FC(V)   ;
 FC_VESSEL(V)$(FLEET2009(V)> 0)  = FIXCOST(V) / 1000   ;
 FC_VESSEL(V)$(FLEET2009(V)= 0)  = 1 ;
* för Fleet2009 = 0 måste ha positivt tal för att annars får vi fartyg utan fiske

* calculate CPUE from historical catch and effort, divide by 1000 to get TON PER DAY
***old inputdata ***  CPUE(F,S,A) $(EFFORT_2009(F) > 0) =  ( CATCH_2009(F,S) / EFFORT_2009(F) )*FISHINGAREA(F,A) ;
CPUE(F,S,A) $(EFFORT_2009(F) > 0) =  CATCH_2009(F,S)*FISHINGAREA(F,A)/1000 ;

* CPUE changes as cod quota changes, obs calculation differs from 2007 version of the model
* TAC 2009 is base year
* elasticity 0,6, catch = alfa*EFFORT*TAC^0.6, see Skarpsillspärmen för uträkning        2541

CPUE(F,"torsk","22-24")$(CPUE_COD = 1) =                         CPUE(F,"torsk","22-24")*((SSB_MOD("torsk","22-24")/SSB_2009("torsk","22-24"))**0.6)          ;
CPUE(F,"torsk","25-29+32")$(CPUE_COD = 1) =                      CPUE(F,"torsk","25-29+32")*((SSB_MOD("torsk","25-29+32")/SSB_2009("torsk","25-29+32"))**0.6) ;
CPUE(F,"torsk","30-31")$(CPUE_COD = 1) =                         CPUE(F,"torsk","30-31")*((SSB_MOD("torsk","30-31")/SSB_2009("torsk","30-31"))**0.6)           ;
CPUE(F,"torsk","K")$(CPUE_COD = 1) =                             CPUE(F,"torsk","K")*((SSB_MOD("torsk","K")/SSB_2009("torsk","K"))**0.6)                      ;
CPUE(F,"torsk","S")$(CPUE_COD = 1) =                             CPUE(F,"torsk","S")*((SSB_MOD("torsk","S")/SSB_2009("torsk","S"))**0.6)                      ;
CPUE(F,"torsk","N")$(CPUE_COD = 1) =                             CPUE(F,"torsk","N")*((SSB_MOD("torsk","N")/SSB_2009("torsk","N"))**0.6)                        ;

CPUE(F,"Sill_industri","22-24")$(CPUE_HERRING = 1) =             CPUE(F,"Sill_industri","22-24")*((SSB_MOD("Sill_industri","22-24")/SSB_2009("Sill_industri","22-24"))**0.2)          ;
CPUE(F,"Sill_industri","25-29+32")$(CPUE_HERRING = 1) =          CPUE(F,"Sill_industri","25-29+32")*((SSB_MOD("Sill_industri","25-29+32")/SSB_2009("Sill_industri","25-29+32"))**0.2) ;
CPUE(F,"Sill_industri","30-31")$(CPUE_HERRING = 1) =             CPUE(F,"Sill_industri","30-31")*((SSB_MOD("Sill_industri","30-31")/SSB_2009("Sill_industri","30-31"))**0.2)           ;
CPUE(F,"Sill_industri","K")$(CPUE_HERRING = 1) =                 CPUE(F,"Sill_industri","K")*((SSB_MOD("Sill_industri","K")/SSB_2009("Sill_industri","K"))**0.2)                      ;
CPUE(F,"Sill_industri","S")$(CPUE_HERRING = 1) =                 CPUE(F,"Sill_industri","S")*((SSB_MOD("Sill_industri","S")/SSB_2009("Sill_industri","S"))**0.2)                      ;
CPUE(F,"Sill_industri","N")$(CPUE_HERRING = 1) =                 CPUE(F,"Sill_industri","N")*((SSB_MOD("Sill_industri","N")/SSB_2009("Sill_industri","N"))**0.2)                        ;
CPUE(F,"Sill_konsum","22-24")$(CPUE_HERRING = 1) =               CPUE(F,"Sill_konsum","22-24")*((SSB_MOD("Sill_konsum","22-24")/SSB_2009("Sill_konsum","22-24"))**0.2)          ;
CPUE(F,"Sill_konsum","25-29+32")$(CPUE_HERRING = 1) =            CPUE(F,"Sill_konsum","25-29+32")*((SSB_MOD("Sill_konsum","25-29+32")/SSB_2009("Sill_konsum","25-29+32"))**0.2) ;
CPUE(F,"Sill_konsum","30-31")$(CPUE_HERRING = 1) =               CPUE(F,"Sill_konsum","30-31")*((SSB_MOD("Sill_konsum","30-31")/SSB_2009("Sill_konsum","30-31"))**0.2)           ;
CPUE(F,"Sill_konsum","K")$(CPUE_HERRING = 1) =                   CPUE(F,"Sill_konsum","K")*((SSB_MOD("Sill_konsum","K")/SSB_2009("Sill_konsum","K"))**0.2)                      ;
CPUE(F,"Sill_konsum","S")$(CPUE_HERRING = 1) =                   CPUE(F,"Sill_konsum","S")*((SSB_MOD("Sill_konsum","S")/SSB_2009("Sill_konsum","S"))**0.2)                      ;
CPUE(F,"Sill_konsum","N")$(CPUE_HERRING = 1) =                   CPUE(F,"Sill_konsum","N")*((SSB_MOD("Sill_konsum","N")/SSB_2009("Sill_konsum","N"))**0.2)                        ;

CPUE(F,"Skarpsill_industri","22-24")$(CPUE_SPRAT = 1) =        CPUE(F,"Skarpsill_industri","22-24")*((SSB_MOD("Skarpsill_industri","22-24")/SSB_2009("Skarpsill_industri","22-24"))**0.2)          ;
CPUE(F,"Skarpsill_industri","25-29+32")$(CPUE_SPRAT = 1) =     CPUE(F,"Skarpsill_industri","25-29+32")*((SSB_MOD("Skarpsill_industri","25-29+32")/SSB_2009("Skarpsill_industri","25-29+32"))**0.2) ;
CPUE(F,"Skarpsill_industri","30-31")$(CPUE_SPRAT = 1) =        CPUE(F,"Skarpsill_industri","30-31")*((SSB_MOD("Skarpsill_industri","30-31")/SSB_2009("Skarpsill_industri","30-31"))**0.2)           ;
CPUE(F,"Skarpsill_industri","K")$(CPUE_SPRAT = 1) =            CPUE(F,"Skarpsill_industri","K")*((SSB_MOD("Skarpsill_industri","K")/SSB_2009("Skarpsill_industri","K"))**0.2)                      ;
CPUE(F,"Skarpsill_industri","S")$(CPUE_SPRAT = 1) =            CPUE(F,"Skarpsill_industri","S")*((SSB_MOD("Skarpsill_industri","S")/SSB_2009("Skarpsill_industri","S"))**0.2)                      ;
CPUE(F,"Skarpsill_industri","N")$(CPUE_SPRAT = 1) =            CPUE(F,"Skarpsill_industri","N")*((SSB_MOD("Skarpsill_industri","N")/SSB_2009("Skarpsill_industri","N"))**0.2)                        ;
CPUE(F,"Skarpsill_konsum","22-24")$(CPUE_SPRAT = 1) =           CPUE(F,"Skarpsill_konsum","22-24")*((SSB_MOD("Skarpsill_konsum","22-24")/SSB_2009("Skarpsill_konsum","22-24"))**0.2)          ;
CPUE(F,"Skarpsill_konsum","25-29+32")$(CPUE_SPRAT = 1) =        CPUE(F,"Skarpsill_konsum","25-29+32")*((SSB_MOD("Skarpsill_konsum","25-29+32")/SSB_2009("Skarpsill_konsum","25-29+32"))**0.2) ;
CPUE(F,"Skarpsill_konsum","30-31")$(CPUE_SPRAT = 1) =           CPUE(F,"Skarpsill_konsum","30-31")*((SSB_MOD("Skarpsill_konsum","30-31")/SSB_2009("Skarpsill_konsum","30-31"))**0.2)           ;
CPUE(F,"Skarpsill_konsum","K")$(CPUE_SPRAT = 1) =               CPUE(F,"Skarpsill_konsum","K")*((SSB_MOD("Skarpsill_konsum","K")/SSB_2009("Skarpsill_konsum","K"))**0.2)                      ;
CPUE(F,"Skarpsill_konsum","S")$(CPUE_SPRAT = 1) =               CPUE(F,"Skarpsill_konsum","S")*((SSB_MOD("Skarpsill_konsum","S")/SSB_2009("Skarpsill_konsum","S"))**0.2)                      ;
CPUE(F,"Skarpsill_konsum","N")$(CPUE_SPRAT = 1) =               CPUE(F,"Skarpsill_konsum","N")*((SSB_MOD("Skarpsill_konsum","N")/SSB_2009("Skarpsill_konsum","N"))**0.2)                        ;

*changing catch composition sprat/herring for major pelagic fisheries (metier 181 and 199),  industry and consumption catches change proportionally
CPUE("181","Skarpsill_industri","25-29+32")  =   CPUE("181","Skarpsill_industri","25-29+32") + CPUE("181","Sill_industri","25-29+32")*CPUEincrease_sprat_181 ;
CPUE("181","Sill_industri","25-29+32")  =   CPUE("181","Sill_industri","25-29+32") - CPUE("181","Sill_industri","25-29+32")*CPUEincrease_sprat_181 ;
CPUE("181","Skarpsill_konsum","25-29+32")  =   CPUE("181","Skarpsill_konsum","25-29+32") + CPUE("181","Sill_konsum","25-29+32")*CPUEincrease_sprat_181 ;
CPUE("181","Sill_konsum","25-29+32")  =   CPUE("181","Sill_konsum","25-29+32") - CPUE("181","Sill_konsum","25-29+32")*CPUEincrease_sprat_181 ;

CPUE("181","Sill_industri","25-29+32")  =   CPUE("181","Sill_industri","25-29+32") + CPUE("181","Skarpsill_industri","25-29+32")*CPUEincrease_herring_181 ;
CPUE("181","Skarpsill_industri","25-29+32")  =   CPUE("181","Skarpsill_industri","25-29+32") - CPUE("181","Skarpsill_industri","25-29+32")*CPUEincrease_herring_181 ;
CPUE("181","Sill_konsum","25-29+32")  =   CPUE("181","Sill_konsum","25-29+32") + CPUE("181","Skarpsill_konsum","25-29+32")*CPUEincrease_herring_181 ;
CPUE("181","Skarpsill_konsum","25-29+32")  =   CPUE("181","Skarpsill_konsum","25-29+32") - CPUE("181","Skarpsill_konsum","25-29+32")*CPUEincrease_herring_181 ;

CPUE("199","Skarpsill_industri","25-29+32")  =   CPUE("199","Skarpsill_industri","25-29+32") + CPUE("199","Sill_industri","25-29+32")*CPUEincrease_sprat_199 ;
CPUE("199","Sill_industri","25-29+32")  =   CPUE("199","Sill_industri","25-29+32") - CPUE("199","Sill_industri","25-29+32")*CPUEincrease_sprat_199 ;
CPUE("199","Skarpsill_konsum","25-29+32")  =   CPUE("199","Skarpsill_konsum","25-29+32") + CPUE("199","Sill_konsum","25-29+32")*CPUEincrease_sprat_199 ;
CPUE("199","Sill_konsum","25-29+32")  =   CPUE("199","Sill_konsum","25-29+32") - CPUE("199","Sill_konsum","25-29+32")*CPUEincrease_sprat_199 ;

CPUE("199","Sill_industri","25-29+32")  =   CPUE("199","Sill_industri","25-29+32") + CPUE("199","Skarpsill_industri","25-29+32")*CPUEincrease_herring_199 ;
CPUE("199","Skarpsill_industri","25-29+32")  =   CPUE("199","Skarpsill_industri","25-29+32") - CPUE("199","Skarpsill_industri","25-29+32")*CPUEincrease_herring_199 ;
CPUE("199","Sill_konsum","25-29+32")  =   CPUE("199","Sill_konsum","25-29+32") + CPUE("199","Skarpsill_konsum","25-29+32")*CPUEincrease_herring_199 ;
CPUE("199","Skarpsill_konsum","25-29+32")  =   CPUE("199","Skarpsill_konsum","25-29+32") - CPUE("199","Skarpsill_konsum","25-29+32")*CPUEincrease_herring_199 ;


CPUE("181","Skarpsill_industri","25-29+32")  =   CPUE("181","Skarpsill_industri","25-29+32") + CPUE("181","Skarpsill_konsum","25-29+32")*CPUEincrease_ind_sprat_181 ;
CPUE("181","Skarpsill_konsum","25-29+32")  =   CPUE("181","Skarpsill_konsum","25-29+32") - CPUE("181","Skarpsill_konsum","25-29+32")*CPUEincrease_ind_sprat_181 ;
CPUE("181","Sill_industri","25-29+32")  =   CPUE("181","Sill_industri","25-29+32") + CPUE("181","Sill_konsum","25-29+32")*CPUEincrease_ind_herring_181 ;
CPUE("181","Sill_konsum","25-29+32")  =   CPUE("181","Sill_konsum","25-29+32") - CPUE("181","Sill_konsum","25-29+32")*CPUEincrease_ind_herring_181 ;

CPUE("199","Skarpsill_industri","25-29+32")  =   CPUE("199","Skarpsill_industri","25-29+32") + CPUE("199","Skarpsill_konsum","25-29+32")*CPUEincrease_ind_sprat_199 ;
CPUE("199","Skarpsill_konsum","25-29+32")  =   CPUE("199","Skarpsill_konsum","25-29+32") - CPUE("199","Skarpsill_konsum","25-29+32")*CPUEincrease_ind_sprat_199 ;
CPUE("199","Sill_industri","25-29+32")  =   CPUE("199","Sill_industri","25-29+32") + CPUE("199","Sill_konsum","25-29+32")*CPUEincrease_ind_herring_199 ;
CPUE("199","Sill_konsum","25-29+32")  =   CPUE("199","Sill_konsum","25-29+32") - CPUE("199","Sill_konsum","25-29+32")*CPUEincrease_ind_herring_199 ;








* COD TAC original
* 22-24= 2541        25-29=10375       30-31=10375     K=187        S=576        N=415
*Sill_industri    (sill_konsum är nästan samma så skiljer inte upp dem)
* 22-24=4 835        25-29=48 032        30-31=14 892       K= 17 481       S= 17 481      N=  16 166
*Sill_konsum        22-24=4 835        25-29=48 032         30-31=14 892       K= 16 329       S= 16 329        N=16241

* Skarpsill_industri
*        22-24=    76 270      25-29=  76 270        30-31=76 270        K= 13 184       S= 13 184        N=1 330
* skarpsill konsum  22-24=76 270           25-29= 76 270         30-31=76 270        K=13 184       S= 13 184       N= 1 330




*max effort days allowed by effort management, only used if less than max days possible by segment
PARAMETER EFFRESTR(V,P) ;
EFFRESTR("SG01",P)= SUM{SEG1, MAX_EFF_F(SEG1,P)} ;
EFFRESTR("SG02",P)= SUM{SEG2, MAX_EFF_F(SEG2,P)} ;
EFFRESTR("SG03",P)= SUM{SEG3, MAX_EFF_F(SEG3,P)} ;
EFFRESTR("SG04",P)= SUM{SEG4, MAX_EFF_F(SEG4,P)} ;
EFFRESTR("SG05",P)= SUM{SEG5, MAX_EFF_F(SEG5,P)} ;
EFFRESTR("SG06",P)= SUM{SEG6, MAX_EFF_F(SEG6,P)} ;
EFFRESTR("SG07",P)= SUM{SEG7, MAX_EFF_F(SEG7,P)} ;
EFFRESTR("SG08",P)= SUM{SEG8, MAX_EFF_F(SEG8,P)} ;
EFFRESTR("SG09",P)= SUM{SEG9, MAX_EFF_F(SEG9,P)} ;
EFFRESTR("SG10",P)= SUM{SEG10, MAX_EFF_F(SEG10,P)} ;
EFFRESTR("SG11",P)= SUM{SEG11, MAX_EFF_F(SEG11,P)} ;
EFFRESTR("SG12",P)= SUM{SEG12, MAX_EFF_F(SEG12,P)} ;
EFFRESTR("SG13",P)= SUM{SEG13, MAX_EFF_F(SEG13,P)} ;
EFFRESTR("SG14",P)= SUM{SEG14, MAX_EFF_F(SEG14,P)} ;
EFFRESTR("SG15",P)= SUM{SEG15, MAX_EFF_F(SEG15,P)} ;
EFFRESTR("SG16",P)= SUM{SEG16, MAX_EFF_F(SEG16,P)} ;
EFFRESTR("SG17",P)= SUM{SEG17, MAX_EFF_F(SEG17,P)} ;
EFFRESTR("SG18",P)= SUM{SEG18, MAX_EFF_F(SEG18,P)} ;
EFFRESTR("SG19",P)= SUM{SEG19, MAX_EFF_F(SEG19,P)} ;
EFFRESTR("SG20",P)= SUM{SEG20, MAX_EFF_F(SEG20,P)} ;
EFFRESTR("SG21",P)= SUM{SEG21, MAX_EFF_F(SEG21,P)} ;
EFFRESTR("SG22",P)= SUM{SEG22, MAX_EFF_F(SEG22,P)} ;
EFFRESTR("SG23",P)= SUM{SEG23, MAX_EFF_F(SEG23,P)} ;
EFFRESTR("SG24",P)= SUM{SEG24, MAX_EFF_F(SEG24,P)} ;



*#############################################################
*            DEFINE VARIABLES
*#############################################################

FREE VARIABLES
 SECT_PROFIT     objective function value is total profit for sector (kr)
;

POSITIVE VARIABLES
 CATCH(FISHERY,STOCK,AREA,PERIOD)    catch by species and fishery (kg\per)
 EFFORT(FISHERY,PERIOD)          optimal units of effort generated in each fishery and period
 CATCH_SG(SEGMENT,STOCK,AREA,PERIOD)  catch by segment and species (kg\per)
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
 EFFORT_FISH1(FISHERY,P)   effort constraint by fishery and period
 EFFORT_FISH2(F,P)
 EFFORT_FISH3(F,P)
 EFFORT_FISH4(F,P)
 EFFORT_FISH5(F,P)
 EFFORT_FISH6(F,P)
 EFFORT_FISH7(F,P)
 EFFORT_FISH8(F,P)
 EFFORT_FISH9(F,P)
 EFFORT_FISH10(F,P)
 EFFORT_FISH11(F,P)
 EFFORT_FISH12(F,P)
 EFFORT_FISH13(F,P)
 EFFORT_FISH14(F,P)
 EFFORT_FISH15(F,P)
 EFFORT_FISH16(F,P)
 EFFORT_FISH17(F,P)
 EFFORT_FISH18(F,P)
 EFFORT_FISH19(F,P)
 EFFORT_FISH20(F,P)
 EFFORT_FISH21(F,P)
 EFFORT_FISH22(F,P)
 EFFORT_FISH23(F,P)
 EFFORT_FISH24(F,P)
 EFFORT_SG1(SEGMENT,P)     effort constraint by segment and period
 EFFORT_SG2(V,P)
 EFFORT_SG3(V,P)
 EFFORT_SG4(V,P)
 EFFORT_SG5(V,P)
 EFFORT_SG6(V,P)
 EFFORT_SG7(V,P)
 EFFORT_SG8(V,P)
 EFFORT_SG9(V,P)
 EFFORT_SG10(V,P)
 EFFORT_SG11(V,P)
 EFFORT_SG12(V,P)
 EFFORT_SG13(V,P)
 EFFORT_SG14(V,P)
 EFFORT_SG15(V,P)
 EFFORT_SG16(V,P)
 EFFORT_SG17(V,P)
 EFFORT_SG18(V,P)
 EFFORT_SG19(V,P)
 EFFORT_SG20(V,P)
 EFFORT_SG21(V,P)
 EFFORT_SG22(V,P)
 EFFORT_SG23(V,P)
 EFFORT_SG24(V,P)
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
*EFFORT_K_TR1(kwH_group)    restricting kwH-days for TR12 in Kattegatt. EU effort regulation 43:2009
EFFORT_K_TR2(kwH_group)
EFFORT_K_GN1(kwH_group)
*EFFORT_K_GT1(kwH_group)        inget fiske i borttagna KwH restriktioner
EFFORT_S_TR1(kwH_group)
EFFORT_S_TR2(kwH_group)
EFFORT_S_TR3(kwH_group)
EFFORT_S_GN1(kwH_group)
*EFFORT_S_GT1(kwH_group)
EFFORT_S_LL1(kwH_group)
EFFORT_K_RIST(kwH_group)
EFFORT_S_RIST(kwH_group)
LLS_GNS_SEG17_2529
LLS_GNS_SEG18_2224
LLS_GNS_SEG18_2529
LLS_GNS_SEG19_2529

SG05_2529_COD(V)
SG06_2529_COD(V)
SG07_2529_COD(V)
SG08_2529_COD(V)
SG06_2224_COD(V)
SG07_2224_COD(V)
SG08_2224_COD(V)

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



 EFFORT_SG1_year(V)
 EFFORT_SG2_year(V)
 EFFORT_SG3_year(V)
 EFFORT_SG4_year(V)
 EFFORT_SG5_year(V)
 EFFORT_SG6_year(V)
 EFFORT_SG7_year(V)
 EFFORT_SG8_year(V)
 EFFORT_SG9_year(V)
 EFFORT_SG10_year(V)
 EFFORT_SG11_year(V)
 EFFORT_SG12_year(V)
 EFFORT_SG13_year(V)
 EFFORT_SG14_year(V)
 EFFORT_SG15_year(V)
 EFFORT_SG16_year(V)
 EFFORT_SG17_year(V)
 EFFORT_SG18_year(V)
 EFFORT_SG19_year(V)
 EFFORT_SG20_year(V)
 EFFORT_SG21_year(V)
 EFFORT_SG22_year(V)
 EFFORT_SG23_year(V)
 EFFORT_SG24_year(V)

;



*#############################################################
*            DEFINE MIP
*#############################################################

* objective is to maximize sector rents
* observe that CPUE is in tonnes per day and price is in kr/kg, but this
* matches since kr/kg equals tkr/ton and thus all calculations are performed
* using tonnes and tkr (VC and FC_VESSEL are both in tkr)

OBJFUNC..
 SECT_PROFIT  =E=  sum{(F,S,AREA,P), (PRICES(F,S) * CATCH(F,S,AREA,P))*DISCOUNT_RATE(P)}
                - sum{(F,P), VARCOST(F) * EFFORT(F,P)}  - sum{V, FC_VESSEL(V)*VESSELS(V)}
 ;


** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** **
** ** ** ** ** EFFORT RESTRICTIONS  ** ** ** ** **

* effort constraint on individual vessels by fishery and period
EFFORT_FISH1(SEG1,P).. EFFORT(SEG1,P) =L= VESSELS("SG01") * MAX_EFF_F(SEG1,P);
EFFORT_FISH2(SEG2,P).. EFFORT(SEG2,P) =L= VESSELS("SG02") * MAX_EFF_F(SEG2,P);
EFFORT_FISH3(SEG3,P).. EFFORT(SEG3,P) =L= VESSELS("SG03") * MAX_EFF_F(SEG3,P);
EFFORT_FISH4(SEG4,P).. EFFORT(SEG4,P) =L= VESSELS("SG04") * MAX_EFF_F(SEG4,P);
EFFORT_FISH5(SEG5,P).. EFFORT(SEG5,P) =L= VESSELS("SG05") * MAX_EFF_F(SEG5,P);
EFFORT_FISH6(SEG6,P).. EFFORT(SEG6,P) =L= VESSELS("SG06") * MAX_EFF_F(SEG6,P);
EFFORT_FISH7(SEG7,P).. EFFORT(SEG7,P) =L= VESSELS("SG07") * MAX_EFF_F(SEG7,P);
EFFORT_FISH8(SEG8,P).. EFFORT(SEG8,P) =L= VESSELS("SG08") * MAX_EFF_F(SEG8,P);
EFFORT_FISH9(SEG9,P).. EFFORT(SEG9,P) =L= VESSELS("SG09") * MAX_EFF_F(SEG9,P);
EFFORT_FISH10(SEG10,P).. EFFORT(SEG10,P) =L= VESSELS("SG10") * MAX_EFF_F(SEG10,P);
EFFORT_FISH11(SEG11,P).. EFFORT(SEG11,P) =L= VESSELS("SG11") * MAX_EFF_F(SEG11,P);
EFFORT_FISH12(SEG12,P).. EFFORT(SEG12,P) =L= VESSELS("SG12") * MAX_EFF_F(SEG12,P);
EFFORT_FISH13(SEG13,P).. EFFORT(SEG13,P) =L= VESSELS("SG13") * MAX_EFF_F(SEG13,P);
EFFORT_FISH14(SEG14,P).. EFFORT(SEG14,P) =L= VESSELS("SG14") * MAX_EFF_F(SEG14,P);
EFFORT_FISH15(SEG15,P).. EFFORT(SEG15,P) =L= VESSELS("SG15") * MAX_EFF_F(SEG15,P);
EFFORT_FISH16(SEG16,P).. EFFORT(SEG16,P) =L= VESSELS("SG16") * MAX_EFF_F(SEG16,P);
EFFORT_FISH17(SEG17,P).. EFFORT(SEG17,P) =L= VESSELS("SG17") * MAX_EFF_F(SEG17,P);
EFFORT_FISH18(SEG18,P).. EFFORT(SEG18,P) =L= VESSELS("SG18") * MAX_EFF_F(SEG18,P);
EFFORT_FISH19(SEG19,P).. EFFORT(SEG19,P) =L= VESSELS("SG19") * MAX_EFF_F(SEG19,P);
EFFORT_FISH20(SEG20,P).. EFFORT(SEG20,P) =L= VESSELS("SG20") * MAX_EFF_F(SEG20,P);
EFFORT_FISH21(SEG21,P).. EFFORT(SEG21,P) =L= VESSELS("SG21") * MAX_EFF_F(SEG21,P);
EFFORT_FISH22(SEG22,P).. EFFORT(SEG22,P) =L= VESSELS("SG22") * MAX_EFF_F(SEG22,P);
EFFORT_FISH23(SEG23,P).. EFFORT(SEG23,P) =L= VESSELS("SG23") * MAX_EFF_F(SEG23,P);
EFFORT_FISH24(SEG24,P).. EFFORT(SEG24,P) =L= VESSELS("SG24") * MAX_EFF_F(SEG24,P);

* segment cannot generate more effort than fleet size allows
EFFORT_SG1("SG01",P).. sum{SEG1, EFFORT(SEG1,P)} =L= VESSELS("SG01") *  MAX_EFF_V("SG01",P);
EFFORT_SG2("SG02",P).. sum{SEG2, EFFORT(SEG2,P)} =L= VESSELS("SG02") *  MAX_EFF_V("SG02",P);
EFFORT_SG3("SG03",P).. sum{SEG3, EFFORT(SEG3,P)} =L= VESSELS("SG03") *  MAX_EFF_V("SG03",P);
EFFORT_SG4("SG04",P).. sum{SEG4, EFFORT(SEG4,P)} =L= VESSELS("SG04") *  MAX_EFF_V("SG04",P);
EFFORT_SG5("SG05",P).. sum{SEG5, EFFORT(SEG5,P)} =L= VESSELS("SG05") *  MAX_EFF_V("SG05",P);
EFFORT_SG6("SG06",P).. sum{SEG6, EFFORT(SEG6,P)} =L= VESSELS("SG06") *  MAX_EFF_V("SG06",P);
EFFORT_SG7("SG07",P).. sum{SEG7, EFFORT(SEG7,P)} =L= VESSELS("SG07") *  MAX_EFF_V("SG07",P);
EFFORT_SG8("SG08",P).. sum{SEG8, EFFORT(SEG8,P)} =L= VESSELS("SG08") *  MAX_EFF_V("SG08",P);
EFFORT_SG9("SG09",P).. sum{SEG9, EFFORT(SEG9,P)} =L= VESSELS("SG09") *  MAX_EFF_V("SG09",P);
EFFORT_SG10("SG10",P).. sum{SEG10, EFFORT(SEG10,P)} =L= VESSELS("SG10") *  MAX_EFF_V("SG10",P);
EFFORT_SG11("SG11",P).. sum{SEG11, EFFORT(SEG11,P)} =L= VESSELS("SG11") *  MAX_EFF_V("SG11",P);
EFFORT_SG12("SG12",P).. sum{SEG12, EFFORT(SEG12,P)} =L= VESSELS("SG12") *  MAX_EFF_V("SG12",P);
EFFORT_SG13("SG13",P).. sum{SEG13, EFFORT(SEG13,P)} =L= VESSELS("SG13") *  MAX_EFF_V("SG13",P);
EFFORT_SG14("SG14",P).. sum{SEG14, EFFORT(SEG14,P)} =L= VESSELS("SG14") *  MAX_EFF_V("SG14",P);
EFFORT_SG15("SG15",P).. sum{SEG15, EFFORT(SEG15,P)} =L= VESSELS("SG15") *  MAX_EFF_V("SG15",P);
EFFORT_SG16("SG16",P).. sum{SEG16, EFFORT(SEG16,P)} =L= VESSELS("SG16") *  MAX_EFF_V("SG16",P);
EFFORT_SG17("SG17",P).. sum{SEG17, EFFORT(SEG17,P)} =L= VESSELS("SG17") *  MAX_EFF_V("SG17",P);
EFFORT_SG18("SG18",P).. sum{SEG18, EFFORT(SEG18,P)} =L= VESSELS("SG18") *  MAX_EFF_V("SG18",P);
EFFORT_SG19("SG19",P).. sum{SEG19, EFFORT(SEG19,P)} =L= VESSELS("SG19") *  MAX_EFF_V("SG19",P);
EFFORT_SG20("SG20",P).. sum{SEG20, EFFORT(SEG20,P)} =L= VESSELS("SG20") *  MAX_EFF_V("SG20",P);
EFFORT_SG21("SG21",P).. sum{SEG21, EFFORT(SEG21,P)} =L= VESSELS("SG21") *  MAX_EFF_V("SG21",P);
EFFORT_SG22("SG22",P).. sum{SEG22, EFFORT(SEG22,P)} =L= VESSELS("SG22") *  MAX_EFF_V("SG22",P);
EFFORT_SG23("SG23",P).. sum{SEG23, EFFORT(SEG23,P)} =L= VESSELS("SG23") *  MAX_EFF_V("SG23",P);
EFFORT_SG24("SG24",P).. sum{SEG24, EFFORT(SEG24,P)} =L= VESSELS("SG24") *  MAX_EFF_V("SG24",P);




* upper bound on fleet size in each segment = 2009 fleet size
FLEET(V)..
 VESSELS(V) =L= FLEET_MAX(V);

FLEET_KWH..
sum{V, VESSELS(V)*KWH_VESSEL_SEG(V)}  =L= 168446 ;
* 168446 is total kwh in 2009
* vad är kapacitetstaket i praktiken???




** ** ** EFFORT K, S, N ** ** **

*EFFORT_K_TR1("K_TR1")..
* sum{(K_TR1,P), EFFORT(K_TR1,P)*KWH_PER_VESSEL(K_TR1)}  =L= MAXEFF_VH("K_TR1")   ;
EFFORT_K_TR2("K_TR2")..
 sum{(K_TR2,P), EFFORT(K_TR2,P)*KWH_PER_VESSEL(K_TR2)}  =L= MAXEFF_VH("K_TR2")   ;
EFFORT_K_GN1("K_GN1")..
 sum{(K_GN1,P), EFFORT(K_GN1,P)*KWH_PER_VESSEL(K_GN1)}  =L= MAXEFF_VH("K_GN1")   ;
*EFFORT_K_GT1("K_GT1")..
* sum{(K_GT1,P), EFFORT(K_GT1,P)*KWH_PER_VESSEL(K_GT1)}  =L= MAXEFF_VH("K_GT1")   ;
* S_TR12 divideras med två för att hålla talstorleken  nere (annars infeasible)
EFFORT_S_TR1("S_TR1")..
 sum{(S_TR1,P), EFFORT(S_TR1,P)*KWH_PER_VESSEL(S_TR1)}/2  =L= MAXEFF_VH("S_TR1")/2   ;
EFFORT_S_TR2("S_TR2")..
 sum{(S_TR2,P), EFFORT(S_TR2,P)*KWH_PER_VESSEL(S_TR2)}/2  =L= MAXEFF_VH("S_TR2")/2   ;
EFFORT_S_GN1("S_GN1")..
 sum{(S_GN1,P), EFFORT(S_GN1,P)*KWH_PER_VESSEL(S_GN1)}  =L= MAXEFF_VH("S_GN1")   ;
*EFFORT_S_GT1("S_GT1")..
* sum{(S_GT1,P), EFFORT(S_GT1,P)*KWH_PER_VESSEL(S_GT1)}  =L= MAXEFF_VH("S_GT1")   ;
EFFORT_S_LL1("S_LL1")..
 sum{(S_LL1,P), EFFORT(S_LL1,P)*KWH_PER_VESSEL(S_LL1)}  =L= MAXEFF_VH("S_LL1")   ;

* svensk reglering som begränsar ristfisket, använder ej pga då fiskas inte kvoten upp. Behöver mer effort till K pga låg lönsamhet i S.
EFFORT_K_RIST("K_RIST")..
 sum{(K_RIST,P), EFFORT(K_RIST,P)*KWH_PER_VESSEL(K_RIST)}  =L= MAXEFF_VH("K_RIST")   ;
EFFORT_S_RIST("S_RIST")..
 sum{(S_RIST,P), EFFORT(S_RIST,P)*KWH_PER_VESSEL(S_RIST)}  =L= MAXEFF_VH("S_RIST")   ;

** ** ** EFFORT BALTIC ** ** **
* OBS! not correct modelling since not all vessels in VESSELS(V) have effort days in the Baltic, not in use!
* i.e. the model overestimates the maximum possible fishing effort in the Baltic
BALTIC_EFFORT_2224(FISHERY)..
         sum{(BALTIC2224_COD,P), EFFORT(BALTIC2224_COD,P)} =L= 201*sum{V, VESSELS(V)}    ;
BALTIC_EFFORT_2529(FISHERY)..
         sum{(BALTIC2529_COD,P), EFFORT(BALTIC2529_COD,P)} =L= 160*sum{V, VESSELS(V)}    ;

* Baltic cod permits -
*SG01_BALTIC_CODNET("SG01",P).. sum{SG01_BALTICCODNET, EFFORT(SG01_BALTICCODNET,P)} =L= BALTIC_COD_PERMIT("SG01") *  MAX_EFF_V("SG01",P);
*SG02_BALTIC_CODNET("SG02",P).. sum{SG02_BALTICCODNET, EFFORT(SG02_BALTICCODNET,P)} =L= BALTIC_COD_PERMIT("SG02") *  MAX_EFF_V("SG02",P);
*SG03_BALTIC_CODNET("SG03",P).. sum{SG03_BALTICCODNET, EFFORT(SG03_BALTICCODNET,P)} =L= BALTIC_COD_PERMIT("SG03") *  MAX_EFF_V("SG03",P);

*SG04_BALTIC_CODTRAWL("SG04",P).. sum{SG04_BALTICCODTRAWL, EFFORT(SG04_BALTICCODTRAWL,P)} =L= BALTIC_COD_PERMIT("SG04") *  MAX_EFF_V("SG04",P);
*SG05_BALTIC_CODTRAWL("SG05",P).. sum{SG05_BALTICCODTRAWL, EFFORT(SG05_BALTICCODTRAWL,P)} =L= BALTIC_COD_PERMIT("SG05") *  MAX_EFF_V("SG05",P);
*SG06_BALTIC_CODTRAWL("SG06",P).. sum{SG06_BALTICCODTRAWL, EFFORT(SG06_BALTICCODTRAWL,P)} =L= BALTIC_COD_PERMIT("SG06") *  MAX_EFF_V("SG06",P);

LLS_GNS_SEG17_2529..
          sum(P, EFFORT("132",P))=L=   {EFFORT_2009("132")/(EFFORT_2009("128")+EFFORT_2009("132"))}*{sum(P, EFFORT("132",P))+sum(P, EFFORT("128",P))}  ;
LLS_GNS_SEG18_2224..
          sum(P, EFFORT("141",P))=L=   {EFFORT_2009("141")/(EFFORT_2009("137")+EFFORT_2009("141"))}*{sum(P, EFFORT("141",P))+sum(P, EFFORT("137",P))}  ;
LLS_GNS_SEG18_2529..
          sum(P, EFFORT("147",P))=L=   {EFFORT_2009("147")/(EFFORT_2009("142")+EFFORT_2009("147"))}*{sum(P, EFFORT("142",P))+sum(P, EFFORT("147",P))}  ;
LLS_GNS_SEG19_2529..
          sum(P, EFFORT("155",P))=L=   {EFFORT_2009("155")/(EFFORT_2009("153")+EFFORT_2009("155"))}*{sum(P, EFFORT("153",P))+sum(P, EFFORT("155",P))}  ;


SG05_2529_COD("SG05").. sum(P, EFFORT("30",P)) =L= 160*BALTIC_COD_PERMIT("SG05")  ;
SG06_2529_COD("SG06").. sum(P, EFFORT("42",P)) =L= 160*BALTIC_COD_PERMIT("SG06")  ;
SG07_2529_COD("SG07").. sum(P, EFFORT("54",P)) =L= 160*BALTIC_COD_PERMIT("SG07")  ;
SG08_2529_COD("SG08").. sum(P, EFFORT("61",P)) =L= 160*BALTIC_COD_PERMIT("SG08")  ;

SG06_2224_COD("SG06").. sum(P, EFFORT("41",P)) =L= 201*BALTIC_COD_PERMIT("SG06")  ;
SG07_2224_COD("SG07").. sum(P, EFFORT("53",P)) =L= 201*BALTIC_COD_PERMIT("SG07")  ;
SG08_2224_COD("SG08").. sum(P, EFFORT("59",P)) =L= 201*BALTIC_COD_PERMIT("SG08")  ;




* ANVÄNDS EJ
*EFFORT_LLS_GNS_2224..
*   sum({GNS_2224,P}, EFFORT(GNS_2224,P))- sum({LLS_2224,P}, EFFORT(LLS_2224,P))  =G= sum(GNS_2224, EFFORT_2009(GNS_2224))- sum(LLS_2224, EFFORT_2009(LLS_2224))  ;
*EFFORT_LLS_GNS_2529..
*   sum({GNS_2529,P}, EFFORT(GNS_2529,P))- sum({LLS_2529,P}, EFFORT(LLS_2529,P))  =G= sum(GNS_2529, EFFORT_2009(GNS_2529))- sum(LLS_2529, EFFORT_2009(LLS_2529))  ;


** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** ** **
* catch as a function of effort *


CATCH_FUNC(F,S,AREA,P)  ..
 CATCH(F,S,AREA,P) =E=  CPUE(F,S,AREA) * EFFORT(F,P) ;



** ** **  ** ** ** ** **  ** ** ** ** ** ** ** ** ** ** ** ** ** **
** ** ** TAC RESTRICTIONS ** ** ** ** ** ** ** ** ** ** ** ** ** **

* annual TAC by species-stock
* unquoted species are modelled with quota = 100 000 tons, constraind below in biological max

TAC_STOCK(S,AREA) ..
 sum{(F,P), CATCH(F,S,AREA,P)} =L=  TAC_MOD(S,AREA) ;

* biological max - constrains species that have no quotas (presently set to 2009 years catch)
BIO_MAX(S,AREA)..
 sum{(F,P), CATCH(F,S,AREA,P)} =L=  BIOL_MAX(S,AREA) ;

* conatraint ensuring that S+K quotas are not exceeded
* same quota for S and K
* Quota K and quota S set the same in Excel

 KS_KOLJA("kolja")..
  sum{(F,P,KS), CATCH(F,"kolja",KS,P)} =L=  TAC_MOD("kolja","K") ;
 KS_KRAFTA("havskrafta")..
  sum{(F,P,KS), CATCH(F,"havskrafta",KS,P)} =L=  TAC_MOD("havskrafta","K") ;
 KS_KUMMEL("KUMMEL")..
  sum{(F,P,KS), CATCH(F,"KUMMEL",KS,P)} =L= TAC_MOD("kummel","K") ;
 KS_PIGGHAJ("PIGGHAJ")..
  sum{(F,P,KS), CATCH(F,"PIGGHAJ",KS,P)} =L=  TAC_MOD("pigghaj","K") ;
 KS_RAKA("RAKA")..
  sum{(F,P,KS), CATCH(F,"RAKA",KS,P)} =L=  TAC_MOD("raka","K") ;
 KS_SILL("SILL_INDUSTRI")..
  sum{(F,P,KS), CATCH(F,"SILL_INDUSTRI",KS,P)}+ sum{(F,P,KS), CATCH(F,"SILL_KONSUM",KS,P)} =L=  TAC_MOD("sill_industri","K") ;
 KS_SILL_INDUSTRI("SILL_INDUSTRI")..
  sum{(F,P,KS), CATCH(F,"SILL_INDUSTRI",KS,P)} =L=  TAC_MOD("sill_industri","K") ;
 KS_SILL_KONSUM("SILL_KONSUM")..
  sum{(F,P,KS), CATCH(F,"SILL_KONSUM",KS,P)} =L=  TAC_MOD("sill_konsum","K") ;

 KS_SKARPSILL("SKARPSILL_INDUSTRI")..
  sum{(F,P,KS), CATCH(F,"SKARPSILL_INDUSTRI",KS,P)}+  sum{(F,P,KS), CATCH(F,"SKARPSILL_KONSUM",KS,P)} =L=  TAC_MOD("skarpsill_industri","K") ;
 KS_TUNGA("TUNGA")..
  sum{(F,P,KS), CATCH(F,"TUNGA",KS,P)} =L=  TAC_MOD("tunga","K") ;
 KS_VITLING("VITLING")..
  sum{(F,P,KS), CATCH(F,"VITLING",KS,P)} =L=  TAC_MOD("vitling","K") ;

* conatraint ensuring that Baltic quotas are not exceeded
 BALTIC_LAX("LAX")..
  sum{(F,P,BALTIC), CATCH(F,"LAX",BALTIC,P)} =L=  TAC_MOD("lax","25-29+32") ;
 BALTIC_SKARPSILL("SKARPSILL_INDUSTRI")$(CATCH_SPRATQUOTA_2529_dummy = 0)..
  sum{(F,P,BALTIC), CATCH(F,"SKARPSILL_INDUSTRI",BALTIC,P)}+  sum{(F,P,BALTIC), CATCH(F,"SKARPSILL_KONSUM",BALTIC,P)} =L=  TAC_MOD("skarpsill_industri","25-29+32") ;
 BALTIC_SILL("SILL_INDUSTRI")..
  sum{(F,P), CATCH(F,"SILL_INDUSTRI","25-29+32",P)}+  sum{(F,P), CATCH(F,"SILL_KONSUM","25-29+32",P)} =L=  TAC_MOD("sill_industri","25-29+32") ;
 BALTIC_RODSPOTTA("RODSPOTTA")..
  sum{(F,P,BALTIC), CATCH(F,"RODSPOTTA",BALTIC,P)} =L=  TAC_MOD("rodspotta","25-29+32") ;

 BALTIC_EASTERNCOD("TORSK")..
  sum{(F,P,BALTIC_EAST), CATCH(F,"TORSK",BALTIC_EAST,P)} =L=  TAC_MOD("torsk","25-29+32") ;

CATCH_SPRATQUOTA_2529$(CATCH_SPRATQUOTA_2529_dummy = 1)..
   sum{(F,P,BALTIC), CATCH(F,"SKARPSILL_INDUSTRI",BALTIC,P)}+  sum{(F,P,BALTIC), CATCH(F,"SKARPSILL_KONSUM",BALTIC,P)} =G=  TAC_MOD("skarpsill_industri","25-29+32") ;



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
         sum{(PASSIVEGEAR,P),  CATCH(PASSIVEGEAR,"Torsk","25-29+32",P)} =L= 0.23*TAC_MOD("Torsk","25-29+32") ;
COD_ACTIVE_25t32$(ACTIVEPASSIVE = 1)..
         sum({ACTIVEGEAR, P},  CATCH(ACTIVEGEAR,"Torsk","25-29+32",P)) =L= 0.77*TAC_MOD("Torsk","25-29+32")  ;
COD_PASSIVE_22t24$(ACTIVEPASSIVE = 1)..
         sum({PASSIVEGEAR, P},  CATCH(PASSIVEGEAR,"Torsk","22-24",P)) =L= 0.45*TAC_MOD("Torsk","22-24")  ;
COD_ACTIVE_22t24$(ACTIVEPASSIVE = 1)..
         sum({ACTIVEGEAR,P},  CATCH(ACTIVEGEAR,"Torsk","22-24",P)) =L= 0.65*TAC_MOD("Torsk","22-24")   ;

* Andelar S o K bygger på uppgifter från Havsfiskelab
* S: cod_active = 75 %, cod passive 25 %   (active tar 403 ton av 537)
* K  cod_active = 85 %, cod passive 15 %   (active tar 60 ton av 70)
*


COD_PASSIVE_S$(ACTIVEPASSIVE = 1)..
         sum{(PASSIVEGEAR,P),  CATCH(PASSIVEGEAR,"Torsk","S",P)} =L= 0.25*TAC_MOD("Torsk","S") ;
COD_ACTIVE_S$(ACTIVEPASSIVE = 1)..
         sum{(ACTIVEGEAR,P),  CATCH(ACTIVEGEAR,"Torsk","S",P)} =L= 0.75*TAC_MOD("Torsk","S") ;
COD_PASSIVE_K$(ACTIVEPASSIVE = 1)..
         sum{(PASSIVEGEAR,P),  CATCH(PASSIVEGEAR,"Torsk","K",P)} =L= 0.15*TAC_MOD("Torsk","K") ;
COD_ACTIVE_K$(ACTIVEPASSIVE = 1)..
         sum{(ACTIVEGEAR,P),  CATCH(ACTIVEGEAR,"Torsk","K",P)} =L= 0.85*TAC_MOD("Torsk","K") ;





* uppdelning enligt Havsfiskelab: rist >= 50 %
*                                 passiv = 20 %
*                                 ej rist = 30 %
* obs att kvoten är K + S så restriktionerna följer detta
*   NORWLOBST_EJRIST_AP_KS gör så att ej rist endast tar max 30 % i Active/Passive scenario
* om bas scenario får "ej rist" ta 50 % av fångsten

NORWLOBST_PASSIVE_KS$(ACTIVEPASSIVE = 1)..
           sum{(PASSIVEGEAR,P),  CATCH(PASSIVEGEAR,"havskrafta","S",P)} + sum{(PASSIVEGEAR,P),  CATCH(PASSIVEGEAR,"havskrafta","K",P)} =L= 0.20*TAC_MOD("havskrafta","S") ;

NORWLOBST_ACTIVE_KS$(ACTIVEPASSIVE = 1)..
           sum{(ACTIVEGEAR,P),  CATCH(ACTIVEGEAR,"havskrafta","S",P)} + sum{(ACTIVEGEAR,P),  CATCH(ACTIVEGEAR,"havskrafta","K",P)} =L= 0.80*TAC_MOD("havskrafta","S") ;

NORWLOBST_EJRIST_AP_KS$(ACTIVEPASSIVE = 1)..
           sum{(KRAFTA_EJRIST,P),  CATCH(KRAFTA_EJRIST,"havskrafta","S",P)} + sum{(KRAFTA_EJRIST,P),  CATCH(KRAFTA_EJRIST,"havskrafta","K",P)}=L= 0.3*TAC_MOD("havskrafta","S") ;

NORWLOBST_EJRIST_KS..
           sum{(KRAFTA_EJRIST,P),  CATCH(KRAFTA_EJRIST,"havskrafta","S",P)} + sum{(KRAFTA_EJRIST,P),  CATCH(KRAFTA_EJRIST,"havskrafta","K",P)}=L= 0.5*TAC_MOD("havskrafta","S") ;

*  dagens fångst 30 %
SHRIMP_COASTAL..
           sum{(SHRIMP_KS_1018,P), CATCH(SHRIMP_KS_1018,"Raka","K",P)} + sum{(SHRIMP_KS_1018,P), CATCH(SHRIMP_KS_1018,"Raka","S",P)} =L= 0.30*TAC_MOD("Raka","S") ;
* kolla rimlig % med Katja, dagens fångst är 11 %
NORWLOBST_COASTAL..
           sum{(NORWLOBST_0012,P), CATCH(NORWLOBST_0012,"havskrafta","K",P)} + sum{(NORWLOBST_0012,P), CATCH(NORWLOBST_0012,"havskrafta","S",P)} =L= 0.25*TAC_MOD("havskrafta","S") ;

SILL_KONSUM_2529..
            sum{(F,P),  CATCH(F,"sill_konsum","25-29+32",P)} =L= 0.5*TAC_MOD("sill_konsum","25-29+32") ;

* kustfiskekvot = max av kvot och infiskat (det senare ofta över kvot pga extratilldelning som sedan leder till höjd kvot 2010

SILL_KUSTKVOT_2224..
             sum{(PEL_KUSTFISKE,P), CATCH(PEL_KUSTFISKE, "sill_konsum", "22-24", P)} =L= 817 ;
SILL_KUSTKVOT_2529..
             sum{(PEL_KUSTFISKE,P), CATCH(PEL_KUSTFISKE, "sill_konsum", "25-29+32", P)} =L= 745 ;
SILL_KUSTKVOT_3031..
             sum{(PEL_KUSTFISKE,P), CATCH(PEL_KUSTFISKE, "sill_konsum", "30-31", P)} =L= 3000 ;
SILL_KUSTKVOT_KS..
             sum{(PEL_KUSTFISKE,P), CATCH(PEL_KUSTFISKE, "sill_konsum", "K", P)} +  sum{(PEL_KUSTFISKE,P), CATCH(PEL_KUSTFISKE, "sill_konsum", "S", P)}=L= 250 ;


* ##### restr till att återskapa dagens situation ######
* Låser TAC mellan segmenten
* obs att catchshare avser andel av totfångst som segmentet står för vilket är en genväg eftesom detta kan skilja mellan områden.
* special för kräfta seg 3 och 4 eftersom dessa annars expanderar pga restriktionen gäller gemensam kvot - därför delat med 2

TAC_SEG1(S,A).. sum{(SEG1,P),  CATCH(SEG1,S,A,P)} =L= SUM(SEG1, CATCHSHARE_2009(SEG1,S,A)*TAC_MOD(S,A)) ;
TAC_SEG2(S,A).. sum{(SEG2,P),  CATCH(SEG2,S,A,P)} =L= SUM(SEG2, CATCHSHARE_2009(SEG2,S,A)*TAC_MOD(S,A)) ;
TAC_SEG3(S,A).. sum{(SEG3,P),  CATCH(SEG3,S,A,P)} =L= SUM(SEG3, CATCHSHARE_2009(SEG3,S,A)*TAC_MOD(S,A)) ;
TAC_SEG4(S,A).. sum{(SEG4,P),  CATCH(SEG4,S,A,P)} =L= SUM(SEG4, CATCHSHARE_2009(SEG4,S,A)*TAC_MOD(S,A)) ;
TAC_SEG5(S,A).. sum{(SEG5,P),  CATCH(SEG5,S,A,P)} =L= SUM(SEG5, CATCHSHARE_2009(SEG5,S,A)*TAC_MOD(S,A)) ;
TAC_SEG6(S,A).. sum{(SEG6,P),  CATCH(SEG6,S,A,P)} =L= SUM(SEG6, CATCHSHARE_2009(SEG6,S,A)*TAC_MOD(S,A)) ;
TAC_SEG7(S,A).. sum{(SEG7,P),  CATCH(SEG7,S,A,P)} =L= SUM(SEG7, CATCHSHARE_2009(SEG7,S,A)*TAC_MOD(S,A)) ;
TAC_SEG8(S,A).. sum{(SEG8,P),  CATCH(SEG8,S,A,P)} =L= SUM(SEG8, CATCHSHARE_2009(SEG8,S,A)*TAC_MOD(S,A)) ;
TAC_SEG9(S,A).. sum{(SEG9,P),  CATCH(SEG9,S,A,P)} =L= SUM(SEG9, CATCHSHARE_2009(SEG9,S,A)*TAC_MOD(S,A)) ;
TAC_SEG10(S,A).. sum{(SEG10,P),  CATCH(SEG10,S,A,P)} =L= SUM(SEG10, CATCHSHARE_2009(SEG10,S,A)*TAC_MOD(S,A)) ;
TAC_SEG11(S,A).. sum{(SEG11,P),  CATCH(SEG11,S,A,P)} =L= SUM(SEG11, CATCHSHARE_2009(SEG11,S,A)*TAC_MOD(S,A)) ;
TAC_SEG12(S,A).. sum{(SEG12,P),  CATCH(SEG12,S,A,P)} =L= SUM(SEG12, CATCHSHARE_2009(SEG12,S,A)*TAC_MOD(S,A)) ;
TAC_SEG13(S,A).. sum{(SEG13,P),  CATCH(SEG13,S,A,P)} =L= SUM(SEG13, CATCHSHARE_2009(SEG13,S,A)*TAC_MOD(S,A)) ;
TAC_SEG14(S,A).. sum{(SEG14,P),  CATCH(SEG14,S,A,P)} =L= SUM(SEG14, CATCHSHARE_2009(SEG14,S,A)*TAC_MOD(S,A)) ;
TAC_SEG15(S,A).. sum{(SEG15,P),  CATCH(SEG15,S,A,P)} =L= SUM(SEG15, CATCHSHARE_2009(SEG15,S,A)*TAC_MOD(S,A)) ;
TAC_SEG16(S,A).. sum{(SEG16,P),  CATCH(SEG16,S,A,P)} =L= SUM(SEG16, CATCHSHARE_2009(SEG16,S,A)*TAC_MOD(S,A)) ;
TAC_SEG17(S,A).. sum{(SEG17,P),  CATCH(SEG17,S,A,P)} =L= SUM(SEG17, CATCHSHARE_2009(SEG17,S,A)*TAC_MOD(S,A)) ;
TAC_SEG18(S,A).. sum{(SEG18,P),  CATCH(SEG18,S,A,P)} =L= SUM(SEG18, CATCHSHARE_2009(SEG18,S,A)*TAC_MOD(S,A)) ;
TAC_SEG19(S,A).. sum{(SEG19,P),  CATCH(SEG19,S,A,P)} =L= SUM(SEG19, CATCHSHARE_2009(SEG19,S,A)*TAC_MOD(S,A)) ;
TAC_SEG20(S,A).. sum{(SEG20,P),  CATCH(SEG20,S,A,P)} =L= SUM(SEG20, CATCHSHARE_2009(SEG20,S,A)*TAC_MOD(S,A)) ;
TAC_SEG21(S,A).. sum{(SEG21,P),  CATCH(SEG21,S,A,P)} =L= SUM(SEG21, CATCHSHARE_2009(SEG21,S,A)*TAC_MOD(S,A)) ;
TAC_SEG22(S,A).. sum{(SEG22,P),  CATCH(SEG22,S,A,P)} =L= SUM(SEG22, CATCHSHARE_2009(SEG22,S,A)*TAC_MOD(S,A)) ;
TAC_SEG23(S,A).. sum{(SEG23,P),  CATCH(SEG23,S,A,P)} =L= SUM(SEG23, CATCHSHARE_2009(SEG23,S,A)*TAC_MOD(S,A)) ;
TAC_SEG24(S,A).. sum{(SEG24,P),  CATCH(SEG24,S,A,P)} =L= SUM(SEG24, CATCHSHARE_2009(SEG24,S,A)*TAC_MOD(S,A)) ;

*TAC restriktioner ovan funkar inte på kvoter som täcker två områden, kompletteras för kräfta (ej torsk pga inga fångster i 30-31)
TAC_SEG2_KRAFTA("havskrafta",A).. sum{(SEG2,P),  CATCH(SEG2,"havskrafta",A,P)} =L= SUM(SEG2, CATCHSHARE_2009(SEG2,"havskrafta",A))*TAC_MOD("havskrafta",A)/2 ;
TAC_SEG3_KRAFTA("havskrafta",A).. sum{(SEG3,P),  CATCH(SEG3,"havskrafta",A,P)} =L= SUM(SEG3, CATCHSHARE_2009(SEG3,"havskrafta",A))*TAC_MOD("havskrafta",A)/2 ;
TAC_SEG4_KRAFTA("havskrafta",A).. sum{(SEG4,P),  CATCH(SEG4,"havskrafta",A,P)} =L= SUM(SEG4, CATCHSHARE_2009(SEG4,"havskrafta",A))*TAC_MOD("havskrafta",A)/2 ;
TAC_SEG5_KRAFTA("havskrafta",A).. sum{(SEG5,P),  CATCH(SEG5,"havskrafta",A,P)} =L= SUM(SEG5, CATCHSHARE_2009(SEG5,"havskrafta",A))*TAC_MOD("havskrafta",A)/2 ;
TAC_SEG6_KRAFTA("havskrafta",A).. sum{(SEG6,P),  CATCH(SEG6,"havskrafta",A,P)} =L= SUM(SEG6, CATCHSHARE_2009(SEG6,"havskrafta",A))*TAC_MOD("havskrafta",A)/2 ;
TAC_SEG7_KRAFTA("havskrafta",A).. sum{(SEG7,P),  CATCH(SEG7,"havskrafta",A,P)} =L= SUM(SEG7, CATCHSHARE_2009(SEG7,"havskrafta",A))*TAC_MOD("havskrafta",A)/2 ;
TAC_SEG8_KRAFTA("havskrafta",A).. sum{(SEG8,P),  CATCH(SEG8,"havskrafta",A,P)} =L= SUM(SEG8, CATCHSHARE_2009(SEG8,"havskrafta",A))*TAC_MOD("havskrafta",A)/2 ;
TAC_SEG9_KRAFTA("havskrafta",A).. sum{(SEG9,P),  CATCH(SEG9,"havskrafta",A,P)} =L= SUM(SEG9, CATCHSHARE_2009(SEG9,"havskrafta",A))*TAC_MOD("havskrafta",A)/2 ;
TAC_SEG10_KRAFTA("havskrafta",A).. sum{(SEG10,P),  CATCH(SEG10,"havskrafta",A,P)} =L= SUM(SEG10, CATCHSHARE_2009(SEG10,"havskrafta",A))*TAC_MOD("havskrafta",A)/2 ;
TAC_SEG11_KRAFTA("havskrafta",A).. sum{(SEG11,P),  CATCH(SEG11,"havskrafta",A,P)} =L= SUM(SEG11, CATCHSHARE_2009(SEG11,"havskrafta",A))*TAC_MOD("havskrafta",A)/2 ;
TAC_SEG12_KRAFTA("havskrafta",A).. sum{(SEG12,P),  CATCH(SEG12,"havskrafta",A,P)} =L= SUM(SEG12, CATCHSHARE_2009(SEG12,"havskrafta",A))*TAC_MOD("havskrafta",A)/2 ;
TAC_SEG13_KRAFTA("havskrafta",A).. sum{(SEG13,P),  CATCH(SEG13,"havskrafta",A,P)} =L= SUM(SEG13, CATCHSHARE_2009(SEG13,"havskrafta",A))*TAC_MOD("havskrafta",A)/2 ;
TAC_SEG14_KRAFTA("havskrafta",A).. sum{(SEG14,P),  CATCH(SEG14,"havskrafta",A,P)} =L= SUM(SEG14, CATCHSHARE_2009(SEG14,"havskrafta",A))*TAC_MOD("havskrafta",A)/2 ;
TAC_SEG15_KRAFTA("havskrafta",A).. sum{(SEG15,P),  CATCH(SEG15,"havskrafta",A,P)} =L= SUM(SEG15, CATCHSHARE_2009(SEG15,"havskrafta",A))*TAC_MOD("havskrafta",A)/2 ;

*TAC restriktioner ovan funkar inte på okvoterade arter, kompletteras för siklöja och ål
TAC_SEG23_SIKLOJA("sikloja",A).. sum{(SEG23,P),  CATCH(SEG23,"sikloja",A,P)} =L= SUM(SEG23, CATCHSHARE_2009(SEG23,"sikloja",A))* BIOL_MAX("sikloja",A) ;
TAC_SEG24_SIKLOJA("sikloja",A).. sum{(SEG24,P),  CATCH(SEG24,"sikloja",A,P)} =L= SUM(SEG24, CATCHSHARE_2009(SEG24,"sikloja",A))* BIOL_MAX("sikloja",A) ;

TAC_SEG13_AL("al",A).. sum{(SEG13,P),  CATCH(SEG13,"al",A,P)} =L= SUM(SEG13, CATCHSHARE_2009(SEG13,"al",A))* BIOL_MAX("al",A) ;
TAC_SEG14_AL("al",A).. sum{(SEG14,P),  CATCH(SEG14,"al",A,P)} =L= SUM(SEG14, CATCHSHARE_2009(SEG14,"al",A))* BIOL_MAX("al",A) ;
TAC_SEG15_AL("al",A).. sum{(SEG15,P),  CATCH(SEG15,"al",A,P)} =L= SUM(SEG15, CATCHSHARE_2009(SEG15,"al",A))* BIOL_MAX("al",A) ;
TAC_SEG16_AL("al",A).. sum{(SEG16,P),  CATCH(SEG16,"al",A,P)} =L= SUM(SEG16, CATCHSHARE_2009(SEG16,"al",A))* BIOL_MAX("al",A) ;
TAC_SEG17_AL("al",A).. sum{(SEG17,P),  CATCH(SEG17,"al",A,P)} =L= SUM(SEG17, CATCHSHARE_2009(SEG17,"al",A))* BIOL_MAX("al",A) ;
TAC_SEG18_AL("al",A).. sum{(SEG18,P),  CATCH(SEG18,"al",A,P)} =L= SUM(SEG18, CATCHSHARE_2009(SEG18,"al",A))* BIOL_MAX("al",A) ;
TAC_SEG19_AL("al",A).. sum{(SEG19,P),  CATCH(SEG19,"al",A,P)} =L= SUM(SEG19, CATCHSHARE_2009(SEG19,"al",A))* BIOL_MAX("al",A) ;




* effort per year based on DAS2009 in model divided by vessels, not same as Hav's DAS per vessel!!
EFFORT_SG1_year("SG01").. sum{(SEG1,P), EFFORT(SEG1,P)} =L= VESSELS("SG01") *  0;
EFFORT_SG2_year("SG02").. sum{(SEG2,P), EFFORT(SEG2,P)} =L= VESSELS("SG02") *  88;
EFFORT_SG3_year("SG03").. sum{(SEG3,P), EFFORT(SEG3,P)} =L= VESSELS("SG03") *  101;
EFFORT_SG4_year("SG04").. sum{(SEG4,P), EFFORT(SEG4,P)} =L= VESSELS("SG04") *  99;
EFFORT_SG5_year("SG05").. sum{(SEG5,P), EFFORT(SEG5,P)} =L= VESSELS("SG05") *  35;
EFFORT_SG6_year("SG06").. sum{(SEG6,P), EFFORT(SEG6,P)} =L= VESSELS("SG06") *  91;
EFFORT_SG7_year("SG07").. sum{(SEG7,P), EFFORT(SEG7,P)} =L= VESSELS("SG07") *  90;
EFFORT_SG8_year("SG08").. sum{(SEG8,P), EFFORT(SEG8,P)} =L= VESSELS("SG08") *  76;
EFFORT_SG9_year("SG09").. sum{(SEG9,P), EFFORT(SEG9,P)} =L= VESSELS("SG09") *  64;
EFFORT_SG10_year("SG10").. sum{(SEG10,P), EFFORT(SEG10,P)} =L= VESSELS("SG10") *  115;
EFFORT_SG11_year("SG11").. sum{(SEG11,P), EFFORT(SEG11,P)} =L= VESSELS("SG11") *  162;
EFFORT_SG12_year("SG12").. sum{(SEG12,P), EFFORT(SEG12,P)} =L= VESSELS("SG12") *  159;
EFFORT_SG13_year("SG13").. sum{(SEG13,P), EFFORT(SEG13,P)} =L= VESSELS("SG13") *  98;
EFFORT_SG14_year("SG14").. sum{(SEG14,P), EFFORT(SEG14,P)} =L= VESSELS("SG14") *  111;
EFFORT_SG15_year("SG15").. sum{(SEG15,P), EFFORT(SEG15,P)} =L= VESSELS("SG15") *  142;
EFFORT_SG16_year("SG16").. sum{(SEG16,P), EFFORT(SEG16,P)} =L= VESSELS("SG16") *  50;
EFFORT_SG17_year("SG17").. sum{(SEG17,P), EFFORT(SEG17,P)} =L= VESSELS("SG17") *  169;
EFFORT_SG18_year("SG18").. sum{(SEG18,P), EFFORT(SEG18,P)} =L= VESSELS("SG18") *  100;
EFFORT_SG19_year("SG19").. sum{(SEG19,P), EFFORT(SEG19,P)} =L= VESSELS("SG19") *  94;
EFFORT_SG20_year("SG20").. sum{(SEG20,P), EFFORT(SEG20,P)} =L= VESSELS("SG20") *  0;
EFFORT_SG21_year("SG21").. sum{(SEG21,P), EFFORT(SEG21,P)} =L= VESSELS("SG21") *  124;
EFFORT_SG22_year("SG22").. sum{(SEG22,P), EFFORT(SEG22,P)} =L= VESSELS("SG22") *  149;
EFFORT_SG23_year("SG23").. sum{(SEG23,P), EFFORT(SEG23,P)} =L= VESSELS("SG23") *  16;
EFFORT_SG24_year("SG24").. sum{(SEG24,P), EFFORT(SEG24,P)} =L= VESSELS("SG24") *  25;




* Keep effort in eel fisheries  equal to 2009
LOCK_EEL(EEL)..
  sum{p, EFFORT(EEL,P)} =E= EFFORT_2009(EEL)     ;



* effort only possible when seasondummy = 1
FISHINGSEASON(F,P).. EFFORT(F,P) =E= EFFORT(F,P)*SEASON(F,P) ;


MAX_EFFORTCHANGE(F)..   SUM{P,EFFORT(F,P)} =L= (MAX_EFFORTINCREASE)*EFFORT_2009(F)       ;
MAX_EFFORTCHANGE_64("64")..   SUM{P,EFFORT("64",P)} =L= (MAX_EFFORTINCREASE_64)*EFFORT_2009("64")       ;
MAX_EFFORTCHANGE_65("65")..   SUM{P,EFFORT("65",P)} =L= (MAX_EFFORTINCREASE_65)*EFFORT_2009("65")       ;
MAX_EFFORTCHANGE_66("66")..   SUM{P,EFFORT("66",P)} =L= (MAX_EFFORTINCREASE_66)*EFFORT_2009("66")       ;

MAX_EFFORTCHANGE_31("31")..   SUM{P,EFFORT("31",P)} =L= (MAX_EFFORTINCREASE_31)*EFFORT_2009("31")       ;
MAX_EFFORTCHANGE_43("43")..   SUM{P,EFFORT("43",P)} =L= (MAX_EFFORTINCREASE_43)*EFFORT_2009("43")       ;
MAX_EFFORTCHANGE_48("48")..   SUM{P,EFFORT("48",P)} =L= (MAX_EFFORTINCREASE_48)*EFFORT_2009("48")       ;
MAX_EFFORTCHANGE_55("55")..   SUM{P,EFFORT("55",P)} =L= (MAX_EFFORTINCREASE_55)*EFFORT_2009("55")       ;
MAX_EFFORTCHANGE_56("56")..   SUM{P,EFFORT("56",P)} =L= (MAX_EFFORTINCREASE_56)*EFFORT_2009("56")       ;
MAX_EFFORTCHANGE_60("60")..   SUM{P,EFFORT("60",P)} =L= (MAX_EFFORTINCREASE_60)*EFFORT_2009("60")       ;
MAX_EFFORTCHANGE_62("62")..   SUM{P,EFFORT("62",P)} =L= (MAX_EFFORTINCREASE_62)*EFFORT_2009("62")       ;
MAX_EFFORTCHANGE_63("63")..   SUM{P,EFFORT("63",P)} =L= (MAX_EFFORTINCREASE_63)*EFFORT_2009("63")       ;


MAX_EFFORTCHANGE_148("148")..   SUM{P,EFFORT("148",P)} =L= (MAX_EFFORTINCREASE_148)*EFFORT_2009("148")       ;
MAX_EFFORTCHANGE_94("94")..   SUM{P,EFFORT("94",P)} =L= (MAX_EFFORTINCREASE_94)*EFFORT_2009("94")       ;
MAX_EFFORTCHANGE_178("178")..   SUM{P,EFFORT("178",P)} =L= (MAX_EFFORTINCREASE_178)*EFFORT_2009("178")       ;
MAX_EFFORTCHANGE_131("131")..   SUM{P,EFFORT("131",P)} =L= (MAX_EFFORTINCREASE_131)*EFFORT_2009("131")       ;
MAX_EFFORTCHANGE_18("18")..   SUM{P,EFFORT("18",P)} =L= (MAX_EFFORTINCREASE_18)*EFFORT_2009("18")       ;
MAX_EFFORTCHANGE_28("28")..   SUM{P,EFFORT("28",P)} =L= (MAX_EFFORTINCREASE_28)*EFFORT_2009("28")       ;

MAX_EFFORTCHANGE_1("1")..   SUM{P,EFFORT("1",P)} =L= (MAX_EFFORTINCREASE_1)*EFFORT_2009("1")       ;
MAX_EFFORTCHANGE_156("156")..   SUM{P,EFFORT("156",P)} =L= (MAX_EFFORTINCREASE_156)*EFFORT_2009("156")       ;
MAX_EFFORTCHANGE_157("157")..   SUM{P,EFFORT("157",P)} =L= (MAX_EFFORTINCREASE_157)*EFFORT_2009("157")       ;
MAX_EFFORTCHANGE_158("158")..   SUM{P,EFFORT("158",P)} =L= (MAX_EFFORTINCREASE_158)*EFFORT_2009("158")       ;
MAX_EFFORTCHANGE_159("159")..   SUM{P,EFFORT("159",P)} =L= (MAX_EFFORTINCREASE_159)*EFFORT_2009("159")       ;


*#############################################################
*            DEFINE MODEL AND SOLVE STATEMENTS
*#############################################################

MODEL FISH_MOD /ALL/;

OPTION MIP = BDMLP;

*SOLVE FISH_MOD USING MIP MAXIMIZING SECT_PROFIT;


MODEL FISH_MOD_SW / OBJFUNC ,
 EFFORT_FISH1,
 EFFORT_FISH2,
 EFFORT_FISH3,
 EFFORT_FISH4,
 EFFORT_FISH5,
 EFFORT_FISH6,
 EFFORT_FISH7,
 EFFORT_FISH8,
 EFFORT_FISH9,
 EFFORT_FISH10,
 EFFORT_FISH11,
 EFFORT_FISH12,
 EFFORT_FISH13,
 EFFORT_FISH14,
 EFFORT_FISH15,
 EFFORT_FISH16,
 EFFORT_FISH17,
 EFFORT_FISH18,
 EFFORT_FISH19,
 EFFORT_FISH20,
 EFFORT_FISH21,
 EFFORT_FISH22,
 EFFORT_FISH23,
 EFFORT_FISH24,
*$ONTEXT
 EFFORT_SG1  ,
 EFFORT_SG2  ,
 EFFORT_SG3  ,
 EFFORT_SG4  ,
 EFFORT_SG5  ,
 EFFORT_SG6  ,
 EFFORT_SG7  ,
 EFFORT_SG8  ,
 EFFORT_SG9  ,
 EFFORT_SG10  ,
 EFFORT_SG11  ,
 EFFORT_SG12  ,
 EFFORT_SG13  ,
 EFFORT_SG14  ,
 EFFORT_SG15  ,
 EFFORT_SG16  ,
 EFFORT_SG17  ,
 EFFORT_SG18  ,
 EFFORT_SG19  ,
 EFFORT_SG20  ,
 EFFORT_SG21  ,
 EFFORT_SG22  ,
 EFFORT_SG23  ,
 EFFORT_SG24  ,
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

SG05_2529_COD,
SG06_2529_COD,
SG07_2529_COD,
SG08_2529_COD,
SG06_2224_COD,
SG07_2224_COD,
SG08_2224_COD,

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

* EFFORT_K_TR1  ,
 EFFORT_K_TR2  ,
 EFFORT_K_GN1,
* EFFORT_K_GT1  ,
 EFFORT_S_TR1   ,
 EFFORT_S_TR2   ,
 EFFORT_S_GN1,
* EFFORT_S_GT1,
 EFFORT_S_LL1,
* EFFORT_K_RIST,
* EFFORT_S_RIST,

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

 EFFORT_SG1_year  ,
 EFFORT_SG2_year  ,
 EFFORT_SG3_year  ,
 EFFORT_SG4_year  ,
 EFFORT_SG5_year  ,
 EFFORT_SG6_year  ,
 EFFORT_SG7_year  ,
 EFFORT_SG8_year  ,
 EFFORT_SG9_year  ,
 EFFORT_SG10_year  ,
 EFFORT_SG11_year  ,
 EFFORT_SG12_year  ,
 EFFORT_SG13_year  ,
 EFFORT_SG14_year  ,
 EFFORT_SG15_year  ,
 EFFORT_SG16_year  ,
 EFFORT_SG17_year  ,
 EFFORT_SG18_year  ,
 EFFORT_SG19_year  ,
 EFFORT_SG20_year  ,
 EFFORT_SG21_year  ,
 EFFORT_SG22_year  ,
 EFFORT_SG23_year  ,
 EFFORT_SG24_year
$OFFTEXT
* MAX_EFFORTCHANGE_100,
* MAX_EFFORTCHANGE_107

  / ;






SOLVE  FISH_MOD_SW USING lp MAXIMIZING SECT_PROFIT;


* ###############################
* #### REVENUES MODEL ###########
* #### need when changing CPUE_COD, then REV_2009/DAS not equal to REV_MOD/DAS


PARAMETER REVENUE_MOD(F), REVENUE_MOD_PEREFFORT(F);

REVENUE_MOD(F) =  sum{(S,AREA,P), (PRICES(F,S) * CATCH.L(F,S,AREA,P))*DISCOUNT_RATE(P)} ;
REVENUE_MOD_PEREFFORT(F)$(sum{P, EFFORT.L(F,P)}>0) = REVENUE_MOD(F)/sum{P, EFFORT.L(F,P)}  ;

DISPLAY REVENUE_MOD, REVENUE_MOD_PEREFFORT;


*#############################################################
*            CALCULTATE INDICATORS FROM RESULTS
*#############################################################


** obs att catch_2009 är per effort i ny version, nedan funkar inte!!!!!!!!
** ** ** ** ** ** **  2009 ** ** ** ** ** ** ** **

PARAMETERS REVENUE_2009, REVENUE_2009_SG1,REVENUE_2009_SG2,REVENUE_2009_SG3,
                         REVENUE_2009_SG4,REVENUE_2009_SG5,REVENUE_2009_SG6,
                         REVENUE_2009_SG7,REVENUE_2009_SG8,REVENUE_2009_SG9,
                         REVENUE_2009_SG10 ;

REVENUE_2009 =  sum{(F,S),PRICES(F,S)*CATCH_2009(F,S)} ;
REVENUE_2009_SG1 =  sum{(SEG1,S),PRICES(SEG1,S)*CATCH_2009(SEG1,S)} ;
REVENUE_2009_SG2 =  sum{(SEG2,S),PRICES(SEG2,S)*CATCH_2009(SEG2,S)} ;
REVENUE_2009_SG3 =  sum{(SEG3,S),PRICES(SEG3,S)*CATCH_2009(SEG3,S)} ;
REVENUE_2009_SG4 =  sum{(SEG4,S),PRICES(SEG4,S)*CATCH_2009(SEG4,S)} ;
REVENUE_2009_SG5 =  sum{(SEG5,S),PRICES(SEG5,S)*CATCH_2009(SEG5,S)} ;
REVENUE_2009_SG6 =  sum{(SEG6,S),PRICES(SEG6,S)*CATCH_2009(SEG6,S)} ;
REVENUE_2009_SG7 =  sum{(SEG7,S),PRICES(SEG7,S)*CATCH_2009(SEG7,S)} ;
REVENUE_2009_SG8 =  sum{(SEG8,S),PRICES(SEG8,S)*CATCH_2009(SEG8,S)} ;
REVENUE_2009_SG9 =  sum{(SEG9,S),PRICES(SEG9,S)*CATCH_2009(SEG9,S)} ;
REVENUE_2009_SG10 =  sum{(SEG10,S),PRICES(SEG10,S)*CATCH_2009(SEG10,S)} ;

PARAMETER VC_2009, VC_2009_SG1,VC_2009_SG2,VC_2009_SG3,
                   VC_2009_SG4,VC_2009_SG5,VC_2009_SG6,
                   VC_2009_SG7,VC_2009_SG8,VC_2009_SG9,
                   VC_2009_SG10 ;

VC_2009 =  sum(F, VARCOST(F)*EFFORT_2009(F))   ;
VC_2009_SG1 =  sum(SEG1, VARCOST(SEG1)*EFFORT_2009(SEG1))   ;
VC_2009_SG2 =  sum(SEG2, VARCOST(SEG2)*EFFORT_2009(SEG2))   ;
VC_2009_SG3 =  sum(SEG3, VARCOST(SEG3)*EFFORT_2009(SEG3))   ;
VC_2009_SG4 =  sum(SEG4, VARCOST(SEG4)*EFFORT_2009(SEG4))   ;
VC_2009_SG5 =  sum(SEG5, VARCOST(SEG5)*EFFORT_2009(SEG5))   ;
VC_2009_SG6 =  sum(SEG6, VARCOST(SEG6)*EFFORT_2009(SEG6))   ;
VC_2009_SG7 =  sum(SEG7, VARCOST(SEG7)*EFFORT_2009(SEG7))   ;
VC_2009_SG8 =  sum(SEG8, VARCOST(SEG8)*EFFORT_2009(SEG8))   ;
VC_2009_SG9 =  sum(SEG9, VARCOST(SEG9)*EFFORT_2009(SEG9))   ;
VC_2009_SG10 =  sum(SEG10, VARCOST(SEG10)*EFFORT_2009(SEG10))   ;

           PARAMETER FC_2009, FC_2009_SG1,FC_2009_SG2,FC_2009_SG3,
                   FC_2009_SG4,FC_2009_SG5,FC_2009_SG6,
                   FC_2009_SG7,FC_2009_SG8,FC_2009_SG9,
                   FC_2009_SG10     ;

FC_2009 =   sum(V, FIXCOST(V))  ;
FC_2009_SG1 =   FIXCOST("SG01")  ;
FC_2009_SG2 =   FIXCOST("SG02")  ;
FC_2009_SG3 =   FIXCOST("SG03")  ;
FC_2009_SG4 =   FIXCOST("SG04")  ;
FC_2009_SG5 =   FIXCOST("SG05")  ;
FC_2009_SG6 =   FIXCOST("SG06")  ;
FC_2009_SG7 =   FIXCOST("SG07")  ;
FC_2009_SG8 =   FIXCOST("SG08")  ;
FC_2009_SG9 =   FIXCOST("SG09")  ;
FC_2009_SG10 =   FIXCOST("SG10")  ;


PARAMETER PROFIT_2009, PROFIT_2009_SG1,PROFIT_2009_SG2,PROFIT_2009_SG3,
                   PROFIT_2009_SG4,PROFIT_2009_SG5,PROFIT_2009_SG6,
                   PROFIT_2009_SG7,PROFIT_2009_SG8,PROFIT_2009_SG9,
                   PROFIT_2009_SG10       ;

PROFIT_2009 = sum{(F,S),PRICES(F,S)*CATCH_2009(F,S)} - sum(F, VARCOST(F)*EFFORT_2009(F)) - sum(V, FIXCOST(V));
PROFIT_2009_SG1 = REVENUE_2009_SG1 - VC_2009_SG1 - FC_2009_SG1 ;
PROFIT_2009_SG2 = REVENUE_2009_SG2 - VC_2009_SG2 - FC_2009_SG2 ;
PROFIT_2009_SG3 = REVENUE_2009_SG3 - VC_2009_SG3 - FC_2009_SG3 ;
PROFIT_2009_SG4 = REVENUE_2009_SG4 - VC_2009_SG4 - FC_2009_SG4 ;
PROFIT_2009_SG5 = REVENUE_2009_SG5 - VC_2009_SG5 - FC_2009_SG5 ;
PROFIT_2009_SG6 = REVENUE_2009_SG6 - VC_2009_SG6 - FC_2009_SG6 ;
PROFIT_2009_SG7 = REVENUE_2009_SG7 - VC_2009_SG7 - FC_2009_SG7 ;
PROFIT_2009_SG8 = REVENUE_2009_SG8 - VC_2009_SG8 - FC_2009_SG8 ;
PROFIT_2009_SG9 = REVENUE_2009_SG9 - VC_2009_SG9 - FC_2009_SG9 ;
PROFIT_2009_SG10 = REVENUE_2009_SG10 - VC_2009_SG10 - FC_2009_SG10 ;


DISPLAY   REVENUE_2009,  REVENUE_2009_SG1,REVENUE_2009_SG2,REVENUE_2009_SG3,
                         REVENUE_2009_SG4,REVENUE_2009_SG5,REVENUE_2009_SG6,
                         REVENUE_2009_SG7,REVENUE_2009_SG8,REVENUE_2009_SG9,
                         REVENUE_2009_SG10

         VC_2009, VC_2009_SG1,VC_2009_SG2,VC_2009_SG3,
                  VC_2009_SG4,VC_2009_SG5,VC_2009_SG6,
                   VC_2009_SG7,VC_2009_SG8,VC_2009_SG9,
                   VC_2009_SG10,

         FC_2009, FC_2009_SG1,FC_2009_SG2,FC_2009_SG3,
                   FC_2009_SG4,FC_2009_SG5,FC_2009_SG6,
                   FC_2009_SG7,FC_2009_SG8,FC_2009_SG9,
                   FC_2009_SG10,

         PROFIT_2009,PROFIT_2009_SG1,PROFIT_2009_SG2,PROFIT_2009_SG3,
                   PROFIT_2009_SG4,PROFIT_2009_SG5,PROFIT_2009_SG6,
                   PROFIT_2009_SG7,PROFIT_2009_SG8,PROFIT_2009_SG9,
                   PROFIT_2009_SG10   ;





PARAMETER CATCH_F_S(F,S) ;
CATCH_F_S(F,S)= SUM((A,P),CATCH.L(F,S,A,P)) ;
DISPLAY CATCH_F_S ;



PARAMETER CATCH_S(S,A) ;
CATCH_S(S,A)= SUM((F,P),CATCH.L(F,S,A,P)) ;


PARAMETER        CATCHDIFF(S,A)
                 CATCHDIFF_PROC(S,A) ;
CATCHDIFF(S,A) = TAC_MOD(S,A)- CATCH_S(S,A) ;
CATCHDIFF_PROC(S,A) $(TAC_MOD(S,A) > 0) = CATCHDIFF(S,A)/TAC_MOD(S,A)*100 ;

* Statistics for 2009 about costs and revenues, obs calculated from parameters
PARAMETER REVENUE_2009_PEREFFORT(F)  ;
PARAMETER PROFIT_2009_PEREFFORT(F)  ;

**** old data input **** REVENUE_2009_PEREFFORT(F) = sum{S,PRICES(F,S)*CATCH_2009(F,S)}/EFFORT_2009(F) ;
REVENUE_2009_PEREFFORT(F) = sum{S,PRICES(F,S)*CATCH_2009(F,S)/1000} ;
PROFIT_2009_PEREFFORT(F) = REVENUE_2009_PEREFFORT(F)-VARCOST(F) ;

DISPLAY CATCH_S, CATCHDIFF, CATCHDIFF_PROC,  REVENUE_2009_PEREFFORT, REVENUE_2009;

DISPLAY VARCOST, FIXCOST, CPUE, VESSELS.L, SECT_PROFIT.L, EFFORT.L ;

DISPLAY CATCH_2009, PRICES ;

** ** ** EFFORT ** ** **

parameters
 K_TR2_opt,K_GN1_opt, S_TR1_opt, S_TR2_opt,  S_GN1_opt,  S_LL1_opt, K_RIST_opt, S_RIST_opt ;

*K_TR1_opt  =  sum{(K_TR1,P), EFFORT.l(K_TR1,P)*KWH_PER_VESSEL(K_TR1)}     ;
K_TR2_opt  =  sum{(K_TR2,P), EFFORT.l(K_TR2,P)*KWH_PER_VESSEL(K_TR2)}     ;
K_GN1_opt   =  sum{(K_GN1,P), EFFORT.l(K_GN1,P)*KWH_PER_VESSEL(K_GN1)}     ;
*K_GT1_opt   =  sum{(K_GT1,P), EFFORT.l(K_GT1,P)*KWH_PER_VESSEL(K_GT1)}     ;
S_TR1_opt =  sum{(S_TR1,P), EFFORT.l(S_TR1,P)*KWH_PER_VESSEL(S_TR1)}     ;
S_TR2_opt =  sum{(S_TR2,P), EFFORT.l(S_TR2,P)*KWH_PER_VESSEL(S_TR2)}     ;
S_GN1_opt  =  sum{(S_GN1,P), EFFORT.l(S_GN1,P)*KWH_PER_VESSEL(S_GN1)}     ;
*S_GT1_opt  =  sum{(S_GT1,P), EFFORT.l(S_GT1,P)*KWH_PER_VESSEL(S_GT1)}     ;
S_LL1_opt  =  sum{(S_LL1,P), EFFORT.l(S_LL1,P)*KWH_PER_VESSEL(S_LL1)}     ;
K_RIST_opt   =  sum{(K_RIST,P), EFFORT.l(K_RIST,P)*KWH_PER_VESSEL(K_RIST)}     ;
S_RIST_opt   =  sum{(S_RIST,P), EFFORT.l(S_RIST,P)*KWH_PER_VESSEL(S_RIST)}     ;

display  K_TR2_opt,K_GN1_opt, S_TR1_opt, S_TR2_opt, S_GN1_opt,  S_LL1_opt, K_RIST_opt, S_RIST_opt ;





*#############################################################
*            WRITE TO EXCEL
*#############################################################
*$ontext

* Dump results to GDX file

execute_unload "results.gdx", CATCH.L, VESSELS.L, CATCH_F_S, SECT_PROFIT, EFFORT.L, VARCOST, REVENUE_2009_PEREFFORT, VC_LAB_ALTLAB, REVENUE_MOD_PEREFFORT,
                             K_TR2_opt, K_GN1_opt, S_TR1_opt, S_TR2_opt, S_GN1_opt, S_LL1_opt, K_RIST_opt, S_RIST_opt, TAC_STOCK.M, BIO_MAX.M, ON_OFF ;

* Write GAMS results to Excel file from GDX file
* Excel file must have same name as gdx file, otherwise one is created
* Data is placed in first sheet if no sheet_name specified
* Merge is used to apend data only, variable labels must be present starting in top-left cell refeered to
execute '=gdxxrw.exe results.gdx par=CATCH_F_S O=E:\E_GAMS_Fiskemodell2009\outputfiles\FishMod2009_Res.xlsx rng=Catch!e4 clear';
execute '=gdxxrw.exe results.gdx equ=TAC_STOCK.M O=E:\E_GAMS_Fiskemodell2009\outputfiles\FishMod2009_Res.xlsx rng=Catch!e251 clear ';
execute '=gdxxrw.exe results.gdx equ=BIO_MAX.M   O=E:\E_GAMS_Fiskemodell2009\outputfiles\FishMod2009_Res.xlsx rng=Catch!q251 clear ';


* write VESSELS levels to "Newsheet" with specified range
execute '=gdxxrw.exe results.gdx var=VESSELS.L     O=E:\E_GAMS_Fiskemodell2009\outputfiles\FishMod2009_Res.xlsx rng=Vessels!b18 clear';
execute '=gdxxrw.exe results.gdx var=SECT_PROFIT.L O=E:\E_GAMS_Fiskemodell2009\outputfiles\FishMod2009_Res.xlsx rng=Vessels!b1 ';
execute '=gdxxrw.exe results.gdx var=EFFORT.L O=E:\E_GAMS_Fiskemodell2009\outputfiles\FishMod2009_Res.xlsx rng=Vessels!e25 clear';

* write to Excel: Utilized effort in Västerhavet (VH)
*execute '=gdxxrw.exe results.gdx par=K_TR1_opt    O=E:\E_GAMS_Fiskemodell2009\outputfiles\FishMod2009_Res.xlsx rng=Vessels!f3 clear';
execute '=gdxxrw.exe results.gdx par=K_TR2_opt    O=E:\E_GAMS_Fiskemodell2009\outputfiles\FishMod2009_Res.xlsx rng=Vessels!f4 clear';
execute '=gdxxrw.exe results.gdx par=K_GN1_opt    O=E:\E_GAMS_Fiskemodell2009\outputfiles\FishMod2009_Res.xlsx rng=Vessels!f6 clear';
*execute '=gdxxrw.exe results.gdx par=K_GT1_opt    O=E:\E_GAMS_Fiskemodell2009\outputfiles\FishMod2009_Res.xlsx rng=Vessels!f7 clear';
execute '=gdxxrw.exe results.gdx par=S_TR1_opt    O=E:\E_GAMS_Fiskemodell2009\outputfiles\FishMod2009_Res.xlsx rng=Vessels!f9 clear';
execute '=gdxxrw.exe results.gdx par=S_TR2_opt    O=E:\E_GAMS_Fiskemodell2009\outputfiles\FishMod2009_Res.xlsx rng=Vessels!f10 clear';
execute '=gdxxrw.exe results.gdx par=S_GN1_opt    O=E:\E_GAMS_Fiskemodell2009\outputfiles\FishMod2009_Res.xlsx rng=Vessels!f12 clear';
*execute '=gdxxrw.exe results.gdx par=S_GT1_opt    O=E:\E_GAMS_Fiskemodell2009\outputfiles\FishMod2009_Res.xlsx rng=Vessels!f13 clear';
execute '=gdxxrw.exe results.gdx par=S_LL1_opt    O=E:\E_GAMS_Fiskemodell2009\outputfiles\FishMod2009_Res.xlsx rng=Vessels!f14 clear';
execute '=gdxxrw.exe results.gdx par=K_RIST_opt    O=E:\E_GAMS_Fiskemodell2009\outputfiles\FishMod2009_Res.xlsx rng=Vessels!f15 clear';
execute '=gdxxrw.exe results.gdx par=S_RIST_opt    O=E:\E_GAMS_Fiskemodell2009\outputfiles\FishMod2009_Res.xlsx rng=Vessels!f16 clear';


*$ontext
* write economic data to "revenue and cost" observe that this is not from the optimization
execute '=gdxxrw.exe results.gdx par=VARCOST O=E:\E_GAMS_Fiskemodell2009\outputfiles\FishMod2009_Res.xlsx rng=revenue_cost!l9 clear';
execute '=gdxxrw.exe results.gdx par=VC_LAB_ALTLAB O=E:\E_GAMS_Fiskemodell2009\outputfiles\FishMod2009_Res.xlsx rng=revenue_cost!l14 clear';
execute '=gdxxrw.exe results.gdx par=REVENUE_2009_PEREFFORT O=E:\E_GAMS_Fiskemodell2009\outputfiles\FishMod2009_Res.xlsx rng=revenue_cost!l7 clear';
execute '=gdxxrw.exe results.gdx par=ON_OFF O=E:\E_GAMS_Fiskemodell2009\outputfiles\FishMod2009_Res.xlsx rng=revenue_cost!l17 clear';
execute '=gdxxrw.exe results.gdx par=REVENUE_MOD_PEREFFORT O=E:\E_GAMS_Fiskemodell2009\outputfiles\FishMod2009_Res.xlsx rng=revenue_cost!l21 clear';
*$offtext
