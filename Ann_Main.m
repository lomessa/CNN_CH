%主程序
%夏季第五批次
%--------------------------------------------------------------------------
%系统参数设置
MWM=104.0;  %molecular weight of the monomer
deltaH=70152.16;  %reactor enthalpy
mW=42.750;  %mass of the water in the reactor
CpW=4.187;  %heat capacities of water
CpM=1.675;  %heat capacities of monomer
CpP=3.140;  %heat capacities of polymer
c=50;%开关初始为50
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
hf=0.704; %第五批次
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
%状态初始化，温度初值均为环境温度
mMin=0;
i=1.2; %[0.8 1.2]中随机取值
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
%初始状态矩阵,7个状态
x0=[Tr0;Tjin0;Tjout0;mM0;mP0;Tjin_del0;Tjout_del0];
%用sim函数解simulink模型初值解求解器设置
Options=simset('Solver','ode15s','InitialState',x0);
%起始时间/s
tinit=0;
%终止时间/s
tfinal=3000*4;
%采样时间/s
sampletime=4;
%仿真步数
kmax=length(tinit:sampletime:tfinal);
%仿真起始时间初始化
tstart=0;
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%为保存仿真结果设置数组
%计算U0
Twall0=TAmb;
f0=mP0/(mM0+mP0+mW);
miuW0=c0*exp(c1*f0)*10^(c2*(a0/Twall0-c3));
h0=d0*exp(d1*miuW0);
U0=1/(1/h0+hf);
A0=(mW/rhoW+mP0/rhoP)*P/B1+B2;
miu0=c0*exp(c1*f0)*10^(c2*(a0/TAmb-c3));
miuwall0=c0*exp(c1*f0)*10^(c2*(a0/TAmb-c3));
Rp0=0;
Sout=[];  %保存副控制器输出
resTrsp=[];  %保存每步仿真的釜温设定值
resmMin=[];  %保存每步仿真的单体进料值
resSimOuts=[];  %保存仿真输出值
resSimStates=[];  %保存仿真状态值
resSout=[];
 S_Out_M=[50,50,50,50];
input_net=[0,0,0,0];
%t=0时模型的状态值
resSimStates=[resSimStates;x0'];
%t=0时模型的输出值，12个输出
Simouts0=[Tr0;(Tjin0+Tjout0)/2;Tjin0;Tjout0;mM0;mP0;Qrea0;U0;...
         (Tjin0+Tjout0)/2;Tjin_del0;Tjout_del0;TAmb;A0;miu0;f0;miuwall0;0];
resSimOuts=[resSimOuts;Simouts0'];
xplant=x0;
yplant=Simouts0;

%--------------------------------------------------------------------------
%开始仿真，求解simulink模型
for k=1:kmax-1    


    %计算当前时刻温度设定值并保存
    Tr_sp=Trsp(TAmb,Tset,theat,tstart);
    resTrsp=[resTrsp;Tr_sp];
%     if tstart>=3600 && tstart<=4000
%         mMin_r=8.316*10^-3;
%     else
%         mMin_r=7.560*10^-3;
%     end
    %保存当前时刻单体进料速率
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
 
    Sout=[Sout;S_Out];%保存副控制器输出，也就是开关量
    c=S_Out;
    
    %解simulink模型
    [SimTime,SimStates,SimOuts]=sim('Batch_Model',[tstart tstart+sampletime],Options);
    resSimStates=[resSimStates;SimStates(end,:)];%保存每次采样的状态
    
    xplant=SimStates(end,:)';
    yplant=SimOuts(end,:)';
    input_net(1)=yplant(7);
    input_net(2)=yplant(8);
    input_net(3)=yplant(16);
    input_net(4)=yplant(13);
    resSimOuts=[resSimOuts;SimOuts(end,:)];%保存模型的输出
    Options=simset('Solver','ode15s','InitialState',SimStates(end,:)');
    tstart=tstart+sampletime;
end
figure (1)
plot(T,'r');
hold on
plot(resTrsp,'g');
