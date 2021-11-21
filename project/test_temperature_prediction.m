clear all; close all;
rng(7); % random seed

%% Graph and Original Signal
load("data/Temperature_Graph.mat");

A=double(full(G.W)); % adjacency matrix
[VA,lamA]=eig(A); lamA=diag(lamA); lmaxA=max(lamA); lminA=min(lamA);  

L=diag(sum(A))-A; % Laplacian matrix
[VL,lamL]=eig(L); lamL=diag(lamL); G.L=L; lmaxL=max(lamL); G.lmax=lmaxL;

N=G.N; % total number of graph nodes
x=G.maxTemp+G.minTemp/2; % graph signal: average temperature
% x=G.minTemp % graph signal: average temperature

%% Create input signal with missing data
M=round(0.20*N); % number of missing nodes
missing_idx=randperm(N,M); % node index to be discarded
S=eye(N);
S(missing_idx,:)=[]; % sampling matrix

x0=x; 
x0(missing_idx)=0; % input signal
x_obs=S*x; % observed signal

%% predicting process
tau = 1e0; % parameter for regularizatoin
verbose=2; % 2,1: showing optimization process; 0: not showing  

% setting the objective function
f2.grad = @(x) 2*S'*(S*x-x_obs);
f2.eval = @(x) norm(S*x-x_obs)^2;
f2.beta = 2 * norm(S)^2;

% setting the regularzation function
paramtik.verbose = verbose-1;
ftik.prox = @(x,T) gsp_prox_tik(x, tau*T, G, paramtik);
ftik.eval = @(x) tau* sum(gsp_norm_tik(G,x));
ftik.grad = @(x) 2 * L * x;
ftik.beta = 2 * lmaxL;

% setting different parameter for the simulation
param_solver.verbose = verbose; % display parameter
param_solver.maxit = 1e4;        % maximum iteration
param_solver.tol = 1e-10;        % tolerance to stop iterating
param_solver.method = 'FISTA';  % desired method for solving the problem

% solving the problem
sol = solvep(x0, {ftik, f2}, param_solver);

y=x0;
y(missing_idx)=sol(missing_idx); %only update missing nodes
output_MSE=immse(x,y);

%% plot original signal 
figure('Position', [550, 360, 350, 250]);   hold on; 
param.colorbar=1;
gsp_plot_signal(G,x,param); % original signal
c1=caxis;
screen2tif('result_plot/InputSignal');

%%  plot input signal
figure('Position', [550, 360, 350, 250]);   hold on; 
param.colorbar=1;
gsp_plot_signal(G,x0,param); hold on; % original signal   
zero_idx=find(x0==0);
scatter(G.coords(zero_idx,1),G.coords(zero_idx,2),G.plotting.vertex_size,"k","filled");
caxis(c1);
screen2tif('result_plot/MissingSignal');

%%  plot predicted signal
figure('Position', [550, 360, 350, 250]);   hold on; 
param.colorbar=1;
gsp_plot_signal(G,y,param);
caxis(c1);
screen2tif('result_plot/PredictedSignal_L');
