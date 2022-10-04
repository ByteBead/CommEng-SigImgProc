# 使用Matlab计算逆变器输出电压的THD

*本文已参与「新人创作礼」活动，一起开启掘金创作之路。*

## 0.要求

有一数字信号处理系统的作用是计算逆变器输出电压的THD（Total Harmonic Distortion，总谐波失真或谐波总畸变率），计算方法是除基波外各次谐波幅值的平方和再开根号，然后与基波（50Hz）幅值的比值即为THD。

要求如下：

+ 系统计算的最高次谐波是18次谐波；

+ 采样数据已提供，在data.mat中，采样频率5000Hz，共5万个点，可用load命令读入；

+ 设计一个低通滤波器（m语言编程或matlab自带工具箱），滤除采样数据中高于最高次谐波的频率，滤波后的数据再用来计算THD；

+ 请用MATLAB语言完成一个函数来计算电压的THD，输出参数为THD计算结果，函数的输入参数为电压采样值*x*；

+ 计算过程中注意结合课程中所讲过的信号处理方法，如去除直流分量、移动平均滤波、分段求频谱再平均等方法；

+ 要求有信号时域波形图（取200点）、滤波前信号的频谱图、滤波后信号的频谱图等；

## 1 使用load读取信号

````matlab
load data.mat
Fs = 5000;                      
T = 1/Fs;              
L = length(data);  
````

## 2 使用fft函数绘制信号的单边频谱

相关代码如下：

```matlab
% 绘制输入信号频谱
Yin = fft(data);
P2In = abs(Yin/L);
P1In = P2In(1:L/2+1);
P1In(2:end-1) = 2*P1In(2:end-1);
fIn = Fs*(0:(L/2))/L;
plot(fIn,P1In) 
title('滤波前信号的频谱图')
xlabel('f (Hz)')
ylabel('单侧幅值频谱|P1(f)|')
```

得到结果如下：

<img src="https://nas.comtech.work:5541/2022/09/13_%E8%BE%93%E5%85%A5%E4%BF%A1%E5%8F%B7%E7%9A%84%E9%A2%91%E8%B0%B1.jpg" alt="输入信号的频谱" style="zoom:50%;" />

## 3 选择合适的滤波器

FIR滤波器是有限长单位冲激响应滤波器，又称为非递归型滤波器，是数字信号处理系统中最基本的元件，它可以在保证任意幅频特性的同时具有严格的线性相频特性。同时其单位抽样响应是有限长的，因而滤波器是稳定的系统。

由于输入的信号是逆变器输出电压，需要满足线性相位，故这里使用FIR滤波器。

设计并应用滤波器的代码如下。

```Matlab
% 2 
% 使用低通滤波器处理信号
% 最高次谐波是18次谐波，通带0-900Hz，阻带950Hz
Fpass = 900;
Fstop = 950;
Ap = 1;
Ast = 30;
lowpassfirFilter = designfilt('lowpassfir','PassbandFrequency',Fpass,...
  'StopbandFrequency',Fstop,'PassbandRipple',Ap,...
  'StopbandAttenuation',Ast,'SampleRate',Fs);
% fvtool(lowpassfirFilter,"Fs",Fs);
dataOut = filtfilt(lowpassfirFilter,data);
```

生成滤波器的幅频响应和相频响应图如下：

![滤波器](https://nas.comtech.work:5541/2022/09/13_%E6%BB%A4%E6%B3%A2%E5%99%A8.png)

## 4. 绘制输出信号的频谱

做图方式同步骤2，得到滤波后信号频谱如下，不难发现19及更高次谐波已被过滤。

<img src="https://nas.comtech.work:5541/2022/09/13_%E8%BE%93%E5%87%BA%E4%BF%A1%E5%8F%B7%E7%9A%84%E9%A2%91%E8%B0%B1.jpg" alt="输出信号的频谱" style="zoom:50%;" />

对应以下程序，为了方便对比，将滤波前函数的频谱和滤波后的频谱进行对比。

```matlab
% 3
% 滤波后信号的频谱图
Yout = fft(dataOut);
P2Out = abs(Yout/L);
P1Out = P2Out(1:L/2+1);
P1Out(2:end-1) = 2*P1Out(2:end-1);
fOut = Fs*(0:(L/2))/L;
figure(1)
subplot(1,2,1)
plot(fIn,P1In) 
title('滤波前信号的频谱图')
xlabel('f (Hz)')
ylabel('单侧幅值频谱|P1(f)|')
subplot(1,2,2)
plot(fOut,P1Out) 
title('滤波后信号的频谱图')
xlabel('f (Hz)')
ylabel('单侧幅值频谱|P1(f)|'
```

![滤波效果对比](https://nas.comtech.work:5541/2022/09/13_%E6%BB%A4%E6%B3%A2%E6%95%88%E6%9E%9C%E5%AF%B9%E6%AF%94.jpg)

## 5. 用 MATLAB 语言编写一个函数来计算电压的 THD的函数

为了确保自己编写的thd函数的正确性，首先使用Matlab的函数thd求解。

![matlab提供的函数返回结果](https://nas.comtech.work:5541/2022/09/13_matlab%E6%8F%90%E4%BE%9B%E7%9A%84%E5%87%BD%E6%95%B0%E8%BF%94%E5%9B%9E%E7%BB%93%E6%9E%9C.jpg)

接着介绍如何自己实现thd函数。

首先对输入的信号进行移动平均值滤波。

定义滤波阶数为meanFitLeval。第n个点的数据为第n-meanFitLeval个点至第n点的平均值。

````Matlab
% 移动平均值滤波 
    meanFitLeval = 23;
    myDataMean = dataOut*0;
    myDataMean(1:meanFitLeval) = dataOut(1:meanFitLeval);
    i = meanFitLeval+1;
    while i<length(dataOut)
        myDataMean(i) = sum(dataOut(i-meanFitLeval:i))/meanFitLeval;
        i=i+1;
    end
````

接着去除信号中的直流分量，将信号减去均值。

```Matlab
 % 去除直流分量
    myDataMeanAC = myDataMean-mean(myDataMean); 
```

做出去除直流分量并进行平均值滤波后的信号与原始信号的对比图。

````matlab
figure(3)
hold on;
plot((1:200)/Fs,vthSig(1:200));
plot((1:200)/Fs,data(1:200));
xlabel('时间')
ylabel('输出电压')
legend("移动平均值滤波+去除直流后的信号","原始信号")
hold off;
````

![信号处理前后对比](https://nas.comtech.work:5541/2022/09/13_%E4%BF%A1%E5%8F%B7%E5%A4%84%E7%90%86%E5%89%8D%E5%90%8E%E5%AF%B9%E6%AF%94.jpg)

使用分段求频谱再平均的方法优化thd的计算。将输入信号按时间分为10组，求出各组信号的fft结果，并取平均值，最后根据公式计算thd值。

```Matlab
% 分段求频谱再平均,输入信号分为10组
    lengthOfPart  = length(myDataMeanAC)/10;
    fftPart = zeros(1,lengthOfPart);
    for i=1:10
        thisPart = myDataMeanAC(1+lengthOfPart*(i-1):lengthOfPart*i);
        fftPart = fftPart + abs(fft(thisPart));
    end
    fftPart = fftPart/10;
    P2fftPart = abs(fftPart/lengthOfPart);
    P1fftPart = P2fftPart(1:lengthOfPart/2+1);
    P1fftPart(2:end-1) = 2*P1fftPart(2:end-1);
    ansfftPart = Fs*(0:(lengthOfPart/2))/lengthOfPart;
    % 求thd
    sumf218 = 0;
    for i=3:18
        sumf218 =  sumf218+P1fftPart(i*50+1)^2;
    end
    VthdMy  = 10*log10(sqrt(sumf218)/P1fftPart(50+1));
```

计算得对于输入信号的前18次谐波的THD值，Matlab thd函数结果为-12.059dB，自行实现的 thd函数结果为-12.067dB，自行实现的函数误差在合理范围内，满足要求。

    "Matlab Thd=-12.059dB My Thd=-12.067dB"
    "Matlab Thd=0.062 My Thd=0.062"
