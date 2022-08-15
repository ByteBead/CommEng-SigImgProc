clear;
tspan = [0,10];   % 横轴t区间
i0 = -6;         % 初始值为0
% 求解微分方程
% d(i(t))+4*i(t)=0
[t1,it] = ode45('f_it',tspan,i0); 
plot(t1,it);
xlabel('时间, s')
ylabel('i(t)')
title('通过微分方程求解通过C的电流i')
