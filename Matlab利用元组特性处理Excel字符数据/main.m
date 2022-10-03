tic
% originData = readtable("data.xlsx");
% load("dataSaved.mat")
% order_ID sku_ID
tempMaxIndex = 549989;
retAns = zeros(tempMaxIndex,3000);
sizeData = size(originData);
lengthData  = sizeData(1);
success = [1 1];

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
    tryFind = find(cellfun(@(x) strcmp(x,thisSku),saveSku), 1);
    if isempty(tryFind) == 1
        saveSku = {saveSku{1,:},thisSku};
        manyNewSku = manyNewSku + 1;
        if thisOrd~=lastOrd
            ordIndex = ordIndex+1;  
        end
        retAns(ordIndex,manyNewSku) = retAns(ordIndex,manyNewSku)+1;
    else
        if thisOrd~=lastOrd
            ordIndex = ordIndex+1;  
        end
        retAns(ordIndex,tryFind) = retAns(ordIndex,tryFind)+1;
    end
    lastOrd = thisOrd;
end

toc
fprintf("处理了数据%d条 订单共%d个 商品共%d个\n",tempMaxIndex,ordIndex,manyNewSku);
