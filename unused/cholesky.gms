$ontext
    Batinclude for Cholesky factorization
    @arguments inputMatrix outputMatrix indexSet

    If the program is called without arguments, it only declares parameters
$offtext

$setlocal DECLARE YES
$setlocal EXECUTE YES

*   Check if program is called without arguments
$if %1a==a $setlocal DECLARE YES
$if %1a==a $setlocal EXECUTE NO

*   If the symbols are already declared, that step is skipped
$if declared batCholInp $setlocal DECLARE NO

*   Declarations
$if %DECLARE%==NO $goto afterDeclarations
parameter batCholInp(*,*);
parameter batCholOut(*,*);
set batCholI /set.%3/;
alias(batCholI,batCholJ,batCholK);
alias(%3,batCholA);
set batCholUp(batCholI,batCholJ);
batCholUp(batCholI,batCholJ) $ [ord(batCholJ) gt ord(batCholI)] = yes;
$label afterDeclarations

*   Execution
$if %EXECUTE%==NO $goto afterExecution
batCholInp(%3,batCholA) = %1(%3,batCholA);
option kill = batCholOut;
loop(batCholI,
    batCholOut(batCholI,batCholI) = sqrt(batCholInp(batCholI,batCholI)
                                  -sum(batCholJ $ [ord(batCholJ) lt ord(batCholI)], sqr(batCholOut(batCholJ,batCholI))));
    loop(batCholJ $ batCholUp(batCholI,batCholJ),
        batCholOut(batCholI,batCholJ)
        = (batCholInp(batCholI,batCholJ)
        - sum(batCholK $ [ord(batCholK) lt ord(batCholI)], batCholOut(batCholK,batCholI)*batCholOut(batCholK,batCholJ)))
        / batCholOut(batCholI,batCholI);
    );
);
$label afterExecution

%2(%3,batCholA) = batCholOut(%3,batCholA);