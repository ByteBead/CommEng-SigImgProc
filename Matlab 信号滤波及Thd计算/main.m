load data.mat
Fs = 5000;                      
T = 1/Fs;              
L = length(data);  


% 1 
% 绘制输入信号频谱
Yin = fft(data);
P2In = abs(Yin/L);
P1In = P2In(1:L/2+1);
P1In(2:end-1) = 2*P1In(2:end-1);
fIn = Fs*(0:(L/2))/L;

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
%fvtool(lowpassfirFilter,"Fs",Fs)
dataOut = filtfilt(lowpassfirFilter,data);

% 3
% 滤波后信号的频谱图
Yout = fft(dataOut);
P2Out = abs(Yout/L);
P1Out = P2Out(1:L/2+1);
P1Out(2:end-1) = 2*P1Out(2:end-1);
fOut = Fs*(0:(L/2))/L;
% figure(1)
% subplot(1,2,1)
% plot(fIn,P1In) 
% title('滤波前信号的频谱图')
% xlabel('f (Hz)')
% ylabel('单侧幅值频谱|P1(f)|')
% subplot(1,2,2)
% plot(fOut,P1Out) 
% title('滤波后信号的频谱图')
% xlabel('f (Hz)')
% ylabel('单侧幅值频谱|P1(f)|')

% 4 
% Official Thd fun
matlabThd = thd(dataOut,Fs,18);
[VthdMy,vthSig]= compute_THD(dataOut,Fs);
sprintf("Matlab Thd=%.3fdB My Thd=%.3fdB",matlabThd,VthdMy)
sprintf("Matlab Thd=%.3f My Thd=%.3f",10^(matlabThd/10),10^(VthdMy/10))

% figure(3)
% hold on;
% plot((1:200)/Fs,vthSig(1:200));
% plot((1:200)/Fs,data(1:200));
% xlabel('时间')
% ylabel('输出电压')
% legend("移动平均值滤波+去除直流后的信号","原始信号")
% hold off;
