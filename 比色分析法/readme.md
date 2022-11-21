# Matlab实现比色分析法

本文介绍了如何使用Matlab实现比色分析法。程序读取录制的视频，分析关键点颜色的变化，并绘制规制了归一化的浓度变化图。

## 效果展示

<img src="https://nas.itrefer.com:5541/2022/11/21_clip_image002.png" alt="Matlab实现比色分析法效果展示" style="zoom:150%;" />

## 核心方法

本程序的核心点在于如何读取Matlab的视频流。

通过VideoReader读取视频。

`v = VideoReader('./Video/Video2.mp4');`

通过CurrentTime设置时间点。

`v.CurrentTime = 0;`

通过readFrame读取特定帧

`backGround = readFrame(v); `或`read(v,[maxIndex maxIndex]);`

通过判断`hasFrame`实现遍历。

## 实现代码

​	使用Matlab读取视频时，可参阅本程序。

```matlab
% v = VideoReader('./Video/Video2.mp4');
% v.CurrentTime = 0;
% backGround = readFrame(v);
% keyPoint = [1680 960];
% indexFrame = 1;
% timeColour = zeros(1,7200);
% while hasFrame(v)
%     vidFrame = readFrame(v) - backGround;
%     timeColour(1,indexFrame) = sum(vidFrame(keyPoint(2),keyPoint(1),:));
%     indexFrame = indexFrame + 1;
% %     image(vidFrame, 'Parent', currAxes);
% %     currAxes.Visible = 'off';
% end
smoothColour = smoothdata(timeColour(1:indexFrame));
%plot(smoothColour,'gaussian',indexFrame*0.1);
[maxData,maxIndex] = max(smoothColour(1:indexFrame));
minLength = 1;
for midIndex = 1:indexFrame
    if timeColour(1,midIndex) > maxData * 0.95
        break;
    end
    if timeColour(1,midIndex) < maxData * 0.1
        minLength = minLength + 1;
    end
end
subplot(3,3,1:3);
normalizeData = 1-smoothColour(1:maxIndex+minLength)/maxData;
normalizeData = normalizeData/max(normalizeData);
plot(normalizeData);
xlabel('Frame')
ylabel('Normalized Data')

subplot(3,3,4);
minFrame = read(v,[minLength minLength]);
plot(keyPoint(2),keyPoint(1),'o');
imshow(minFrame)
hold on;
plot(keyPoint(1),keyPoint(2),'o');
hold off;

subplot(3,3,5);
midFrame = read(v,[midIndex midIndex]);
imshow(midFrame)
hold on;
plot(keyPoint(1),keyPoint(2),'o');
hold off;

subplot(3,3,6);
maxFrame = read(v,[maxIndex maxIndex]);
imshow(maxFrame)
hold on;
plot(keyPoint(1),keyPoint(2),'o');
hold off;

a1 = keyPoint(2)-25;
a2 = keyPoint(2)+25;
b1 = keyPoint(1)-50;
b2 = keyPoint(1)+50;

subplot(3,3,7);
imshow(minFrame(a1:a2,b1:b2,:));

subplot(3,3,8);
imshow(midFrame(a1:a2,b1:b2,:));

subplot(3,3,9);
imshow(maxFrame(a1:a2,b1:b2,:));
```



## 缺失文件说明

​	由于文件大小限制，没有上传 ./Video 的相关内容，完整文件链接如下。

​	[百度网盘链接](https://pan.baidu.com/s/1f2v4NkUwLiWVfohyfd6krg?pwd=d207 )