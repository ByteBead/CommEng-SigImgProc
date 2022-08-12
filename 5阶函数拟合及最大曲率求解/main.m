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
% 曲率一阶导数
dk(x) = diff(k(x));
% 求曲率的极值点
dkxs = double(solve(dk));
ansDkx = 0;
% 求曲率的最大值点
ansMax = 0;
for index = 1:length(dkxs)
    fprintf("极值点 P=%.2f k=%.2f\n",10^dkxs(index,1),dk(dkxs(index,1)))
    if ansMax<dk(dkxs(index,1))
        ansMax=dk(dkxs(index,1));
        ansDkx=dkxs(index);
    end
end
fprintf("压力为P=%.2f时 孔隙比e=%.2f 曲率最大\n",10^ansDkx,f(ansDkx))

% 做图 对数图
figure;
lineIndex = 1:0.01:3.8;
semilogx(10.^lineIndex, f(lineIndex))
hold on;
semilogx(10.^lgP, e,'.')
semilogx(10.^ansDkx,f(ansDkx),'*');
hold off;
xlabel("压力P")
ylabel("孔隙比e")
pointMsg = sprintf("(%.2f,%.2f)",10.^ansDkx,f(ansDkx));
text(10.^ansDkx,f(ansDkx),pointMsg,'EdgeColor','red');

% 做图 lg图
figure;
hold on;
lineIndex = 1:0.01:3.8;
plot(lineIndex, f(lineIndex))
plot(lgP, e,'.')
plot(ansDkx,f(ansDkx),'*');
hold off;
xlabel("压力 lg(P)")
ylabel("孔隙比e")
pointMsg = sprintf("(%.2f,%.2f)",ansDkx,f(ansDkx));
text(ansDkx,f(ansDkx),pointMsg,'EdgeColor','red');
