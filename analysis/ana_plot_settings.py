# #
# Settings functions
# #

# Colors and markers
lbl = ['ROS', 'ROD', 'RCS', 'RCD', 'EOS', 'EOD', 'ECS', 'ECD']
col = ['DeepSkyBlue','DodgerBlue','Gold','Chocolate','YellowGreen','OliveDrab','Firebrick','Maroon']
lt = ['-','-','-','-','-','-','-','-']
mrk = ['D','o','D','o','D','o','D','o']
mrk_alpha = [0.6, 1]
mean_mrk = 'h'
mean_col = 'k'
sg_mrk_up = '^'
sg_mrk_dw = 'v'
sg_col = '#555555'
sel_pr_bnd = [0, 0.05, 0.2, 0.35, 0.5, 1] # increase boundaries for marker sizes

# Figure parameters
title_size = 24
title_pad = 0.1
axis_label_size = 22
axis_tick_size= 20
tick_label_size = 12
fig_ext = '.png'

# Analysis parameters
thresh_inv_crit = 0.75 # % above or below which only some performances may lie
thresh_inv_crit2 = 0.1 # proportion of bootstraps outside x-range
alpha_z = 1.96
