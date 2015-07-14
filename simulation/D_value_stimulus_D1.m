ccc; GERT_Init;

%% Load stimulus presented in Figure S12
load stimulusD1;

%% Visualize the stimulus (convert to GERT format)
Ea = GElements;
Ea.x = double(stim.x);
Ea.y = double(stim.y);
Ea = settag(Ea,'b',1:Ea.n); Ea = settag(Ea,'c',1:stim.ctag);
Ea.dims = [1 512 1 512];
img_params.global_rendering = true; 
img_params.blend_mode = 'MaxDiff'; 
IMG = GERT_RenderDisplay(@GERT_DrawElement_RadialGabor,Ea,struct,img_params);
imshow(IMG);

%% Compute the value D
%   = ratio of average Euclidean distance of each background element to its
%   nearest neighbor, to the average Euclidean distance between neigboring
%   contour elements

D_value = D_value_compute(stim)

%% Compute the value p
%   = proportion of resampled differences in average Voronoi surface area
%   that is more extreme than the true difference in average Voronoi
%   surface area (see manuscript for details)

cidx = Ea.gettag('c'); % indices to contour elements
bidx = Ea.gettag('b'); % indices to background elements
cld_params.border_dist = stim.min_dist * 3;
res = GERT_CheckCue_LocalDensity(Ea,cidx,bidx,cld_params);

p_value = res.pm
% value of 1 indicates that the background is more dense than the contour
% in the stimulus than in any of the 1000 resamplings.
