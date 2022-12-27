symbol = {'1','2','3','4','5','6','7','8','9','*','0','#'};
[tones, Fs, f, lfg, hfg] = DTMFToneGenerator(symbol, false);

% 展示每个拨号音频的特性
N = 800;          % Tones of 100 ms
t = (0:N-1)/Fs;   % 800 samples at Fs
for toneChoice=1:12
    fftDraw(tones(:,toneChoice),Fs,...
        ['按键 "', symbol{toneChoice},'": [',num2str(f(1,toneChoice)),',',num2str(f(2,toneChoice)),']'])
end

% 求解此估计问题的一个常见方法是计算接近七个基本音调的离散时间傅里叶变换 (DFT) 采样。
% 对于基于 DFT 的解，已证明使用频域中的 205 个采样可以最小化原始频率和估计 DFT 的点之间的误差。
% 为了最小化原始频率和估计 DFT 的点之间的误差
% 我们截断音调，只保留 205 个采样或 25.6 毫秒用于进一步处理。
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

% 取消注释可以听一下效果
% for i = [1 9 2 1 6 8 2 5 5 11 11]
%     p = audioplayer(tones(:,i),Fs,16);
%     play(p)
%     pause(0.5)
% end