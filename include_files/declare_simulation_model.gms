EQUATIONS
*   Primal model equations
    e_objFunc "Objective function"
    e_catch(fishery,species)        "Catch of each fishery of each species"
    e_sortA(fishery,species)         "Sorting the catch into category A"
    e_sortB(fishery,species)         "Sorting the catch into category B"
    e_landings(fishery,species)
    e_discards(fishery,species)
    e_effRestrSeg(segment)          "Restriction on fishing effort per segment"
    e_effRestrFishery(fishery)      "Restriction on fishing effort per fishery"
    e_catchQuota(catchQuotaName,quotaArea) "Catch quotas per species and quota area"
    e_effortRegulation(effortGroup,area) "THE effort regulation (i V�sterhavet)"
    e_effortPerEffortGroup(effortGroup,area) "Computation of effort per effort group for use in THE effort regulation"

    e_reportVarCostAve(fishery) "Computation of average variable cost, for reporting independent of functional form for MC"

* Seal equation
    e_sealSubsidy              "restriction on total 'additional' seal subsidy in entire fishery compared to baseline"
    ;



VARIABLES
*   Primal model variables
    v_profit                        "Profits of fishery sector"
    v_varCostAve(fishery)           "Average variable cost over effort (Total variable cost/effort) per fishery"
    pv_varCostConst(fishery)        "Variable cost - intercept of MC function"
    pv_varCostSlope(fishery)        "Variable cost - slope of MC function"
    pv_PMPconst(f)                       "Calibration term (PMP)"
    pv_PMPslope(f)                       "Calibration term (PMP)"
    v_effortAnnual(fishery)         "Annual fishing effort per fishery"
    v_catch(fishery,species)        "Catch per fishery and species (tons/year)"
    v_sortA(fishery,species)        "Primary sorting. This is probably the species, size etc. that was the target of the fishery (tons/year)"
    v_sortB(fishery,species)        "Secondary sorting, economically inferior in terms of price or quota availability (tons/year)"
    v_landings(fishery,species)     "Landings (tons/year)"
    v_discards(fishery,species)     "Discards (tons/year)"
    v_vessels(segment)              "Number of vessels per segment, determining fixed costs"
    v_effortPerEffortGroup(effortGroup,area)
    pv_TACAdjustment(catchQuotaName,quotaArea) "Adjustment of quotas needed to fit to catches from observed fishing efforts"
    pv_delta(fishery,species)       "Scale of Cobb-Douglas production function, or rather: if catch=a*E^b1*S^b2, then delta=a*S^b2"
    pv_maxEffFishery(fishery)       "Max effort per fishery and period (days per vessel)"
    pv_kwh(segment)                 "Average engine power per segment estimated (kwh)"
    ;


** Seal parameter and variables
parameter  p_compRate                "share of the catch value eaten by seals that is compensated. 0.5 implies that half of the revenues foregone by seal pred is compensated"  /0/;
variable   v_sealSubsidy             "total seal subsidy"     ;


*   Effort and sorting variables must be positive
POSITIVE VARIABLES v_effort, v_sortA, v_sortB;


*-------------------------------------------------------------------------------
*   Primal model implementation
*-------------------------------------------------------------------------------

e_objFunc ..
    v_profit =E=
*       Revenues
        SUM((f,s) $ fishery_species(f,s), p_pricesA(f,s)*v_sortA(f,s) + p_pricesB(s)*p_landingObligation(f,s)*v_sortB(f,s))

*       plus subsidies
       +SUM(f, v_effortAnnual(f)*p_subsidyPerDAS(f))

*       minus variable costs
       -SUM(f, pv_varCostConst(f)*v_effortAnnual(f) + 1/2*pv_varCostSlope(f)*sqr(v_effortAnnual(f))
*       ... shifted by an exogenous change in price or quantity of each cost item, weighted with its share in VC
*           In the baseline scenario, the shifters must be zero and the shares add up to 1
               *SUM(VariableInput, p_varCostOriShare(f,VariableInput)
                       *(1 + p_varCostPriceShift(f,VariableInput))
                       *(1 + p_varCostQuantShift(f,VariableInput)))
            )

*       minus fixed costs
       -SUM(seg, p_fixCostSumOri(seg)*v_vessels(seg))

*       plus calibration term (PMP cost) depending on effort
       -SUM(f, pv_PMPconst(f)*v_effortAnnual(f) + 1/2*pv_PMPslope(f)*sqr(v_effortAnnual(f)))

        ;

e_catch(f,s) $ fishery_species(f,s) ..
    v_catch(f,s) =E=

*   times how catch changes (of all species) if effort changes
    pv_delta(f,s) * v_effortAnnual(f)**p_catchElasticity(f);

e_sortA(f,s) $ fishery_species(f,s) ..
    v_sortA(f,s) =E= p_shareA(f,s)*v_catch(f,s);

e_sortB(f,s) $ fishery_species(f,s) ..
    v_sortB(f,s) =E= p_shareB(f,s)*v_catch(f,s);


e_landings(f,s) $ fishery_species(f,s) ..
    v_landings(f,s) =E= v_sortA(f,s)+p_landingObligation(f,s)*v_sortB(f,s);

e_discards(f,s) $ fishery_species(f,s) ..
    v_discards(f,s) =E= [1-p_landingObligation(f,s)]*v_sortB(f,s);


e_effRestrSeg(seg) ..

*   Sum of fishery efforts carried out by this segment
    SUM(f $ segment_fishery(seg,f), v_effortAnnual(f))
    =L=
*   Number of vessels in fleet times max effort per vessel
    v_vessels(seg)*p_maxEffSeg(seg);


e_effRestrFishery(f) ..

*   Begr�nsning p� hur m�nga fiskedagar varje fishery kan g�ra i varje period
*   Begr�nsningen ber�knas utifr�n s�song (m�nadsbasis) och antal fartyg och
*   fiskedagar hos flottan som g�r detta fishery

    v_effortAnnual(f) =L= SUM(seg $ segment_fishery(seg,f), v_vessels(seg))*pv_maxEffFishery(f);


e_effortPerEffortGroup(effortGroup,area) $ p_maxEffortPerEffortGroup(effortGroup,area) ..

    v_effortPerEffortGroup(effortGroup,area)
        =E= sum(f $ [fishery_effortGroup(f,effortGroup) and fishery_area(f,area)],
                    v_effortAnnual(f) * sum(seg $ segment_fishery(seg,f), pv_kwh(seg)));

e_effortRegulation(effortGroup,area) $ p_maxEffortPerEffortGroup(effortGroup,area) ..

        v_effortPerEffortGroup(effortGroup,area)
            =L=
        p_maxEffortPerEffortGroup(effortGroup,area);


*   Om fiske ska f�rbjudas helt, s�tt kvoten till ngt litet positivt tal
*   Om ingen begr�nsning ska finnas, s�tt kvoten till "0" (ingen kvot).
e_catchQuota(catchQuotaName,quotaArea) $ (p_TACOri(catchQuotaName,quotaArea) GT 0) ..


*   Sum of catch for fishery active in the present area,
*    and all species caught that belong to this "quota species"
    SUM((f,s) $ catchQuotaName_quotaArea_fishery_species(catchQuotaName,quotaArea,f,s),
            v_landings(f,s))
    =L=
*   Quota for this quota species in this quota area
    p_TACOri(catchQuotaName,quotaArea)*pv_TACAdjustment(catchQuotaName,quotaArea);

*   Denna funktion är behändig att ha för att rapportering ska fungera oberoende av hur vi definierar variabla kostnader
*   Rapporteringen beh�ver bara lita p� att vi har skrivit r�tt v�rde p� varCostAve.
*   VarCostAve ing�r inte i optimalitetsvillkor eller begr�nsningar - det �r bara en rapportfunktion
e_reportVarCostAve(f)..
    v_varCostAve(f) =E= (pv_varCostConst(f) + 1/2*pv_varCostSlope(f)*v_effortAnnual(f))
    
*       ... shifted by an exogenous change in price or quantity of each cost item, weighted with its share in VC
*           In the baseline scenario, the shifters must be zero and the shares add up to 1
               *SUM(VariableInput, p_varCostOriShare(f,VariableInput)
                       *(1 + p_varCostPriceShift(f,VariableInput))
                       *(1 + p_varCostQuantShift(f,VariableInput)))    

    ;

e_sealSubsidy..
         v_sealSubsidy =E=
          SUM((f,s) $ fishery_species(f,s), [p_pricesA(f,s)*v_sortA(f,s) + p_pricesB(s)*p_landingObligation(f,s)*v_sortB(f,s)]*p_shareDASseal(f)*p_compRate );


MODEL m_coreEquations "The behavioural equations of the system"
    / e_objFunc,e_catch,e_sortA,e_sortB,e_landings,e_discards /;

MODEL m_reportingEquations "Equations that define handy variables that are not part of the objective or any constraint"
    / e_reportVarCostAve /;

