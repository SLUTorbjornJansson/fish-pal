*-------------------------------------------------------------------------------
$ontext

   Fish Pal

   GAMS file :

   @purpose  : Remove costs for seal damage based on estimates of cost per DAS
   @author   : Torbj�rn Jansson, Staffan Waldo
   @date     : 05/03/18
   @since    :
   @refDoc   :
   @seeAlso  :
   @module   : scenario
   @calledBy :

$offtext
*-------------------------------------------------------------------------------

* HOW TO USE THIS FILE:
* ------------------------
* Include this file as "$batinclude"
* After the batinclude and file name, you provide a number, being the percentage change
* that you want to impose on cost.
* It is supposed to be percentage points.


* --- Take the batinclude-argument and give it a proper name
$setlocal SEAL_COST_CHANGE_RATE %1

* --- Check that it is not less than -100
if(%SEAL_COST_CHANGE_RATE% < -100,
    abort "ERROR: You tried to reduce cost by more than 100%, which is physically impossible! The argument was %SEAL_COST_CHANGE_RATE%";
)

* --- Check that there is an argument at all
$ifi "%SEAL_COST_CHANGE_RATE%"==""    $abort "ERROR: You must provide a batinclude-argument for %system.fn%."






* --- Enter data on seal cost per fishery and day

parameter p_SealCostPerDAS(fishery) "Cost of seal damage per day of effort for each fishery (1000 sek/day)" /

1         0.196842895
2         0.196842895
3         0.196842895
4         0.196842895
5         0.196842895
6         0.08662505
7         0.196842895
8         0.196842895
9         0.178595868
10        0.04809005
11        0
12        0.196842895
13        0.196842895
14        0.196842895
15        0.178595868
16        0.196842895
17        0.196842895
18        0.08662505
19        0.0006526
20        0.244811608
21        0.0006526
22        0.225941227
23        0.0006526
24        0.225941227
25        0.225941227
26        0.244811608
27        0.03514871
28        0.156066928
29        0.113771073
30        0.113771073
31        0.091546473
32        0.113771073
33        0.091546473
34        0.113771073
35        0.113771073
36        0.113771073
37        0.03514871
38        0.03514871
39        0.113771073
40        0.113771073
41        0.03514871
42        0.156066928
43        0.113771073
44        0.03514871
45        0
46        0
47        0.091546473
48        0.03514871
49        0.156066928
50        0.113771073
51        0.03514871
52        0.03514871
53        0.113771073
54        0.091546473
55        0.196842895
56        0.196842895
57        0.196842895
58        0.196842895
59        0.196842895
60        0.196842895
61        0.178595868
62        0.196842895
63        0.178595868
64        0.178595868
65        0.04809005
66        0.196842895
67        0.178595868
68        0.196842895
69        0.03514871
70        0.156066928
71        0.113771073
72        0.156066928
73        0.113771073
74        0.08662505
75        0.196842895
76        0.196842895
77        0.196842895
78        0.196842895
79        0.196842895
80        0.08662505
81        0.03514871
82        0.03514871
83        0.03514871
84        0.113771073
85        0
86        0
87        0.03514871
88        0.156066928
89        0.113771073
90        0.03514871
91        0
92        0
93        0.091546513
94        0.113771073
95        0.113771073
96        0.03514871
97        0.03514871
98        0.091546473
99        0.178595868
100       0.196842895
101       0.178595868
102       0.178595868
103       0.196842895
104       0.244811608
105       0.0006526
106       0.0006526
107       0.244811608
108       0
109       0.225941227
110       0.0006526
111       0.225941227
112       0.225941227
113       0.178595868
114       0.196842895
115       0.196842895
116       0.113771073
117       0.113771073
118       0.178595868
119       0.196842895
120       0.178595868
121       0.196842895
122       0
123       0
124       0
125       0
126       0
127       0
128       0
129       0
130       0
131       0
132       0
133       0
134       0
135       0
136       0
137       0
138       0
139       0
140       0
141       0
142       0
143       0
144       0
145       0
146       0
147       0
148       0
149       0
150       0
151       0
152       0
153       0
154       0
155       0
156       0
157       0
158       0
159       0
160       0
161       0
162       0
163       0
164       0
165       0
166       0
167       0
168       0
169       0
170       0
171       0
172       0
173       0
174       0
175       0
176       0
177       0
178       0
179       0
180       0
181       0
182       0
183       0
184       0
185       0
186       0
187       0
188       0
189       0
190       0
191       0
192       0
193       0
194       0
195       0
196       0
197       0
198       0
199       0
200       0
201       0
202       0
203       0
204       0
205       0
206       0
207       0
208       0
209       0
210       0
211       0
212       0
213       0
214       0
215       0
216       0
217       0
218       0
219       0
220       0
221       0
222       0
223       0
224       0
225       0
226       0
227       0
228       0
229       0
230       0
231       0
232       0
233       0
234       0
235       0
236       0
237       0
238       0
239       0
240       0
241       0
242       0
243       0
244       0
245       0
246       0
247       0
/;

* --- Change seal cost in variable costs

pv_varCostConst.FX(f) = pv_varCostConst.L(f) + p_SealCostPerDAS(f)*%SEAL_COST_CHANGE_RATE%/100;


* ------------------------------------------------------------------------------
* --- Assert that the variable costs are non-negative everywhere.
* ------------------------------------------------------------------------------

$setlocal ERROR_FILE "output\error_negative_costs.gdx"
set fishery_with_problem(fishery) "Fishery where some problem was detected";

fishery_with_problem(f) = yes $ [pv_varCostConst.l(f) lt 0];

if([card(fishery_with_problem) gt 0],
    execute_unload "%ERROR_FILE%";
    display "WARNING: Some fisheries have negative intercept terms for the variable costs in %system.fn%. Check pv_varCostConst.l in %ERROR_FILE%. Problem fisheries are: ", fishery_with_problem;
);

fishery_with_problem(f) = yes $ [(pv_varCostConst.l(f) + pv_varCostSlope.l(f)*p_effortOri(f)/2) lt 0];

if([card(fishery_with_problem) gt 0],
    execute_unload "%ERROR_FILE%";
    abort "ERROR: Some fisheries have negative average variable costs. That is senseless! Inspect all data in %system.fn% and in %ERROR_FILE%", fishery_with_problem;
);
