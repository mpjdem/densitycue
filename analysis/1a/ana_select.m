function [sel_cpred, sel_cpred_boot] = ana_select(dat, sim, ps, n_reps, n_curves, n_per_curve, n_sets)
    
    sel_cpred.ps = ps;
	sel_cpred.all_curves = zeros(1,length(ps)-1);
	sel_cpred.ind_curves = zeros(length(ps)-1, n_curves);
    sel_cpred.n_per = zeros(length(ps)-1, n_curves);

	% Mean performance per p-criterion
	[dat_m, n_per] = grpstats(dat.eval,{dat.cond_equid, dat.cond_closed,...
		dat.cond_dispdens, dat.cond_contdens, dat.setn},{'mean','numel'});
	dat_m = reshape(dat_m,n_sets,[]);
    n_per = reshape(n_per,n_sets,[]);
	sim_p = grpstats(sim.pt,{sim.cond_equid, sim.cond_closed,...
					sim.cond_dispdens, sim.cond_contdens, sim.setn},{'mean'});
	sim_p = reshape(sim_p,n_sets,[]);
    
	for i = 1:length(ps)-1
        dat_m_t = dat_m;
        n_per_t = n_per;
        msk = logical((sim_p>=ps(i)) .* (sim_p<=ps(i+1)));
		dat_m_t(~msk) = NaN;
        n_per_t(~msk) = NaN;
		dat_m_t = reshape(dat_m_t,[n_sets, n_per_curve, n_curves]);
        n_per_t = reshape(n_per_t,[n_sets, n_per_curve, n_curves]);
        tmp = nansum((dat_m_t.*n_per_t)./repmat(nansum(n_per_t,1),[n_sets,1,1]),1);
        sel_cpred.ind_curves(i,:) = nansum(tmp.*nansum(n_per_t,1)./repmat(nansum(nansum(n_per_t,1),2),[1,n_per_curve,1]),2);
        sel_cpred.n_per(i,:) = nansum(nansum(n_per_t,1),2);
    end
    sel_cpred.all_curves = mean(sel_cpred.ind_curves,2);

	% Resampling statistics
	load bootstrap_samples.mat idx_mat samp_mat

	sel_cpred_boot.ind_curves = zeros(length(ps)-1, n_curves, n_reps);
	for r = 1:n_reps
		sim_p_r = zeros(n_sets, n_curves*n_per_curve);
		dat_m_r = zeros(n_sets, n_curves*n_per_curve);
        n_per_r = zeros(n_sets, n_curves*n_per_curve);
		% Shuffle each column separately (because between conditions, set
		% numbers are actually unrelated to one another)      
		for j = 1:n_curves*n_per_curve
			sim_p_r(:,j) = sim_p(idx_mat(:,j,r),j);
			dat_m_r(:,j) = dat_m(idx_mat(:,j,r),j);
            n_per_r(:,j) = n_per(idx_mat(:,j,r),j);
		end
		% Then resample the rows
		sim_p_r = sim_p_r(samp_mat(:,r),:);
		dat_m_r = dat_m_r(samp_mat(:,r),:);
        n_per_r = n_per_r(samp_mat(:,r),:);
		% Evaluate against the criteria
		for i = 1:length(ps)-1
            dat_m_rt = dat_m_r;
            n_per_rt = n_per_r;
            msk = logical((sim_p_r>=ps(i)) .* (sim_p_r<=ps(i+1)));
            dat_m_rt(~msk) = NaN;
            n_per_rt(~msk) = NaN;
            dat_m_rt = reshape(dat_m_rt,[n_sets, n_per_curve, n_curves]);
            n_per_rt = reshape(n_per_rt,[n_sets, n_per_curve, n_curves]);
            tmp = nansum((dat_m_rt.*n_per_rt)./repmat(nansum(n_per_rt,1),[n_sets,1,1]),1);
            sel_cpred_boot.ind_curves(i,:,r) = nansum(tmp.*nansum(n_per_rt,1)./repmat(nansum(nansum(n_per_rt,1),2),[1,n_per_curve,1]),2);
            sel_cpred_boot.n_per(i,:,r) = nansum(nansum(n_per_rt,1),2);
        end
	end

	sel_cpred_boot.all_curves = mean(sel_cpred_boot.ind_curves,2);
	
end