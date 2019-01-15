$setlocal percentChange %1

$ifi "%percentChange%"=="" $abort "You must provide a percentage change in subsidy (in %system.fn%)"

p_subsidyBudget = p_subsidyBudget * (1 + %percentChange%/100);