import numpy as np
import scipy.io as io
import matplotlib.pyplot as plt
from os.path import join as pjoin
from os.path import isdir
from os import mkdir

# #
# Settings
# #

# Data structure
n_curves = 8
n_points_on_curve = 1

# General settings
execfile("../ana_plot_settings.py")

# #
# Make result directory
# # 
dir_res = 'figs'
if not isdir(dir_res):
    mkdir(dir_res)
    
# #
# Detect
# #

def plot_detect_single(sim_name, fname=None):
    
    print sim_name
    
    if sim_name == 'data':
        title = 'Human observers'
    else:
        title = 'Ideal observer: ' + sim_name    
    
    # Settings
    fig_sz = (10,8)
    miny = -0.1
    maxy = 0.5
    axis_pad_x = 1
    xlbl = 'Stimulus Condition'
    ylbl = 'Proportion Correct'
    
    mrk_sz = 8
    hor_lw = 2
    hor_lc = 'k'
    hor_ls = '-'
    bar_w = 0.8
    sg_dist = 30
    sg_mrk_sz = 6
      
    # Load data
    d_o = io.loadmat(pjoin('res',sim_name,'observe.mat'))
    y = d_o['obs_means']['y'][0,0]
    se = d_o['obs_means']['se_y'][0,0]
    
    minx = 0-axis_pad_x
    maxx = n_curves-1+axis_pad_x

    # Make figure
    plt.figure(figsize=fig_sz)
    plt.hold(True)
    
    # Plot data
    plt.axhline(0, ls = hor_ls, color=hor_lc, lw=hor_lw)
    plt.bar(range(n_curves),y-0.5, color=col, width = bar_w, align='center')
    for cond in range(n_curves):
        sg = int((np.abs(y[cond]-0.5)-se[cond]*alpha_z) > 0)
        sg_y = y[cond]-0.5+(np.sign(y[cond]-0.5)*((maxy-miny)/sg_dist))
        if sg:
            if y[cond]-0.5 > 0:
                mrk_tmp = sg_mrk_up
            else:
                mrk_tmp = sg_mrk_dw
            plt.plot(cond, sg_y, color=sg_col, markersize=sg_mrk_sz, marker=mrk_tmp)
                   
    plt.hold(False)
    
    # Tweak plot
    plt.xlabel(xlbl, size=axis_label_size)
    plt.ylabel(ylbl, size=axis_label_size)
    plt.xticks(range(n_curves), lbl, size=axis_tick_size)
    plt.yticks(np.linspace(0,1,11)-0.5, np.linspace(0,1,11), size=axis_tick_size)
    plt.tick_params(top='off',right='off', bottom="off")
    plt.xlim([minx, maxx])
    plt.ylim([miny, maxy])
    
    plt.title(title, size=title_size, y=0.5+maxy+title_pad*(maxy-miny))    
    plt.tight_layout()
    
    # Save file
    if fname:
        plt.savefig(pjoin(dir_res,fname+fig_ext))
    else:
        plt.savefig(pjoin(dir_res,'detect_'+sim_name+fig_ext))


def plot_detect_series(sim_names, ref_sim, fname=None):    

    print ref_sim, sim_names[0]
    
    # Settings
    xlbl = 'Metric'
    ylbl = 'Proportion correct'
    sim_lbl = [ref_sim] + sim_names
    
    fig_sz = (10,5)
    axis_pad_x = 0.5
    miny = 0.4
    maxy = 1.0
    
    mrk_sz = 12
    mean_mrk_sz = 13
    sg_mrk_sz = 5
    sg_dist = 50
    
    ver_lw = 2
    mean_lw = 1
    ver_lc = 'k'
    mean_lc = 'k'

    # Load data
    ym = np.zeros([len(sim_names)+1,n_curves])
    ydm = np.zeros([len(sim_names)+1,n_curves])
    yds = np.zeros([len(sim_names)+1,n_curves])
        
    for n,sim_name in enumerate([ref_sim]+sim_names):
        d_o = io.loadmat(pjoin('res',sim_name,'observe.mat'))
        y = d_o['obs_boot']['y'][0,0]
        if n==0:
            yr = y
        ym[n,:] = np.nanmean(y,0)
        ydm[n,:] = np.nanmean(yr-y,0)
        yds[n,:] = np.nanstd(yr-y,0)

    minx = -axis_pad_x
    maxx = 1+len(sim_names)-axis_pad_x
    
    # Make figure
    plt.figure(figsize=fig_sz)    
    plt.hold(True)
    
    # Draw lines
    plt.axvline(0.5, color=ver_lc, lw=ver_lw)
    plt.axhline(np.nanmean(ym[0,:]), color=mean_lc, lw=mean_lw)
    
    # Go over each metric
    for sim in range(len(sim_names)+1):
        
        # Plot individual condition markers
        for cond in range(n_curves):
            plt.plot(sim, ym[sim,cond], mrk[cond], color=col[cond], markersize=mrk_sz)
            if sim > 0:
                sg = int((np.abs(ydm[sim,cond])-yds[sim,cond]*alpha_z) > 0)
                if ydm[sim,cond] < 0:
                    mrk_tmp = sg_mrk_up
                else:
                    mrk_tmp = sg_mrk_dw
                if sg:
                    plt.plot(sim+((maxx-minx)/sg_dist), ym[sim,cond], color=sg_col, markeredgecolor=sg_col, markersize=sg_mrk_sz, marker=mrk_tmp)
        
        # Plot mean marker
        plt.plot(sim, np.nanmean(ym[sim,:]), mean_mrk+mean_col, markersize=mean_mrk_sz)
        if sim > 0:
            sg = int((np.abs(np.nanmean(ydm[sim,:]))-(np.nanmean(yds[sim,:])/np.sqrt(n_curves))*alpha_z) > 0)
            if np.nanmean(ydm[sim,:]) < 0:
                mrk_tmp = sg_mrk_up
            else:
                mrk_tmp = sg_mrk_dw
            if sg:
                plt.plot(sim+((maxx-minx)/sg_dist), np.nanmean(ym[sim,:]), color=sg_col, markeredgecolor=sg_col, markersize=sg_mrk_sz, marker=mrk_tmp)

    plt.hold(False)
    
    # Tweak plot
    plt.xlabel(xlbl, size=axis_label_size)
    plt.ylabel(ylbl, size=axis_label_size)
    plt.xticks(range(len(sim_names)+1),sim_lbl, size=axis_tick_size)
    plt.yticks(size=axis_tick_size)
    plt.tick_params(top='off',right='off', labelsize=tick_label_size)
    plt.xlim([minx, maxx])
    plt.ylim([miny, maxy])
    
    plt.tight_layout()
    
    # Save file
    if fname:
        plt.savefig(pjoin(dir_res,fname+fig_ext))
    else:
        plt.savefig(pjoin(dir_res,'detect_series_'+ref_sim+'_'+sim_names[0]+fig_ext))

# #
# Create all figures
# # 

# Main article
selected_metrics = ['AvgDist1','AvgDist3','RadCount2','RadCountFull']
comparison_metric = 'Voronoi'

plot_detect_single('data',
                    fname='FIG_detect_data_exp2')
plot_detect_single('Voronoi',
                    fname='FIG_detect_Voronoi_exp2')
plot_detect_series(selected_metrics, comparison_metric,
                    fname='FIG_detect_series_exp2')
                    
# Supplementary Materials
all_avgdist_metrics = ['AvgDist', 'AvgDist1','AvgDist2','AvgDist3','AvgDist4','AvgDist5']
all_radcount_metrics = ['RadCountFull', 'RadCount125','RadCount15','RadCount175','RadCount2','RadCount225']

plot_detect_series(all_avgdist_metrics, comparison_metric,
                    fname='FIG_SUP_detect_series_AvgDist_exp2')
plot_detect_series(all_radcount_metrics, comparison_metric,
                    fname='FIG_SUP_detect_series_RadCount_exp2')
