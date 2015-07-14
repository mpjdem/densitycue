function [obs_means, obs_fit, obs_fit_boot] = ana_observe(inp, n_reps, n_curves, n_per_curve, n_sets)

    % Mean performance per condition
    [means_y, std_y, codes_y, y_n] = grpstats(inp.eval,{inp.cond_equid, inp.cond_closed,...
                     inp.cond_dispdens, inp.cond_contdens},{'mean','std','gname', 'numel'});

    % Mean actual contour distance per condition
    [means_x, std_x, codes_x] = grpstats(inp.cdist,{inp.cond_equid, inp.cond_closed,...
                     inp.cond_dispdens, inp.cond_contdens},{'mean','std','gname'});

    % In case of a simulation files:
    % Determine in which conditions the contour is /less/ dense
    % And leave them out of the logistic fits
    if isfield(inp,'mt')
        mt = grpstats(inp.mt,{inp.cond_equid, inp.cond_closed,...
            inp.cond_dispdens, inp.cond_contdens},{'mean'});
        conds_to_use = (mt<=0);
            % NOTE: for RadCount, inp.mt was inverted first
    else
        conds_to_use = ones(1,64);
    end
    
    % Do a logistic fit on the data
    % Each column is one curve
    % Output: the threshold for each curve, and the fit parameters
    x_for_fit = reshape(means_x,[n_per_curve, n_curves]);
    y_for_fit = reshape(means_y,[n_per_curve, n_curves]);
    n_for_fit = reshape(y_n,[n_per_curve, n_curves]);
    mask_for_fit = reshape(conds_to_use,[n_per_curve, n_curves]);
    [thresh, pars] = fit_logistic(x_for_fit, y_for_fit, n_for_fit, mask_for_fit);
    
    % For returning
    obs_means.x_for_fit = x_for_fit;
    obs_means.y_for_fit = y_for_fit;
    obs_means.n_for_fit = n_for_fit;
    obs_means.mask_for_fit = mask_for_fit;
    obs_means.codes_x = codes_x;
    obs_means.codes_y = codes_y;
    obs_fit.thresh = thresh;
    obs_fit.pars = pars;

    % Resampling statistics
    % Calculate condition means /per stimulus set/
    [ym, n_per] = grpstats(inp.eval,{inp.cond_equid, inp.cond_closed,...
        inp.cond_dispdens, inp.cond_contdens, inp.setn},{'mean','numel'});
    ym = reshape(ym, n_sets,[]);
    n_per = reshape(n_per, n_sets,[]);

    % Now we will resample the stimulus set percentages
    % Then re-average them into one number per condition
    % We will do this based on existing random numbers
    load bootstrap_samples.mat idx_mat samp_mat
    thresh_boot = zeros(n_reps, n_curves);
    pars_boot = zeros(n_reps, 2, n_curves);
    
    for r = 1:n_reps
        ym_r = zeros(n_sets, n_curves*n_per_curve);
        n_per_r = zeros(n_sets, n_curves*n_per_curve);
        
        % Shuffle each column separately (because between conditions, set
        % numbers are actually unrelated to one another)      
        for j = 1:n_curves*n_per_curve
            ym_r(:,j) = ym(idx_mat(:,j,r),j);
            n_per_r(:,j) = n_per(idx_mat(:,j,r),j);
        end
        % Then resample the rows
        ym_r = ym_r(samp_mat(:,r),:);
        n_per_r = n_per_r(samp_mat(:,r),:);
        % Re-average over the sets
        ym_r = sum((ym_r.*n_per_r)./repmat(sum(n_per_r,1),[n_sets,1]),1)';
        % Make a per-curve matrix for the logistic fit
        ys = reshape(ym_r,[n_per_curve, n_curves]);
        % And find the fitted thresholds for these resampled points
        [thresh_boot(r,:), pars_boot(r,:,:)] = fit_logistic(x_for_fit, ys, n_for_fit, mask_for_fit);
    end
    
    % For returning
    obs_fit_boot.thresh = thresh_boot;
    obs_fit_boot.pars = pars_boot;

end
