% Run the simulation for the Luminance metric (Supplementary Materials S3)
% d0s are standard deviations of Gaussian filter (in cycles per image)
ccc;
sim_name = 'Lum';
oriented = true;
d0s = [15 20 25];

experiments = {'1a','1b'};

for exp_name = experiments
    for d0 = d0s

    % Input file
    basedir = ['..' filesep];
    datfile = [basedir 'data' filesep exp_name{1} filesep 'all.mat'];
    load(datfile, 'dat');

    % Stimulus directory
    stimdir = [basedir 'experiment' filesep exp_name{1} filesep 'stims' filesep];

    % Output file
    if ~exist([exp_name{1} filesep sim_name], 'dir')
        mkdir([exp_name{1} filesep sim_name]);
    end
    if oriented == false
        sim_file = [exp_name{1} filesep sim_name filesep 'all_' num2str(d0) '.mat'];
    else
        sim_file = [exp_name{1} filesep sim_name filesep 'all_or_' num2str(d0) '.mat'];
    end
    
    % Check whether file exists
    if exist(sim_file, 'file')
       disp('File exists')
       continue
    end

    % Make a simulation structure
    trials_n = length(dat.subj);
    sim = struct;
    sim.target = dat.target;                    % copy some values
    sim.cond_contdens = dat.cond_contdens;
    sim.cond_dispdens = dat.cond_dispdens;
    sim.cond_closed = dat.cond_closed;
    sim.cond_equid = dat.cond_equid;
    sim.stimseq = dat.stimseq;

    sim.resp = zeros(1,trials_n);
    sim.eval = -ones(1,trials_n);

    % Filename parts
    fname_dispdens = {'lo','hi'};
    fname_closed = {'op','cl'};
    fname_equid = {'ran','eq'};

    % Run through the trials
    for trial = 1:trials_n

        disp(trial)

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

        % Render image
        [tIMG, tC, tEa, mindist_t] = Lum_render_image(t_fname, true, oriented);
        [dIMG, dC, dEa, mindist_d] = Lum_render_image(d_fname, false, oriented);

        % Determine contour and background zones
        h_res = size(tIMG,1);
        v_res = size(tIMG,2);
        limg_t = false(h_res, v_res);
        dild = round(mindist_t);
        dilate_disk = strel('disk', dild, 0);
        limg_t(sub2ind([h_res v_res],round(tC.x),round(tC.y))) = true;
        limg_t  = imdilate(limg_t, dilate_disk);

        limg_b = ~limg_t;
        border = round(mindist_t*3);
        limg_b(1:border,:) = false;
        limg_b(:,1:border) = false;
        limg_b(end-border:end,:) = false;
        limg_b(:,end-border:end) = false;

        % Filter image
        tIMGp = Lum_lowpass_filter(tIMG, d0);
        dIMGp = Lum_lowpass_filter(dIMG, d0);

        % Compute mean luminances
        lum_tc = mean(tIMGp(limg_t));
        lum_tb = mean(tIMGp(limg_b));
        lum_dc = mean(dIMGp(limg_t));
        lum_db = mean(dIMGp(limg_b));

        sim.mt1(trial) = lum_tc;
        sim.mt2(trial) = lum_tb;
        sim.mt(trial) = lum_tc-lum_tb;
        sim.md1(trial) = lum_dc;
        sim.md2(trial) = lum_db;
        sim.md(trial) = lum_dc-lum_db;

        % Determine the simulated response
        if abs(sim.mt(trial))>abs(sim.md(trial))
            sim.resp(trial) = t;
            sim.eval(trial) = 1;
        else
            sim.resp(trial) = d;
            sim.eval(trial) = 0;
        end

        % On to the next trial

    end

    sim.amt = abs(sim.mt);
    save(sim_file, 'sim');

    end
    
end
    