
function [W,C] = anntrain2(N)

resTj=xlsread('C:\Users\Administrator\Desktop\ANN-CH\anndata.xlsx', 'sheet1','A1:A3001');
resQrea=xlsread('C:\Users\Administrator\Desktop\ANN-CH\anndata.xlsx', 'sheet1','B1:B3000');
resU=xlsread('C:\Users\Administrator\Desktop\ANN-CH\anndata.xlsx',  'sheet1','C1:C3000');
resMiuwall=xlsread('C:\Users\Administrator\Desktop\ANN-CH\anndata.xlsx', 'sheet1','D1:D3000');%�ܴ���ϵ��
resA=xlsread('C:\Users\Administrator\Desktop\ANN-CH\anndata.xlsx', 'sheet1','E1:E3000');%����ճ��ϵ��



for i=1:N
       input_train(i,1)=resQrea(i);  input_train(i,2)=resU(i); input_train(i,3)=resMiuwall(i);%input_train(i,4)=resA(i);
end

for i=1:N
        output_train(i)=resTj(i+1);
end
k=N;
[ldx,C]=kmeans(input_train,k);%cΪ�������ľ���
z=dist(input_train,C');
%�������������
spread=1;
z=z/spread;
G=radbas(z);
%����������㵽������Ȩֵw
%�������
d=output_train;
%α�棬���Ȩֵ����
W=pinv(G)*d';



