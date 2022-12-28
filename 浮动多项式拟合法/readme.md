# Python实现浮动多项式拟合

浮动多项式拟合，即是用最小二乘法选配项数不等的若干个多项式方程，并从若干个方程中,选取符合水文特性的最优多项式为单一曲线的拟合方程。

为了采用上游站水位法推求宜昌站流量，在宜昌站上游约40km处的三斗坪站观测同时水位。下表为1966年三斗坪站水位与宜昌站实测流量成果表。

通过对上述资料分析，三斗坪站水位与宜昌站实测流量具有较好的单一关系，可以使用单一线法定线。

![Python实现浮动多项式拟合 流量](https://pic.itrefer.com/2022/12/28_image-20221228102036781.png)

下面介绍实现进行浮动多项式拟合的程序。

## 读取保存的水位-流量数据

读取Excel的水文数据用了pandas库。

```Python
import pandas as pd

riverData = pd.read_excel("data.xlsx")
xOri = list(riverData['水位'])
yOri = list(riverData['流量'])
Z0 = min(xOri)
```

## 浮动多项式法进行拟合

拟合使用了np库的polyfit方法。多项式拟合从2次开始测试，逐次递增，直至3类检验符合要求。

```python
import matplotlib.pyplot as plt
import numpy as np


# 准备数据,将(x,y)坐标点进行输入
x = np.array(xOri)
y = np.array(yOri)
x = x-Z0
# 使用polyfit方法来拟合,并选择多项式,这里先使用2次方程
z1 = np.polyfit(x, y, 3)
# 使用poly1d方法获得多项式系数,按照阶数由高到低排列
p1 = np.poly1d(z1)
# 在屏幕上打印拟合多项式
print(p1)
# 求对应x的各项拟合函数值
fx = p1(x)
# 绘制坐标系散点数据及拟合曲线图
plt.rcParams["figure.figsize"] = (9, 8)
Z = x+Z0
plot1 = plt.plot(Z, y, '*', label='origin data')
plot2 = plt.plot(Z, fx, 'r', label='polyfit data')
plt.xlabel('Z')
plt.ylabel('Q')
plt.legend(loc=2)  # 指定legend的位置,类似象限的位置
plt.title('Fit of level and rate')
plt.savefig('Fit.png',dpi=200)
```

<img src="https://pic.itrefer.com/2022/12/28_Fit.png" alt="浮动多项式法进行拟合-拟合情况" style="zoom:33%;" />

## 符号检验

符号检验法是通过两个相关样本的每对数据之差的符号进行检验，从而比较两个样本的显著性。具体地讲，若两个样本差异不显著，正差值与负差值的个数应大致各占一半。

```Python
judgeSig = fx-y
SigP = 0
for thisZ in judgeSig:
    if thisZ>0:
        SigP+=1
print("测试点数",len(judgeSig),"正值个数",SigP)
SigU = (abs(SigP-len(judgeSig)*0.5)-0.5)/0.5/np.sqrt(len(judgeSig))
print("符号检验值(显著性水平5%时u<1.96)",SigU)
```

## 适线检验

适线检验是对实测点与曲线间正负偏离值的排列情况的检验，如所定水位流量关系曲线是完全适中的平衡状态，则符号变换的概率为1/2。

```python
judgeK = 0
for i in range(1,len(fx)):
    if (fx[i]-y[i])*(fx[i-1]-y[i-1])>0:
        judgeK +=1
u2 = (abs(judgeK-0.5*(len(fx)-1))-0.5)/0.5/np.sqrt(len(fx)-1)
print("异偏个数",judgeK)
print("适线检验值(显著性水平5%时u<1.64)",u2)
```

## 偏离数值检验

偏离数值检验是考察检验测点偏离曲线的平均偏离值是否在合理范围。

```python
pMean = np.mean(judgeSig)
P = []
for i in range(0,len(fx)):
    P.append((y[i]-fx[i])/fx[i])
P = np.array(P)
Sp = np.sqrt(np.sum((P-pMean)*(P-pMean))/(len(fx)-1))
SpMean = Sp/np.sqrt(len(fx))
t = pMean/SpMean
print("偏离数值检验值(显著性水平10%时t<1.94)",abs(t))
```

