$ONTEXT
    A MINLP model for HPD implemented with BARON

    The primal model to estimate is a simple LP model:

    MINIMIZE        x'C
    SUBJECT TO      x'A =< b
                    x >= 0

    We assume that x and C are observed with disturbances errX and errC,
    and that we have priors for A and b, p(A) and p(b), and also for the
    error terms.


   y
    |
    | \        /
    |  \      /
    |   \  o /
    |    \  /
    |     \/
    |     /\
   _|____/__\________
    |   /    \      x



    @author: Torbjörn Jansson, SLU

$OFFTEXT

SETS
    r Restrictions /r1,r2/;


PARAMETERS
    p_obsX   "Observed exogenous"
    p_obsY   "Observed endogenous"
    p_a(r)   "Use delivery or use of resource r per unit of exogenous"
    p_b(r)   "Fix endowment of resource r"
    p_c      "Value of endogenous in objective"
    p_d      "Value of endogenous in objective"
    p_wErrX
    p_wErrY
    ;

VARIABLES
*   Variables of primal model
    v_z         "Variable to optimize, be it primal or dual"
    pv_x        "Estimated x"
    v_y         "Estimated y"

*   Variables of dual model
    pv_a(r)     "Estimated use of restriction j by activity i"
    pv_b(r)     "Estimated endowment of j"
    pv_c        "Estimated contribution of y to agent's objective"
    pv_d        "Estimated contribution of x to agent's objective"
    v_errX
    v_errY
    v_slack(r)  "Slack of resource r"
    v_lambda(r) "Estimated dual of restriction for resource r"

*   MINLP specifics
    v_hasSlack(r) "Binary choice if restriction has slack or not"
;

POSITIVE VARIABLES v_slack, v_lambda;

BINARY VARIABLE v_hasSlack;



EQUATIONS
    e_primObje  "Objective function of primal model"
    e_constr(r) "Constraint r"

    e_hpdObj    "Objective function of posterior mode (hpd) estimator"
    e_focY      "First order condition w.r.t. y"
    e_cs(r)     "Complementary slackness of restriction r"
    e_errY      "Definition of error in Y"
    e_errX      "Definition of error in X"

    e_csBinSlack(r)  "Binary version of complementary slackness condition for restriction r (slack part)"
    e_csBinLambda(r)  "Binary version of complementary slackness condition for restriction r (lambda part)"
;


* Primal model: linear objective function and linear constraints
e_primObje ..
    v_z =E= v_y*pv_c + pv_x*pv_d;

e_constr(r) ..
    v_y - pv_a(r)*pv_x - pv_b(r) =E= v_slack(r);

* Econometric model: posterior density function, Karush-Kuhn-Tucker and aux..

e_hpdObj ..
    v_z =E=
*   Log of prior density for error x
            p_wErrX*SQR(v_errX)
*   Log of prior density for c
        +   p_wErrY*SQR(v_errY)

    ;

e_focY ..
    pv_c - SUM(r, v_lambda(r)) =E= 0;

e_cs(r) ..
    v_lambda(r)*v_slack(r) =E= 0;

e_errY ..
    p_obsY =E= v_y + v_errY;

e_errX ..
    p_obsX =E= pv_x + v_errX;

e_csBinSlack(r) ..
    v_slack(r) =L= v_hasSlack(r)*1000;

e_csBinLambda(r) ..
    v_lambda(r) =L= (1-v_hasSlack(r))*1000;


MODEL m_primal "Simple LP model" /e_primObje, e_constr/;
MODEL m_hpdEst "Highest posterior density estimator" /e_hpdObj, e_constr, e_focY, e_cs, e_errX, e_errY/;
MODEL m_hpdBin "Estimation solved with binary MINLP algorithm" /e_hpdObj, e_constr, e_focY, e_csBinSlack, e_csBinLambda, e_errX, e_errY/;
*   Använd styrfilen som heter "baron.opt" för att ställa in solverns beteende (använd conopt för NLP-problemet).
m_hpdBin.optfile = 1;

*   Construct true data
p_a("r1") =  1;
p_a("r2") = -1;

p_b("r1") = -1;
p_b("r2") =  3;

p_c = 1;
p_d = 0;

pv_x.FX = 3;

*   Test true model

pv_a.FX(r) = p_a(r);
pv_b.FX(r) = p_b(r);
pv_c.FX    = p_c;
pv_d.FX    = p_d;

SOLVE m_primal USING NLP MINIMIZING v_z;


*   Errors on x and y are equally heavy
p_wErrY = 1;
p_wErrX = 1;

*   Let estimator determine x freely
pv_x.LO = -INF;
pv_x.UP =  INF;

*   Invent observations for x and y

p_obsX = 3;
p_obsY = 3;

SOLVE m_hpdEst USING NLP MINIMIZING v_z;

p_obsX = 1.5;
p_obsY = 2;

SOLVE m_hpdEst USING NLP MINIMIZING v_z;

OPTION MINLP=BARON;

SOLVE m_hpdBin USING MINLP MINIMIZING v_z;
OPTION v_z:6;
DISPLAY v_z.l;


