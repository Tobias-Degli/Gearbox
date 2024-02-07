clc
clear
close all

load('data.mat');
% Definindo o tempo
n=size(data.Time); n=n(1); duracao=5; incr_t=0.00002; t=(0:incr_t:duracao); 

% Discretizando o sinal analógico do encoder 1 em onda quadrada
a_atual=discretizacao(data.Dev1_ai8,n);
a_anterior=a_atual(2:n); a_atual=a_atual(1:n-1);
b_atual=discretizacao(data.Dev1_ai12,n);
b_anterior=b_atual(2:n); b_atual=b_atual(1:n-1);
mat_1=[a_atual,a_anterior,b_atual,b_anterior];

% Discretizando o sinal analógico do encoder 2 em onda quadrada
a_atual=discretizacao(data.Dev1_ai10,n);
a_anterior=a_atual(2:n); a_atual=a_atual(1:n-1);
b_atual=discretizacao(data.Dev1_ai15,n);
b_anterior=b_atual(2:n); b_atual=b_atual(1:n-1);
mat_2=[a_atual,a_anterior,b_atual,b_anterior];

% Função que acha os incrementos (demora muito)
% Roda só uma vez e salva os dados para trabalhar
%s1=incremento(mat_1,n-1); save('incr1.mat');
%s2=incremento(mat_2,n-1); save('incr2.mat');
incr1=load('incr1.mat'); incr2=load('incr2.mat');

% Deslocamento acumulado em forma de degral
t1=t(1:n-1); y1 = zeros(1,n-1)'; y2 = zeros(1,n-1)';
for i=2:n-1
    y1(i)=y1(i-1)+incr1.s1(i);
    y2(i)=y2(i-1)+incr2.s2(i);
end

% Deslocamento  acumulado real, suavizado por interpolação ponto a ponto
yy1=360*interpolacao(t1,y1,n-1)/4000;
yy2=360*interpolacao(t1,y2,n-1)/4000;

% Velocidade por derivação por método numérico via MATLAB
dyy1=n*diff(yy1)/duracao;
dyy2=n*diff(yy2)/duracao;

% media móvel ajuda para limpar o sinal por ter muitas amostras
dyy1m=n*diff(movmean(yy1,n/500))/duracao;
dyy2m=n*diff(movmean(yy2,n/500))/duracao;

% Filtro de dados (Remove ruído dos dados iniciais da velocidade)
yy1=filtro(yy1,n); nn=size(yy1); t_y1=(0:incr_t:nn*incr_t);
yy2=filtro(yy2,n); nn=size(yy2); t_y2=(0:incr_t:nn*incr_t);
dyy1=filtro(dyy1,n); nn=size(dyy1); t_d1=(0:incr_t:nn*incr_t);
dyy2=filtro(dyy2,n); nn=size(dyy2); t_d2=(0:incr_t:nn*incr_t);

% Obtenção do torque através da medição de corrente
% https://simplemotor.com/calculations/
tensao_desligado=data.Dev1_ai14(100:500); tensao_desligado=mean(tensao_desligado);
tensao_ligado=data.Dev1_ai14; corrente=(tensao_ligado-tensao_desligado)/0.1;
I=corrente; V=24; E=0.7; rpm=1;
T = (I * V * E *60) / (rpm*2*pi);

% Tamanho da amostra a ser usada no LM.
tam=n-size(dyy2); k=tam(1); passo=10; tam=10000; j=1;
for i=1:tam
    dyyt(i)=dyy2(j);
    t_t(i)=t_d2(j);
    yyy1(i)=yy1(j);
    yyy2(i)=yy2(j);
    dyyy1(i)=dyy1(j);
    rpm=60*dyyt(i)/360;
    Tt(i)=T(k)/rpm;
    j=j+passo;
    k=k+passo;

end

%Fitt curve for Torque
i=2; f=tam; x=t_t(i:f)'; y=Tt(i:f)'; f1=fit(x,y,'exp2')

figure(); plot(x,y,'LineWidth',1.5,'color',"k"); hold on; plot(f1); hold off; 
legend('Experimental','Aproximação','Interpreter','latex')
xlabel('t [s]');
ylabel('T_{in} [Nm]');

% ----------------------------------LM-----------------------------------------
% ESCOLHA DA VARIÁVEL DE ESTADO (Grau de liberdade)
% p=1; % Posição do eixo de entrada
% p=2; % Posição do pinhão
% p=3; % Posição da engrenagem
% p=4; % Posição do eixo de saída
% p=5; % Velocidade do eixo de entrada
% p=6; % Velocidade do pinhão
 p=7; % Velocidade da engrenagem
% p=8; % Velocidade do eixo de saída

% Parâmetros do modelo
Im=0.001264; IL=0.0016769; Ip=0.00128825; Ig=0.20612; rp=0.015; rg=0.03; Tout=0;
noise=0.01; qmb=9429.559471*noise; kc=163.3*noise; kmb=485305730*noise; k4=2*2.658; qc=0.06;

% Dados do experimento e da simulação
yexp=pi*dyyt/180; t=t_t; ti=t(1); tf=t(end); y0 = [0 ,0 ,0 ,0 ,0 ,0 ,0 ,0];
n_pontos=size(t); n_pontos=n_pontos(2); n_pontos=n_pontos(1); freq=(tf-ti)/n_pontos;  tspan1=ti:freq:tf;
n_pontos2=n_pontos/2;  freq=(tf-ti)/n_pontos2; tspan=ti:freq:tf; correct=n_pontos/n_pontos2; tempo=0*tspan;

% Parâmetros do algorítmo LM
eps=0.0001; lambda=1; Np=3; omega=eye(Np,Np); e3 = 0.0001; % erro do critério de parada
sigma= 0.0137; diag_w=zeros(n_pontos2,1)+1/sigma^2; w = diag(diag_w);% graus / segundo PEREIRA_2020 pag 64

i=0;
while i<250 % Valor grande, maior que o número de iterações necessário para convergir
    i=i+1
    [~,y] = ode45(@(t,y) GPdydt(t,tf,y,Im,IL,Ip,Ig,kc(i),qc,qmb(i),kmb(i),Tout,rp,rg,k4), tspan, y0);
    yhat=y(2:end,p);
    [~,y] = ode45(@(t,y) GPdydt(t,tf,y,Im,IL,Ip,Ig,kc(i)+eps*kc(i),qc,qmb(i),kmb(i),Tout,rp,rg,k4), tspan, y0);
    ykc=y(2:end,p); dykc=(ykc-yhat)/(eps*kc(i));
    [~,y] = ode45(@(t,y) GPdydt(t,tf,y,Im,IL,Ip,Ig,kc(i),qc,qmb(i)+eps*qmb(i),kmb(i),Tout,rp,rg,k4), tspan, y0);
    yqmb=y(2:end,p); dyqmb=(yqmb-yhat)/(eps*qmb(i));
    [~,y] = ode45(@(t,y) GPdydt(t,tf,y,Im,IL,Ip,Ig,kc(i),qc,qmb(i),kmb(i)+eps*kmb(i),Tout,rp,rg,k4), tspan, y0);
    ykmb=y(2:end,p);  dykmb=(ykmb-yhat)/(eps*kmb(i));
    J=[dykc,dyqmb,dykmb]; %SEQUÊNCIA
    for ii=1:Np
        omega(ii,ii)=J(ii,ii);
    end
    yexp2=yhat*0;
    for ind=1:size(yhat)
        yexp2(ind)=yexp(correct*ind-1);
        tempo(ind)=tspan1(correct*ind-1);
    end
    s1=(yexp2-yhat)'*w*(yexp2-yhat);
    Mat_A=J'*w*J;
    Vet_B=J'*w*(yexp2-yhat);
    P0=linsolve(Mat_A,Vet_B);
    % Deve respeitar a sequência
    kc(i+1)=kc(i)+P0(1); qmb(i+1)=qmb(i)+P0(2); kmb(i+1)=kmb(i)+P0(3);

    [~,y] = ode45(@(t,y) GPdydt(t,tf,y,Im,IL,Ip,Ig,kc(i+1),qc,qmb(i+1),kmb(i+1),Tout,rp,rg,k4), tspan, y0);
    yhat=y(2:end,p);
    s2=(yexp2-yhat)'*w*(yexp2-yhat);
    if s2>s1 %(Entra neste looping se a est. tiver ruim)
        lambda(i+1)=lambda(i)*10;
        kc(i+1)=kc(i); qmb(i+1)=qmb(i); kmb(i+1)=kmb(i);
    else
        lambda(i+1)=0.1*lambda(i);
    end
    %Critério de parada
    Pk_atual=[kc(i+1),qmb(i+1),kmb(i+1)];
    Pk_anterior=[kc(i),qmb(i),kmb(i)];
    if (max(abs(Pk_atual-Pk_anterior)))< e3
        i=100000 % Valor grande só para encerrar o while
    end
end
toc

[~,y] = ode45(@(t,y) GPdydt(t,tf,y,Im,IL,Ip,Ig,kc(end),qc,qmb(end),kmb(end),Tout,rp,rg,k4), tspan1, y0);

figure ()
plot(kmb)
grid on
legend('kmb')
xlabel('i');
ylabel('k_{mb} (N/m)');

figure ()
plot(qmb)
grid on
legend('qmb')
xlabel('i');
ylabel('q_{mb}');

figure ()
plot(kc)
grid on
legend('kc')
xlabel('i');
ylabel('k_{c} (N/m)');

figure ()
plot(tspan1(2:end),movmean(180*y(2:end,2)/pi,n/1000),'LineWidth',2,'color',"b")
hold on
plot(tspan1(2:end),180*y(2:end,3)/pi,'color',"#0072BD")
hold on
plot(tspan1(2:end),-yyy1,"--",'LineWidth',2,'color',"r")
hold on
plot(tspan1(2:end),yyy2,"--",'LineWidth',2,'color',"k")
hold off
legend({'$\theta_p$ model','$\theta_g$ model','$\theta_p$ exp','$\theta_g$ exp'},'Interpreter','latex')
xlabel('t (s)');
ylabel({'dθ/dt (°/s)'},'Interpreter','latex');

figure ()
plot(tspan1(2:end),movmean(180*y(2:end,6)/pi,n/1000),'color',"b")
hold on
plot(tspan1(2:end),180*y(2:end,7)/pi,'color',"#0072BD")
hold on
plot(tspan1(2:end),-movmean(dyyy1,n/2000),'color',"red")
hold on
plot(tspan1(2:end),movmean(180*yexp/pi,n/1000),'color',"k")
hold off
legend({'$d\theta_p$ model','$d\theta_g$ model','$d\theta_p$ exp','$d\theta_g$ exp'},'Interpreter','latex')
xlabel('t (s)');
ylabel({'dθ/dt (°/s)'},'Interpreter','latex');
