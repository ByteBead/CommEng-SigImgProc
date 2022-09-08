t = 32:0.001:52;
k = 6;
it = 2*sqrt(2).*cos(k*t);
Req = 1/((1/1)+(1/(-i*0.5))+(1/i));
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