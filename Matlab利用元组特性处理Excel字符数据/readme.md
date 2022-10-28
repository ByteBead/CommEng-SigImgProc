# Matlab利用元组特性处理Excel字符串数据

## 0 要求

需要将订单号和商品编号数字化，成一个矩阵，类似下图所示。

![60ACA77D8CD4C10449FE92A25002E25C](https://nas.itrefer.com:5541/2022/10/03_60ACA77D8CD4C10449FE92A25002E25C.jpg)

其中，每个订单1行，每个商品1列。

数据格式类似：

![Screenshot-2022-10-06 20.58.54](https://nas.itrefer.com:5541/2022/10/06_Screenshot-2022-10-06%2020.58.54.png)

## 1.思路

逐个订单遍历，如果出现新的商品名*thisLine.sku_ID*，就加入元组*saveSku*。

如果数据这一行的**订单号**与上一行**订单号**相等，则*ordIndex*不变，否则*ordIndex+1*。

相关变量的作用如下：

+ originData 原始数据
+ retAns 结果
+ sizeData 原始数据的规模 lengthData原始数据的列数
+ thisLine 当前行 thisLine.order_ID 订单号 thisLine.sku_ID 商品号
+ ordIndex 已处理的订单数
+ saveSku 所有商品名 saveSku中元素所在的位置代表对应retAns的列编号

tic/toc函数可以统计程序运行的时间，以估算更大数据下所需的时间。

## 2.实现程序

使用Matlab实现上述程序。

```matlab
tic
% originData = readtable("data.xlsx");
% load("dataSaved.mat")
% order_ID sku_ID
tempMaxIndex = 10000;
retAns = zeros(tempMaxIndex,3000);
sizeData = size(originData);
lengthData  = sizeData(1);

thisLine = originData(1,:);
thisOrd = thisLine.order_ID;
lastOrd = "";
ordIndex = 1;
thisSku = thisLine.sku_ID;
saveSku = {thisSku};
lenSaveSku = 1;
manyNewSku = 1;
retAns(1,1) = 1;

for index = 2:tempMaxIndex
    thisLine = originData(index,:);
    thisOrd = string(thisLine.order_ID);
    thisSku = string(thisLine.sku_ID);
    % 寻找thisSku在saveSku的位置 如果找到返回位置 如果找不到返回空[]
    tryFind = find(cellfun(@(x) strcmp(x,thisSku),saveSku), 1);
    if isempty(tryFind) == 1
    		% 没有找到thisSku，将其添加到saveSku
        saveSku = {saveSku{1,:},thisSku};
        manyNewSku = manyNewSku + 1;
        if thisOrd~=lastOrd
            ordIndex = ordIndex+1;  
        end
        retAns(ordIndex,manyNewSku) = retAns(ordIndex,manyNewSku)+1;
    else
    		%找到thisSku，对应ordIndex行tryFind列加1
        if thisOrd~=lastOrd
            ordIndex = ordIndex+1;  
        end
        retAns(ordIndex,tryFind) = retAns(ordIndex,tryFind)+1;
    end
    lastOrd = thisOrd;
end
toc
fprintf("处理了数据%d条 订单共%d个 商品共%d个\n",tempMaxIndex,ordIndex,manyNewSku);
```

## 3.运行截图

前10000条数据运行结果如下

![Re-Screenshot-2022-10-03 20.13.20](https://nas.itrefer.com:5541/2022/10/03_Re-Screenshot-2022-10-03%2020.13.20.png)

系统资源占用如下

![Screenshot-2022-10-03 20.08.21](https://nas.itrefer.com:5541/2022/10/03_Screenshot-2022-10-03%2020.08.21.png)

## 4.开发心得

项目总体难度不大，有几点经验可以吸取：

+ isempty判断返回值是否为空

+ 利用cellfun函数实现元组查找(两种方法)

  ```Matlab
  idx  = ismember(cell_name, find_str)
  [row, col] = find(cellfun(@(x) strcmp(x,find_str),cell_name);
  ```

  