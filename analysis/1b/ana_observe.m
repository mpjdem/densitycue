function [obs_means, obs_boot] = ana_observe(inp, n_reps, n_curves, n_sets)

    % Mean performance per condition
    [means_y, std_y, codes_y, y_n] = grpstats(inp.eval,{inp.cond_equid, inp.cond_closed,...
                     inp.cond_dispdens, inp.cond_contdens},{'mean','std','gname', 'numel'});
                 
    [means_y_ps, std_y_ps, codes_y_ps, y_n_ps] = grpstats(inp.eval,{inp.cond_equid, inp.cond_closed,...
                     inp.cond_dispdens, inp.cond_contdens, inp.subj},{'mean','std','gname', 'numel'});
    
    % For returning
    obs_means.y = means_y;
    obs_means.codes_y = codes_y;
    n_subj = length(unique(inp.subj));
    means_y_ps = reshape(means_y_ps, [length(means_y_ps)/n_subj, n_subj]);
    
    obs_means.se_y = std(means_y_ps,[],2) / sqrt(n_subj);
    
    
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
    means_y = zeros(n_reps, n_curves);
    
    for r = 1:n_reps
        ym_r = zeros(n_sets, n_curves);
        n_per_r = zeros(n_sets, n_curves);
        
        % Shuffle each column separately (because between conditions, set
        % numbers are actually unrelated to one another)      
        for j = 1:n_curves
            ym_r(:,j) = ym(idx_mat(:,j,r),j);
            n_per_r(:,j) = n_per(idx_mat(:,j,r),j);
        end
        % Then resample the rows
        ym_r = ym_r(samp_mat(:,r),:);
        n_per_r = n_per_r(samp_mat(:,r),:);
        % Re-average over the sets, and save
        means_y(r,:) = sum((ym_r.*n_per_r)./repmat(sum(n_per_r,1),[n_sets,1]),1)';
    end
    
    % For returning
    obs_boot.y = means_y;

end
