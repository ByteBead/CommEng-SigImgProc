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

