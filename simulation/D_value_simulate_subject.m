function D_value_simulate_subject(subj_n, sim_name, exp_name)
    
    % Input file
    basedir = ['..' filesep];
    subj_file = [basedir 'data' filesep exp_name filesep 'dat' num2str(subj_n) '.mat'];
    load(subj_file, 'dat');
    
    % Stimulus directory
    stimdir = [basedir 'experiment' filesep exp_name filesep 'stims' filesep];
    
    % Output file
    if ~exist([exp_name filesep sim_name], 'dir')
       mkdir([exp_name filesep sim_name]); 
    end
    sim_file = [exp_name filesep sim_name filesep 'sim_' sim_name '_' num2str(subj_n) '.mat'];
    
    % Check whether file exists
    if exist(sim_file, 'file')
       disp('File exists')
       return 
    end
    
    % Make a simulation structure
    trials_n = dat.next_trial-1;
    sim = struct;
    sim.target = dat.target;                    % copy some values
    sim.cond_contdens = dat.cond_contdens;
    sim.cond_dispdens = dat.cond_dispdens;
    sim.cond_closed = dat.cond_closed;
    sim.cond_equid = dat.cond_equid;
    sim.stimseq = dat.stimseq;
    sim.resp = zeros(1,trials_n);               % fill in these values later
    sim.eval = -ones(1,trials_n);
    sim.pt = -ones(1,trials_n);                 % (p-value of target)

    % Filename parts
    fname_dispdens = {'lo','hi'};
    fname_closed = {'op','cl'};
    fname_equid = {'ran','eq'};
       
    % Run through the trials
    for trial = 1:trials_n

        % Determine filenames
        t = sim.target(trial); % 1 or 2
        t_fname = [stimdir ...
                   't_' fname_dispdens{sim.cond_dispdens(trial)} '_' ...
                   fname_closed{sim.cond_closed(trial)+1} '_' ...
                   fname_equid{sim.cond_equid(trial)+1} '_' ...
                   num2str(sim.cond_contdens(trial)) '_' ...
                   num2str(sim.stimseq{trial}(t*2))  '.mat'];

        % Load target display elements & contour description 
        load(t_fname, 'stim');
        stim.closed = sim.cond_closed(trial);
        
        % Determine D-value for target display
        sim.dt(trial) = D_value_compute(stim);

        % On to the next trial
    end
    
    save(sim_file, 'sim');

end