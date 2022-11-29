% 离散信号-门函数卷积
% 门函数1的长度
lx1 = 3;
% 门函数1的坐标范围
index1 = 0:lx1;    
% 门函数1的值
sig1 = ones(1,lx1+1); 

% 门函数2的生成方法同1
lx2 = 4;
index2 = 0:lx2;     
sig2 = ones(1,lx2+1);

% 声明卷积后的门函数坐标序列
ansIndex=0:lx1+lx2;  
% 使用conv卷积相关门函数
y=conv(sig1,sig2);

% 做图
figure;  
subplot(3,1,1); 
% stem用于离散信号做图
stem(index1,sig1);
% 限制坐标范围
xlim([0 lx1+lx2])
xlabel('n');
ylabel('g1(n)');
title('门函数1 g1(n)');

subplot(3,1,2);
stem(index2,sig2);
xlim([0 lx1+lx2])
xlabel('n');
ylabel('g2(n)');
title('门函数2 g2(n)');

subplot(3,1,3);  
stem(ansIndex,y);
xlim([0 lx1+lx2])
xlabel('n');
ylabel('y(n)');
title('线性卷积 g1(n)*g2(n)');



