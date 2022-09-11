N=0:40-1;
fs =20;
Ts = 1/fs;
f = 8;
% 原始信号
x=sin(2*pi*f*N/40); 
% 对原始信号插值 补0
M=3;              %插值M=3，合计数据120个
x1(M*N+1)=x(N+1); %合计数据为22个，原始数据坐标为1/4/7/10/13/16/19/22
x1(M*N+2)=0;      %零点2/5/8，坐标N*M+1+m，m=1，变量为N
x1(M*N+3)=0;      %零点3/6/9/12/15/18/21/24，坐标N*M+1+m，m=2
x10 = x1;
NM=[0:120-1];
subplot(2,2,1);
stem(NM,x1,'r');
title('对原始信号内插0')
% 正弦插值
for k=0:40-1
    for m=1:M-1 
        for n=0:40-1
            x1(k*M+m+1)=x1(k*M+m+1)+x(n+1)*sinc(k-n+m/M);
            n=n+1;
        end 
    m=m+1;
    end 
    k=k+1;
end
subplot(2,2,2);
stem(NM,x1);
axis([0 120 -1.1 1.1]);
title('正弦插值')
% 对已补0
ffty = fft(x10); 
mid = length(ffty)/2;
% 频率数据归零 将高频部分置0
ffty(mid-mid*0.5:mid+mid*0.5)=0;
% 对应真实频率
fR = (0:length(ffty)-1)*fs/length(ffty);
subplot(2,2,3);
plot(fR,abs(ffty))
title('对插值信号进行傅立叶变换')
% 对处理过的频率做傅立叶反变换
NM2 = ifft(ffty);
subplot(2,2,4);
stem(NM2(1:120));
axis([0 120 -1.1 1.1]);
title('频率归零后进行傅立叶反变换')

% 相关原理参考
% https://www.zhihu.com/question/446265998/answer/1760223418

