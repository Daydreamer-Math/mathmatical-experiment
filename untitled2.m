
%优化模型建立
A = [];
b = [];
Aeq = [];
beq = [];
lb=[];
ub=[];
x0=p;
fun=@(x)y(x); %目标函数
nonlcon=@h; %非线性约束条件
x = fmincon(fun,x0,A,b,Aeq,beq,lb,ub,nonlcon);%最优方案
xa=x(:,1:31);%A水库每天给5个地区的灌水方案
xb=x(:,32:62);%B水库每天给5个地区的灌水方案
xc=x(:,63:93);%C水库每天给5个地区的灌水方案
disp(xa)
disp(xb)
disp(xc)
Va=zeros(1,31);
    Vb=zeros(1,31);
    Vc=zeros(1,31);
    Va(2)=8000;
    Vb(2)=6000;
    Vc(2)=4000;
    for t=2:30
    D1(t)=50*sin(pi*(t-1)/10); %5个地区的灌溉需求
    D2(t)=80;
    D3(t)=120*exp(-1*0.02*(t-1));
    D4(t)=60;
    D5(t)=100*cos(pi*(t-1)/15)+50;
    Qa(t)=200*sin(pi*(t-1)/15)+300; %3个水库每天的自然流入量
    Qb(t)=150*cos(pi*(t-1)/200)+250;
    Qc(t)=100;
    Sa=sum(xa); %水库每天运出的水
    Sb=sum(xb);
    Sc=sum(xc);
    Va(t+1)=0.97*Va(t)+Qa(t)-Sa(t);%A水库的库容变化差分方程
    Vb(t+1)=0.97*Vb(t)+Qb(t)-Sb(t);%B水库的库容变化差分方程
    Vc(t+1)=0.97*Vc(t)+Qc(t)-Sc(t);%C水库的库容变化差分方程
    end

    %水库库容变化曲线图
    figure(1);
    i=1:30;
    va=Va(:,2:31);
    vb=Vb(:,2:31);
    vc=Vc(:,2:31);
    subplot(2,2,1),plot(i,va,"r-."),
    title('Va的库容变化'),gtext('Va'),
    xlabel("t"),ylabel("Va"),legend('Va') %A水库库容变化图
    subplot(2,2,2),plot(i,vb,"k-o"),
    title('Vb的库容变化'),gtext('Vb'),
    xlabel("t"),ylabel("Vb"),legend('Vb') %B水库库容变化图
    subplot("Position",[0.2,0.05,0.6,0.45]),plot(i,vc,"b-*"),
    title('Vc的库容变化'),gtext('Vc'),
    xlabel("t"),ylabel("Vc"),legend('Vc') %C水库库容变化图
    hold off

    %灌溉方案热力图
figure(2);
cadata=xa(:,2:31);
xvalues=1:30;
yvalues={"1号灌溉地","2号灌溉地","3号灌溉地","4号灌溉地","5号灌溉地"};
hea1=heatmap(xvalues,yvalues,cadata);
hea1.Title='Va水库的水力输送';
hea1.XLabel='时间';
hea1.YLabel='运输量';
hea1=heatmap(xvalues,yvalues,cadata); %A水库输送方案热力图

figure(3);
cbdata=xb(:,2:31);
hea2=heatmap(xvalues,yvalues,cbdata);
hea2.Title='Vb水库的水力输送';
hea2.XLabel='时间';
hea2.YLabel='运输量'; %B水库输送方案热力图

figure(4);
ccdata=xc(:,2:31);
hea3=heatmap(xvalues,yvalues,ccdata);
hea3.Title='Vc水库的水力输送';
hea3.XLabel='时间';
hea3.YLabel='运输量'; %C水库输送方案热力图

%成本构成饼状图
F=[0.5,0.6,0.4,0.7,0.8;
   0.4,0.5,0.3,0.6,0.7;
   0.6,0.7,0.5,0.8,0.9];
Ca=zeros(5,31);
Cb=zeros(5,31);
Cc=zeros(5,31);
for i=1:5
Ca(i,:)=F(1,i).*xa(i,:); %A每天给5个地区输送水的成本矩阵
Cb(i,:)=F(2,i).*xb(i,:); %B每天给5个地区输送水的成本矩阵
Cc(i,:)=F(3,i).*xc(i,:); %C每天给5个地区输送水的成本矩阵
end
C1=sum(Ca(:,2:31),2); %A给每个地区输送的水总成本矩阵
C2=sum(Cb(:,2:31),2); %B给每个地区输送的水总成本矩阵
C3=sum(Cc(:,2:31),2); %C给每个地区输送的水总成本矩阵
C=[C1',C2',C3'];
figure(5);
makeup=["水库A输送1号地成本",'水库A输送2号地成本','水库A输送3号地成本','水库A输送4号地成本',  '水库A输送5号地成本','水库B输送1号地成本','水库B输送2号地成本','水库B输送3号地成本',...
    '水库B输送4号地成本','水库B输送5号地成本','水库C输送1号地成本','水库C输送2号地成本','水库C输送3号地成本','水库C输送4号地成本','水库C输送5号地成本'];

piec=piechart(C,makeup);%绘制饼图


function y=y(x) %构造目标函数
xa=x(:,1:31); %水库每天运出去的水
xb=x(:,32:62);
xc=x(:,63:93);
F=[0.5,0.6,0.4,0.7,0.8;
   0.4,0.5,0.3,0.6,0.7;
   0.6,0.7,0.5,0.8,0.9];
Ca=zeros(5,31);
Cb=zeros(5,31);
Cc=zeros(5,31);
for i=1:5
Ca(i,:)=F(1,i).*xa(i,:); %水库运出水的运送成本矩阵
Cb(i,:)=F(2,i).*xb(i,:);
Cc(i,:)=F(3,i).*xc(i,:);
end
y=sum(Ca,"all")+sum(Cb,"all")+sum(Cc,"all");
end


function [c,ceq]=h(x) %整理约束条件
xa=x(:,1:31); %水库每天运出去的水
xb=x(:,32:62);
xc=x(:,63:93);
Va=zeros(1,31);
    Vb=zeros(1,31);
    Vc=zeros(1,31);
    Va(2)=8000;
    Vb(2)=6000;
    Vc(2)=4000;
for t=2:30
    D1(t)=50*sin(pi*(t-1)/10);
    D2(t)=80;
    D3(t)=120*exp(-1*0.02*(t-1));
    D4(t)=60;
    D5(t)=100*cos(pi*(t-1)/15)+50;
    Qa(t)=200*sin(pi*(t-1)/15)+300;
    Qb(t)=150*cos(pi*(t-1)/200)+250;
    Qc(t)=100;
    Sa=sum(xa);
    Sb=sum(xb);
    Sc=sum(xc);
    Va(t+1)=0.97*Va(t)+Qa(t)-Sa(t);
    Vb(t+1)=0.97*Vb(t)+Qb(t)-Sb(t);
    Vc(t+1)=0.97*Vc(t)+Qc(t)-Sc(t);
    c(1,t-1)=-(xa(1,t)+xb(1,t)+xc(1,t))+D1(t); %满足5个地区的用水需求
    c(2,t-1)=-(xa(2,t)+xb(2,t)+xc(2,t))+D2(t);
    c(3,t-1)=-(xa(3,t)+xb(3,t)+xc(3,t))+D3(t);
    c(4,t-1)=-(xa(4,t)+xb(4,t)+xc(4,t))+D4(t);
    c(5,t-1)=-(xa(5,t)+xb(5,t)+xc(5,t))+D5(t);
    c(6,t-1)=1000-Va(t); %满足每天每个水库的最小库容量不少于1000
    c(7,t-1)=1000-Vb(t);
    c(8,t-1)=1000-Vc(t);
    c(9,t-1)=Va(t)-10000; %满足每天每个水库库容量不超过10000
    c(10,t-1)=Vb(t)-10000;
    c(11,t-1)=Vc(t)-10000;
    c(12,t-1)=-1*xa(1,t); %满足运走的水量不可能为负数
    c(13,t-1)=-1*xa(2,t);
    c(14,t-1)=-1*xa(3,t);
    c(15,t-1)=-1*xa(4,t);
    c(16,t-1)=-1*xa(5,t);
    c(17,t-1)=-1*xb(1,t);
    c(18,t-1)=-1*xb(2,t);
    c(19,t-1)=-1*xb(3,t);
    c(20,t-1)=-1*xb(4,t);
    c(21,t-1)=-1*xb(5,t);
    c(22,t-1)=-1*xc(1,t);
    c(23,t-1)=-1*xc(2,t);
    c(24,t-1)=-1*xc(3,t);
    c(25,t-1)=-1*xc(4,t);
    c(26,t-1)=-1*xc(5,t);
end
ceq=[];
end
%寻找满足约束条件的初始值，结束后手动保存变量
clear,clc %创立一个随机矩阵
x=[zeros(5,1),randi([70,80],5,30),zeros(5,1),randi([80,90],5,30),zeros(5,1),randi([20,30],5,30)];
xa=x(:,1:31);
xb=x(:,32:62);
xc=x(:,63:93);
Va=zeros(1,31);
Vb=zeros(1,31);
Vc=zeros(1,31);
Va(2)=8000;
Vb(2)=6000;
Vc(2)=4000;

for t=2:30 %约束条件
    D1(t)=50*sin(pi*((t-1)/10));
    D2(t)=80;
    D3(t)=120*exp(-1*0.02*(t-1));
    D4(t)=60;
    D5(t)=100*cos(pi*(t-1)/15)+50;
    Qa(t)=200*sin(pi*(t-1)/15)+300;
    Qb(t)=150*cos(pi*(t-1)/200)+250;
    Qc(t)=100;
    Sa=sum(xa);
    Sb=sum(xb);
    Sc=sum(xc);
    
    Va(t+1)=0.97*Va(t)+Qa(t)-Sa(t);
    Vb(t+1)=0.97*Vb(t)+Qb(t)-Sb(t);
    Vc(t+1)=0.97*Vc(t)+Qc(t)-Sc(t);
    c(1,t-1)=-(xa(1,t)+xb(1,t)+xc(1,t))+D1(t);
    c(2,t-1)=-(xa(2,t)+xb(2,t)+xc(2,t))+D2(t);
    c(3,t-1)=-(xa(3,t)+xb(3,t)+xc(3,t))+D3(t);
    c(4,t-1)=-(xa(4,t)+xb(4,t)+xc(4,t))+D4(t);
    c(5,t-1)=-(xa(5,t)+xb(5,t)+xc(5,t))+D5(t);
    c(6,t-1)=1000-Va(t);
    c(7,t-1)=1000-Vb(t);
    c(8,t-1)=1000-Vc(t);
    c(9,t-1)=Va(t)-10000;
    c(10,t-1)=Vb(t)-10000;
    c(11,t-1)=Vc(t)-10000;
    c(12,t-1)=-1*xa(1,t);
    c(13,t-1)=-1*xa(2,t);
    c(14,t-1)=-1*xa(3,t);
    c(15,t-1)=-1*xa(4,t);
    c(16,t-1)=-1*xa(5,t);
    c(17,t-1)=-1*xb(1,t);
    c(18,t-1)=-1*xb(2,t);
    c(19,t-1)=-1*xb(3,t);
    c(20,t-1)=-1*xb(4,t);
    c(21,t-1)=-1*xb(5,t);
    c(22,t-1)=-1*xc(1,t);
    c(23,t-1)=-1*xc(2,t);
    c(24,t-1)=-1*xc(3,t);
    c(25,t-1)=-1*xc(4,t);
    c(26,t-1)=-1*xc(5,t);
end
if c<=0 %满足约束条件，输出该随机矩阵并手动保存
    p=x;
    disp(p)
else
    disp("false") %不满足，输出false，根据c的值修改随机矩阵范围，继续运行直到找到符合要求的矩阵
end