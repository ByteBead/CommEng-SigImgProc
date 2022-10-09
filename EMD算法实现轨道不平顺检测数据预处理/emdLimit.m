function [output] = emdLimit(fs,data,passWave)
    % fs 采样精度 单位 1/m
    % data 数据
    % EMD经验模态分解
    qt = emd(data);
    [~,emdMaxIndex] = size(qt);
    output = qt(:,1)*0;
    for i=1:emdMaxIndex
        % 希尔伯特变换
        z=hilbert(qt(:,i));   
        % 确定平均波长
        wavelength = abs(1/mean(fs/(2*pi)*diff(unwrap(angle(z)))));
        if wavelength<passWave
            output = output+z;
        end
    end
end
% 参考链接 
% https://ww2.mathworks.cn/help/signal/ug/hilbert-transform-and-instantaneous-frequency.html
