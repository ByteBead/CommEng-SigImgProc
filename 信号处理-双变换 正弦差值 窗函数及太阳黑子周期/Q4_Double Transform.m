clear;
format compact

x = [1,2,3,4,5,6,7,8];
y = [1,2,3,4,3,5,3,7];
data = x + y * i;
xFFT = fft(x);
yFFT = fft(y);
mixFFT = fft(data);
fprintf("两个序列长度相等时，有x(t)+i*y(t)<---->x(w)+i*y(w)\n")
det = sum(abs(mixFFT-xFFT-yFFT*i));
fprintf("双变换算法和单独变换序列算法的差为%.3f\n",det)

clear;

x = [1,2,3,4,5,6,7,8,9,10];
y = [0,0,1,2,3,4,3,5,3,7];
xFFT = fft(x);
yFFT = fft(y);
data = x + y * i;
mixFFT = fft(data);
fprintf("两个序列长度不等时，对短序列头部补0 x(t)+i*y(t)<---->x(w)+i*y(w)\n")
det = sum(abs(mixFFT-xFFT-yFFT*i));
fprintf("双变换算法和单独变换序列算法的差为%.3f\n",det)