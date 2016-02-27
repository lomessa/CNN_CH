%主程序
%--------------------------------------------------------------------------
%系统参数设置
MWM=104.0;  %molecular weight of the monomer
deltaH=70152.16;  %reactor enthalpy
mW=42.750;  %mass of the water in the reactor
CpW=4.187;  %heat capacities of water
CpM=1.675;  %heat capacities of monomer
CpP=3.140;  %heat capacities of polymer
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
hf=0.000;  %fouling factor depending on batch number
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
ki=0.8;
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
%状态初始化，温度初值均为环境温度
mMin=0;
i=1.2; %[0.8 1.2]
Tr0=TAmb;
Tjin0=TAmb;
Tjout0=TAmb;
Tj0=TAmb;
mP0=11.227;  
mM0=0; 
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
tfinal=4*2251;%150*60;
%采样时间/s
sampletime=4;
%仿真步数
kmax=length(tinit:sampletime:tfinal);
%仿真起始时间初始化
tstart=0;
%--------------------------------------------------------------------------
%串级PID参数设置，PID采用了防止“微分冲击”的形式
%副控制器输出：阀门开度（0-100%）
%被控变量：釜温Tr
global spid;  %副控制器(slave)，采用PI控制
%副控制器PID参数设置
spid.dt=sampletime;  %s
spid.Kc=16;%25;    %比例，Kc<0,表示正作用，Kc>0，表示反作用20 30
spid.tauI=300;%180;  %积分/s40
spid.tauD=0;   %没有微分作用
spid.error1=0;
spid.error2=0;
spid.pv1=Tj0;
spid.pv2=Tj0;
spid.max=100;%控制器输出限幅
spid.min=0;
spid.Sc=50;  %副控制器输出初始值为0，即此时冷水阀和蒸汽阀都是关闭的
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
Mout=[];  %保存主控制器输出
Sout=[];  %保存副控制器输出
resTrsp=[];  %保存每步仿真的釜温设定值
resmMin=[];  %保存每步仿真的单体进料值
resSimOuts=[];  %保存仿真输出值
resSimStates=[];  %保存仿真状态值
%t=0时模型的状态值
resSimStates=[resSimStates;x0'];
%t=0时模型的输出值，12个输出
Simouts0=[Tr0;(Tjin0+Tjout0)/2;Tjin0;Tjout0;mM0;mP0;Qrea0;U0;...
         (Tjin0+Tjout0)/2;Tjin_del0;Tjout_del0;TAmb;A0;miu0;f0;miuwall0;0];
resSimOuts=[resSimOuts;Simouts0'];
xplant=x0;
yplant=Simouts0;
rescold=[];
reshot=[];
spread=1;
M_Out_S=TAmb;
%--------------------------------------------------------------------------
%神经网络训练
[W,C]=anntrain2(3000);
%--------------------------------------------------------------------------
%开始仿真，求解simulink模型
input_net=[Qrea0,U0,miuwall0];
for k=1:kmax-1 
    if tstart>=1800 && tstart<6000
      
        spid.Kc=70;%25;    %比例，Kc<0,表示正作用，Kc>0，表示反作用20 30
        spid.tauI=180;%180;  %积分/s40
        spid.tauD=0;   %没有微分作用
    end
    
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
       
    else
        mMin=0;
     
    end
     resmMin=[resmMin;mMin];
   Dist=dist(input_net,C');
   Dist=Dist/spread;
   DIST_G=radbas(Dist);
    M_Out=DIST_G*W;
   Mout=[Mout,M_Out];
    %调用副PID控制器
    S_Out=S_ControllerPID(M_Outt(k),yplant(9));
    %S_Out=S_ControllerPID(M_Out,yplant(2));
    Sout=[Sout;S_Out];
    c=S_Out;
    %解simulink模型
    [SimTime,SimStates,SimOuts]=sim('Batch_Model',[tstart tstart+sampletime],Options);
    resSimStates=[resSimStates;SimStates(end,:)];%保存每次采样的状态
    resSimOuts=[resSimOuts;SimOuts(end,:)];%保存模型的输出
    xplant=SimStates(end,:)';
    yplant=SimOuts(end,:)';
    input_net(1)=yplant(7);
    input_net(2)=yplant(8);
    input_net(3)=yplant(16);
    %input_net(4)=yplant(13); 
    Options=simset('Solver','ode15s','InitialState',SimStates(end,:)');
    tstart=tstart+sampletime;
end

