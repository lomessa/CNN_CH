
function [W,C] = anntrain2(N)

resTj=xlsread('C:\Users\Administrator\Desktop\ANN-CH\anndata.xlsx', 'sheet1','A1:A3001');
resQrea=xlsread('C:\Users\Administrator\Desktop\ANN-CH\anndata.xlsx', 'sheet1','B1:B3000');
resU=xlsread('C:\Users\Administrator\Desktop\ANN-CH\anndata.xlsx',  'sheet1','C1:C3000');
resMiuwall=xlsread('C:\Users\Administrator\Desktop\ANN-CH\anndata.xlsx', 'sheet1','D1:D3000');%总传热系数
resA=xlsread('C:\Users\Administrator\Desktop\ANN-CH\anndata.xlsx', 'sheet1','E1:E3000');%釜壁粘度系数



for i=1:N
       input_train(i,1)=resQrea(i);  input_train(i,2)=resU(i); input_train(i,3)=resMiuwall(i);%input_train(i,4)=resA(i);
end

for i=1:N
        output_train(i)=resTj(i+1);
end
k=N;
[ldx,C]=kmeans(input_train,k);%c为聚类中心矩阵
z=dist(input_train,C');
%计算隐含层输出
spread=1;
z=z/spread;
G=radbas(z);
%计算从隐含层到输出层的权值w
%期望输出
d=output_train;
%伪逆，求出权值向量
W=pinv(G)*d';



