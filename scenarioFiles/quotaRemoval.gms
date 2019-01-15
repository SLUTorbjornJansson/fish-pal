$ONTEXT

    @purpose: Scenario file for fisk, with no change from calibration point

    @author: Torbjörn Jansson, Staffan Waldo

    @date: 2013-09-23

    @calledby: prototyp.gms

$OFFTEXT

*   Sätt alla kvoter till noll, vilket innebär "ingen kvot finns".
p_TAC_MOD(quotaSpecies,quotaArea) = 0;