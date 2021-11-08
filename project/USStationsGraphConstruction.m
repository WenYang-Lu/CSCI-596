clear all; close all;
%% load data
T=table2array(readtable("data/Temperature20030909.csv"));
% T=table2array(readtable("Temperature20060227.csv"));
% T=table2array(readtable("Temperature20030201.csv"));

%% graph construction
loc=T(:,1:2); % location  
Gparam.type = 'knn'; Gparam.k=6; Gparam.sigma=1; Gparam.use_l1=0; % parameters for knn graph construction
G=gsp_nn_graph(loc,Gparam); % graph
G.maxTemp=T(:,3); G.minTemp=T(:,4); % temperature signal
W=G.W; N=G.N;
Wnew=zeros(G.N,G.N);
for i=1:N
    for j=1:N
        if W(i,j)~=0
            Wnew(i,j)=W(i,j)/sqrt(sum(W(i,:))*sum(W(:,j))); % edge weight normalization
        end
    end
end
G.W=Wnew;
save("data/Temperature_Graph.mat",'G');

%% check graph signal
% x=G.maxTemp;
% x=G.minTemp;
x=(G.minTemp+G.maxTemp)/2;
figure;
gsp_plot_signal(G,x);
%% check signal spectrum
A=double(full(G.W)); lmaxA=eigs(A,1); [VA,lamA]=eig(A); lamA=diag(lamA);
L=diag(sum(A))-A; lmaxL=eigs(L,1); [VL,lamL]=eig(L); lamL=diag(lamL); G.L=L; G.lmax=lmaxL;
figure;
plot(lamL,abs(VL\x),'Linewidth',2);
xlim([0,2]); ylim([0,100])