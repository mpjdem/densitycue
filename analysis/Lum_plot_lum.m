%% Plot the relation between the luminance metric and average human
%% performance for all trials of Experiment 1.
%  See Supplementary Materials S3 - Luminance value
%  and Supplementary Figure S13

%  The simulation files are in the folder simulation/(exp)/Lum, or can be
%  generated with script Lum_simulate_all.m 

%  3 different filter widths are plotted: 15, 20, and 25 cycles per image.

ccc; GERT_Init;

n_bins = 10;
smoothing_width = ['15';'25']; % std of Gaussian in cycles per image
basedir = ['..' filesep];

%% Load human data
dat_1a = load([basedir 'data' filesep '1a' filesep 'all.mat']);
dat_corr_1a = dat_1a.dat.eval;
dat_conds_1a = (dat_1a.dat.cond_dispdens-1)*4 + dat_1a.dat.cond_closed*2 + dat_1a.dat.cond_equid;

dat_1b = load([basedir 'data' filesep '1b' filesep 'all.mat']);
dat_corr_1b = dat_1b.dat.eval;
dat_conds_1b = (dat_1b.dat.cond_dispdens-1)*4 + dat_1b.dat.cond_closed*2 + dat_1b.dat.cond_equid;

%% Code and color-code conditions:

line_colors = [[0.1 0.4 0.1]; 
               [0.4 0.1 0.1]; 
               [0.3 0.6 0.3];
               [0.6 0.3 0.3]; 
               [0.5 0.8 0.5];           
               [0.8 0.5 0.5]]; % reddish for dense, greenish for sparse

% 0 = lo_op_ran;  ROS  'DeepSkyBlue'  00BFFF
% 1 = lo_op_eq;   EOS  'YellowGreen'  9ACD32
% 2 = lo_cl_ran;  RCS  'Gold'         FFD700
% 3 = lo_cl_eq;   ECS  'Firebrick'    B22222
% 4 = hi_op_ran;  ROD  'DodgerBlue'   1E90FF
% 5 = hi_op_eq;   EOD  'OliveDrab'    6B8E23
% 6 = hi_cl_ran;  RCD  'Chocolate'    D2691E
% 7 = hi_cl_eq;   ECD  'Maroon'       800000
           
line_colors = [  hex2rgb('00BFFF'); ...
            hex2rgb('9ACD32'); ...
            hex2rgb('FFD700'); ...
            hex2rgb('B22222'); ...
            hex2rgb('1E90FF'); ...
            hex2rgb('6B8E23'); ...
            hex2rgb('D2691E'); ...
            hex2rgb('800000')]/255;

figure('position', [50,50,1050,550]);
for w = 1:2
    
    color = 0;
    
    subplot(1,2,w); hold on;
    
    sim_1a = load([basedir 'simulation' filesep '1a' filesep 'Lum' filesep 'all_', smoothing_width(w,:) '.mat']);
    sim_val_1a = sim_1a.sim.mt;
    sim_conds_1a = (sim_1a.sim.cond_dispdens-1)*4 + sim_1a.sim.cond_closed*2 + sim_1a.sim.cond_equid;
    
    if ~all(dat_conds_1a == sim_conds_1a)
       error ('incompatible files') 
    end
    
    sim_1b = load([basedir 'simulation' filesep '1b' filesep 'Lum' filesep 'all_', smoothing_width(w,:) '.mat']);
    sim_val_1b = sim_1b.sim.mt;
    sim_conds_1b = (sim_1b.sim.cond_dispdens-1)*4 + sim_1b.sim.cond_closed*2 + sim_1b.sim.cond_equid;
    
    if ~all(dat_conds_1b == sim_conds_1b)
       error ('incompatible files') 
    end
    
    for condition = 0:7
    
        % Condition 0-3: sparse
        % Condition 4-7: dense
    
        color = color+1;
        
        %trial_sel_1a = (sim_conds_1a >= ((condition-1)*4) & (sim_conds_1a < (condition*4)));
        trial_sel_1a = (sim_conds_1a ==condition);
        sim_val_this_1a = sim_val_1a(trial_sel_1a);
        dat_corr_this_1a =  dat_corr_1a(trial_sel_1a);
        
        [foo, ind] = sort(sim_val_this_1a);
        sim_val_this_1a_sorted = sim_val_this_1a(ind);
        dat_corr_this_1a_sorted = dat_corr_this_1a(ind);

        bins = round(linspace(1,size(sim_val_this_1a_sorted,2),n_bins+1));
        for bin = 1:n_bins
            sim_val_bins_1a(bin) = mean(sim_val_this_1a_sorted(bins(bin):bins(bin+1)));
            dat_corr_bins_1a(bin) = mean(dat_corr_this_1a_sorted(bins(bin):bins(bin+1)));
        end
        plot(sim_val_bins_1a,dat_corr_bins_1a,'o','MarkerSize',8,'LineWidth',2,'Color',line_colors(color,:),'MarkerFaceColor',line_colors(color,:));
        
        [thresholds, pars] = fit_logistic(sim_val_bins_1a',dat_corr_bins_1a', repmat(6400/n_bins,[n_bins 1]));
        yfit = 0.5 + 0.5 * (1 ./ (1 + exp(- (pars(1) + (pars(2) * linspace(min(sim_val_bins_1a),max(sim_val_bins_1a),1000))))));
        plot(linspace(min(sim_val_bins_1a),max(sim_val_bins_1a),1000),yfit,'b-','LineWidth',3,'Color',line_colors(color,:));
          
        %trial_sel_1b = (sim_conds_1b >= ((condition-1)*4) & (sim_conds_1b < (condition*4)));
        trial_sel_1b = (sim_conds_1b ==condition);
        sim_val_this_1b_mean = mean(sim_val_1b(trial_sel_1b));
        dat_corr_this_1b_mean =  mean(dat_corr_1b(trial_sel_1b));
        
        plot(sim_val_this_1b_mean, dat_corr_this_1b_mean, '<', 'MarkerSize',8, 'Color',line_colors(color,:), 'MarkerFaceColor',line_colors(color,:));
        
    end
    
    set(gca,'YLim',[0.35 1.05],'XLim',[-1.5 1]*10e-4);
    set(get(gca,'XLabel'),'String','Luminance metric','FontSize',16)
    set(get(gca,'YLabel'),'String','Proportion correct','FontSize',16);
    
    line([0 0],[0.35 1.05],'Color',[0.2 0.2 0.2],'LineStyle','--','LineWidth',1.5);
    text(-1.4*10e-4,0.4, ['width = ' smoothing_width(w,:)],'FontSize',12);
    
    hold off;
end

%print(gcf,'FIG_SUP_luminance.png','-dpng',['-r',num2str(600)],'-opengl');

set(gcf, 'PaperPositionMode','auto')   
print(gcf,'FIG_SUP_luminance.png','-dpng','-opengl')







