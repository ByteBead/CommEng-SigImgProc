clear;
% 12 天 24组 数据
load("originData.mat")
t = (12*(1:24)-4)*3600;
rSand = originData(:,2)';
waterFlow = originData(:,1)';
sand = (originData(:,1).*originData(:,2))';
data = zeros(2,24);
data(1,:) = waterFlow;
data(2,:) = sand;
data = data';
dataSort = sortrows(data,1);

%cftool(dataSort(:,1),dataSort(:,2))
% 设置 fittype 和选项。
ft = fittype( 'poly2' );
% 对数据进行模型拟合。
[fitresult, gof] = fit( dataSort(:,1), dataSort(:,2), ft );
fprintf('拟合结果 %.2fx^2 %.2fx + %.2f\n',fitresult.p1,fitresult.p2,fitresult.p3++9156+4500);
% 绘制数据拟合图。
figure(2);
hold on;
flowIndex = 800:2800;
flowAns = fitresult.p1 .*flowIndex.^2+fitresult.p2.*flowIndex + fitresult.p3+9156+4500;
plot(flowIndex,flowAns,'r')
plot(dataSort(:,1), dataSort(:,2),'x')
xlabel('水流量')
ylabel('排沙量')
legend('观测数值','拟合曲线','Location', 'NorthWest')
hold off;
syms x y
in = 2252;
ansIn = fitresult.p1 *in^2+fitresult.p2*in + fitresult.p3+9156+4500;
fprintf("水流量为时%d，估计排沙量%.0f\n",in,ansIn)
in = 2648;
ansIn = fitresult.p1 *in^2+fitresult.p2*in + fitresult.p3+9156+4500;
fprintf("水流量为时%d，估计排沙量%.0f\n",in,ansIn)