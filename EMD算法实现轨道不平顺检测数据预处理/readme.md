# EMD算法实现轨道不平顺检测数据预处理

## 1.需求简介

高速综合检测车对轨道水平不平顺的检测是通过对超高进行25 m 高通滤波的方法，但由于标定误差、曲线超高、仪器漂移等原因使超高信号包含明显的非平稳趋势项，而对其进行滤波并不能消除该趋势项;此外,轨距不平顺由于陀螺漂移、曲线段不均匀磨耗等原因也存在着非线性的趋势项。而这些趋势项的存在,使得对信号进行时域的相关分析或频域的功率谱分析产生较大误差，特别是使得低频段的信号严重失真。因此,消除轨道不平顺测试数据中的趋势项是预处理中一项重要的工作。

本程序复现了论文中的改进的经验模态分解(EMD)方法对信号进行分解，该方法根据信号本身的固有特性进行分解，具有自适应性强的特点，从而避免了采用小波分析方法中小波基函数选择的难题，从而提高了检测数据处理的准确性和有效性。

## 2.实现过程

+ 利用 EMD 将轨道不半顺检测信号分解解为若干个本征模函数信号$c_a(t)$和一个残余项$r_b(t)$之和即
  + $$ q(t) = \sum_{a=1}^b{c_a(t)+r_b(t)} $$  

```matlab
		% EMD经验模态分解
    qt = emd(data);
```

+ 去掉检测信号的低频部分，利用剩余高频部分的本征模函数分量对信号进行重构，就得到消
  除趋势项后的真实检测信号。由于 200km/h提速干线铁路轨道不平顺管理波长为110m，所以，只需将波长大于110m的低频本征模函数分量和残余项去除即可。
  + 判断分量的波长需要使用希尔伯特变换，对于本案例 采样率fs为最小采样距离的倒数，单位1/m。

```matlab
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
```

## 3.完整函数及效果测试

将该模块封装成以下函数。

```Matlab
function [output] = emdLimit(fs,data,passWave)
    % fs 采样精度 单位 1/m
    % data 数据
    % passWave 波长阈值
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
```

对于测试数据，效果如下：

![截屏2022-10-09 10.59.34](https://www.itrefer.com/pictureBed/2022/10/09_%E6%88%AA%E5%B1%8F2022-10-09%2010.59.34.png)

## 4.参考资料

Matlab官方说明文档如下

+ https://ww2.mathworks.cn/help/signal/ug/hilbert-transform-and-instantaneous-frequency.html

+ https://ww2.mathworks.cn/help/signal/ref/emd.html?s_tid=srchtitle_emd_1

原始论文

+ 轨道不平顺检测数据的预处理方法分析
