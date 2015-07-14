function make_bootstrap_samples(n_sets, n_conds, n_reps)

    idx_mat = zeros(n_sets, n_conds, n_reps);
    samp_mat = zeros(n_sets, n_reps);
    
    for r = 1:n_reps
        tmp = zeros(n_sets, n_conds);
        [foo, idx] = Shuffle(tmp);
        idx_mat(:,:,r) = idx;
        samp_mat(:,r) = Randi(n_sets, [1 n_sets]);        
    end
    
    save bootstrap_samples.mat idx_mat samp_mat
    
end
