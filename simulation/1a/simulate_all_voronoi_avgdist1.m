ccc; GERT_Init;

addpath(['..' filesep '..' filesep 'common' filesep])

sim1 = load('AvgDist1\all.mat');
sim2 = load('Voronoi\all.mat');

sim = sim1.sim;

% retain least extreme p-value for target
[foo ind] = sort([sim1.sim.pt;sim2.sim.pt],1);
lowest_p = ind(1,:);
sim.pt = sim1.sim.pt.*(lowest_p==1) + sim2.sim.pt.*(lowest_p==2);

% retain least extreme p-value for distractor
[foo ind] = sort([sim1.sim.pd;sim2.sim.pd],1);
lowest_p = ind(1,:);
sim.pd = sim1.sim.pd.*(lowest_p==1) + sim2.sim.pd.*(lowest_p==2);

% evaluate
sim.eval = (abs(sim.pt-0.5)) >= (abs(sim.pd-0.5));

clear sim1 sim2;

save('Combined\all.mat','sim');