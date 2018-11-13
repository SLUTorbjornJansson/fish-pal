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
ACTIVEPASSIVE "ACTIVE AND PASSIVE HAVE SEPARATE QUOTAS" /1/ ;

*$stop
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
CPUEincrease_herring_181 /0/
CPUEincrease_sprat_199 /0/
CPUEincrease_herring_199 /0/
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

DISPLAY "datDir = %datDir%";

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

i=%datDir%\data_gams_TJ.xlsx


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

r37=VESSELS!segment;segmentLabel
o37=segment.inc

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
$include segment.inc
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

SET SEGMENT_FISHERY(SEGMENT,FISHERY) "Definition of which fisheries belong to each segment";

SEGMENT_FISHERY(SEGMENT,FISHERY) = YES $ [SUBSETS(FISHERY,'SEGKOD') EQ ORD(SEGMENT)];

DISPLAY SEGMENT_FISHERY;
*$STOP

* fill subsets with content, segkod=column in subset matrix, row=fisheries



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

SET KWH_GROUP_FISHERY(kwh_group,FISHERY) "Vilket fiske hör till vilken kwh-grupp enligt EU:s effortreglering för Västerhavet" /
    K_TR2.(2,4,9,11,12,19,21,22, 32, 34, 35,45,46)
    K_GN1.(115,116, 117,118,133,149)
    S_TR1.(47, 57,58)
    S_TR2.(5, 7,8,13, 16,17,23,26,27,39,40,51,52,70,72,76,77,82,83)
    S_GN1.(122,123,135,136)
    S_LL1.(150)

*   Här tillkommer den svenska regleringen som fungerar på liknande vis
*    K_RIST.(3,10,20,33,44)
*    S_RIST.(1,6,15,25,38,50,66,69,75)
    /;

DISPLAY KWH_GROUP_FISHERY;


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

EFFRESTR(SEGMENT,P) = SUM{FISHERY $ SEGMENT_FISHERY(SEGMENT,FISHERY), MAX_EFF_F(FISHERY,P)};


PARAMETER MAX_FISHING_DAYS(SEGMENT) Maximala fiskedagar per segment och år;

MAX_FISHING_DAYS("DTS_KRÄFTA_0010")     =  0;
MAX_FISHING_DAYS("DTS_KRÄFTA_1012")     =  88;
MAX_FISHING_DAYS("DTS_KRÄFTA_1218")     =  101;
MAX_FISHING_DAYS("DTS_KRÄFTA_1824")     =  99;
MAX_FISHING_DAYS("DTS_1012")     =     35;
MAX_FISHING_DAYS("DTS_1218")     =     91;
MAX_FISHING_DAYS("DTS_1824")     =     90;
MAX_FISHING_DAYS("DTS_2440")     =     76;
MAX_FISHING_DAYS("DTS_RÄKA_1012")     =   64;
MAX_FISHING_DAYS("DTS_RÄKA_1218")     =   115;
MAX_FISHING_DAYS("DTS_RÄKA_1824")     =   162;
MAX_FISHING_DAYS("DTS_RÄKA_2440")     =   159;
MAX_FISHING_DAYS("FPO_KRÄFTA_0010")     =  98;
MAX_FISHING_DAYS("FPO_KRÄFTA_1012")     =  111;
MAX_FISHING_DAYS("FPO_0010")     =     142;
MAX_FISHING_DAYS("FPO_1012")     =     50;
MAX_FISHING_DAYS("PAS_0010")     =     169;
MAX_FISHING_DAYS("PAS_1012")     =     100;
MAX_FISHING_DAYS("PAS_1218")     =     94;
MAX_FISHING_DAYS("PTS_1824")     =     0;
MAX_FISHING_DAYS("PTS_2440")     =     124;
MAX_FISHING_DAYS("PTS_40XX")     =     149;
MAX_FISHING_DAYS("PTS_SIKL_1012")     =   16;
MAX_FISHING_DAYS("PTS_SIKL_1218")     =   25;

* ###############################
* #### Define model #############
* ###############################

$INCLUDE model_equations.gms


SOLVE  FISH_MOD_SW USING lp MAXIMIZING v_SECT_PROFIT;


* ###############################
* #### REVENUES MODEL ###########
* #### need when changing CPUE_COD, then REV_2009/DAS not equal to REV_MOD/DAS


PARAMETER REVENUE_MOD(F), REVENUE_MOD_PEREFFORT(F);

REVENUE_MOD(F) =  sum{(S,AREA,P), (PRICES(F,S) * v_CATCH.L(F,S,AREA,P))*DISCOUNT_RATE(P)} ;
REVENUE_MOD_PEREFFORT(F)$(sum{P, v_EFFORT.L(F,P)}>0) = REVENUE_MOD(F)/sum{P, v_EFFORT.L(F,P)}  ;

DISPLAY REVENUE_MOD, REVENUE_MOD_PEREFFORT;


*#############################################################
*            CALCULTATE INDICATORS FROM RESULTS
*#############################################################

$STOP
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
execute '=gdxxrw.exe results.gdx par=CATCH_F_S O=E:\E_GAMS_Fiskemodell2009\outputfiles\FishMod2009_Res_TJ.xlsx rng=Catch!e4 clear';
execute '=gdxxrw.exe results.gdx equ=TAC_STOCK.M O=E:\E_GAMS_Fiskemodell2009\outputfiles\FishMod2009_Res_TJ.xlsx rng=Catch!e251 clear ';
execute '=gdxxrw.exe results.gdx equ=BIO_MAX.M   O=E:\E_GAMS_Fiskemodell2009\outputfiles\FishMod2009_Res_TJ.xlsx rng=Catch!q251 clear ';


* write VESSELS levels to "Newsheet" with specified range
execute '=gdxxrw.exe results.gdx var=VESSELS.L     O=E:\E_GAMS_Fiskemodell2009\outputfiles\FishMod2009_Res_TJ.xlsx rng=Vessels!b18 clear';
execute '=gdxxrw.exe results.gdx var=SECT_PROFIT.L O=E:\E_GAMS_Fiskemodell2009\outputfiles\FishMod2009_Res_TJ.xlsx rng=Vessels!b1 ';
execute '=gdxxrw.exe results.gdx var=EFFORT.L O=E:\E_GAMS_Fiskemodell2009\outputfiles\FishMod2009_Res_TJ.xlsx rng=Vessels!e25 clear';

* write to Excel: Utilized effort in Västerhavet (VH)
*execute '=gdxxrw.exe results.gdx par=K_TR1_opt    O=E:\E_GAMS_Fiskemodell2009\outputfiles\FishMod2009_Res_TJ.xlsx rng=Vessels!f3 clear';
execute '=gdxxrw.exe results.gdx par=K_TR2_opt    O=E:\E_GAMS_Fiskemodell2009\outputfiles\FishMod2009_Res_TJ.xlsx rng=Vessels!f4 clear';
execute '=gdxxrw.exe results.gdx par=K_GN1_opt    O=E:\E_GAMS_Fiskemodell2009\outputfiles\FishMod2009_Res_TJ.xlsx rng=Vessels!f6 clear';
*execute '=gdxxrw.exe results.gdx par=K_GT1_opt    O=E:\E_GAMS_Fiskemodell2009\outputfiles\FishMod2009_Res_TJ.xlsx rng=Vessels!f7 clear';
execute '=gdxxrw.exe results.gdx par=S_TR1_opt    O=E:\E_GAMS_Fiskemodell2009\outputfiles\FishMod2009_Res_TJ.xlsx rng=Vessels!f9 clear';
execute '=gdxxrw.exe results.gdx par=S_TR2_opt    O=E:\E_GAMS_Fiskemodell2009\outputfiles\FishMod2009_Res_TJ.xlsx rng=Vessels!f10 clear';
execute '=gdxxrw.exe results.gdx par=S_GN1_opt    O=E:\E_GAMS_Fiskemodell2009\outputfiles\FishMod2009_Res_TJ.xlsx rng=Vessels!f12 clear';
*execute '=gdxxrw.exe results.gdx par=S_GT1_opt    O=E:\E_GAMS_Fiskemodell2009\outputfiles\FishMod2009_Res_TJ.xlsx rng=Vessels!f13 clear';
execute '=gdxxrw.exe results.gdx par=S_LL1_opt    O=E:\E_GAMS_Fiskemodell2009\outputfiles\FishMod2009_Res_TJ.xlsx rng=Vessels!f14 clear';
execute '=gdxxrw.exe results.gdx par=K_RIST_opt    O=E:\E_GAMS_Fiskemodell2009\outputfiles\FishMod2009_Res_TJ.xlsx rng=Vessels!f15 clear';
execute '=gdxxrw.exe results.gdx par=S_RIST_opt    O=E:\E_GAMS_Fiskemodell2009\outputfiles\FishMod2009_Res_TJ.xlsx rng=Vessels!f16 clear';


*$ontext
* write economic data to "revenue and cost" observe that this is not from the optimization
execute '=gdxxrw.exe results.gdx par=VARCOST O=E:\E_GAMS_Fiskemodell2009\outputfiles\FishMod2009_Res_TJ.xlsx rng=revenue_cost!l9 clear';
execute '=gdxxrw.exe results.gdx par=VC_LAB_ALTLAB O=E:\E_GAMS_Fiskemodell2009\outputfiles\FishMod2009_Res_TJ.xlsx rng=revenue_cost!l14 clear';
execute '=gdxxrw.exe results.gdx par=REVENUE_2009_PEREFFORT O=E:\E_GAMS_Fiskemodell2009\outputfiles\FishMod2009_Res_TJ.xlsx rng=revenue_cost!l7 clear';
execute '=gdxxrw.exe results.gdx par=ON_OFF O=E:\E_GAMS_Fiskemodell2009\outputfiles\FishMod2009_Res_TJ.xlsx rng=revenue_cost!l17 clear';
execute '=gdxxrw.exe results.gdx par=REVENUE_MOD_PEREFFORT O=E:\E_GAMS_Fiskemodell2009\outputfiles\FishMod2009_Res_TJ.xlsx rng=revenue_cost!l21 clear';
*$offtext
