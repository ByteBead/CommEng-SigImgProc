dataIn = readmatrix("originData.xlsx");
dataOut = dataIn;
fix = [2,4,5,6,7,8,9];
fs = 1/((dataIn(2,1)-dataIn(1,1))*1000);
mtitle = {'实际里程(km)','轨距(mm)','超高(mm)','水平(mm)',...
    '三角坑(mm)','左高低120米(mm)',...
    '右高低120米(mm)','左轨向120米(mm)',...
    '右轨向120米(mm)','左复合不平顺(mm)',...
    '右复合不平顺(mm)','车载仪(g)',' '};   
for index = 1:7
    dataOut(:,fix(index)) = real(emdLimit(fs,dataIn(:,fix(index)),120));
    subplot(7,1,index);
    hold on;
    plot(dataIn(:,1),dataIn(:,fix(index)));
    plot(dataIn(:,1),dataOut(:,fix(index)),'--');
    xlabel('里程/m')
    ylabel('幅值/mm')
    legend('原始数据','去趋势后的数据')
    hold off;
end  
[m, n] = size(dataOut);            
data_cell = mat2cell(dataOut, ones(m,1), ones(n,1));    % 将data切割成m*n的cell矩阵             
result = [mtitle; data_cell];            % 将变量名称和数值组集到result
s = xlswrite('output.xlsx', result);                % 将result写入到wind.xls文件中