%釜温设定曲线
%Tamb:环境温度
%Tset:进入恒温阶段设定值
%theat:升温阶段时间
% function Tr_sp=Trsp(Tamb,Tset,theat,t)
% if t<=theat
%     Tr_sp=Tamb+(Tset-Tamb)*(10*(t/theat)^3-15*(t/theat)^4+6*(t/theat)^5);
% else
%     Tr_sp=Tset;
% end


function Tr_sp=Trsp(Tamb,Tset,theat,t)
if t<=theat
    Tr_sp=Tamb+(Tset-Tamb)*(10*(t/theat)^3-15*(t/theat)^4+6*(t/theat)^5);
 elseif t>theat && t<3000
     Tr_sp=Tset;
 elseif t>=3000 && t<3400
     Tr_sp=Tset-1;
 elseif t>=3400 && t<4000
     Tr_sp=Tset;
 elseif t>=4000 && t<5000
     Tr_sp=Tset+1;
else
    Tr_sp=Tset;
end

% function Tr_sp=Trsp(Tamb,Tset,theat,t)
% if t<=theat
%     Tr_sp=Tamb+(Tset-Tamb)*(10*(t/theat)^3-15*(t/theat)^4+6*(t/theat)^5);
% elseif t>theat && t<2100
%     Tr_sp=Tset;
% elseif t>=2100 && t<2400
%     Tr_sp=Tset-1;
% else
%     Tr_sp=Tset;
% end