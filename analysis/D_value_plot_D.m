%% Relationship between the measure D and human performance
%  See Supplementary Materials S2 - D value
%  and Supplementary Figure S11

%  The simulation files are in the folders simulation/1*/D_value, or can be
%  generated with script simulation/D_value_simulate_all.m

ccc; GERT_Init;

n_bins = 10;

basedir = ['..' filesep];

%% Load D and data for both experiments
simD_1a = load([basedir 'simulation' filesep '1a' filesep 'D_value' filesep 'all.mat']);
simD_1b = load([basedir 'simulation' filesep '1b' filesep 'D_value' filesep 'all.mat']);
data_1a = load([basedir 'data' filesep '1a' filesep 'all.mat']);
data_1b = load([basedir 'data' filesep '1b' filesep 'all.mat']);


%% Code and color-code conditions:
Condition = (data_1a.dat.cond_dispdens-1)*4 + data_1a.dat.cond_closed*2 + data_1a.dat.cond_equid;
% 0 = lo_op_ran;  ROS  'DeepSkyBlue'  00BFFF
% 1 = lo_op_eq;   EOS  'YellowGreen'  9ACD32
% 2 = lo_cl_ran;  RCS  'Gold'         FFD700
% 3 = lo_cl_eq;   ECS  'Firebrick'    B22222
% 4 = hi_op_ran;  ROD  'DodgerBlue'   1E90FF
% 5 = hi_op_eq;   EOD  'OliveDrab'    6B8E23
% 6 = hi_cl_ran;  RCD  'Chocolate'    D2691E
% 7 = hi_cl_eq;   ECD  'Maroon'       800000
Colors = [  hex2rgb('00BFFF'); ...
            hex2rgb('9ACD32'); ...
            hex2rgb('FFD700'); ...
            hex2rgb('B22222'); ...
            hex2rgb('1E90FF'); ...
            hex2rgb('6B8E23'); ...
            hex2rgb('D2691E'); ...
            hex2rgb('800000')];

%% Experiment 1a:
%  Plot average human performance per bin of D, separately for each condition
%  Fit logistic curve to the data
figure; hold on;
for condition = 0:7
    D_value   = simD_1a.sim.dt(Condition==condition);
    Correct   = data_1a.dat.eval(Condition==condition);
    
    [bla, ind] = sort(D_value);
    D_sorted   = D_value(ind);
    Corr_sorted = Correct(ind);

    bins = round(linspace(1,size(D_sorted,2),n_bins+1));
    for bin = 1:n_bins
        d(bin) = mean(D_sorted(bins(bin):bins(bin+1)));
        correct(bin) = mean(Corr_sorted(bins(bin):bins(bin+1)));
        n_per_bin(bin) = length(D_sorted(bins(bin):bins(bin+1)));
    end
    plot(d,correct,'ko','MarkerSize',12,'LineWidth',2,'Color',Colors(condition+1,:)/255,'MarkerFaceColor',Colors(condition+1,:)/255);
    [thresholds, pars] = fit_logistic(d', correct', n_per_bin);
    yfit = 0.5 + 0.5 * (1 ./ (1 + exp(- (pars(1) + (pars(2) * linspace(min(d),max(d),1000))))));
    plot(linspace(min(d),max(d),1000),yfit,'b-','LineWidth',3,'Color',Colors(condition+1,:)/255);
end

%% Experiment 1b:
%  Plot average human performance, separately for each condition
Condition = (data_1b.dat.cond_dispdens-1)*4 + data_1b.dat.cond_closed*2 + data_1b.dat.cond_equid;
for condition = 0:7
    D_value   = mean(simD_1b.sim.dt(Condition==condition));
    Correct   = mean(data_1b.dat.eval(Condition==condition));   
    plot(D_value,Correct,'^','MarkerSize',12,'LineWidth',2,'Color',Colors(condition+1,:)/255,'MarkerFaceColor',Colors(condition+1,:)/255);
end

set(gca,'YLim',[0.4 1.01],'XLim',[0.7 1.7]);
set(get(gca,'XLabel'),'String','D metric','FontSize',16)
set(get(gca,'YLabel'),'String','Proportion correct','FontSize',16);
line([1 1],[0.40 1.01],'Color',[0.2 0.2 0.2],'LineStyle','--','LineWidth',1.5);

print(gcf,'FIG_SUP_D.png','-dpng',['-r',num2str(600)],'-opengl');





