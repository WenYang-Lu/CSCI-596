clear all; close all;
rng(7); % random seed

%% Graph and Signal
load("data/Temperature_Graph.mat");

A=double(full(G.W)); % adjacency matrix
lmaxA=eigs(A,1); [VA,lamA]=eig(A); lamA=diag(lamA);

L=diag(sum(A))-A; % Laplacian matrix
lmaxL=eigs(L,1); [VL,lamL]=eig(L); lamL=diag(lamL); G.L=L; G.lmax=lmaxL;

N=G.N; % total number of graph nodes
x=(G.maxTemp+G.minTemp)/2; % graph signal: average temperature

%% Ideal filter
fcL=0.75; %cut-off frequency
fun_gL= @(lam) double(lam<=fcL*lmaxL);
fun_gA= @(lam) double(lam>=-(fcL-0.5)*2*lmaxA);

%% Chebyshev filter approximation
M=20; % filter's polynomial order
c_cheby=gsp_cheby_coeff(G,fun_gL,M);

%% Noisy signal setting
mu=0; 
sig=sqrt(0.25);
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

    % chebyshev filter
    tic;
    y_chebyL=gsp_cheby_op(G,c_cheby,xn(:,s)); 
    runtime_chebyL(s)=toc; 
    tic;
    y_chebyA=myGraphCheby_op(A,c_cheby/2,xn(:,s),[-lmaxA,lmaxA]); 
    runtime_chebyA(s)=toc;
        
    % SNR calculation
    MSE_chebyL(s)=norm(y_chebyL-x)/norm(x); SNR_chebyL(s)=snr(x,y_chebyL-x);
    MSE_chebyA(s)=norm(y_chebyA-x)/norm(x); SNR_chebyA(s)=snr(x,y_chebyA-x);
end

% runtime (millisecond)
time_chebyL=sum(runtime_chebyL)/S*1000;
time_chebyA=sum(runtime_chebyA)/S*1000;

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
ylim([0,80]);
xlabel('Graph frequency \lambda'); title('Magnitude of Spectrum');
set(gca,'FontSize',14);
screen2tif('result_plot/OriSignal_SpecA');

%% plot graph signal
figure('Position', [550, 360, 350, 250]);   hold on; 
param.colorbar=1;
gsp_plot_signal(G,x,param); % original signal

figure('Position', [550, 360, 350, 250]);   hold on; 
param.colorbar=1; 
gsp_plot_signal(G,xn(:,s),param); % noisy signal

%%  plot denoised signal --- L
figure('Position', [550, 360, 350, 250]);   hold on; 
param.colorbar=1;
gsp_plot_signal(G,y_chebyL,param);
screen2tif('result_plot/DenoisedSignal_L');
%% plot denoised signal --- A
figure('Position', [550, 360, 350, 250]);   hold on; 
param.colorbar=1;
gsp_plot_signal(G,y_chebyA,param);
screen2tif('result_plot/DenoisedSignal_A');

