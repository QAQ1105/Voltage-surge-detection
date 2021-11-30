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
ya = (1.0000000+a*(t>t1 & t<t2)).*sin(2*pi*50*t);
fprintf("111");

for i = 1:size(ya,2)-winLen
    yaRe(:,i) = ya(:,i:i+winLen-1);
end
fprintf("222");

figure(1) 

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
figure(2)
t1 = win :1/fs : 0.50000;
plot(t1,yaRms);
title('半周期均方根值曲线')
xlabel('时间/s')
ylabel('半周期均方根值/V')

yaRmsMax =vpa(max(yaRms),7)
yaRmsMin =vpa(min(yaRms),7)
yita = vpa(yaRmsMax/yaRmsMin,7);
fprintf("%.7f\n",yita);
yita_cha = (yita-1-a)/(1+a);
fprintf("%.7f\n",yita_cha);

for k = 1 : size(yaRms,2)
    if (yaRms(1,k) >1.01* yaRmsMin)
        if (flag1 == 1)
        continue;
        else
            flag1 = 1;
            time_begin = (k-1)/winLen*0.01+0.01;
            fprintf("%.5f\n",time_begin);
            fprintf("%d\n",k);
        end
    else
        if (flag1 == 1)
            time_end = (k-1)/winLen*0.01+0.01;
            fprintf("%.5f\n",time_end);
            fprintf("%d\n",k);
            flag1 = 0;
        
        else
            continue;
        end
    end

end
time_all = vpa(time_end - time_begin,5)
fprintf("%.5f\n",time_all);

