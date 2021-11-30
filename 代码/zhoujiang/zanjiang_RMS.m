% 骤降RMS法仿真
% 能求出对应的骤降深度和骤变时间

clear 
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
ya = (1.0000000-a*(t>t1 & t<t2)).*sin(2*pi*50*t);

for i = 1:size(ya,2)-winLen
    yaRe(:,i) = ya(:,i:i+winLen-1);
end

% figure(1);
% subplot(2,1,1)
% plot(t,y);
% title('正常电压信号')
% xlabel('时间/s')
% ylabel('电压/V')
% subplot(2,1,2)
% plot(t,ya);
% title('发生骤降的电压信号')
% xlabel('时间/s')
% ylabel('电压/V')

%获取 rms曲线的最大最小值 计算骤变深度
yaRms = rms(yaRe);
t1 = win :1/fs : 0.50000;
% figure(2)
% plot(t1,yaRms);
% title('半周期均方根值曲线')
% xlabel('时间/s')
% ylabel('半周期均方根值/V')

yaRmsMax =vpa(max(yaRms),7)
yaRmsMin =vpa(min(yaRms),7)
yita = vpa(yaRmsMin/yaRmsMax,7);
fprintf("%.7f\n",yita);
yita_cha = (yita-1+a)/(1-a);
fprintf("%.7f\n",yita_cha);

% 计算骤变时间 设置rms曲线的最高值的gama倍作为阈值，当rms曲线幅值低于阈值时，检查标志位flag1，来确定是处于骤变刚发生还是已经发生
% 通过flag1 可以用于后续确定骤变结束的时间
for k = 1 : size(yaRms,2)
    if (yaRms(1,k) < 0.99* yaRmsMax)
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
end
time_all = vpa(time_end - time_begin,5);
fprintf("%.5f\n",time_all);

