function [pred_res, pred_res_boot] = ana_predict(dat, sim, n_reps, n_curves, n_per_curve, n_sets)
    
    % Compute means
    [means_dat, std_dat, codes_dat, dat_n] = grpstats(dat.eval,...
        {dat.cond_equid, dat.cond_closed, dat.cond_dispdens, ...
        dat.cond_contdens},{'mean','std','gname', 'numel'});

    [means_sim, std_sim, codes_sim, sim_n] = grpstats(sim.eval,...
        {sim.cond_equid, sim.cond_closed, sim.cond_dispdens, ...
        sim.cond_contdens},{'mean','std','gname', 'numel'});

    % Determine in which conditions contour is /less/ dense
    if isfield(sim,'mt')
        mt = grpstats(sim.mt,{sim.cond_equid, sim.cond_closed,...
            sim.cond_dispdens, sim.cond_contdens},{'mean'});
        conds_to_use = (mt<=0);%|(means_y<0.55);
            % NOTE: for RadCount, inp.mt was inverted first
    else
        conds_to_use = ones(1,64);
    end
    
    % Do the fits
    x_for_fit = reshape(means_dat,[n_per_curve, n_curves]);
    y_for_fit = reshape(means_sim,[n_per_curve, n_curves]);
    n_for_fit = reshape(dat_n,[n_per_curve, n_curves]);
    mask_for_fit = reshape(conds_to_use,[n_per_curve, n_curves]);
    
    x_for_fit(x_for_fit>0.99)=0.99; y_for_fit(y_for_fit>0.99)=0.99;
    x_for_fit(x_for_fit<0.01)=0.01; y_for_fit(y_for_fit<0.01)=0.01;
    x_for_fit = log(x_for_fit./(1-x_for_fit));
    y_for_fit = log(y_for_fit./(1-y_for_fit));
    
    [pars_ind, pars_all, ssw, ssb] = fit_linear(x_for_fit, y_for_fit, n_for_fit, mask_for_fit);
    
    % Compute r² within and between 
    rqw = zeros(1,n_curves);
    for cond = 1:n_curves
       xm = x_for_fit(mask_for_fit(:,cond),cond);
       ym = y_for_fit(mask_for_fit(:,cond),cond);
       tmp = corrcoef(xm, ym).^2;
       rqw(cond) = tmp(1,2);
    end
    xm = x_for_fit(mask_for_fit);
    ym = y_for_fit(mask_for_fit);
    tmp = corrcoef(xm(:),ym(:)).^2;
    rqb = tmp(1,2);
    
    % For returning
    pred_res.x_for_fit = x_for_fit;
    pred_res.y_for_fit = y_for_fit;
    pred_res.n_for_fit = n_for_fit;
    pred_res.codes_dat = codes_dat;
    pred_res.codes_sim = codes_sim;
    pred_res.pars_ind = pars_ind;
    pred_res.pars_all = pars_all;
    pred_res.mask_for_fit = mask_for_fit;
    pred_res.ssw = ssw;
    pred_res.ssb = ssb;
    pred_res.rqw = rqw;
    pred_res.rqb = rqb;
    
    % Calculate condition means /per stimulus set/
    [dat_m, n_per] = grpstats(dat.eval,{dat.cond_equid, dat.cond_closed,...
    dat.cond_dispdens, dat.cond_contdens, dat.setn},{'mean','numel'});
    dat_m = reshape(dat_m,n_sets,[]);
    n_per = reshape(n_per,n_sets,[]);
    
    sim_m = grpstats(sim.eval,{sim.cond_equid, sim.cond_closed,...
    sim.cond_dispdens, sim.cond_contdens, sim.setn},{'mean'});
    sim_m = reshape(sim_m,n_sets,[]);
    
    % Now we will resample the stimulus set percentages
    % Then re-average them into one number per condition
    % We will do this based on existing random numbers
    load bootstrap_samples.mat idx_mat samp_mat
    pred_res_boot.pars_ind = zeros(2, n_curves, n_reps);
    pred_res_boot.ssw = zeros(1, n_curves, n_reps);
    pred_res_boot.rqw = zeros(1, n_curves, n_reps);
    pred_res_boot.pars_all = zeros(2, n_reps);
    pred_res_boot.ssb = zeros(1, n_reps);
    pred_res_boot.rqb = zeros(1, n_reps);
    for r = 1:n_reps
        dat_m_r = zeros(n_sets, n_curves*n_per_curve);
        sim_m_r = zeros(n_sets, n_curves*n_per_curve);
        n_per_r = zeros(n_sets, n_curves*n_per_curve);
        % Shuffle each column separately (because between conditions, set
        % numbers are actually unrelated to one another)      
        for j = 1:n_curves*n_per_curve
            dat_m_r(:,j) = dat_m(idx_mat(:,j,r),j);
            sim_m_r(:,j) = sim_m(idx_mat(:,j,r),j);
            n_per_r(:,j) = n_per(idx_mat(:,j,r),j);
        end
        % Then resample the rows
        dat_m_r = dat_m_r(samp_mat(:,r),:);
        sim_m_r = sim_m_r(samp_mat(:,r),:);
        n_per_r = n_per_r(samp_mat(:,r),:);
        % Re-average over the sets
        dat_m_r = sum((dat_m_r.*n_per_r)./repmat(sum(n_per_r,1),[n_sets,1]),1)';
        sim_m_r = sum((sim_m_r.*n_per_r)./repmat(sum(n_per_r,1),[n_sets,1]),1)';
        % Make a 8x8 matrix for the logistic fit
        dat_s = reshape(dat_m_r,[n_per_curve, n_curves]);
        sim_s = reshape(sim_m_r,[n_per_curve, n_curves]);
        % And do the fits
        dat_s(dat_s>0.99)=0.99; sim_s(sim_s>0.99)=0.99;
        dat_s(dat_s<0.01)=0.01; sim_s(sim_s<0.01)=0.01;
        dat_s = log(dat_s./(1-dat_s));
        sim_s = log(sim_s./(1-sim_s));
        [pred_res_boot.pars_ind(:,:,r), pred_res_boot.pars_all(:,r), pred_res_boot.ssw(:,r), pred_res_boot.ssb(:,r)] = fit_linear(dat_s, sim_s, n_for_fit, mask_for_fit);
        % And the r² computations 
        for cond = 1:n_curves
            xm = dat_s(mask_for_fit(:,cond),cond);
            ym = sim_s(mask_for_fit(:,cond),cond);
            tmp = corrcoef(xm, ym).^2;
            pred_res_boot.rqw(1,cond,r) = tmp(1,2);
        end
        xm = dat_s(mask_for_fit);
        ym = sim_s(mask_for_fit);
        tmp = corrcoef(xm(:),ym(:)).^2;
        pred_res_boot.rqb(1,r) = tmp(1,2);
    end
end
