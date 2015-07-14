function [pars_ind, pars_all, ss_within, ss_between] = fit_linear(d, s, n, mask)

    % If no mask is provided, fit every point
    if ~exist('mask','var')
        mask = ones(size(d));
    end
    
    % Count number of columns = number of curves
    n_curves = size(d,2);
    pars_ind = zeros(2, n_curves);
    ss_within = zeros(1, n_curves);
    ss_between = 0;
    
    % Fit each curve
    for c = 1:n_curves
        
        % Fetch the mask, data, sims, n
        m = logical(mask(:,c));
        xc = d(:,c); %xc(~m) = 0.5; %xc = xc(m);
        yc = s(:,c); yc(~m) = 0.5; %yc = yc(m);
        yn = n(:,c); %yn = yn(m);
        
        % Do the linear fit of dat versus sim for this curve
        [par, dev, stats] = glmfit(xc, yc, 'normal');
        
        % Calculate within-condition fit
        ss_within(c) = sum(stats.resid.^2);
        
        % Save parameters
        pars_ind(:,c) = par;
        
    end
    
    ss_within = sum(ss_within);
    
    % Do an overall linear fit
    m = logical(mask(:));
    xc = d(:); xc = xc(m);
    yc = s(:); yc = yc(m);
    yn = n(:); yn = yn(m);
    [pars_all, dev, stats] = glmfit(xc, yc, 'normal');
    
    % Calculate sum-of-squares between conditions
    ss_between = sum(stats.resid.^2) - ss_within;
 
end
