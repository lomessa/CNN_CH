%副控制器
%sp:主控制器输出
%pv：夹套温度测量值
function Sc=S_ControllerPID(sp,pv)
global spid
%计算误差
error=sp-pv;
%比例、积分、微分表达式
P=error-spid.error1;
I=spid.dt/spid.tauI*error;
D=-(pv-2*spid.pv1+spid.pv2)*spid.tauD/spid.dt;
%控制信号输出计算
Sc=spid.Sc+spid.Kc*(P+I+D);
%副控制器输出是阀门开度，范围为0—100%，故需进行限幅
if Sc<spid.min
    Sc=spid.min;
end
if Sc>spid.max
    Sc=spid.max;
end
%保存前一时刻误差值，更新控制器参数
spid.error2=spid.error1;
spid.error1=error;
spid.pv2=spid.pv1;
spid.pv1=pv;
spid.Sc=Sc;