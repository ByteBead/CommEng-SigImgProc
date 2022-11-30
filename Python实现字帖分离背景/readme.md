# Python实现字帖分离背景

## 1. 要求

+ 从背景中提取出文字，并二值化
+ 去除背景中的虚线部分
+ 调整图片大小为150*150

![22](https://www.itrefer.com/pictureBed/2022/10/13_22.png)

## 2. 实现思路

​	通过对图像中的颜色进行聚类，得到手写字体的颜色，利用滤波算法过滤虚线。

### 2.1 导入相关包，并读取图片

```python
import math
import os
from PIL import Image
import matplotlib.pyplot as plt
import numpy as np
from scipy.cluster.vq import kmeans
import cv2

dispose_dir = 'work'  # 数据集文件夹
save_path = 'out'  # 输出文件夹
try:
    os.mkdir(save_path)
except FileExistsError:
    pass
```

### 2.2 对图片进行大小调整

```python
for pic in os.listdir(dispose_dir):
    # 读取图片并二值化，并将图片resize为150
    # print(os.path.join(dispose_dir, picroot))
    thisPicRoot = os.path.join(dispose_dir, pic)
    try:
        picOri = cv2.resize(cv2.imread(thisPicRoot), (150, 150))
        imgGray = cv2.resize(cv2.imread(thisPicRoot, 0), (150, 150))
    except:
        continue
    thisPicRoot = os.path.join(dispose_dir, pic)
    img = Image.open(thisPicRoot)
```

### 2.3 聚类

```python
 		w, h = img.size
    points = []
    for count, color in img.getcolors(w * h):
        points.append(color)
    fe = np.array(points, dtype=float)  # 聚类需要是Float或者Double
    book = np.array((fe[100], fe[1], fe[8], fe[8]))  # 聚类中心，初始值
    codebook, distortion = kmeans(fe, 3)  
    centers = np.array(codebook, dtype=int)  # 变为色彩，还得转为整数
```

### 2.4 二值化

+ 字迹颜色应为黑色，故应选择聚类中颜色最接近(0,0,0)的那一类
+ 在判定时，将像素点的元素的值减去聚类得到的中心颜色judge，并设置阈值为60，若得到的结果为负数，证明该点比judge点更黑，故这里不去绝对值。
+ 直接去除边缘
+ 对结果进行均值滤波，然后二值化

```Python
    minRGB = 255 * 3
    judge = [255, 255, 255]
    for i in range(0, 3):
        if centers[i][1] + centers[i][2] + centers[i][0] < minRGB:
            minRGB = centers[i][1] + centers[i][2] + centers[i][0]
            judge = centers[i]
    for dx in range(0, 150):
        for dy in range(0, 150):
            c = picOri[dx, dy]
            dc = c - judge
            if dc[1]+dc[2]+dc[0]< 60:
                imgGray[dx, dy] = 0
            else:
                imgGray[dx, dy] = 255
            if dx < 20 or dx > 130 or dy < 20 or dy > 130:
                imgGray[dx, dy] = 255
                dst = cv2.blur(imgGray, (5, 5))
    for dx in range(10, 140):
        for dy in range(10, 140):
            if dst[dx, dy]<230:
               dst[dx, dy] = 0 
            else:
               dst[dx, dy] = 255 
    mask = dst
```

### 2.5 计算图像重心确定文字区域，做图，并保存

```python
    # 计算图片的重心，作为图片的圆心
    M = cv2.moments(mask)
    cX = int(M["m10"] / M["m00"])
    cY = int(M["m01"] / M["m00"])
    # 计算圆的半径
    maxR = 0
    for dx in range(0, 150):
        for dy in range(0, 150):
            if mask[dx, dy] == 0 and (cX - dx) * (cX - dx) + (cY - dy) * (cY - dy) > maxR:
                maxR = (cX - dx) * (cX - dx) + (cY - dy) * (cY - dy)
    maxR = math.sqrt(maxR)
    maxR = min(cX, cY, 150 - cX, 150 - cY, maxR)
    # 在原图上绘制圆，展示结果以便于查看
    cv2.circle(picOri, (cX, cY), round(maxR), (255, 0, 0))
    plt.imshow(picOri)
    plt.show()
    # 结果图需要绘制的是黑色实心圆
    circlePic = picOri * 0 + 255
    cv2.circle(circlePic, (cX, cY), round(maxR), (0, 0, 0), -1)
    plt.imshow(dst)
    plt.show()
    cv2.imwrite(os.path.join(save_path, pic), dst)  # 保存提交图片
    cv2.imwrite(os.path.join(save_path, pic.split('.png')[0] + '-c.png'), circlePic)  # 保存提交图片

```

### 2.6 效果展示

![截屏2022-10-13 11.13.47](https://www.itrefer.com/pictureBed/2022/10/13_%E6%88%AA%E5%B1%8F2022-10-13%2011.13.47.png)

## 3. 总结与反思

这个问题一开始我的想法是用颜色过滤结合滤波算法实现，但是由于字迹颜色变化大，所以效果不理想。

之后尝试了聚类结合滤波算法去实现，效果好了很多，但是在该问题的排名仍不靠前，我拒绝对特殊的图片调整特别的参数，我认为仍存在的问题是没有前置的图像处理算法，不清楚**聚类前加一些对比度调整**或者**用边缘识别然后填充**会不会好一点。