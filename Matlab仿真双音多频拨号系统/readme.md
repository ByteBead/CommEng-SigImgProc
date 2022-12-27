# Matlab仿真双音多频拨号系统

本文介绍了如何使用Matlab仿真双音多频拨号系统，并通过Goertzel算法节约频谱分析的计算量。

## 背景介绍

双音多频 (DTMF) 信令是语音通信控制的基础，在世界范围内广泛用于在现代电话通讯中拨打号码和配置交换机。双音多频 (DTMF) 信令也用于语音邮件、电子邮件和电话银行等系统。

一个 DTMF 信号由两个正弦波（即音调）的总和组成，频率取自两个互斥的组。选择这些频率是为了防止接收器将任何谐波错误地检测为其他 DTMF 频率。每对音调包含一个低组频率（697 Hz、770 Hz、852 Hz、941 Hz）和一个高组频率（1209 Hz、1336 Hz、1477 Hz），并表示唯一符号。分配给电话拨号盘按钮的频率如下所示：

![img](https://ww2.mathworks.cn/help/signal/ug/dftestimationexample_01_zh_CN.png)

本文基于以上频率的拨号按钮进行仿真。

## 相关函数介绍

Matlab官方在<a href='https://ww2.mathworks.cn/help/signal/ug/dft-estimation-with-the-goertzel-algorithm.html?searchHighlight=DTMF&s_tid=srchtitle_DTMF_2'>使用 Goertzel 算法进行 DFT 估计</a>这篇文章给出了双音多频 (DTMF) 信号的生成函数，本文利用这一函数生成按键音频，函数的相关信息如下:

+ 函数名 DTMFToneGenerator
+ 输入变量
  + symbol 按键序列
  + concatFlag 控制是否插入间隔
+ 输出变量
  + tones 音频信号
  + Fs 采样率
  + f  3*4 的 12组按键频率
  + lfg = [697 770 852 941] 四组低音的标准频率
  + hfg = [1209 1336 1477]  三组高音的标准频率

```matlab
function [tones, Fs, f, lfg, hfg] = DTMFToneGenerator(symbols, concatFlag)

% Copyright 2015 The MathWorks, Inc.
% Telephone pad symbols = {'1','2','3','4','5','6','7','8','9','*','0','#'}
% concatFlag 控制是否插入间隔
if  nargin < 2
  concatFlag = true;
end


lfg = [697 770 852 941]; % Low frequency group
hfg = [1209 1336 1477];  % High frequency group

% Generate 12 frequency pairs
% 这一段生成了 3*4 的 12组按键频率
f   = [reshape(ones(3,1)*lfg,1,12); repmat(hfg,1,4)];

% Generate DTMF tones
% 这一段声明了生成音频的相关参数 Fs 采样率 N 单个拨号的点数
% N/Fs = 0.1s 即 单个拨号0.1s
Fs  = 8000;       % Sampling frequency 8 kHz
N   = 800;        % Tones of 100 ms
t   = (0:N-1)/Fs; % 800 samples at Fs
pit = 2*pi*t;
tones = zeros(N,numel(symbols));
for i=1:numel(symbols),
    switch (symbols{i})
        case '1'
            tones(:,i) = sum(sin(f(:,1)*pit))';
        case '2'
            tones(:,i) = sum(sin(f(:,2)*pit))';
        case '3'
            tones(:,i) = sum(sin(f(:,3)*pit))';
        case '4'
            tones(:,i) = sum(sin(f(:,4)*pit))';
        case '5'
            tones(:,i) = sum(sin(f(:,5)*pit))';
        case '6'
            tones(:,i) = sum(sin(f(:,6)*pit))';
        case '7'
            tones(:,i) = sum(sin(f(:,7)*pit))';
        case '8'
            tones(:,i) = sum(sin(f(:,8)*pit))';
        case '9'
            tones(:,i) = sum(sin(f(:,9)*pit))';
        case '*'
            tones(:,i) = sum(sin(f(:,10)*pit))';
        case '0'
            tones(:,i) = sum(sin(f(:,11)*pit))';
        case '#'
            tones(:,i) = sum(sin(f(:,12)*pit))';
    end
end
if concatFlag
  % Insert pause between delays
  tones = [tones; 0.05*randn(N/8,numel(symbols))];
  tones = [0.05*randn(N/8,1); tones(:)];
end
```

## 实现程序

1. 创建相关按键音频并展示响应特性。

```matlab
symbol = {'1','2','3','4','5','6','7','8','9','*','0','#'};
[tones, Fs, f, lfg, hfg] = DTMFToneGenerator(symbol, false);

% 展示每个拨号音频的特性
N = 800;          % Tones of 100 ms
t = (0:N-1)/Fs;   % 800 samples at Fs
for toneChoice=1:12
    fftDraw(tones(:,toneChoice),Fs,...
        ['按键 "', symbol{toneChoice},'": [',num2str(f(1,toneChoice)),',',num2str(f(2,toneChoice)),']'])
end

```

以按键7为例展示时域和频域波形，其中频域波形还是使用fft实现的，并没有使用优化方法。

![双音多频拨号系统-按键7的波形图展示](https://pic.itrefer.com/2022/12/27_Screenshot-2022-12-27%2014.18.30.png)

注意，做图使用的fftDraw为自行编写并封装的函数，源码如下:

```matlab
function fftDraw(X,Fs,fftTitle)
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
    xlim([0 0.1])
    subplot(2,1,2);
    plot(f,P1) 
    title([fftTitle,'  频域'])
    xlabel('f (Hz)')
    ylabel('A')
end


```

2. 信号求解

求解此估计问题的一个常见方法是计算接近七个基本音调的离散时间傅里叶变换 (DFT) 采样。

对于基于 DFT 的解，已证明使用频域中的 205 个采样可以最小化原始频率和估计 DFT 的点之间的误差。

为了最小化原始频率和估计 DFT 的点之间的误差,我们截断音调，只保留 205 个采样或 25.6 毫秒用于进一步处理。

此时，我们可以使用快速傅里叶变换 (FFT) 算法来计算 DFT。然而，Goertzel 算法在这种情形下常用的原因是估计 DFT 所需的采样点数量少。在本例中，Goertzel 算法比 FFT 算法更高效。

Goertzel算法把离散傅立叶转换看成是一组滤波器，将输入的信号与滤波器中的脉冲响应做卷积运算，求的滤波器的输出。

Goertzel算法与离散傅立叶变换的相似处在于他们都可以分析某个特定频段的离散信号；不同之处在于，Goertzel算法每次迭代的运算都是使用实数的乘法。虽然说在全频域的计算上，Goertzel算法会比其他的傅立叶转换快速算法的复杂度来的高，但是它能区段式的分析每个小区段的频率组成，因此可以编写成较简单的运算架构，实际应用在处理器内的数值计算会更有效率。Goertzel算法逆向操作生成出弦波，而这个过程只需花费一个乘法和一个加法运算。

```matlab

tones = tones(1:205,:);
Nt = 205;
original_f = [lfg(:);hfg(:)];  % Original frequencies
k = round(original_f/Fs*Nt);   % Indices of the DFT
estim_f = round(k*Fs/Nt);      % Frequencies at which the DFT is estimated
figure;
for toneChoice = 1:12
    tone = tones(:,toneChoice);
    % Estimate DFT using Goertzel
    judge = abs(goertzel(tone,k+1)); % Goertzel uses 1-based indexing
    subplot(4,3,toneChoice),stem(estim_f,judge);
    title(['按键"', symbol{toneChoice},'": [',num2str(f(1,toneChoice)),',',num2str(f(2,toneChoice)),']'])
    xlim([650 1550]);
    if toneChoice>9
        xlabel('F (Hz)');
    end
end
```

下面展示的是对应于电话拨号盘的网格上每个音调的 Goertzel 的 DFT 幅值，这里没有用官方的做图函数做图。

![双音多频拨号系统-每个音调的 Goertzel 的 DFT 幅值](https://pic.itrefer.com/2022/12/27_Screenshot-2022-12-27%2014.29.14.png)

3. 自定义信号测试

```matlab
% 下面对中国的手机号进行简单的测试
% 192-1682-5500
[testSound, ~, ~, ~, ~] = DTMFToneGenerator({'1','9','2','1','6','8','2','5','5','0','0'}, false);
fprintf("下面对中国的手机号进行简单的测试 192-1682-5500\n");
key=[
    '1','2','3';
    '4','5','6';
    '7','8','9';
    '*','0','#'
    ];
fprintf("识别结果\n");
for index  = 1:11
    thisKey = testSound(1:205,index);
    judge = abs(goertzel(thisKey,k+1));
    zb=find(abs(judge)>50);
    fprintf("%c",key(zb(1),zb(2)-4));
end
fprintf("\n");
```

以下代码段可以播放真实的拨号声音。

```Matlab
for i = [1 9 2 1 6 8 2 5 5 11 11]
     p = audioplayer(tones(:,i),Fs,16);
     play(p)
     pause(0.5)
end
```

