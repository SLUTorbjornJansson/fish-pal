*-------------------------------------------------------------------------------
$ontext

   CAPRI project

   GAMS file : change_econComp_by_x_percent.gms

   @purpose  : Change economic compensation with X % from current 15 milj SEK and split according to economic loss due to seal interaction (%DAS with seal *catch value)
   @author   : Torbjörn Jansson, Staffan Waldo
   @date     : 17/09/18
   @since    :
   @refDoc   :
   @seeAlso  :
   @module   : scenario-components
   @calledBy :

$offtext
*-------------------------------------------------------------------------------

* HOW TO USE THIS FILE:
* ------------------------
* Include this file as "$batinclude"
* After the batinclude and file name, you provide a number, being the percentage change in seal compensation compared to current 15 milj SEK
* It is supposed to be percentage points.


* --- Take the batinclude-argument and give it a proper name
$setlocal p_additionalEconComp %1


* current economic compensation is 15'000'000 sek, or "15000" expressed in thousand SEK as in the parameter



ScenarioDummy_sealComp = 1 ;

*** restriction
*
   equation  e_sealComp      ;

    e_sealComp..
    SUM((f,s) $ fishery_species(f,s), p_ShareDASseal(f)*(  p_pricesA(f,s)*v_sortA(f,s) + p_pricesB(s)*p_landingObligation(f,s)*v_sortB(f,s))  )  =L= 15000 ;

*     keep in change_econComp in order to include e_sealComp in policy-eqautions. This definition replaces the one from "noChange"

     model m_policyEquations /e_effRestrSeg,e_effRestrFishery,e_catchQuota,
     e_effortPerEffortGroup, e_effortRegulation, e_sealComp /;





***** OLD
$ontext
* number of DAS with seal for each fishery
parameter p_sealDAS(fishery) ;
p_sealDAS(fishery) =  p_ShareDASseal(fishery)*p_effortOri(fishery) ;

*total number of DAS with seals all fisheries
parameter p_sealDAStot ;
p_sealDAStot = sum(fishery, p_sealDAS(fishery));

* each fishey's share of total DAS with seal
parameter p_sealCompAllocationKey(fishery) ;
p_sealCompAllocationKey(fishery) =   p_sealDAS(fishery) / p_sealDAStot ;

* each fishery is allocated additional seal compensation according to share of total DAS with seal in entire fishery
parameter p_totEcCompFishery(fishery);
p_totEcCompFishery(fishery) = p_sealCompAllocationKey(fishery)* %p_additionalEconComp% ;

* economic compensation for seals per DAS. Assumed to be constant even if DAS allocation changes in model simulation
parameter p_totEcCompDAS(fishery);
p_totEcCompDAS(fishery) =   p_totEcCompFishery(fishery)/ p_effortOri(fishery) ;



display     p_sealDAS, p_sealDAStot,   p_sealCompAllocationKey, p_totEcCompFishery, p_totEcCompDAS ;

$offtext

$ontext
parameter p_ShareDASseal(fishery) "Share of days at sea when seal damage is observed" /
1         .0209699
2         .1322957
3         .1742739
4         0
5         .2473404
6         0
7         .6105738
8         .1523179
9         .4933333
10        .0884956
11        0
12        .4852583
13        .6581248
14        .2121275
15        .3128008
16        .4857529
17        .5713476
18        .4251402
19        .2884615
20        .2932057
21        .0497945
22        .5235757
23        .0730858
24        .4316736
25        .4293389
26        .2313324
27        0
28        0
29        .1214154
30        0
31        0
32        .2848101
33        .101753
34        .2534351
35        .1667736
36        .0948478
37        .0230728
38        0
39        .0233918
40        0
41        .0322465
42        .074581
43        0
44        .1522694
45        .6
46        0
47        .0196995
48        .5647059
49        0
50        .1149335
51        .0132177
52        .0213772
53        0
54        .2554712
55        .3236515
56        0
57        .0857143
58        0
59        .4123711
60        .0151515
61        .1085271
62        .2214941
63        .0142857
64        .4650206
65        0
66        .7667732
67        .2184954
68        .3044327
69        0
70        0
71        0
72        0
73        0
74        .1641618
75        .3468255
76        .2408196
77        .5290576
78        .4455299
79        .7577938
80        .3192438
81        0
82        0
83        0
84        0
85        0
86        0
87        .0122433
88        0
89        0
90        .0930899
91        0
92        0
93        0
94        0
95        .125
96        .0153728
97        0
98        .2804428
99        .2054197
100       .0350877
101       .3714606
102       .5333334
103       .4520042
104       .131236
105       0
106       .2400443
107       .0540541
108       0
109       .4942529
110       .3623188
111       .3090909
112       0
113       0
114       .1714286
115       0
116       0
117       0
118       .3482587
119       .4102564
120       .3157895
121       .5714286
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
135       .7078261
136       0
137       0
138       .2916667
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
151       .5795454
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
164       .047619
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

$offtext