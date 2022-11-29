## 1.任务描述

给出排水排沙观测数据，包含时间，水流量，含沙量三个参数，要求如下。

- 建立模型计算每天的排沙量。
- 确定排沙量与水流量的关系，并估计水流量为$2252m^3/s$和$2648m^3/s$时的排沙量。

## 2.建立模型计算每天的排沙量

+ **排沙量 = 水流量 * 含沙量** 

+ 由于排沙量是一个连续变量，故采用三次样条差值。

```matlab
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
```

结果如下<img src="https://nas.itrefer.com:5541/2022/09/22_Q1.jpg" alt="调沙问题-观测数据" style="zoom:67%;" />

```
总排沙量184398480000m3
第1天8:00-23:59排沙量5509491642m3
第2天排沙量14390833475m3
第3天排沙量18751414880m3
第4天排沙量22053814839m3
第5天排沙量25162472866m3
第6天排沙量26784351951m3
第7天排沙量26271841114m3
第8天排沙量22243210316m3
第9天排沙量12557316648m3
第10天排沙量6676062756m3
第11天排沙量3414695265m3
第12天0:00-20:00排沙量582974248m3
```

## 3.确定排沙量与水流量的关系，并估计指定水流量时的排沙量

为了确定水流量和排沙量的关系，我们参考了一下文献：

+ 王丹在《来水含沙量与过滤出水流量的回归分析》中使用了基于最小二乘法的线性拟合。

+ 同套文在《 基于LSTM深度学习的河流径流量及含沙量预测方法研究》中使用了深度学习的方法进行拟合。

由上两篇论文，我们可知，水流量和排沙量没有明确的解析表达式，但总体而言水流量和排沙量呈现正相关性。

我们采用多项式拟合的方法确定水流量和排沙量的关系，要求是

+ 水流量为最小值900时，排沙量为4500
+ 水流量大于0时，排沙量大于0
+ 拟合的多形式的导数在x>0时恒正

尝试了1-6次多形式，2次多项式满足要求且误差较小，Matlab代码如下。

````matlab
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
fprintf('拟合结果 %.2f*x^2%.2f+x%.2f\n',fitresult.p1,fitresult.p2,fitresult.p3++9156+4500);
% 绘制数据拟合图。
figure(2);
hold on;
plot(fitresult, dataSort(:,1), dataSort(:,2) )
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
````

一次多项式拟合

<img src="https://nas.itrefer.com:5541/2022/09/22_fit1.png" alt="调沙观测数据-一次多项式拟合" style="zoom:50%;" />

二次多项式拟合

<img src="https://nas.itrefer.com:5541/2022/09/22_fit2.png" alt="调沙观测数据-二次多项式拟合" style="zoom:50%;" />

四次多项式拟合

<img src="https://nas.itrefer.com:5541/2022/09/22_fit4.png" alt="调沙观测数据-四次多项式拟合" style="zoom:50%;" />

结论如下：

1. 拟合结果 $y=0.08*x^2-98.12x+29051.13$  (x:水流量 y:排沙量)
2. 水流量为时2252，估计排沙量$207267m^3/s$
3. 水流量为时2648，估计排沙量$321141m^3/s$

拟合曲线图如下。

<img src="https://nas.itrefer.com:5541/2022/09/22_Q2.jpg" alt="调沙观测数据-拟合曲线图" style="zoom:150%;" />