$ONTEXT

    @purpose: Scenario file for fisk, with no change from calibration point

    @author: Torbj�rn Jansson, Staffan Waldo

    @date: 2013-09-23

    @calledby: prototyp.gms

$OFFTEXT

*   S�tt alla kvoter till noll, vilket inneb�r "ingen kvot finns".
p_TAC_MOD(quotaSpecies,quotaArea) = 0;