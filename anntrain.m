%RBF_Train �ú��������������ѵ��������Ϊy(k-1),y(k-2),y(k-3),c(k-1),mMin(k-1),���Ϊy(k)

resTj=xlsread('C:\Users\Administrator\Desktop\ANN-CH\anndata.xlsx', 'sheet1','A1:A30001');
resQrea=xlsread('C:\Users\Administrator\Desktop\ANN-CH\anndata.xlsx', 'sheet1','B1:B3000');
resU=xlsread('C:\Users\Administrator\Desktop\ANN-CH\anndata.xlsx',  'sheet1','C1:C3000');
resMiuwall=xlsread('C:\Users\Administrator\Desktop\ANN-CH\anndata.xlsx', 'sheet1','D1:D3000');%�ܴ���ϵ��
resA=xlsread('C:\Users\Administrator\Desktop\ANN-CH\anndata.xlsx', 'sheet1','E1:E3000');%����ճ��ϵ��

N=size(resA,1);

for i=1:N
       input_train(i,1)=resQrea(i);  input_train(i,2)=resU(i); input_train(i,3)=resMiuwall(i);input_train(i,4)=resA(i);
end

for i=1:N
        output_train(i)=resTj(i+1);
end
goal=4;

spread=1.5;

net= newrb(input_train',output_train,goal,spread);








