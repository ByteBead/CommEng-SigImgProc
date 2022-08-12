format short
P = [50	100	200	400	800	1600 3200];
lgP = log10(P);
%%%%%%%
% debug = 1 测试模式 e取固定值
%%%%%%%
debug = 1;
if debug == 1
    e = [0.858	0.808	0.76	0.683	0.585	0.515	0.435];
else if debug ==2
        e = input("e=");
    end
end

% 设置 fittype 和选项。
ft = fittype( 'poly4' );
% 对数据进行模型拟合。
fitAns = fit( lgP', e', ft )
syms x;
% A1x^4+A2x^3+A3x^2+A4x+A5的方程式
f(x) = fitAns.p1*x^4 +fitAns.p2*x^3+fitAns.p3*x^2+fitAns.p4*x+fitAns.p5;
% 一阶求导
df(x) = diff(f(x),1);
% 二阶求导
d2f(x) = diff(f(x),2);
% 曲率
k(x) = abs(d2f(x))/((1+df(x)^2)^(3/2));
maxK_k = 0;
maxK_lgP = 0;
for indexlgP = log10(10):0.001:log10(3200)
   if k(indexlgP)>maxK_k
        maxK_lgP = indexlgP;
        maxK_k = k(indexlgP);
   end
end
fprintf("压力为P=%.2f时 孔隙比e=%.2f 曲率最大\n",10^maxK_lgP,maxK_k)
figure;
hold on;
semilogy(P, e)
semilogy(10^maxK_lgP,f(maxK_lgP),'*');
hold off;
xlabel("压力P")
ylabel("孔隙比e")
figure;
hold on;
plot(lgP, e)
plot(maxK_lgP,f(maxK_lgP),'*');
hold off;
xlabel("压力 lg(P)")
ylabel("孔隙比e")