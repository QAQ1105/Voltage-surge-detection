% 骤变信号检测 S变换改进法
% 可区分骤升骤降信号
clc;
clear all;
%X为td的预计算值 Y为对应的S变换自适应参数值 拟合成五次多项式
X = [0.01863, 0.01963, 0.02274, 0.02698, 0.02999, 0.03081, 0.03136, 0.03352, 0.03648, 0.03879, 0.03935, 0.04021, 0.043, 0.04685, 0.04970, 0.05046, 0.05109, 0.0534, 0.05655, 0.05898, 0.05959, 0.06039, 0.06308, 0.0668, 0.06958, 0.07032, 0.07098, 0.07334, 0.0766, 0.07907, 0.0797, 0.08048, 0.08312, 0.08677, 0.0895, 0.090227, 0.09091, 0.09332, 0.09660, 0.09912, 0.09976, 0.10054, 0.10315, 0.10675, 0.10945, 0.11018, 0.11087, 0.1133, 0.11662, 0.11916, 0.11982, 0.12058, 0.12316, 0.12673, 0.12942, 0.13013, 0.13084, 0.13328, 0.13663, 0.1392, 0.13985, 0.14061, 0.14318, 0.14672, 0.14939, 0.1501, 0.1508, 0.15327, 0.15665, 0.15922, 0.15988, 0.16063, 0.16319, 0.16671, 0.16938, 0.17007, 0.17078, 0.17326, 0.17666, 0.17924, 0.17991];
Y=([30.0, 29.0, 28.0, 26.0, 23.0, 22.0, 22.0, 22.0, 22.0, 23.0, 23.0, 23.0, 22.0, 21.0, 19.0, 18.0, 18.0, 16.0, 14.0, 13.0, 13.0, 13.0, 13.0, 12.0, 11.0, 11.0, 11.0, 11.0, 11.0, 11.0, 11.0, 11.0, 11.0, 10.0, 10.0, 10.0, 10.0, 9.0, 8.0, 8.0, 8.0, 8.0, 8.0, 7.0, 7.0, 7.0, 7.0, 7.0, 7.0, 7.0, 7.0, 7.0, 7.0, 6.0, 6.0, 6.0, 6.0, 6.0, 5.0, 5.0, 5.0, 5.0, 5.0, 5.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 4.0, 3.0, 3.0, 3.0]-1)*0.1+1;
p = polyfit(X,Y,5);
alpha=5;%初始S变换参数值
T = 0.5;%采样时间
fs =128000; %采样频率
t = 0:1/fs:T-1/fs; %时间
t1=0.20001;   %电压骤变开始时间
t2=0.32001;   %电压骤变结束时间
a=0.2000001;    %电压骤变幅值
y = sin(2*pi*50*t);%正常电压信号
ya = (1.0000000-a*(t>t1 & t<t2)).*sin(2*pi*50*t); %发生骤变的电压信号
global td;%电压骤变的持续时间
global Tmin;
global Tmax;
global result;
global flag;%用于判断是否
% figure(1);
% plot(t,ya);   
[st,t,f] = st_gaijin(ya,alpha,0,200,1/(fs),1);
% figure(2); 
% surf(t,f,abs(st),'EdgeColor','none');
% title('发生骤升的电压信号的S变换时间-频率-幅值图像');
% xlabel("时间/s");
% ylabel("频率/Hz");
% zlabel("幅值");
% % figure(3);
% plot(t,abs(st(26,:)));
% title("基频幅值曲线");
% xlabel("时间/s");
% ylabel("幅值");
% axis([0 0.5 0.35 0.5]);

%获取差分曲线
for j = 1 : T * fs-1
    st_chafen(j) = abs(st(26,j)) - abs(st(26,j+1));
end

%获取s变换的最大值和最小值，用于计算骤变深度
Amax = max(abs(st(26,:)));
Amin = min(abs(st(26,:)));

% % figure(4);
% plot(t(:,1:T*fs-1),st_chafen);
% title("基频幅值向量差分曲线");
% xlabel("时间/s");
% ylabel("差分值");


Threshold = 0;%对满足下面的极值条件的点的过滤阈值
result = [];%初始化result数组用来存放差分曲线极值对应的时间

%寻找并过滤差分曲线的极值点
%flag用于判断极值点是否满足阈值条件

for k = 2 : (T*fs - 2) 
    if (abs(st_chafen(k)) > abs(st_chafen(k-1))) && (abs(st_chafen(k)) > abs(st_chafen(k+1)))
        flag = 1;

        for threshold = 0 : Threshold
            if (st_chafen(k) * st_chafen(k + threshold) < 0) ||(st_chafen(k) * st_chafen(k-threshold) < 0) || (abs(st_chafen(k)) < 1e-7)
                flag = 0;
            end
        end
        if (flag == 1)
            temp = zeros(2,1);
            temp = transpose([t(k) st_chafen(k) ]);
            result = [result temp];
            [stmin,minindex] = min(result,[],2);  
            Tmin = result(1,minindex(2));
            [stmax,maxindex] = max(result,[],2); 
            Tmax = result(1,maxindex(2));
            td = Tmax - Tmin;
        end
    end 
end

%初步计算出骤变的持续时间，并用之前得到的拟合公式来获取自适应参数alpha_new
if (td < 0)
   t_begin = vpa(Tmax,5);
   t_end = vpa(Tmin,5);
   alpha_new = polyval(p,Tmin - Tmax);
   td = vpa(t_end - t_begin,5); 
   td_cha = vpa(td-(t2-t1),5);
   
   
   fprintf("%.5f\n",t1);
   fprintf("%.5f\n",t2);
   fprintf("发生了骤降\n");
   fprintf("骤降持续时间为: %.5fs\n",td);
   yita = vpa(Amin/Amax,7);
   fprintf("%.7f",yita);
   yita_cha = vpa((yita-1+a)/(1-a),7);
else
   t_begin = vpa(Tmax,5);
   t_end = vpa(Tmin,5);
   td = vpa(t_begin - t_end,5);
   td_cha = vpa(td-(t2-t1),5);
   alpha_new = polyval(p,Tmax - Tmin);
   fprintf("%.5f\n",t1);
   fprintf("%.5f\n",t2);
   fprintf("发生了骤升\n");
   fprintf("骤升持续时间为: %5fs\n",td);
   yita = vpa(Amax/Amin,7);
   fprintf("%.7f",yita);
   yita_cha = vpa((yita-1-a)/(1+a),7);
   
   
end



% figure(1);
% plot(t,ya);   
% 使用上述计算出的新的自适应参数进行S变换
[st,t,f] = st_gaijin(ya,alpha_new,0,200,1/(fs),1);
% figure(2); 
% surf(t,f,abs(st),'EdgeColor','none');
% title('发生骤升的电压信号的S变换时间-频率-幅值图像');
% xlabel("时间/s");
% ylabel("频率/Hz");
% zlabel("幅值");
% % figure(3);
% plot(t,abs(st(26,:)));
% title("基频幅值曲线");
% xlabel("时间/s");
% ylabel("幅值");
% axis([0 0.5 0.35 0.5]);

%获取差分曲线
for j = 1 : T * fs-1
    st_chafen(j) = abs(st(26,j)) - abs(st(26,j+1));
end

%获取s变换的最大值和最小值，用于计算骤变深度
Amax = max(abs(st(26,:)));
Amin = min(abs(st(26,:)));

% % figure(4);
% plot(t(:,1:T*fs-1),st_chafen);
% title("基频幅值向量差分曲线");
% xlabel("时间/s");
% ylabel("差分值");


Threshold = 0;%对满足下面的极值条件的点的过滤阈值
result = [];%初始化result数组用来存放差分曲线极值对应的时间

%寻找并过滤差分曲线的极值点
%flag用于判断极值点是否满足阈值条件

for k = 2 : (T*fs - 2) 
    if (abs(st_chafen(k)) > abs(st_chafen(k-1))) && (abs(st_chafen(k)) > abs(st_chafen(k+1)))
        flag = 1;

        for threshold = 0 : Threshold
            if (st_chafen(k) * st_chafen(k + threshold) < 0) ||(st_chafen(k) * st_chafen(k-threshold) < 0) || (abs(st_chafen(k)) < 1e-7)
                flag = 0;
            end
        end
        if (flag == 1)
            temp = zeros(2,1);
            temp = transpose([t(k) st_chafen(k) ]);
            result = [result temp];
            [stmin,minindex] = min(result,[],2);  
            Tmin = result(1,minindex(2));
            [stmax,maxindex] = max(result,[],2); 
            Tmax = result(1,maxindex(2));
            td = Tmax - Tmin;
        end
    end 
end

%初步计算出骤变的持续时间，并用之前得到的拟合公式来获取自适应参数alpha_new
if (td < 0)
   t_begin = vpa(Tmax,5);
   t_end = vpa(Tmin,5);
   alpha_new = 0.2609/(Tmin-Tmax+0.0488);
   td = vpa(t_end - t_begin,5); 
   td_cha = vpa(td-(t2-t1),5);
   
   
   fprintf("%.5f\n",t1);
   fprintf("%.5f\n",t2);
   fprintf("发生了骤降\n");
   fprintf("骤降持续时间为: %.5fs\n",td);
   yita = vpa(Amin/Amax,7);
   fprintf("%.7f",yita);
   yita_cha = vpa((yita-1+a)/(1-a),7);
else
   t_begin = vpa(Tmax,5);
   t_end = vpa(Tmin,5);
   td = vpa(t_begin - t_end,5);
   td_cha = vpa(td-(t2-t1),5);
   alpha_new = 0.2609/(-Tmin+Tmax+0.0488);
   fprintf("%.5f\n",t1);
   fprintf("%.5f\n",t2);
   fprintf("发生了骤升\n");
   fprintf("骤升持续时间为: %5fs\n",td);
   yita = vpa(Amax/Amin,7);
   fprintf("%.7f",yita);
   yita_cha = vpa((yita-1-a)/(1+a),7);
   
   
end




