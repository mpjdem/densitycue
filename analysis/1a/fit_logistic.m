function [thresholds, pars] = fit_logistic(x, y, yn, mask)
    
    % If no mask is provided, fit every point
    if ~exist('mask','var')
        mask = ones(size(x));
    end
    
    % Count number of columns = number of curves
    n_curves = size(x,2);
    
    % Prepare the output variables:
    % - thresholds for each curve
    % - logistic parameters for each curve
    thresholds = zeros(1,n_curves);
    pars = zeros(2,n_curves);
    
    fl=inline('log((max(.50+1e-6, min(p, 1-1e-6))-.50) ./ (1-max(.50+1e-6, min(p, 1-1e-6))))');
    fd=inline('0.50 ./ ((1-max(.50+1e-6, min(p, 1-1e-6))) .* (max(.50+1e-6, min(p, 1-1e-6))-0.50))');
    fi=inline('(.50 + exp(x)) ./ (1+exp(x))');
    twoafc_link = {fl fd fi};   
    
    % Fit each curve
    for c = 1:n_curves
        
        % Fetch the data points to use for this curve
        m = logical(mask(:,c));
        
        % Fetch the x-data, apply the mask
        xc = x(:,c);
        %xc = xc(m);
        
        % Fetch the y-data
        yc = y(:,c);
        yc(~m) = 0.5;
        %yc = yc(m);

        % Fetch the n-data, apply the mask
        n = yn(:,c);
        %n = n(m);
               
        % Subtract 1 from perfect performances
        ycn = yc.*n;
        ycn(round(ycn)==round(n)) = ycn(round(ycn)==round(n))-1;
       
        % Do the logistic fit of x versus y
        par = glmfit(xc, [ycn ones(length(yc),1).*n], 'binomial', 'link', twoafc_link);
        threshold = -par(1)/par(2);
               
        if (isnan(threshold))
          % The above glmfit is the optimal way to fit a logistic function.
          % It takes the binomial variability at each yc level into
          % account. However, due to (quasi-)complete separation, glmfit
          % sometimes returns NaN values. In that case we do a non-binomial
          % fitting (i.e. not taking binomial variability into account),
          % but with the correct link function for a lower asymptote at
          % 50%.
          % Two options:
          % (1) Matlab's fminsearch: Nelder-Mead minimization of the
          % (negative) log-likelihood corresponding to the 0.50 lower
          % asymptote. Gives reasonable fits, even after warning message
          % "maximum number of function evaluations has been exceeded"
          % (2) R's optim function: similar  but slightly different results
          % compared to fminsearch, probably due to differences in
          % numerical techniques. Calling R is inefficient.
          
            
          % (1) Nelder-Mead minimization of the (negative) log-likelihood
            nsucc = round(n.*yc);
            nfail = n-nsucc;
            negLogLik = @(p)(-sum(nsucc.*log(0.5+0.5.*(1./(1+ exp(-(p(1)+p(2).*xc)))))+nfail.*log(1-(0.5+0.5.*(1./(1+ exp(-(p(1)+p(2).*xc))))))));
            par = fminsearch(negLogLik,[mean(xc) -2]); % gives reasonable fit, even after warning message 
            threshold = -par(1)/par(2);
            
%           % (2) Same in R:
%             eval('!del params.csv'); eval('!del xyn.csv');
%             csvwrite('xyn.csv',[xc ycn./n n]);
%             system('R CMD BATCH fit_logistic_R.R');
%             par = csvread('params.csv');
%             threshold = -par(1)/par(2);
        end

%         plot(xc,y(:,c),'ro');
%         hold on;
%         yfit = 0.5 + 0.5 * (1 ./ (1 + exp(- (par(1) + (par(2) * linspace(xc(1),xc(end),100))))));
%         plot(linspace(xc(1),xc(end),100),yfit,'c-');

        thresholds(c) = threshold;
        pars(:,c) = par;
    end

end

