Sets
    i "Plants"  /1*19/
    c "Carriers" /1*1540/
    p "Products" /1*2036/
    r "Ports" /1*11/
    o 'Order' /1*9216/
    k 'customer'/1*47/

    ;
Table U(i,r) 'assignment ports to plants'

            1             2        3        4        5        6        7        8        9        10      11
1           1             1        0        0        0        0        0        0        0        0        0
2           0             0        1        0        0        0        0        0        0        0        0
3           0             0        0        1        0        0        0        0        0        0        0
4           0             0        0        0        1        0        0        0        0        0        0
5           0             0        0        0        0        1        0        0        0        0        0
6           0             0        0        0        0        1        0        0        0        0        0
7           1             1        0        0        0        0        0        0        0        0        0
8           0             0        0        1        0        0        0        0        0        0        0
9           0             0        0        1        0        0        0        0        0        0        0
10          1             1        0        0        0        0        0        0        0        0        0
11          0             0        0        1        0        0        0        0        0        0        0
12          0             0        0        1        0        0        0        0        0        0        0
13          0             0        0        1        0        0        0        0        0        0        0
14          0             0        0        0        0        0        1        0        0        0        0
15          0             0        0        0        0        0        0        1        0        0        0
16          0             0        0        0        0        0        0        0        1        0        0
17          0             0        0        0        0        0        0        0        0        1        0
18          0             0        0        0        0        0        0        0        0        0        1
19          0             0        0        1        0        0        0        0        0        0        0
;



Parameters    
$call gdxxrw.exe SCMDATA.xlsx par=A rng=ProductsPerPlant!A1:B2037
$call gdxxrw.exe SCMDATA.xlsx par=W rng=weightOrder!A1:D9216
$call gdxxrw.exe SCMDATA.xlsx par=S rng=costRate!A1:B1541
$call gdxxrw.exe SCMDATA.xlsx par=K rng=WhCosts!A1:B20
$call gdxxrw.exe SCMDATA.xlsx par=P rng=WhCapacities!A1:B20
$call gdxxrw.exe SCMDATA.xlsx par=Mn rng=minCarWeight!A1:B1541
$call gdxxrw.exe SCMDATA.xlsx par=Mx rng=maxCarWeight!A1:B1541
;
*=== Now import data from GDX
Parameter A(i, j);  "The plant i that can handle product p"
$gdxin SCMDATA.gdx
$load A
$gdxin

*=== Fix variables to values from Excel file
x.FX(i,j) = A(i,j);

*=== Now import data from GDX
Parameter  W(p,k,o); "Weight of product p  required by customer k in order o"
$gdxin SCMDATA.gdx
$load W
$gdxin

*=== Fix variables to values from Excel file
x.FX(p,k,o) = W(p,k,o);

*=== Now import data from GDX
Parameter     S(c);   "Shipping cost rate of carrier c"
$gdxin SCMDATA.gdx
$load S
$gdxin

*=== Fix variables to values from Excel file
x.FX(c) = S(c);


*=== Now import data from GDX
Parameter  K(i);   "Holding one unit product cost of plant i"
$gdxin SCMDATA.gdx
$load K
$gdxin

*=== Fix variables to values from Excel file
x.FX(i) = K(i);

*=== Now import data from GDX
Parameter  P(i); "Capacity of plants for products"
$gdxin SCMDATA.gdx
$load P
$gdxin

*=== Fix variables to values from Excel file
x.FX(i) = P(i);

*=== Now import data from GDX
Parameter  Mn(c);  "Minimum stroing weight of carrier c"
$gdxin SCMDATA.gdx
$load Mn
$gdxin

*=== Fix variables to values from Excel file
x.FX(c) = Mn(c);

*=== Now import data from GDX
Parameter  Mx(c);  "Maximum stroing weight of carrier c"
$gdxin SCMDATA.gdx
$load Mx
$gdxin

*=== Fix variables to values from Excel file
x.FX(c) = Mx(c);

;
Binary Variables
    X(p,c,i) "Whether product p is transported by carrier c from plant i";

Positive Variables
    Y(p,c,i) "Number of units of product p supplied by carrier c from plant i";

Equations
Objective
Cons1
Cons2
Cons3
Cons4
Cons5
Cons6
Cons7
Cons8
Cons9
Cons10
;

Objective.. minimize =e= sum(((i,p,c), Y(p,c,i)*K(i)) + (S(c)*X(p,c,i)*Q(p,k)))   ;

Cons1.. sum((c,i), Y(p,c,i)) =e= Q(p,k);

Cons2.. sum(i, X(p,c,i)) =l= 1;

Cons3.. X(p,c,i) =l= P(i);

Cons4.. sum((i,c), W(p,k)*Y(p,c,i)) =l= Mx(c)*X(p,c,i);

Cons5.. sum((p,c), Y(p,c,i)) =l= P(i);

Cons6.. sum((p,c), X(p,c,i)) =e= 1;

Cons7.. X(p,c,i) =l= A(i,r);

Cons8.. X(p,c,i) =l= B(k,i);

Cons9.. X(p,c,i) =l= H(c,r);

Cons10.. X(p,c,i) =e= 0 or 1;


Model SupplyChain /all/;


Solve SupplyChain using MIP minimizing Objective;
display x.l, x.m;