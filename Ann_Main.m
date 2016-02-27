%������
%�ļ���������
%--------------------------------------------------------------------------
%ϵͳ��������
MWM=104.0;  %molecular weight of the monomer
deltaH=70152.16;  %reactor enthalpy
mW=42.750;  %mass of the water in the reactor
CpW=4.187;  %heat capacities of water
CpM=1.675;  %heat capacities of monomer
CpP=3.140;  %heat capacities of polymer
c=50;%���س�ʼΪ50
c0=5.2*10^-5;
c1=16.4;
c2=2.3;
c3=1.563;
a0=555.556;
k0=55;  %pre-exponential factor
k1=1000;
k2=0.4;
E=29560.89;  %activation energy
R=8.314;  %nature gas const
rhoM=900.0;  %monomer density
rhoP=1040.0;  %polymer density
rhoW=1000.0;  %water density
P=1.594;  %jacket perimeter
B1=0.193;  %reactor bottom area
B2=0.167;  %jacket bottom area
d0=0.814;
d1=-5.13;
hf=0.704; %��������
%fouling factor depending on batch number
%[0.000 0.176 0.352 0.528 0.704]
UAloss=0.00567567;  %heat loss coefficient
Tset=355.382;  %temperature setpoint of the feed phase
TAmb=305.38;  %ambient temperature winter:280.38 summer:305.38
TM=TAmb;  %the feed temperature
mC=21.455;  %mass of the water in the circulation loop
mC_r=0.9412;  %circulation rate
CpC=4.187;  %heat capacities of coolant
theta1=22.8;  %time delay in jacket22.8 34.2
theta2=15;  %time delay in recirculation loop 15 22.5
tauP=40.2;  %heating/cooling time constant
Tinlet=294.26;  %coolant temperature winter:278.71 summer:294.26
Tsteam=449.82;  %steam temperature
theat=30*60;  %time of the feed phase /s
tM0=30*60;  %feed time/s
tM1=100*60;%100*60;  %stop feed time/s
Qrea0=0;
TSet=355.382;  %reactor temperature setpoint of the feed pahse 
mMin_r=7.560*10^-3;  %monomer feed rate
ki=1;
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%״̬��ʼ�����¶ȳ�ֵ��Ϊ�����¶�
mMin=0;
i=1.2; %[0.8 1.2]�����ȡֵ
Tr0=TAmb;
Tjin0=TAmb;
Tjout0=TAmb;
Tj0=TAmb;
mP0=11.227;  
mM0=0; 
S_Out=50;
%Tjin_del0=280.38;
%Tjout_del0=280.38;
Tjin_del0=TAmb;
Tjout_del0=TAmb;
%��ʼ״̬����,7��״̬
x0=[Tr0;Tjin0;Tjout0;mM0;mP0;Tjin_del0;Tjout_del0];
%��sim������simulinkģ�ͳ�ֵ�����������
Options=simset('Solver','ode15s','InitialState',x0);
%��ʼʱ��/s
tinit=0;
%��ֹʱ��/s
tfinal=3000*4;
%����ʱ��/s
sampletime=4;
%���沽��
kmax=length(tinit:sampletime:tfinal);
%������ʼʱ���ʼ��
tstart=0;
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%Ϊ�����������������
%����U0
Twall0=TAmb;
f0=mP0/(mM0+mP0+mW);
miuW0=c0*exp(c1*f0)*10^(c2*(a0/Twall0-c3));
h0=d0*exp(d1*miuW0);
U0=1/(1/h0+hf);
A0=(mW/rhoW+mP0/rhoP)*P/B1+B2;
miu0=c0*exp(c1*f0)*10^(c2*(a0/TAmb-c3));
miuwall0=c0*exp(c1*f0)*10^(c2*(a0/TAmb-c3));
Rp0=0;
Sout=[];  %���渱���������
resTrsp=[];  %����ÿ������ĸ����趨ֵ
resmMin=[];  %����ÿ������ĵ������ֵ
resSimOuts=[];  %����������ֵ
resSimStates=[];  %�������״ֵ̬
resSout=[];
 S_Out_M=[50,50,50,50];
input_net=[0,0,0,0];
%t=0ʱģ�͵�״ֵ̬
resSimStates=[resSimStates;x0'];
%t=0ʱģ�͵����ֵ��12�����
Simouts0=[Tr0;(Tjin0+Tjout0)/2;Tjin0;Tjout0;mM0;mP0;Qrea0;U0;...
         (Tjin0+Tjout0)/2;Tjin_del0;Tjout_del0;TAmb;A0;miu0;f0;miuwall0;0];
resSimOuts=[resSimOuts;Simouts0'];
xplant=x0;
yplant=Simouts0;

%--------------------------------------------------------------------------
%��ʼ���棬���simulinkģ��
for k=1:kmax-1    


    %���㵱ǰʱ���¶��趨ֵ������
    Tr_sp=Trsp(TAmb,Tset,theat,tstart);
    resTrsp=[resTrsp;Tr_sp];
%     if tstart>=3600 && tstart<=4000
%         mMin_r=8.316*10^-3;
%     else
%         mMin_r=7.560*10^-3;
%     end
    %���浱ǰʱ�̵����������
    if k>=tM0/sampletime && k<=tM1/sampletime
        mMin=mMin_r;
        resmMin=[resmMin;mMin_r];
    else
        mMin=0;
        resmMin=[resmMin;0];
    end
    
    if k>=2
        S_Out_M=sim(net,input_net);
       
    end
    
    kk=1;
    while(kk<=4)
        
          if (S_Out_M(kk)<0||S_Out_M(kk)>100)
            kk=kk+1;
          else break;
          end
       
    end
    
    S_Out=S_Out_M(kk);
    
    if S_Out>100
        S_Out=100;
    else if S_Out<0
        S_Out=0;
        end
    end
 
    Sout=[Sout;S_Out];%���渱�����������Ҳ���ǿ�����
    c=S_Out;
    
    %��simulinkģ��
    [SimTime,SimStates,SimOuts]=sim('Batch_Model',[tstart tstart+sampletime],Options);
    resSimStates=[resSimStates;SimStates(end,:)];%����ÿ�β�����״̬
    
    xplant=SimStates(end,:)';
    yplant=SimOuts(end,:)';
    input_net(1)=yplant(7);
    input_net(2)=yplant(8);
    input_net(3)=yplant(16);
    input_net(4)=yplant(13);
    resSimOuts=[resSimOuts;SimOuts(end,:)];%����ģ�͵����
    Options=simset('Solver','ode15s','InitialState',SimStates(end,:)');
    tstart=tstart+sampletime;
end
figure (1)
plot(T,'r');
hold on
plot(resTrsp,'g');
