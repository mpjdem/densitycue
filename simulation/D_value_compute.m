function D_value = D_value_compute(stim)

% D = ratio of background distance over contour distance
% computed as ratio of the average Euclidean distance of each background
% element to its natural neigbors, to the average Euclidean distance between
% neighboring contour elements

% stim = stimulus structure (as in the mat-files in the experiment\1a\stims
% folder
% fields:
%   x -> vector with x positions for all elements (uint16)
%   y -> vector with y positions for all elements (uint16)
%   ctag -> index of last contour element (integer)
%   min_dist -> minimum distance between background elements (in pixels)
%   RFP_params -> parameters to generate RFP contour (not needed here)
%   closed -> Boolean (0 = open contour; 1 = closed contour)

c_idx = 1:stim.ctag;

%% Compute average Euclidean distance between ordered contour elements:
c_1 = double([stim.x(c_idx); stim.y(c_idx)]');
c_2 = double([c_1(2:end,:); c_1(1,:)]);
c_distance = sqrt(sum((c_1-c_2).^2,2)); 
if stim.closed == 0
   c_distance = c_distance(1:end-1);
end
c_distance = mean(c_distance);


%% Compute average Euclidean distance between background elements:
% Construct GERT Elements object from "stim" information
elements = GElements;
elements.x = double(stim.x);
elements.y = double(stim.y);
elements = settag(elements,'b',1:elements.n);
elements = settag(elements,'c',1:stim.ctag);
elements.dims = [1 512 1 512];
% Define parameters to compute AvgDist (default: natural neighbors)
cld_params.method_dens = 'AvgDist';
cld_params.method_stat = 'MC';
cld_params.mc_samples_n = 1000;
cld_params.border_dist = 3*stim.min_dist;
% Compute AvgDist
res = GERT_CheckCue_LocalDensity(elements, gettag(elements,'c'),gettag(elements,'b'), cld_params);
% res.c2 = vector of average distance to natural neighbors for each
% background element
b_distance = mean(res.c2);

D_value = b_distance/c_distance;





