ccc; GERT_Init;

addpath(['..' filesep '..' filesep 'common' filesep])

subjs = [4,5,6,7,8,9,20,21]; 

% RadCount125
rc125_params = struct;
rc125_params.method_dens = 'RadCount';
rc125_params.method_stat = 'MC';
rc125_params.mc_samples_n = 1000;
rc125_params.rad = 1.25; % in terms of mindist, will be recomputed in simulate_subject

% RadCount15
rc15_params = struct;
rc15_params.method_dens = 'RadCount';
rc15_params.method_stat = 'MC';
rc15_params.mc_samples_n = 1000;
rc15_params.rad = 1.5; % in terms of mindist, will be recomputed in simulate_subject

% RadCount175
rc175_params = struct;
rc175_params.method_dens = 'RadCount';
rc175_params.method_stat = 'MC';
rc175_params.mc_samples_n = 1000;
rc175_params.rad = 1.75; % in terms of mindist, will be recomputed in simulate_subject

% RadCount2
rc2_params = struct;
rc2_params.method_dens = 'RadCount';
rc2_params.method_stat = 'MC';
rc2_params.mc_samples_n = 1000;
rc2_params.rad = 2; % in terms of mindist, will be recomputed in simulate_subject

% RadCount225
rc225_params = struct;
rc225_params.method_dens = 'RadCount';
rc225_params.method_stat = 'MC';
rc225_params.mc_samples_n = 1000;
rc225_params.rad = 2.25; % in terms of mindist, will be recomputed in simulate_subject

% AvgDist1
ad1_params = struct;
ad1_params.method_dens = 'AvgDist';
ad1_params.method_stat = 'MC';
ad1_params.mc_samples_n = 1000;
ad1_params.avg_n = 1;

% AvgDist2
ad2_params = struct;
ad2_params.method_dens = 'AvgDist';
ad2_params.method_stat = 'MC';
ad2_params.mc_samples_n = 1000;
ad2_params.avg_n = 2;

% AvgDist3
ad3_params = struct;
ad3_params.method_dens = 'AvgDist';
ad3_params.method_stat = 'MC';
ad3_params.mc_samples_n = 1000;
ad3_params.avg_n = 3;

% AvgDist4
ad4_params = struct;
ad4_params.method_dens = 'AvgDist';
ad4_params.method_stat = 'MC';
ad4_params.mc_samples_n = 1000;
ad4_params.avg_n = 4;


% AvgDist5
ad5_params = struct;
ad5_params.method_dens = 'AvgDist';
ad5_params.method_stat = 'MC';
ad5_params.mc_samples_n = 1000;
ad5_params.avg_n = 5;

% AvgDist
ad_params = struct;
ad_params.method_dens = 'AvgDist';
ad_params.method_stat = 'MC';
ad_params.mc_samples_n = 1000;

% Voronoi
vor_params = struct;
vor_params.method_dens = 'Voronoi';
vor_params.method_stat = 'MC';
vor_params.mc_samples_n = 1000;

% RadCountFull
rcf_params = struct;
rcf_params.method_dens = 'RadCount';
rcf_params.method_stat = 'MC';
rcf_params.mc_samples_n = 1000;
rcf_params.rad = linspace(1,2,20); % in terms of mindist, will be recomputed in simulate_subject

% For all methods, border_dist is computed as a function of the mindist of the condition in
% simulate_subject!

sims = {'Voronoi'};
sims_params = {vor_params};

% Do all simulations
for i = 1:length(sims)
    sim_name = sims{i};
    
    for subj_n = subjs
        disp(subj_n)
        simulate_subject(subj_n, sim_name, sims_params{i});
    end
    
    if ~exist([sim_name filesep 'all.mat'], 'file')
        onebigfile([sim_name filesep], ['sim_' sim_name '_'], 6400);
    end
    
end

% Done
