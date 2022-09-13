function [VthdMy,myDataMeanAC] = compute_THD(dataOut,Fs)
    % 移动平均值滤波 
    meanFitLeval = 23;
    myDataMean = dataOut*0;
    myDataMean(1:meanFitLeval) = dataOut(1:meanFitLeval);
    i = meanFitLeval+1;
    while i<length(dataOut)
        myDataMean(i) = sum(dataOut(i-meanFitLeval:i))/meanFitLeval;
        i=i+1;
    end
    % 去除直流分量
    myDataMeanAC = myDataMean-mean(myDataMean); 
    % 分段求频谱再平均,输入信号分为5组
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
end


