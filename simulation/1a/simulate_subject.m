function simulate_subject(subj_n, sim_name, cld_params)
    
    logfile = 0; % simulate from log-file or from (reduced) stim file

    % Input file
    basedir = ['..' filesep '..' filesep];
    subj_file = [basedir 'data' filesep '1a' filesep 'dat' num2str(subj_n) '.mat'];
    load(subj_file, 'dat');
    
    % Stimulus directory
    stimdir = [basedir 'experiment' filesep '1a' filesep 'stims' filesep];
    
    % Output file
    if ~exist(sim_name, 'dir')
       mkdir(sim_name); 
    end
    sim_file = [sim_name filesep 'sim_' sim_name '_' num2str(subj_n) '.mat'];
    
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
    sim.pd = -ones(1,trials_n);                 % (p-value of distractor)

    % Filename parts
    fname_dispdens = {'lo','hi'};
    fname_closed = {'op','cl'};
    fname_equid = {'ran','eq'};
    
    % Save the original rad input
    if strcmp(cld_params.method_dens, 'RadCount') 
        or_rad = cld_params.rad;
    end
    
    % Run through the trials
    for trial = 1:trials_n

        % Output current trial number to command window
        %trial

        % Determine filenames
        t = sim.target(trial); % 1 or 2
        t_fname = [stimdir ...
                   't_' fname_dispdens{sim.cond_dispdens(trial)} '_' ...
                   fname_closed{sim.cond_closed(trial)+1} '_' ...
                   fname_equid{sim.cond_equid(trial)+1} '_' ...
                   num2str(sim.cond_contdens(trial)) '_' ...
                   num2str(sim.stimseq{trial}(t*2))  '.mat'];

        d = 3-t; % if target = 1, distractor = 2, and vice versa
        d_fname = [stimdir ...
                   'd_' fname_dispdens{sim.cond_dispdens(trial)} '_' ...
                   num2str(sim.stimseq{trial}(d*2)) '.mat'];

        % Load target display elements & contour description 
        
        if logfile % do simulation based on original logfile
            load(t_fname, 'slog')
            t_els = slog.Functions.GERT_RenderDisplay{1}.IN_elements;
            t_els = t_els.rmid(); % apparently some stimuli have duplicate elements; remove these 
            t_cont = slog.Functions.GERT_PlaceElements_Contour{1}.IN_contour;
            clear slog;
        else % do simulation based on stripped logfile (reduced filesize)
            load(t_fname, 'stim');
            t_els = GElements;
            t_els.x = double(stim.x);
            t_els.y = double(stim.y);
            t_els = settag(t_els,'b',1:t_els.n); t_els = settag(t_els,'c',1:stim.ctag);
            t_els.dims = [1 512 1 512];
            t_cont = GERT_GenerateContour_RFP(stim.RFP_params);
            t_cont = GERT_Transform_Shift(t_cont,[256 256]);
            clear stim;
        end

        % Load distractor display elements
        
        if logfile % do simulation based on original logfile
            load(d_fname, 'slog')
             d_els = slog.Functions.GERT_RenderDisplay{1}.IN_elements;
             d_els = d_els.rmid();
             mindist = slog.Functions.GERT_PlaceElements_Background{1}.IN_params.min_dist;
             clear slog;
        else % do simulation based on stripped logfile (reduced filesize)
            load(d_fname, 'stim');
            d_els = GElements;
            d_els.x = double(stim.x);
            d_els.y = double(stim.y);
            d_els = settag(d_els,'b',1:d_els.n);
            d_els.dims = [1 512 1 512];
            mindist = stim.min_dist;
            clear stim;
        end

        % Determine p-value for target display
        cidx = t_els.gettag('c'); % indices to contour elements
        bidx = t_els.gettag('b'); % indices to background elements

        if strcmp(cld_params.method_dens, 'RadCount')
            cld_params.rad = mindist * or_rad;
        end
        cld_params.border_dist = mindist * 3;
        
        res = GERT_CheckCue_LocalDensity(t_els,cidx,bidx,cld_params);
        
        sim.pt(trial) = res.pm; % p-value target
        sim.mt1(trial) = mean(res.c1); % mean density of contour
        sim.mt2(trial) = mean(res.c2); % mean density of background
        sim.mt(trial) = mean(res.c1)- mean(res.c2); % difference

        % Compute the effective mean distance between elements, along the
        % contour, for this particular trial.
        % To do this, we find the contour definition point that is closest to
        % each element. For contour definition points, we know the distance
        % along the contour, and since we have 1000 of them per contour, this
        % approach is precise enough. We then sort the elements according to
        % position along the contour (randomly placed elements aren't in any
        % order), and compute their distances using the diff() function.
        dmat = GERT_Aux_EuclDist(t_cont.x,t_cont.y,t_els.x(cidx),t_els.y(cidx));
        [val,idx] = min(dmat,[],1);
        pos_on_contour = sort(t_cont.cdist(idx));
        sim.cdist(trial) = mean(diff(pos_on_contour));  

        % Determine p-value for distractor display
        %
        % To do this, we will overlay the target contour description on the distractor
        % display, and label the closest elements as 'contour' elements.
        %
        % The number of 'fake' contour elements is determined by temporarily
        % populating the contour randomly with the effective mindist of the 
        % distractor display, and counting the resulting number of elements.
        %

        % Compute distances of elements to contour, and sort
        dmat = GERT_Aux_EuclDist(t_cont.x, t_cont.y, d_els.x, d_els.y);
        [distance_to_contour, foo] = min(dmat,[],1);
        [foo, sorted_dels_idx] = sort(distance_to_contour);

        % Make the fake contour in order to determine its n
        pec_params.method = 'Random';
        pec_params.eucl_mindist = mindist;
        fake_contour = GERT_PlaceElements_Contour(t_cont, pec_params);

        % Get contour and background indices
        cidx = sorted_dels_idx(1:fake_contour.n);
        bidx = setdiff(1:d_els.n,cidx);

        % To visualize:
        d_els = d_els.settag('c',cidx);
        % d_els.plot()

        % Now do the distractor cue computation, same as above
        res = GERT_CheckCue_LocalDensity(d_els,cidx,bidx,cld_params);
        sim.pd(trial) = res.pm;
        sim.md(trial) = mean(res.c1)- mean(res.c2);

        % Determine the simulated response 
        if abs(sim.pt(trial)-0.5) >= abs(sim.pd(trial)-0.5)
            sim.resp(trial) = t;
            sim.eval(trial) = 1;
        else
            sim.resp(trial) = d;
            sim.eval(trial) = 0;        
        end

        % On to the next trial

    end
    
    save(sim_file, 'sim');

end