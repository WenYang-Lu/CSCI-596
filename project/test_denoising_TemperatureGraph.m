clear all; close all;
rng(7); % random seed

%% Graph and Signal
load("data/Temperature_Graph.mat");

A=double(full(G.W)); % adjacency matrix
[VA,lamA]=eig(A); lamA=diag(lamA); lmaxA=max(lamA); lminA=min(lamA);  

L=diag(sum(A))-A; % Laplacian matrix
[VL,lamL]=eig(L); lamL=diag(lamL); G.L=L; lmaxL=max(lamL); G.lmax=lmaxL;

N=G.N; % total number of graph nodes
x=(G.maxTemp+G.minTemp)/2; % graph signal: average temperature
% x=G.minTemp % graph signal: average temperature

%% Ideal filter
fc=0.4; %cut-off frequency
fun_gL= @(lam) double(lam<=fc*lmaxL);
fun_gA= @(lam) double(lam>=-(fc-0.5)*2*lmaxA);

%% Chebyshev filter approximation
M=10; % filter's polynomial order
[b_butter,a_butter] = butter(3,fc);
fun_butter= @(lam) abs(polyval(b_butter,exp(-1j*lam/lmaxL*pi))./polyval(a_butter,exp(-1j*lam/lmaxL*pi)));
c_cheby=gsp_cheby_coeff(G,fun_butter,M);

%% Noisy signal setting
mu=0; 
sig=sqrt(0.5);
% sig=sqrt([0.25,0.2,0.15,0.1,0.05]); 
% sig=sqrt([2.5,2.0,1.5,1.0,0.5]); 
% sig=sqrt([5,4,3,2,1]);
% sig=sqrt([8.0, 6.5, 5.0, 3.5, 2.0]);
% sig=sqrt([7, 5.5, 4, 2.5]);

S=length(sig);
xn=zeros(N,S); %noisy signal
for s=1:S
    xn(:,s)=x+sig(s)*randn(N,1)+mu;
end

%% filtering process
MSE_ori=zeros(1,S); SNR_ori=zeros(1,S);
MSE_chebyL=zeros(1,S); SNR_chebyL=zeros(1,S); runtime_chebyL=zeros(1,S);
MSE_chebyA=zeros(1,S); SNR_chebyA=zeros(1,S); runtime_chebyA=zeros(1,S);

for s=1:S
    MSE_ori(s)=immse(x,xn(:,s)); % MSE_ori=norm(fn-f).^2/N;
    SNR_ori(s)=snr(x,xn(:,s)-x); % SNR_ori=20*log10(norm(f)/norm(fn-f));

    % chebyshev filtering
    tic;
    y_chebyL=myGraphCheby_op(L,c_cheby/2,xn(:,s),[0,lmaxL],true); 
    runtime_chebyL(s)=toc; 
    tic;
    y_chebyA=myGraphCheby_op(A,c_cheby/2,xn(:,s),[-lmaxA,lmaxA],false); 
    runtime_chebyA(s)=toc;
        
    % SNR calculation
    MSE_chebyL(s)=immse(x,y_chebyL); SNR_chebyL(s)=snr(x,y_chebyL-x);
    MSE_chebyA(s)=immse(x,y_chebyA); SNR_chebyA(s)=snr(x,y_chebyA-x);
end

% runtime (millisecond)
time_chebyL=sum(runtime_chebyL)/S*1000;
time_chebyA=sum(runtime_chebyA)/S*1000;
%% write csv files
writematrix(L,"IOdata/L.csv");
writematrix(A,"IOdata/A.csv");
writematrix(x,"IOdata/x.csv");
writematrix(xn,"IOdata/xn.csv");
writematrix(c_cheby/2,"IOdata/filterCoeff.csv");
writematrix([0,lmaxL],"IOdata/eigValRangeL.csv");
writematrix([-lmaxA,lmaxA],"IOdata/eigValRangeA.csv");
writematrix(y_chebyL,"IOdata/y_L.csv");
writematrix(y_chebyA,"IOdata/y_A.csv");

%% plot filter response --- L
figure('Position', [550, 360, 500, 300]);  hold on; 
xlim([0,lmaxL]); ylim([-0.2,1.2]);
xlabel('Graph frequency \lambda'); title('Magnitude Response');

num_grid=500; 
lam_grid=linspace(0,lmaxL,num_grid)';
%%%%%% ideal %%%%%%
plot(lam_grid,fun_gL(lam_grid),'k','Linewidth',2); 
%%%%%% chebyshev %%%%%%
plot(lam_grid,gsp_cheby_eval(lam_grid,c_cheby,[0,lmaxL]),'linewidth',2);

legend({'Ideal','Chebyshev'},'fontsize',14,'Location','southwest');
set(gca,'Fontsize',14');
screen2tif('result_plot/FilterRespL');

%% plot filter response --- A
figure('Position', [550, 360, 500, 300]);  hold on; 
xlim([-1,1]); ylim([-0.2,1.2]);
xlabel('Graph frequency \lambda'); title('Magnitude Response');

num_grid=500;
lam_grid=linspace(-lmaxA,lmaxA,num_grid)';

%%%%%% ideal %%%%%%
plot(lam_grid,fun_gA(lam_grid),'k','Linewidth',2);
%%%%%% chebyshev %%%%%%
plot(lam_grid,mycheby_eval(lam_grid,c_cheby/2,[-lmaxA,lmaxA],'chebyA'),'linewidth',2);
legend({'Ideal','Chebyshev [6]'},'fontsize',14,'Location','southeast');
set(gca,'Fontsize',14');
screen2tif('result_plot/FilterRespA');


%% plot signal spectrum  --- L
figure('Position', [550, 360, 500, 300]);  hold on; 
plot(lamL,abs(VL\x),'Linewidth',2); 
ylim([0,20]);
xlabel('Graph frequency \lambda'); title('Magnitude of Spectrum');
set(gca,'FontSize',14);
screen2tif('result_plot/OriSignal_SpecL');

%%  plot signal spectrum  --- A
figure('Position', [550, 360, 500, 300]);  hold on;
plot(lamA,abs(VA\x),'Linewidth',2); 
ylim([0,110]);
xlabel('Graph frequency \lambda'); title('Magnitude of Spectrum');
set(gca,'FontSize',14);
screen2tif('result_plot/OriSignal_SpecA');

%% plot graph signal --- original
figure('Position', [550, 360, 350, 250]);   hold on; 
param.colorbar=1;
gsp_plot_signal(G,x,param); % original signal
c1=caxis;

figure('Position', [550, 360, 350, 250]);   hold on; 
param.colorbar=1; 
gsp_plot_signal(G,xn(:,s),param); % noisy signal
caxis(c1);
%%  plot denoised signal --- L
figure('Position', [550, 360, 350, 250]);   hold on; 
param.colorbar=1;
gsp_plot_signal(G,y_chebyL,param);
caxis(c1);
screen2tif('result_plot/DenoisedSignal_L');

%% plot denoised signal --- A
figure('Position', [550, 360, 350, 250]);   hold on; 
param.colorbar=1;
gsp_plot_signal(G,y_chebyA,param);
% caxis(c1);
screen2tif('result_plot/DenoisedSignal_A');


