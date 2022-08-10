function yd=DYDtR2(t,y)  %定义一个函数，函数名为DYDt50，t、y为输入变量
    U=20;
    R=10000;
    C=1e-6;
    yd=-(1/(R*C))*y(1)+(1/(R*C))*U;  %微分方程的公式
end
