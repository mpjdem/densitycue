clear all
addpath(['..' filesep '..' filesep 'common' filesep])
warning('off')

% Settings
dir_data = ['..' filesep '..' filesep 'data' filesep '1a'];
dir_sim = ['..' filesep '..' filesep 'simulation' filesep '1a'];
dir_res = ['res'];
sims = {'AvgDist','AvgDist1','AvgDist2', 'AvgDist3','AvgDist4','AvgDist5',...
        'RadCountFull','RadCount125','RadCount15','RadCount175','RadCount2','RadCount225',...
        'Voronoi', 'Voronoi_AvgDist1'};

n_curves = 8;
n_per_curve = 8;
n_sets = 50;
n_resampling = 1000;
ps = [0 0.01 0.05 0.2 0.35 0.65 1];

% Make result directory
if ~exist(dir_res', 'dir')
    mkdir(dir_res);
end

% Make bootstrap samples
make_bootstrap_samples(n_sets, n_curves*n_per_curve, n_resampling);

% Create one data file
onebigfile(dir_data, 'dat', 6400);
for sim_name = sims
    onebigfile([dir_sim filesep sim_name{1} filesep], ['sim_' sim_name{1} '_'], 6400);
end

% Load data
dat = load([dir_data filesep 'all.mat']);
dat = dat.dat;

% Copy cdist information to dat, from any sim
sim = load([dir_sim filesep sims{1} filesep 'all.mat']);
sim = sim.sim;
dat.cdist = sim.cdist;

% Fit curves on data
if ~exist([dir_res filesep 'data'], 'dir')
    mkdir([dir_res filesep 'data']);
end
fname = [dir_res filesep 'data' filesep 'observe.mat'];
disp('data')
if ~exist(fname, 'file')
    [obs_means, obs_fit, obs_fit_boot] = ana_observe(dat, n_resampling, n_curves, n_per_curve, n_sets);
    save(fname, 'obs_means', 'obs_fit', 'obs_fit_boot');
end

% Process the various simulated datasets
for sim_name = sims
	
    disp(sim_name{1})
    
	% Load simulation
	sim = load([dir_sim filesep sim_name{1} filesep 'all.mat']);
	sim = sim.sim;
    
    sim.eval = double(abs(sim.pt-0.5) >= abs(sim.pd-0.5));
    % Because RadCountFull is detecting non-homogenous distractor displays
    % and can therefore never reach 100% correct even for the easiest
    % conditions
    
    if ~exist([dir_res filesep sim_name{1}], 'dir')
        mkdir([dir_res filesep sim_name{1}]);
    end
    
    % If RadCount method, invert mt
    if strfind(sim_name{1}, 'RadCount')
       sim.mt = -sim.mt; 
    end
	
	% Fit curves on simulation
    fname = [dir_res filesep sim_name{1} filesep 'observe.mat'];
    if ~exist(fname, 'file')
        [obs_means, obs_fit, obs_fit_boot] = ana_observe(sim, n_resampling, n_curves, n_per_curve, n_sets);
        save(fname, 'obs_means', 'obs_fit', 'obs_fit_boot');
    end
	
	% Predict condition means
    fname = [dir_res filesep sim_name{1} filesep 'predict.mat'];
    if ~exist(fname, 'file')
        [pred_res, pred_res_boot] = ana_predict(dat, sim, n_resampling, n_curves, n_per_curve, n_sets);
        save(fname, 'pred_res', 'pred_res_boot');
     end
         
	% Display selection performance
    fname = [dir_res filesep sim_name{1} filesep 'select.mat'];
    if ~exist(fname, 'file')
        [sel_cpred, sel_cpred_boot] = ana_select(dat, sim, ps, n_resampling, n_curves, n_per_curve, n_sets);
        save(fname, 'sel_cpred', 'sel_cpred_boot');
    end
end

% All done
