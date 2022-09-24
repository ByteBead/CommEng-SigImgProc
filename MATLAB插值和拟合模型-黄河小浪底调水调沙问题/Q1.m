clear;
% 12 天 24组 数据
load("originData.mat")
sand= originData(:,1).*originData(:,2);
% 8:00/20:00
t = (12*(1:24)-4)*3600;
startTime = 8*3600;
endTime = (12*24-4)*3600;
% 三次样条插值
sandRe = csape(t,sand');
% 生成一个更长的以s为单位的时间序列
t1s = startTime:endTime;
sandRe1s = ppval(sandRe,t1s);
% 积分运算求总含沙量
sandOut=quadl(@(tt)fnval(sandRe,tt),startTime,endTime);   
%integral
figure(1);
hold on;
plot(t1s,sandRe1s,'b');
plot(t,sand,'*');
hold off;
legend('三次样条插值结果','观测站点采样值');
xlabel('时间/s')
ylabel('排沙量/m3')
title('排水排沙观测数据')
fprintf("总排沙量%.0fm3\n",sandOut)

sandOut=quadl(@(tt)fnval(sandRe,tt),startTime,3600*24);
fprintf("第%d天8:00-23:59排沙量%.0fm3\n",1,sandOut)
for i=2:11
    sandOut=quadl(@(tt)fnval(sandRe,tt),3600*24*(i-1),3600*24*(i));
    fprintf("第%d天排沙量%.0fm3\n",i,sandOut)
end
sandOut=quadl(@(tt)fnval(sandRe,tt),3600*24*11,endTime);
fprintf("第%d天0:00-20:00排沙量%.0fm3\n",12,sandOut);