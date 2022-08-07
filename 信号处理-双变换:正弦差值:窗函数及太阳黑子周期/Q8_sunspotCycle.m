clear;
load('sunSpotData.mat')


Fs = 1;                   % Sampling frequency                    
T = 1/Fs;                 % Sampling period       
L = length(sunSpotData)+1;  % Length of signal

Y = fft(sunSpotData);
% 计算双侧频谱 P2。然后基于 P2 和偶数信号长度 L 计算单侧频谱 P1。

P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end) = 2*P1(2:end);
% 定义频域 f 并绘制单侧幅值频谱 P1。

f = Fs*(0:(L/2))/L;
P1(1) = 0;
figure;
plot(1./f,P1) 
xlabel('周期(Year)')
ylabel('单侧幅值')
title('太阳黑子活动周期强度图')

[maxA,indexMax] = max(P1);
fSun = 1/f(indexMax);
fprintf("测得太阳黑子的周期是%.2f年\n",fSun)


whamming = designfilt('lowpassfir','FilterOrder',100,'CutoffFrequency',0.0283,...
  'SampleRate',1,'Window','hamming');

wblackman = designfilt('lowpassfir','FilterOrder',100,'CutoffFrequency',0.0283,...
  'SampleRate',1,'Window','blackman');

wrectwin = designfilt('lowpassfir','FilterOrder',100,'CutoffFrequency',0.0283,...
  'SampleRate',1,'Window','rectwin');

% hfvt = fvtool(whamming,wblackman,wrectwin);
% legend(hfvt,'Hamming window', 'Blackman window', 'Rectwin window')

sigHamming = filtfilt(whamming,sunSpotData);
sigBlackman = filtfilt(wblackman,sunSpotData);
sigRectwn = filtfilt(wrectwin,sunSpotData);

figure;
subplot(2,2,1);
plot(sunSpotData);
plot(1./f,P1) 
xlabel('周期(Year)')
ylabel('单侧幅值')
title('太阳黑子活动周期强度图')


subplot(2,2,2);
Y = fft(sigHamming);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(L/2))/L;
P1(1) = 0;
plot(1./f,P1) 
xlabel('周期(Year)')
ylabel('单侧幅值')
title('通过窗函数Hamming太阳黑子活动周期强度图')

subplot(2,2,3);
Y = fft(sigBlackman);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(L/2))/L;
P1(1) = 0;
plot(1./f,P1) 
xlabel('周期(Year)')
ylabel('单侧幅值')
title('通过窗函数Blackman太阳黑子活动周期强度图')

subplot(2,2,4);
Y = fft(sigRectwn);
P2 = abs(Y/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = Fs*(0:(L/2))/L;
P1(1) = 0;
plot(1./f,P1) 
xlabel('周期(Year)')
title('通过窗函数Rectwn太阳黑子活动周期强度图')
[maxA,indexMax] = max(P1);
fSun = 1/f(indexMax);
fprintf("测得太阳黑子的第二周期是%.3f年\n",fSun)
P1(indexMax) = 0;
[maxA,indexMax] = max(P1);
fSun = 1/f(indexMax);
fprintf("测得太阳黑子的第三周期是%.3f年\n",fSun)