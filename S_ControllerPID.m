%��������
%sp:�����������
%pv�������¶Ȳ���ֵ
function Sc=S_ControllerPID(sp,pv)
global spid
%�������
error=sp-pv;
%���������֡�΢�ֱ��ʽ
P=error-spid.error1;
I=spid.dt/spid.tauI*error;
D=-(pv-2*spid.pv1+spid.pv2)*spid.tauD/spid.dt;
%�����ź��������
Sc=spid.Sc+spid.Kc*(P+I+D);
%������������Ƿ��ſ��ȣ���ΧΪ0��100%����������޷�
if Sc<spid.min
    Sc=spid.min;
end
if Sc>spid.max
    Sc=spid.max;
end
%����ǰһʱ�����ֵ�����¿���������
spid.error2=spid.error1;
spid.error1=error;
spid.pv2=spid.pv1;
spid.pv1=pv;
spid.Sc=Sc;