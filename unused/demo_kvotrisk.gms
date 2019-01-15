PARAMETERS
    MC      Marginalkostnad (kronor per kg) /50/
    Pin     Pris inom kvot (kronor per kg) /100/
    Pout    Pris utom kvot (kronor per kg) /10/
    sdev    Standardavvikelse av fångst (ton) /5/
    s       Parameter i fördelningsfunktionen
    C       Integrationskonstant i fördelningsfunktionen
    kvot    Fiskekvot (ton) /100/
    ;

VARIABLES
    v_catch Planerad fångst
    v_rev   Intäkter
    v_cost  Kostnader
    v_qcost Förväntad kostnad för kvotöverskridande
    v_profit    Förväntad vinst

*   Extra variabler för analys av resultaten
    v_mc    Marginalkostnad vid planerad fångst
    v_mr    Förväntad marginalintäkt vid planerad fångst
    ;

EQUATIONS
    e_rev   Intäkter till marknadspris
    e_cost  Rörliga kostnader
    e_qcost Förväntad kostnad för kvotöverskridande
    e_profit    Förväntad vinst

*   Extra ekvationer för analys av resultaten
    e_mc    Marginalkostnad vid planerad fångst
    e_mr    Marginalintäkt vid planerad fångst
    ;

e_profit ..
    v_profit =E= v_rev - v_cost - v_qcost;

e_rev ..
    v_rev =E= Pin*v_catch;

e_cost ..
    v_cost =E= MC*v_catch;

e_qcost ..
    v_qcost =E= (Pin-Pout)*(s*LOG[EXP(kvot/s)+EXP(v_catch/s)] + C);

*   Block av ekvationer för analys av resultaten

e_mc ..
    v_mc =E= MC;

e_mr ..
    v_mr =E= Pin
           - (Pin-Pout)*1/[1+EXP(-(v_catch-kvot)/s)];


MODEL m_kvotrisk /ALL/;

*   Beräkna den logistiska fördelningens parametrar utifrån givna data
s = SQRT(3)*sdev/PI;
C = -s*LOG(EXP(kvot/s)+1);
DISPLAY s,C;

SOLVE m_kvotrisk USING NLP MAXIMIZING v_profit;