ccc; GERT_Init;

addpath(['..' filesep 'common' filesep])

subjs_1a = [4,5,6,7,8,9,20,21];
subjs_1b = [4,5,7,8,20,21];
sim_name = 'D_value';

for subj_n = subjs_1a
    disp(subj_n)
    D_value_simulate_subject(subj_n, sim_name, '1a');
end

for subj_n = subjs_1b
    disp(subj_n)
    D_value_simulate_subject(subj_n, sim_name, '1b');
end

if ~exist(['1a' filesep sim_name filesep 'all.mat'], 'file')
    onebigfile(['1a' filesep sim_name filesep], ['sim_' sim_name '_'], 6400);
end

if ~exist(['1b' filesep sim_name filesep 'all.mat'], 'file')
    onebigfile(['1b' filesep sim_name filesep], ['sim_' sim_name '_'], 800);
end

% Done
