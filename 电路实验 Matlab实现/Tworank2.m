function yd=Tworank2(t,y)
    U=10;
    R1=4;
    R2=2;
    C=1;
    L=1;
    yd=[-(1/(R1*C))*y(1)-(1/C)*y(2)+(1/(R1*C))*U;(1/L)*y(1)-(R2/L)*y(2)];
end