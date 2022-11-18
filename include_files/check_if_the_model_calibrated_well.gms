$onText
    @purpose: Check if the model calibrated well by comparing est and sim


$offtext

scalar p_relTolCal "Relative tolerance for OK calibration" /0.0001/;


* --- For v_effortAnnual

parameter p_diffEffort(fisheryDomain,statItem) "Deviation beween calibration and simulation for Effort";

p_diffEffort(f,"est") = p_fiskResultat(f,"allSpecies","v_effortAnnual","est");

p_diffEffort(f,"sim") = p_fiskResultat(f,"allSpecies","v_effortAnnual","sim");

p_diffEffort(f,"diffE")
    $ p_diffEffort(f,"est")
    = p_diffEffort(f,"sim")/p_diffEffort(f,"est")-1;
    
*  Delete all "rows" where the relative deviation is less than the tolerance for acceptance
p_diffEffort(f,statItem) $ [abs(p_diffEffort(f,"diffE")) lt p_relTolCal] = 0;

problem_fishery(f) = yes $ p_diffEffort(f,"diffE");

if(card(problem_fishery),
    abort "ERROR: Some fishery does not calibrate within tolerance", problem_fishery, p_diffEffort;
else
    display "Calibration test for v_effortAnnual passed successfully at the following tolerance", p_relTolCal;
);


* --- For v_catch

parameter p_diffCatch(speciesDomain,statItem) "Deviation beween calibration and simulation for Catch";

p_diffCatch(s,"est") = p_fiskResultat("total",s,"v_catch","est");

p_diffCatch(s,"sim") = p_fiskResultat("total",s,"v_catch","sim");

p_diffCatch(s,"diffE")
    $ p_diffCatch(s,"est")
    = p_diffCatch(s,"sim")/p_diffCatch(s,"est")-1;
    
*  Delete all "rows" where the relative deviation is less than the tolerance for acceptance
p_diffCatch(s,statItem) $ [abs(p_diffCatch(s,"diffE")) lt p_relTolCal] = 0;

problem_species(s) = yes $ p_diffCatch(s,"diffE");

if(card(problem_species),
    abort "ERROR: The catch of some species does not calibrate within tolerance", problem_species, p_diffCatch;
else
    display "Calibration test for v_catch passed successfully at the following tolerance", p_relTolCal;
);
