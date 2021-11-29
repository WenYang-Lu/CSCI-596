data = readtable('mpi_speedup.csv','NumHeaderLines',1);
clf
plot(data{:,1},data{:,2}./data{:,3},'-o','LineWidth',2)
text(1070,8,'Speedup ~ N^{(2.3)}','fontsize', 14, 'Color', [0.4940 0.1840 0.5560])
hold on
plot(data{:,1},data{:,2}./data{:,4},'-o','LineWidth',2)
hold on
plot(data{:,1},data{:,2}./data{:,5},'-o','LineWidth',2)
hold on
plot(data{:,1},data{:,2}./data{:,6},'-o','LineWidth',2)
x0 = linspace(319,1200,10);
y16 =  6.303e-07*x0.^2.305 + 2.145 ;
plot(x0,y16,'--','LineWidth',2, 'Color', [0.4940 0.1840 0.5560])
legend('Number of process = 2','Number of process = 4','Number of process = 8','Number of process = 16','Location','northwest')
xlabel('Number of observatory, N')
ylabel('Speedup, T / T_{{number of process=1}}')
set(gca, 'fontsize', 20)
xlim([319 1200])
ylim([0 10])

