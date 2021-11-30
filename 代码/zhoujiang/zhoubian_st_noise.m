% 骤变信号的S变换法仿真，可区分骤降骤升信号
% 加入噪声版本
clc;
clear all;
alpha=5;%初始S变换参数值
T = 0.5;%采样时间
fs =128000; %采样频率
t = 0:1/fs:T-1/fs; %时间
t1=0.20001;   %电压骤变开始时间
t2=0.32001;   %电压骤变结束时间
a=0.2000001;    %电压骤变幅值
y = sin(2*pi*50*t);%正常电压信号
ya = (1.0000000-a*(t>t1 & t<t2)).*sin(2*pi*50*t); %发生骤变的电压信号
yaNoise = awgn(ya,10);
global td;%电压骤变的持续时间
global Tmin;
global Tmax;
global result;
global flag;%用于判断是否
figure(1);
plot(t,yaNoise);   
[st,t,f] = st_gaijin(yaNoise,alpha,0,200,1/(fs),1);
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
            fprintf("666\n");
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
   fprintf("%.5f\n",t1);
   fprintf("%.5f\n",t2);
   fprintf("发生了骤升\n");
   fprintf("骤升持续时间为: %5fs\n",td);
   yita = vpa(Amax/Amin,7);
   fprintf("%.7f",yita);
   yita_cha = vpa((yita-1-a)/(1+a),7);
end
