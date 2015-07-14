clear all;
addpath(['..' filesep '..' filesep 'common' filesep])
warning('off')

% Settings
dir_data = ['..' filesep '..' filesep 'data' filesep '1b'];
dir_sim = ['..' filesep '..' filesep 'simulation' filesep '1b'];
dir_res = ['res'];
sims = {'AvgDist','AvgDist1','AvgDist2', 'AvgDist3','AvgDist4','AvgDist5',...
        'RadCountFull','RadCount125','RadCount15','RadCount175','RadCount2','RadCount225',...
        'Voronoi'}; 
n_curves = 8;
n_per_curve = 1;
n_sets = 50;
n_resampling = 1000;

% Make result directory
if ~exist(dir_res', 'dir')
    mkdir(dir_res);
end

% Make bootstrap samples
make_bootstrap_samples(n_sets, n_curves, n_resampling);

% Create one data file
onebigfile(dir_data, 'dat', 800);
for sim_name = sims
    onebigfile([dir_sim filesep sim_name{1} filesep], ['sim_' sim_name{1} '_'], 800);
end

% Load data
dat = load([dir_data filesep 'all.mat']);
dat = dat.dat;

% Compute means in data
if ~exist([dir_res filesep 'data'], 'dir')
    mkdir([dir_res filesep 'data']);
end
fname = [dir_res filesep 'data' filesep 'observe.mat'];
disp('data')
if ~exist(fname, 'file')
    [obs_means, obs_boot] = ana_observe(dat, n_resampling, n_curves, n_sets);
    save(fname, 'obs_means', 'obs_boot');
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
	
	% Compute means in simulation
    fname = [dir_res filesep sim_name{1} filesep 'observe.mat'];
    if ~exist(fname, 'file')
        [obs_means, obs_boot] = ana_observe(sim, n_resampling, n_curves, n_sets);
        save(fname, 'obs_means', 'obs_boot');
    end
end

% All done