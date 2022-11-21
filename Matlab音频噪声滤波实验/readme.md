# 使用Matlab完成的音频噪声滤波实验

本文介绍了一个使用Matlab完成的音频噪声滤波实验，设计了FIR、IIR两种滤波器，对多频噪声进行了低通滤波。

## 1.要求

读入一段音乐信号在信号中分别加入以下几种噪声：

+ 白噪声
+ 单频噪声
+ 多频噪声

绘出叠加噪声前后的语音信号时域波形和频谱

选用Matlab中的两种数字滤波器对被污染的语音信号进行滤波

分析滤波后信号的频谱，画出滤波后信号的时域波形和频谱

## 2.实现过程

1.使用audioread函数读取音频

```matlab
clear;
clc;
% letSound = 1 启用声音播放 不建议
letSound = 0;
[music,Fs] = audioread('.\testMusic.mp3');
% 取单声道
musicSingle=  music(:,1);
% noiseLeval 噪音强度 -2dB
noiseLeval = 10^(-2/10);
```

2.创建并叠加噪声

正弦干扰的表达式为 $sin(2π*f*t)$

对于离散系统，时间序列为 $(1-length)/Fs$     $Fs为采样率$ 

```Matlab
% 高斯白噪声
whiteNoise = (2*rand(length(musicSingle),1)-1)*noiseLeval;
% 时间序列
t = (1:length(musicSingle))'/Fs;
% 噪声 200Hz
noise200 = noiseLeval*sin(2*pi*(200)*t);
% 15kHz 17kHz 19kHz 正弦信号
noise17k = noiseLeval*sin(2*pi*(17*10^3)*t);
noise19k = noiseLeval*sin(2*pi*(19*10^3)*t);
noise15k = noiseLeval*sin(2*pi*(15*10^3)*t);

plotFFT(musicSingle,Fs,'原始音频')

addWhiteNoise = musicSingle+whiteNoise;
plotFFT(addWhiteNoise,Fs,'原始音频+白噪声')

addNosise200 = musicSingle+noise200;
plotFFT(addNosise200,Fs,'原始音频+200Hz正弦干扰')

addNosiseMix = musicSingle+noise15k+noise17k+noise19k;
plotFFT(addNosiseMix,Fs,'原始音频+多频率噪声')

if letSound == 1
    sound(musicSingle,Fs);
    sound(addWhiteNoise,Fs);
    sound(addNosise200,Fs);
    sound(addNosiseMix,Fs);
end
```

3.设计滤波器并滤波

使用了FIR和IIR滤波器进行滤波。

+ FIR具有线性相位、容易设计的优点。
+ 设计同样参数的滤波器，FIR 比 IIR 需要更多的参数。

归一化频率计算公式为   $f/(Fs/2)$

+ Fs 为采样率
+ 单位 $π(rand/sample)$

![IIR滤波器](https://nas.itrefer.com:5541/2022/11/16_image16685860313970.png)

![FIR滤波器](https://nas.itrefer.com:5541/2022/11/16_image16685859896050.png)

```Matlab
% 12kHz 低通IIR滤波器 16阶
[b,a] = butter(16,(12*10^3)/(Fs/2));
dataOutButter = filter(b,a,addNosiseMix);
figure;
freqz(b,a,[],Fs)
title('12kHz 低通IIR滤波器')
plotFFT(dataOutButter,Fs,'带多频噪声信号通过IIR低通滤波器')


% 12kHz 低通FIR滤波器 40阶
bhi = fir1(40,(12*10^3)/(Fs/2),'low');
figure;
freqz(bhi,1)
title('12kHz 低通FIR滤波器')

dataOutFIR = filter(bhi,1,addNosiseMix);
plotFFT(dataOutFIR,Fs,'带多频噪声信号通过FIR低通滤波器')

if letSound == 1
    sound(dataOutButter,Fs);
    sound(dataOutFIR,Fs);
end

audiowrite("addWhiteNoise.wav",addWhiteNoise,Fs)
audiowrite("addNosise200.wav",addNosise200,Fs)
audiowrite("addNosiseMix.wav",addNosiseMix,Fs)
audiowrite("dataOutButter.wav",dataOutButter,Fs)
audiowrite("dataOutFIR.wav",dataOutFIR,Fs)
```

## 3.附 FFT 快速傅立叶变换 时域和频域做图函数

```matlab
function plotFFT(X,Fs,fftTitle)
    L = length(X);
    Y = fft(X);
    P2 = abs(Y/L);
    P1 = P2(1:L/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    f = Fs*(0:(L/2))/L;
    figure;
    subplot(2,1,1);
    plot((1:L)/Fs,X) 
    title([fftTitle,'  时域'])
    xlabel('t/s')
    ylabel('A')
    subplot(2,1,2);
    plot(f,P1) 
    title([fftTitle,'  频域'])
    xlabel('f (Hz)')
    ylabel('A')
end
```

![原始音频图](https://nas.itrefer.com:5541/2022/11/16_image16685864638160.png)

![原始音频+多频率噪声图](https://nas.itrefer.com:5541/2022/11/16_image16685864422510.png)

![信号通过滤波器](https://nas.itrefer.com:5541/2022/11/16_image16685860872440.png)