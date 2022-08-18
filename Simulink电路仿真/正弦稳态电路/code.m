% 声明时间序列
t = 32:0.001:50;
% 采样率补偿
k = 6;
% 电流源电流 最大值为有效值的sqrt(2)倍
it = 2*sqrt(2).*cos(k*t);
% 求并联等效电阻
Req = 1/((1/1)+(1/(-i*0.5))+(1/i));
% 求电压
ut = 2*sqrt(2)*abs(Req).*cos(k*t+angle(Req))/10;
figure;
subplot(2,1,2);
plot(t,it);
xlabel('t/s')
ylabel('i(t)/A')
subplot(2,1,1);
plot(t,ut);
xlabel('t/s')
ylabel('U(t)/v')
