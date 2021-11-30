clear all
clc
fs = 12800;   %采样频率
f=0:0.1:200;
t = 0:1/fs:0.5  %时间
t1=0.2;   %电压暂降开始时间
t2=0.3;   %电压暂降结束时间
a=0.2;    %电压暂降幅值
win=0.01; %更新周
y = sin(2*pi*50*t)
ya = (1+a*(t>t1 & t<t2)).*sin(2*pi*50*t); %电压暂降公式
[st,t,f] = st(ya,0,100,1/fs);
figure(1)
subplot(2,1,1)

plot(t,y)
axis([0 0.5 -1.5 1.5])
subplot(2,1,2)
plot(t,ya)
axis([0 0.5 -1.5 1.5])
z = abs(st);
figure(2)
surf(t,f,abs(z),'EdgeColor','none');
figure(3)

plot(t,abs(z(26,:)))
axis([0 0.5 0.4 0.7])

for j = 1 : 6400
    st_chafen(j) = abs(st(26,j)) - abs(st(26,j+1));
end

result = [];
figure(4);
plot(t(:,1:6400),st_chafen);
Threshold = 200;
temp = zeros(2,1);
for k = 2 : 6399
    if (abs(st_chafen(k)) > abs(st_chafen(k-1))) && (abs(st_chafen(k)) > abs(st_chafen(k+1)))
        flag = 1;
        for threshold = 1 : Threshold
            if (st_chafen(k) * st_chafen(k + threshold) <= 0) || (st_chafen(k) * st_chafen(k-threshold) < 0) || (abs(st_chafen(k)) < 1e-5)
                flag = 0;
            end
        end
        
        if (flag == 1)
            
            temp = transpose([t(k) st_chafen(k)]);
            result = [result temp];
%             fprintf('发生骤变时间为 %d\n',t(k));
%             fprintf('%f\n',st_chafen(k));
            [stmin,minindex] = min(result,[],2);  
            Tmin = result(1,minindex(2))
            Emin = stmin(2,1);
            [stmax,maxindex] = max(result,[],2); 
            Tmax = result(1,maxindex(2))
            Emax = stmax(2,1);
            td = Tmax - Tmin;
            if (td < 0)
                t1 = Tmax;
                t2 = Tmin;
                td = t2 - t1;
                fprintf("发生了骤降\n");
                fprintf("骤降持续时间为: %f\n",td);
            else
                t1 = Tmin;
                t2 =Tmax;
                td = t2 - t1;
                fprintf("发生了骤升\n");
                fprintf("骤升持续时间为: %f\n",td);
            end
        
        end
        
        
        
        
    end
     
end
