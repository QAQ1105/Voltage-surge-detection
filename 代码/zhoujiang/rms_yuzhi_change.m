% 求解rms法中的最佳阈值

clear all;
clc;
fs = 128000;   %采样频率
t = 0:1/fs:0.50000;  %时间
t1=0.20001;   %电压暂降开始时间
t2=0.36001;   %电压暂降结束时间
a=0.2000001;    %电压暂降幅值
win=0.01000; %更新周期
winLen = win * fs;
y = sin(2*pi*50*t);
flag1 = 0;
global time_begin;
global time_end;
global k_result;
global k_begin;
ya = (1.0000000-a*(t>t1 & t<t2)).*sin(2*pi*50*t);


for i = 1:size(ya,2)-winLen
    yaRe(:,i) = ya(:,i:i+winLen-1);
end


% figure(1) 

subplot(2,1,1)
plot(t,y);
title('正常电压信号')
xlabel('时间/s')
ylabel('电压/V')
subplot(2,1,2)
plot(t,ya);
title('发生骤降的电压信号')
xlabel('时间/s')
ylabel('电压/V')

yaRms = rms(yaRe);
% figure(2)
t1 = win :1/fs : 0.50000;
plot(t1,yaRms);
title('半周期均方根值曲线')
xlabel('时间/s')
ylabel('半周期均方根值/V')

yaRmsMax =vpa(max(yaRms),7);
yaRmsMin =vpa(min(yaRms),7);
yita = vpa(yaRmsMin/yaRmsMax,7);
%fprintf("%.7f\n",yita);
yita_cha = (yita-1+a)/(1-a);
%fprintf("%.7f\n",yita_cha);
for gama = 0.9:0.01:0.99
    
    for k = 1 : size(yaRms,2)
    if (yaRms(1,k) < gama*yaRmsMax)
        k_begin = k;
        break;
        
    end
    end
for k = 1 : size(yaRms,2)
    if (yaRms(1,k) < gama*yaRmsMax)
        k_result(k) = k;
        
    end
end
    if (yaRms(1,k) < gama* yaRmsMax)
        if (flag1 == 1)
        continue;
        else
            flag1 = 1;
            time_begin = (k-1)/winLen*0.01+0.01;
%             fprintf("%.5f\n",time_begin);
%             fprintf("%d",k);
        end
    else
        if (flag1 == 1)
            time_end = (k-1)/winLen*0.01+0.01;
%             fprintf("%.5f\n",time_end);
%             fprintf("%d",k);
            flag1 = 0;
        
        else
            continue;
        end
    end



for m = 1 : size(k_result)
    if (k_result(1,m) > 0)
        k_begin = k_result(1,m)
        
    end
    break;
end

[K_end,k_end] = max(k_result)
time_begin = (k_begin-1)/winLen*0.01+0.01
time_end = (k_end-1)/winLen*0.01+0.01
time_all = vpa(time_end - time_begin,5)
fprintf("%.5f\n",time_all);
time_cha_result((gama-0.9)/0.001+1) = time_all - 0.16;

end
    
   

