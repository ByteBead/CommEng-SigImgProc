# Matlab使用最小二乘法拟合电气信号的谐波分量

*本文已参与「新人创作礼」活动，一起开启掘金创作之路。*

## 原理

这种算法是将输入的暂态电气量与一个预设的含有非周期分量及某些谐波分量的函数按最小二乘法（或称最小平方误差）的原理进行我合，使被处理的函数与预设函数尽可能逼近，其总方差 $E^2$或最小均方差 $(E_{min})/N$为最小，从而可求出输入信号中的基频及各种暂态分量的幅值和相角。

## 实现过程

首先假定在故障时，输人暂态电流、电压中包含有非周期分量及小于5次谐波的各整次倍的谐波。这样，以电流为例，可以将一预设的电流时间函数取为。

$i(t)=p_0e^{-\lambda t}+\displaystyle \sum^{5}_{k=1}{p_ksin(kw_1t+\theta_k)}$

由于函数展开$e^{-\lambda t}=1-\lambda t+{(\lambda t)}^2/2!+O({(\lambda t)}^2)$

取展开式的前2项，则$i(t)$可以表达为

$i(t)=p_0-p_0\lambda t+\displaystyle \sum^{5}_{k=1}{p_ksin(kw_1t)cos(\theta_k)}+\displaystyle \sum^{5}_{k=1}{p_kcos(kw_1t)sin(\theta_k)}$

不难发现，我们需要拟合以下12个变量，分别为

$p_0,-p_0t,p_{1,2,...,k}cos(\theta_{1,2,...,k}),p_{1,2,...,k}cos(\theta_{1,2,...,k})$

```matlab
mtitle = "测试函数";
t = 2:0.01:2.2;
% 声明时间序列
w1 = 30;
%iData = 100*sin(1.3*w1.*t+pi/4)+50*exp(-t/0.1);
iData = 160*sin(0.9*w1.*t+pi/5)+150*exp(-t/0.1).*sin(3.4*w1.*t+pi/4);
%用最小二乘求解非线性曲线拟合（数据拟合）问题（lsqcurvefit函数）
fun = @(fit,t)fit(1)...
    -fit(2).*t...
    +sin(1*w1.*t)*fit(3)...
    +sin(2*w1.*t)*fit(4)...
    +sin(3*w1.*t)*fit(5)...
    +sin(4*w1.*t)*fit(6)...
    +sin(5*w1.*t)*fit(7)...
    +cos(1*w1.*t)*fit(8)...
    +cos(2*w1.*t)*fit(9)...
    +cos(3*w1.*t)*fit(10)...
    +cos(4*w1.*t)*fit(11)...
    +cos(5*w1.*t)*fit(12);
% 声明需要拟合函数参数的初始值以加快收敛
x0 = ones(1,12)*max(iData)*0.8;
% 使用最小二乘法拟合
fit = lsqcurvefit(fun,x0,t,iData);
% 计算拟合的电流
fitData = fun(fit,t);
% 做图
figure;
hold on;
plot(t,iData);
plot(t,fitData);
legend('测量值',"最小二乘法拟合值");
xlabel("时间t/s")
ylabel("电流I/A")
title(mtitle);
hold off;

% 频率 k*w/2/pi 相角(弧度)deg 幅值p1
p1 = sqrt(fit(3)^2+fit(8)^2);
deg1 = asin(fit(3)/p1);
p2 = sqrt(fit(4)^2+fit(9)^2);
deg2 = asin(fit(4)/p1);
formatSpec = '基波频率%.2f(Hz) 相角(弧度)%.2f 幅值%.4f\n';
fprintf(formatSpec,w1/(2*pi),deg1,p1);
formatSpec = '二次谐波频率%.2f(Hz) 相角(弧度)%.2f 幅值%.4f\n';
fprintf(formatSpec,w1*2/(2*pi),deg2,p2);
```

## 结果如下

![Screenshot-2022-10-04 21.18.14](https://nas.itrefer.com:5541/2022/10/04_Screenshot-2022-10-04%2021.18.14.png)

## 参考文献截图

![readMe](https://nas.itrefer.com:5541/2022/10/04_readMe.JPG)
