# Matlab和Simulink实现卷积的演示

两个信号的卷积，可以理解为是先将一个信号翻转，然后进行滑动叠加。

也可以理解为在输入信号的每个位置叠加对应时延和幅度的单位响应。对于线性时不变系统，如果知道该系统的单位响应，那么将单位响应和输入信号求卷积，就相当于把输入信号的各个时间点的单位响应 加权叠加，就直接得到了输出信号。

本文介绍了如何使用Matlab展示两个门函数序列进行卷积，以及如何在Simulink搭建一个对应的模型。

## Matlab实现门函数序列卷积

离散函数卷积公式如下：

<img src="https://www.itrefer.com/pictureBed/2022/11/29_Screenshot-2022-11-29%2015.08.40.png" alt="离散函数卷积公式" style="zoom:80%;" />

Matlab相关函数如下：

+ conv函数实现卷积
+ stem函数绘制离散序列图
+ xlim限制做图的序列范围

```matlab
% 离散信号-门函数卷积
% 门函数1的长度
lx1 = 3;
% 门函数1的坐标范围
index1 = 0:lx1;    
% 门函数1的值
sig1 = ones(1,lx1+1); 

% 门函数2的生成方法同1
lx2 = 4;
index2 = 0:lx2;     
sig2 = ones(1,lx2+1);

% 声明卷积后的门函数坐标序列
ansIndex=0:lx1+lx2;  
% 使用conv卷积相关门函数
y=conv(sig1,sig2);

% 做图
figure;  
subplot(3,1,1); 
% stem用于离散信号做图
stem(index1,sig1);
% 限制坐标范围
xlim([0 lx1+lx2])
xlabel('n');
ylabel('g1(n)');
title('门函数1 g1(n)');

subplot(3,1,2);
stem(index2,sig2);
xlim([0 lx1+lx2])
xlabel('n');
ylabel('g2(n)');
title('门函数2 g2(n)');

subplot(3,1,3);  
stem(ansIndex,y);
xlim([0 lx1+lx2])
xlabel('n');
ylabel('y(n)');
title('线性卷积 g1(n)*g2(n)');
```

<img src="https://www.itrefer.com/pictureBed/2022/11/29_demo2.jpg" alt="Matlab门函数序列卷积" style="zoom: 67%;" />

## Simulink模拟门函数序列卷积

涉及的4个模块如下：

+ Constant模块  [1 1 1 0] [1 1 1 1] 

+ Convolution模块  提供卷积功能
+ Display模块 显示卷积所得结果

<img src="https://www.itrefer.com/pictureBed/2022/11/29_demo3.png" alt="Simulink模拟离散序列卷积" style="zoom:67%;" />
