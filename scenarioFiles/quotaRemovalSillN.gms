$ONTEXT

    @purpose: Scenario file for fisk, with no change from calibration point

    @author: Torbjörn Jansson, Staffan Waldo

    @date: 2013-09-23

    @calledby: prototyp.gms

$OFFTEXT

*   Sätt sillkvoten i Nordsjön till noll, vilket innebär "ingen kvot finns".
p_TAC_MOD("Sill","N") = 0;
