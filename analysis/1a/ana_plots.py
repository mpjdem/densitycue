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
n_points_on_curve = 8

# General settings
execfile("../ana_plot_settings.py")

# #
# Make result directory
# # 
dir_res = 'figs'
if not isdir(dir_res):
    mkdir(dir_res)

# #
# Helper functions
# #
def inv_marker_horizontal(n_inv, hrange):
    """Compute horizontal placement of invalid markers."""
    if n_inv > 1:
        x_inv = list(np.linspace(-hrange, hrange, n_inv))
    else:
        x_inv = [0]
    return x_inv

def sg_compute(mn, se):
    """Compute significance of difference."""
    return (np.abs(mn)-(se*alpha_z)) > 0
    
def sg_marker_plot(x, y, up, sg_mrk_sz, sg_dist, hor_pos=True):
    """Plot a significance marker."""
                
    if up:
        mrk_tmp = sg_mrk_up
    else:
        mrk_tmp = sg_mrk_dw
    
    if hor_pos:    
        plt.plot(x+sg_dist, y, color=sg_col, markeredgecolor=sg_col, 
                 markersize=sg_mrk_sz, marker=mrk_tmp)
    else:
        plt.plot(x, y+sg_dist, color=sg_col, markeredgecolor=sg_col, 
                 markersize=sg_mrk_sz, marker=mrk_tmp)

def compute_marker_size(this_n, all_n, mrk_sz):
    tmp = (float(this_n)/float(all_n)) - np.asarray(sel_pr_bnd)
    tmp[tmp<0] = 999
    mrk_sz_mod = np.argmin(tmp)
    return mrk_sz+(2*mrk_sz_mod)


# #
# Detect
# #

def plot_detect_single(sim_name, fname=None):
    
    """Plot the full detection curves for a single metric."""
    
    print 'Detect Single: ', sim_name
    
    # Settings
    if sim_name == 'data':
        title = 'Human observers'
    else:
        title = 'Ideal observer: ' + sim_name
    xlbl = 'Contour Spacing (pixels)'
    ylbl = 'Proportion Correct'
    
    fig_sz = (10,8)
    miny = 0.4
    maxy = 1.0
    axis_pad_x = 1
    
    mrk_sz = 8
    
    curve_pad = 0.5
    curve_lw = 2.5
    
    hor_lw = 1
    hor_ls = '--'
    hor_col = 'k'

    # Load data
    d_o = io.loadmat(pjoin('res',sim_name,'observe.mat'))
    x = d_o['obs_means']['x_for_fit'][0,0]
    y = d_o['obs_means']['y_for_fit'][0,0]
    msk = d_o['obs_means']['mask_for_fit'][0,0]
    pars = d_o['obs_fit']['pars'][0,0]
    tr = d_o['obs_fit']['thresh'][0,0]
    tr = tr.squeeze()
    
    minx = np.amin(x) - axis_pad_x
    maxx = np.amax(x) + axis_pad_x
        
    # Make figure
    plt.figure(figsize=fig_sz)
    plt.hold(True)

    # Plot the curves
    for cond in range(n_curves):
        
        # 75% threshold line
        plt.axhline(0.75, ls=hor_ls, lw=hor_lw, color=hor_col)
        
        # Compute the curve
        if np.mod(cond,2)==0:
            cminx = np.amin(x[:,range(0,n_curves,2)])-curve_pad
            cmaxx = np.amax(x[:,range(0,n_curves,2)])+curve_pad
        else:
            cminx = np.amin(x[:,range(1,n_curves,2)])-curve_pad
            cmaxx = np.amax(x[:,range(1,n_curves,2)])+curve_pad
        fx = np.linspace(cminx, cmaxx, 100)
        fy = 1. / (1+np.exp(-(pars[0,cond]+pars[1,cond]*fx)))
        fy = 0.5 + (fy/2)
        
        # Plot curve if the threshold is within a reasonable range
        if np.all(y[:,cond]>thresh_inv_crit) or np.all(y[:,cond]<thresh_inv_crit):
            pass
        else:
            plt.plot(fx, fy, lt[cond], color=col[cond], lw=curve_lw)
       
        # Plot the individual data points
        lbl_tmp = lbl[cond]
        for pt in range(n_points_on_curve):
            plt.plot(x[pt,cond], y[pt,cond], mrk[cond], label=lbl_tmp, 
                     color=col[cond], markersize=mrk_sz, 
                     alpha=mrk_alpha[msk[pt,cond]])
            lbl_tmp = None
            
    plt.hold(False)
    
    # Tweak plot
    plt.xlim([minx, maxx])
    plt.ylim([miny, maxy])
    plt.xlabel(xlbl, size=axis_label_size)
    plt.ylabel(ylbl, size=axis_label_size)
    
    plt.xticks(size=axis_tick_size)
    plt.yticks(size=axis_tick_size)
    plt.tick_params(top='off',right='off')

    plt.title(title, size=title_size, y=maxy+title_pad*(maxy-miny))
    plt.legend(numpoints=1, ncol=1)

    plt.tight_layout()
    
    # Save file
    if fname:
        plt.savefig(pjoin(dir_res,fname+fig_ext))
    else:
        plt.savefig(pjoin(dir_res,'detect_'+sim_name+fig_ext))


def plot_detect_series(sim_names, ref_sim, fname=None):    
    
    """Compare detection thresholds between metrics."""

    print 'Detect Series: ', ref_sim, sim_names
    
    # Settings
    xlbl = 'Metric'
    ylbl = 'Threshold'
    
    all_sims = [ref_sim] + sim_names
    y_ticks_lbl = ['Inv']  + range(15,35,5) + ['Inv']
    
    fig_sz = (10,5)
    axis_pad_x = 0.5
    axis_pad_extra_y = 0.1
    
    mrk_sz = 12
    mrk_hrange_inv = 0.15
    mean_mrk_sz = 13
    sg_mrk_sz = 5
    sg_dist = 0.2

    ver_lw = 2
    mean_lw = 1
    inv_lw = 0.5
    ver_lc = 'k'
    mean_lc = 'k'
    inv_lc = 'k'

    # Load data
    tm = np.zeros([len(all_sims),n_curves])
    tam = np.zeros([len(all_sims)])
    tdm = np.zeros([len(all_sims),n_curves])
    tdam = np.zeros([len(all_sims)])
    tds = np.zeros([len(all_sims),n_curves])
    tdas = np.zeros([len(all_sims)])
    inv_msk_hi = np.zeros([len(all_sims),n_curves], dtype='bool')
    inv_msk_lo = np.zeros([len(all_sims),n_curves], dtype='bool')
        
    for n,sim_name in enumerate(all_sims):
        
        d_o = io.loadmat(pjoin('res', sim_name, 'observe.mat'))
        x_for_fit = d_o['obs_means']['x_for_fit'][0,0]
        y_for_fit = d_o['obs_means']['y_for_fit'][0,0]
        t = d_o['obs_fit_boot']['thresh'][0,0]
        
        # Determine which markers are invalid
        for cond in range(n_curves):
            msk1 = (t[:,cond]>np.amax(x_for_fit[:,cond])) 
            msk2 = (t[:,cond]<np.amin(x_for_fit[:,cond]))
            t[msk1|msk2,cond] = np.nan
            if np.all(y_for_fit[:,cond]>thresh_inv_crit) or (np.sum(msk1) > len(msk1)*thresh_inv_crit2):
                inv_msk_hi[n,cond] = True
            elif np.all(y_for_fit[:,cond]<thresh_inv_crit) or (np.sum(msk2) > len(msk2)*thresh_inv_crit2):
                inv_msk_lo[n,cond] = True
            
        # Compute means and standard deviations
        if n==0:
            tr = t
        tm[n,:] = np.nanmean(t,0)
        tam[n] = np.nanmean(np.nanmean(t,1))
        tdm[n,:] = np.nanmean(tr-t,0)
        tdam[n] = np.nanmean(np.nanmean(tr,1)-np.nanmean(t,1))
        tds[n,:] = np.nanstd(tr-t,0)
        tdas[n] = np.nanstd(np.nanmean(tr,1)-np.nanmean(t,1))

    minx = -axis_pad_x
    maxx = len(all_sims)-axis_pad_x
    miny = np.nanmin(x_for_fit.flatten())
    maxy = np.nanmax(x_for_fit.flatten())
    miny_extra = miny - (maxy-miny)*axis_pad_extra_y
    maxy_extra = maxy + (maxy-miny)*axis_pad_extra_y
    
    y_inv_hi = np.mean([maxy,maxy_extra])
    y_inv_lo = np.mean([miny,miny_extra])
    y_ticks = [y_inv_lo] + y_ticks_lbl[1:-1] + [y_inv_hi]
    
    # Make figure
    plt.figure(figsize=fig_sz)    
    plt.hold(True)
    
    # Draw lines
    plt.axvline(0.5, color=ver_lc, lw=ver_lw)
    plt.axhline(tam[0], color=mean_lc, lw=mean_lw)
    plt.axhline(miny, color=inv_lc, lw=inv_lw)
    plt.axhline(maxy, color=inv_lc, lw=inv_lw)
    
    # Go over each metric
    for sim in range(len(sim_names)+1):
        
        # Horizontal placement of invalid markers
        x_inv_hi = inv_marker_horizontal(np.sum(inv_msk_hi[sim,:]), mrk_hrange_inv)
        x_inv_lo = inv_marker_horizontal(np.sum(inv_msk_lo[sim,:]), mrk_hrange_inv)
        
        # Plot individual condition markers
        for cond in range(n_curves):
            if inv_msk_hi[sim,cond]:
                x = sim + x_inv_hi.pop()
                y = y_inv_hi
            elif inv_msk_lo[sim,cond]:
                x = sim + x_inv_lo.pop() 
                y = y_inv_lo
            else:
                x = sim
                y = tm[sim,cond]
            plt.plot(x, y, mrk[cond], color=col[cond], markersize=mrk_sz)
            
            # Significance marker
            if sim > 0 and ~inv_msk_lo[sim,cond] and ~inv_msk_hi[sim,cond]:
                if sg_compute(tdm[sim,cond], tds[sim,cond]):
                    sg_marker_plot(x, y, tdm[sim,cond] < 0, sg_mrk_sz, sg_dist)
        
        # Plot mean marker
        if not np.any(inv_msk_hi[sim,:] + inv_msk_lo[sim,:]):
            plt.plot(sim, tam[sim], mean_mrk, color=mean_col, markersize=mean_mrk_sz)
            
            # Significance marker
            if sim > 0:
                if sg_compute(tdam[sim], tdas[sim]):
                    sg_marker_plot(sim, tam[sim], tdam[sim] < 0, sg_mrk_sz, sg_dist)

    plt.hold(False)
    
    # Tweak plot
    plt.xlim([minx, maxx])
    plt.ylim([miny_extra, maxy_extra])
    plt.xlabel(xlbl, size=axis_label_size)
    plt.ylabel(ylbl, size=axis_label_size)
    
    plt.xticks(range(len(all_sims)), all_sims, size=axis_tick_size)
    plt.yticks(y_ticks, y_ticks_lbl, size=axis_tick_size)
    plt.tick_params(top='off',right='off', labelsize=tick_label_size)
    
    plt.tight_layout()
    
    # Save file
    if fname:
        plt.savefig(pjoin(dir_res,fname+fig_ext))
    else:
        plt.savefig(pjoin(dir_res,'detect_series_'+ref_sim+'_'+sim_names[0]+fig_ext))


# #
# Predict
# #

def plot_predict_single(sim_name, fname=None):
    
    """Plot the full condition mean predictions for a single metric."""
    
    print 'Predict Single: ', sim_name
    
    # Settings
    xlbl = 'Human Performance (logit)'
    ylbl = 'Metric Performance (logit)'
    
    fig_sz = (7,7)
    axis_pad = 0.2
    
    mrk_sz = 8
    txt_dist = 0.3
    txt_sz = 16
    
    fit_ind_lw = 1
    fit_all_lw = 2
    fit_all_lc = 'k'
    fit_all_lt = '--'
    
    # Load data    
    d_p = io.loadmat(pjoin('res',sim_name,'predict.mat'))
    x = d_p['pred_res']['x_for_fit'][0,0]
    y = d_p['pred_res']['y_for_fit'][0,0]
    msk = d_p['pred_res']['mask_for_fit'][0,0]
    pari = d_p['pred_res']['pars_ind'][0,0]
    para = d_p['pred_res']['pars_all'][0,0]
    rqw = d_p['pred_res']['rqw'][0,0]
    rqb = d_p['pred_res']['rqb'][0,0]
    
    minx = np.nanmin(x.flatten())-axis_pad
    maxx = np.nanmax(x.flatten())+axis_pad
    miny = np.nanmin(y.flatten())-axis_pad
    maxy = np.nanmax(y.flatten())+axis_pad
    minx = np.amin([minx,miny])
    miny = minx
    maxx = np.amax([maxx,maxy])
    maxy = maxx
    
    # Make figure
    plt.figure(figsize=fig_sz)
    plt.hold(True)
    
    # Plot data
    xregr= np.linspace(minx,maxx,100)
    for cond in range(n_curves):
        # Markers
        for pt in range(n_points_on_curve):
            plt.plot(x[pt,cond], y[pt,cond], mrk[cond], color=col[cond], 
                     alpha=mrk_alpha[msk[pt,cond]])
                     
        # Lines
        plt.plot(xregr, pari[0,cond]+pari[1,cond]*xregr, 
                 lt[cond], color=col[cond], lw=fit_ind_lw)
                            
    plt.plot(xregr, para[0]+para[1]*xregr, fit_all_lt, color=fit_all_lc, lw=fit_all_lw)    
        
    plt.hold(False)
        
    # Tweak figure
    plt.axis('equal')
    plt.xlim([minx, maxx])
    plt.ylim([miny, maxy])
    plt.xlabel(xlbl, size=axis_label_size)
    plt.ylabel(ylbl, size=axis_label_size)
    
    plt.xticks(np.arange(0, np.ceil(maxx)), np.arange(0,np.ceil(maxx)), size=axis_tick_size)
    plt.yticks(np.arange(0, np.ceil(maxy)), np.arange(0,np.ceil(maxy)), size=axis_tick_size)
    plt.tick_params(top='off',right='off')
    
    plt.title(sim_name, size=title_size)
    
    txt = r'$\overline{r}_{W}^{2} = ' + \
          str(round(np.nanmean(rqw),2)) + \
          '$ \n$r_{B}^{2} - \overline{r}_{W}^{2} = ' + \
          str(round(np.nanmean(rqw)-rqb,2)) + '$'
          
    plt.text(maxx-txt_dist, miny+txt_dist, txt, 
             horizontalalignment='right', verticalalignment='bottom', 
             size=txt_sz)

    plt.tight_layout()
    
    # Save to file
    if fname:
        plt.savefig(pjoin(dir_res,fname+fig_ext))
    else:
        plt.savefig(pjoin(dir_res,'predict_'+sim_name+fig_ext))


def plot_predict_series(sim_names, ref_sim, fname=None):

    """Compare condition mean prediction between metrics."""

    print 'Predict Series: ', ref_sim, sim_names
    
    # Settings
    fig_sz = (10,5)
    xlbl = 'Metric'
    ylbl = ''
    
    axis_pad_x = 0.4
    miny = 0.0
    maxy = 1.0
    
    bar_x = [-0.1, 0.1]
    bar_width = 0.15
    bar_w_col = 'r'
    bar_b_col = 'g'
        
    mrk_sz = 7
    mean_mrk_sz = 14
    sg_mrk_sz = 5
    sg_dist = 0.02
    
    ver_lw = 2
    ver_ls = '-'
    ver_col = 'k'
    
    # Load data
    all_sims = [ref_sim]+sim_names
    wm = np.zeros([len(all_sims), n_curves])
    wdm = np.zeros([len(all_sims), n_curves])
    wds = np.zeros([len(all_sims), n_curves])
    wam = np.zeros([len(all_sims)])
    wdam = np.zeros([len(all_sims)])
    wdas = np.zeros([len(all_sims)])
    bm = np.zeros(len(all_sims))
    bdm = np.zeros(len(all_sims))
    bds = np.zeros(len(all_sims))

    for n,sim_name in enumerate([ref_sim]+sim_names):
        d_p = io.loadmat(pjoin('res',sim_name,'predict.mat'))
        w = d_p['pred_res_boot']['rqw'][0,0]
        b = d_p['pred_res_boot']['rqb'][0,0]
        b = -b+np.nanmean(w,1).squeeze()
        wm[n,:] = np.nanmean(w,2).squeeze()
        wam[n] = np.nanmean(np.nanmean(w,1).squeeze())
        bm[n] = np.nanmean(b)
        if n==0:
            wr = w
            br = b
        else:
            wdm[n,:] = np.nanmean(w-wr,2).squeeze()
            wds[n,:] = np.nanstd(w-wr,2).squeeze()
            wdam[n] = np.nanmean(np.nanmean(w,1)-np.nanmean(wr,1),1).squeeze()
            wdas[n] = np.nanstd(np.nanmean(w,1)-np.nanmean(wr,1),1).squeeze()
            bdm[n] = np.nanmean(b-br)
            bds[n] = np.nanstd(b-br)

    minx = -axis_pad_x
    maxx = len(all_sims) + axis_pad_x

    # Make figure
    plt.figure(figsize=fig_sz)
    plt.hold(True)
    
    # Plot data
    plt.axvline(0.5, ls=ver_ls, color=ver_col, lw=ver_lw) 
    
    for sim in range(len(all_sims)):
        # Bars
        if sim==0:
            lbl_bar_b = '$r_{B}^{2} - \overline{r}_{W}^{2}$'
            lbl_bar_w = '$\overline{r}_{W}^{2}$'
        else:
            lbl_bar_b = None
            lbl_bar_w = None
        plt.bar(sim+bar_x[0], wam[sim], label=lbl_bar_w, color=bar_w_col, width=bar_width, align='center')
        plt.bar(sim+bar_x[1], bm[sim], label=lbl_bar_b, color=bar_b_col, width=bar_width, align='center')
        
        # Significance markers
        if sg_compute(wdam[sim], wdas[sim]):
            sg_marker_plot(sim+bar_x[0], wam[sim], wdam[sim]>0, sg_mrk_sz, sg_dist, False)
        if sg_compute(bdm[sim], bds[sim]):
            sg_marker_plot(sim+bar_x[1], bm[sim], wdam[sim]<0, sg_mrk_sz, sg_dist, False)
        
    plt.hold(False)
     
    # Tweak plot
    plt.xlim([minx, maxx])
    plt.ylim([miny, maxy])
    plt.xlabel(xlbl, size=axis_label_size)
    plt.ylabel(ylbl, size=axis_label_size)
    
    plt.xticks(range(len(all_sims)), all_sims, size=axis_tick_size)
    plt.yticks(size=axis_tick_size)
    plt.tick_params(top='off',right='off', bottom='off', labelsize=tick_label_size)

    plt.legend()
    
    plt.tight_layout()
    
    # Save file
    if fname:
        plt.savefig(pjoin(dir_res,fname+fig_ext))
    else:
        plt.savefig(pjoin(dir_res,'predict_series_'+ref_sim+'_'+sim_names[0]+fig_ext))
    

# #
# Select
# #

def plot_select_single(sim_name, fname=None):
    
    """Plot the full dependence of human performance on metric p-values."""
    
    print 'Select Single: ', sim_name
    
    
    # Settings
    fig_sz = (10,8)
    xlbl = 'Metric Min/Max P-Values'
    ylbl = 'Average Human Performance'
    
    miny = 0.35
    maxy = 1.0
    axis_pad_x = 0.5
    axis_pad_extra_y = 0.1
    
    y_ticks_lbl = ['Inv']  + list(np.arange(0.4,1.01,0.1))
    
    mrk_sz = 5
    mrk_hrange_inv = 0.15
    
    curv_all_lw = 2
    curv_all_ls = '--'
    curv_all_lc = 'k'
    
    hor_lw = 1
    hor_ls = '-'
    hor_col = 'k'
    
    inv_lw = 0.5
    inv_ls = '-'
    inv_col = 'k'
    
    # Load data
    d_s = io.loadmat(pjoin('res', sim_name, 'select.mat'))
    ps = d_s['sel_cpred']['ps'][0,0][0]
    ns = d_s['sel_cpred']['n_per'][0,0]
    cpred_a = d_s['sel_cpred']['all_curves'][0,0]
    cpred_i = d_s['sel_cpred']['ind_curves'][0,0]
    
    minx = -axis_pad_x
    maxx = len(ps)-1-axis_pad_x
    miny_extra = miny - (maxy-miny)*axis_pad_extra_y
    
    y_inv = np.mean([miny,miny_extra])
    y_ticks = [y_inv] + y_ticks_lbl[1:]
    x_ticks_lbl = []
    for i in range(len(ps)-1):
        x_ticks_lbl.append(str(ps[i])+'\n'+str(ps[i+1]))
        
    inv_msk = (ns==0)    
    
    # Make figure
    fig = plt.figure(figsize=fig_sz)
    plt.hold(True)

    # Plot data    
    plt.axhline(0.5, ls=hor_ls, lw=hor_lw, color=hor_col)
    plt.axhline(miny, ls=inv_ls, lw=inv_lw, color=inv_col)
    
    wm = np.zeros([len(ps)-1,n_curves])  
    for p in range(len(ps)-1):
        x_inv = inv_marker_horizontal(np.sum(inv_msk[p,:]), mrk_hrange_inv)
        for cond in range(n_curves):
            # Compute invalid marker positions and marker sizes
            if inv_msk[p,cond]:
                x = p+x_inv.pop()
                y = y_inv
            else:
                x = p
                y = cpred_i[p,cond]
            mrk_sz_tmp = compute_marker_size(ns[p,cond], np.sum(ns[:,cond]), mrk_sz)

            # Compute weighted means
            wm[p,cond] = cpred_i[p,cond]*(ns[p,cond]/float(np.sum(ns[p,:])))
            
            # Plot markers
            plt.plot(x, y, mrk[cond], markersize=mrk_sz_tmp, color=col[cond])
            
    # Plot weighted means
    plt.plot(range(len(ps)-1), np.sum(wm,1), color=curv_all_lc, ls=curv_all_ls, lw=curv_all_lw)
    
    plt.hold(False)
    
    # Tweak the figure
    plt.xlim([minx,maxx])
    plt.ylim([miny_extra,maxy])
    plt.xlabel(xlbl, size=axis_label_size)
    plt.ylabel(ylbl, size=axis_label_size)
    
    plt.xticks(np.arange(len(ps)-1), x_ticks_lbl, size=None)
    plt.yticks(y_ticks, y_ticks_lbl, size=axis_tick_size)
    plt.tick_params(top='off',right='off', labelsize=tick_label_size) 
    
    plt.title(sim_name, size=title_size)

    plt.tight_layout()
    
    # Save file
    if fname:
        plt.savefig(pjoin(dir_res,fname+fig_ext))
    else:
        plt.savefig(pjoin(dir_res,'select_'+sim_name+'.png'))


def plot_select_series(sim_names, ref_sim, pl, fname=None):    
    
    """Compare human performance for a specific p-level of different metrics."""

    print 'Select Series: ', ref_sim, sim_names
    
    # Settings
    fig_sz = (10,7)
    xlbl = 'Metric'
    ylbl = 'Human performance'
    
    all_sims = [ref_sim]+sim_names
    
    miny = 0.35
    maxy = 1.0
    axis_pad_x = 0.5
    axis_pad_y_extra = 0.1
    
    y_ticks_lbl = ['Inv']  + list(np.arange(0.4,1.01,0.1))
    
    mrk_sz = 5
    mrk_hrange_inv = 0.15
    mean_mrk_sz = 7
    sg_mrk_sz = 5
    sg_dist = 0.15
    
    ver_ls = '-'
    ver_lc = 'k'
    ver_lw = 2
    
    hor_lw = 1
    hor_ls = '-'
    hor_col = 'k'
    
    inv_lw = 0.5
    inv_ls = '-'
    inv_col = 'k'
    
    # Load data
    cim = np.zeros([len(all_sims), n_curves])
    cam = np.zeros(len(all_sims))
    cidm = np.zeros([len(all_sims), n_curves])
    cids = np.zeros([len(all_sims), n_curves])
    cadm = np.zeros(len(all_sims))
    cads = np.zeros(len(all_sims))
    
    for n,sim_name in enumerate(all_sims):
        
        d_s = io.loadmat(pjoin('res', sim_name, 'select.mat'))
        cpred_i = d_s['sel_cpred_boot']['ind_curves'][0,0]
        cpred_a = d_s['sel_cpred_boot']['all_curves'][0,0]
        ns = d_s['sel_cpred']['n_per'][0,0]
        ns_boot = d_s['sel_cpred_boot']['n_per'][0,0]
        ps = d_s['sel_cpred']['ps'][0,0][0]
        
        cpred_i = cpred_i[pl,:,:].squeeze()
        cpred_a = cpred_a[pl,0,:].squeeze()
        cim[n,:] = np.nanmean(cpred_i,1)
        
        # Determine invalid markers and marker n's
        if n==0:
            n_per = np.zeros([len(all_sims), len(ps)-1, n_curves])
            inv_msk = np.zeros([len(all_sims), len(ps)-1, n_curves], dtype='bool')
        inv_msk[n,:,:] = (ns==0)  
        n_per[n,:,:] = ns.astype(float)
        
        # Compute weighted means across conditions
        wm_vals = ns[pl,:]/np.sum(ns[pl,:]).astype(float)
        wm_vals_boot = ns_boot[pl,:,:]/np.sum(ns_boot[pl,:,:],0).astype(float)
        wm = np.zeros([n_curves])  
        wm_boot = np.zeros(cpred_i.shape)
        for cond in range(n_curves):
            wm[cond] = cim[n,cond]*wm_vals[cond]
            wm_boot[cond,:] = cpred_i[cond,:]*wm_vals_boot[cond,:]
        cam[n] = np.nansum(wm)
        cpred_a_wm = np.nansum(wm_boot,0)
        
        # Save means and standard deviations across bootstraps
        if n==0:
            cri = cpred_i
            cra = cpred_a_wm
        else:
            cidm[n,:] = np.nanmean(cri-cpred_i,1)
            cids[n,:] = np.nanstd(cri-cpred_i,1)
            cadm[n] = np.nanmean(cra-cpred_a_wm)
            cads[n] = np.nanstd(cra-cpred_a_wm)
    
    minx = -axis_pad_x
    maxx = len(all_sims)-1+axis_pad_x
    miny_extra = miny - (maxy-miny)*axis_pad_y_extra
    
    y_inv = np.mean([miny,miny_extra])
    y_ticks = [y_inv] + y_ticks_lbl[1:]
    
    # Make figure
    plt.figure(figsize=fig_sz)   
    plt.hold(True) 
    
    # Plot data
    plt.axhline(0.5, ls=hor_ls, lw=hor_lw, color=hor_col)
    plt.axhline(miny, ls=inv_ls, lw=inv_lw, color=inv_col)
    plt.axvline(0.5, ls=ver_ls, color=ver_lc, lw=ver_lw)
    
    for sim in range(len(all_sims)):
        x_inv = inv_marker_horizontal(np.sum(inv_msk[sim,pl,:]), mrk_hrange_inv)
        
        for cond in range(n_curves):
            if inv_msk[sim,pl,cond]:
                x = sim+x_inv.pop()
                y = y_inv
            else:
                x = sim
                y = cim[sim,cond]
            mrk_sz_tmp = compute_marker_size(n_per[sim,pl,cond], np.sum(n_per[sim,:,cond]), mrk_sz)
            plt.plot(x, y, mrk[cond], color=col[cond], markersize=mrk_sz_tmp)
            
            if sim > 0 and ~inv_msk[sim,pl,cond]:
                if sg_compute(cidm[sim,cond],cids[sim,cond]):
                    sg_marker_plot(x, y, cidm[sim,cond] < 0, sg_mrk_sz, sg_dist)
        
        mrk_sz_tmp = compute_marker_size(np.mean(n_per[sim,pl,:]), np.mean(np.sum(n_per[sim,:,:],0)), mrk_sz)
        plt.plot(sim, cam[sim], mean_mrk, color=mean_col, markersize=mrk_sz_tmp)  
        
        if sg_compute(cadm[sim],cads[sim]): 
            sg_marker_plot(sim, cam[sim], cadm[sim] < 0, sg_mrk_sz, sg_dist)

    plt.hold(False)
    
    # Tweak plot
    plt.xlim([minx, maxx])
    plt.ylim([miny_extra, maxy])
    plt.xlabel(xlbl, size=axis_label_size)
    plt.ylabel(ylbl, size=axis_label_size)
    
    plt.xticks(range(len(all_sims)), all_sims, size=axis_tick_size)
    plt.yticks(y_ticks, y_ticks_lbl, size=axis_tick_size)
    plt.tick_params(top='off',right='off', labelsize=tick_label_size)

    plt.title('p = '+str(ps[pl])+' - '+str(ps[pl+1]),size=title_size)
    
    plt.tight_layout()
    
    # Save file
    if fname:
        plt.savefig(pjoin(dir_res,fname+fig_ext))
    else:
        plt.savefig(pjoin(dir_res,'select_series_'+ref_sim+'_'+sim_names[0]+'_'+str(pl)+fig_ext))

# #
# Create all figures
# # 

# Main article
selected_metrics = ['AvgDist1','AvgDist3','RadCount2','RadCountFull']
comparison_metric = 'Voronoi'

plot_detect_single('data',
                    fname='FIG_detect_data_exp1')
plot_detect_single('Voronoi',
                    fname='FIG_detect_Voronoi_exp1')
plot_detect_series(selected_metrics, comparison_metric,
                    fname='FIG_detect_series_exp1')

plot_predict_single('Voronoi',
                    fname='FIG_predict_Voronoi_exp1')
plot_predict_series(selected_metrics, comparison_metric,
                    fname='FIG_predict_series_exp1')

plot_select_single('Voronoi',
                    fname='FIG_select_Voronoi_exp1')
plot_select_series(selected_metrics, comparison_metric, 4,
                    fname='FIG_select_series_exp1_3565')
plot_select_series(selected_metrics, comparison_metric, 5,
                    fname='FIG_select_series_exp1_651')
plot_select_series(['Voronoi', 'AvgDist1'], 'Voronoi_AvgDist1', 4,
                    fname='FIG_select_combined_exp1_3565')

# Supplementary Materials
all_avgdist_metrics = ['AvgDist', 'AvgDist1','AvgDist2','AvgDist3','AvgDist4','AvgDist5']
all_radcount_metrics = ['RadCountFull', 'RadCount125','RadCount15','RadCount175','RadCount2','RadCount225']

plot_detect_series(all_avgdist_metrics, comparison_metric,
                    fname='FIG_SUP_detect_series_AvgDist_exp1')
plot_detect_series(all_radcount_metrics, comparison_metric,
                    fname='FIG_SUP_detect_series_RadCount_exp1')
                    
plot_predict_series(all_avgdist_metrics, comparison_metric,
                    fname='FIG_SUP_predict_series_AvgDist_exp1')
plot_predict_series(all_radcount_metrics, comparison_metric, 
                    fname='FIG_SUP_predict_series_RadCount_exp1')

plot_select_series(all_avgdist_metrics, comparison_metric, 4,
                    fname='FIG_SUP_select_series_AvgDist_exp1_3565')
plot_select_series(all_radcount_metrics, comparison_metric, 4,
                    fname='FIG_SUP_select_series_RadCount_exp1_3565')
                    
plot_select_series(all_avgdist_metrics, comparison_metric, 5,
                    fname='FIG_SUP_select_series_AvgDist_exp1_651')
plot_select_series(all_radcount_metrics, comparison_metric, 5,
                    fname='FIG_SUP_select_series_RadCount_exp1_651')
                    
