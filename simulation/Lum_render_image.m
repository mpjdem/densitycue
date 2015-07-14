function [IMG, t_cont, t_els, mindist] = Lum_render_image(fname, target, oriented)

% Render original stimulus display from the description in the stripped
% stim.mat file.

load(fname, 'stim');
t_els = GElements;
t_els.x = double(stim.x);
t_els.y = double(stim.y);
if target
    t_els = settag(t_els,'b',1:t_els.n); t_els = settag(t_els,'c',1:stim.ctag);
    t_cont = GERT_GenerateContour_RFP(stim.RFP_params);
    t_cont = GERT_Transform_Shift(t_cont,[256 256]);
else
    t_cont = [];
end
t_els.dims = [1 512 1 512];
mindist = stim.min_dist;


ors = [];
for this_el = 1:stim.ctag
   [foo, idx] = min(GERT_Aux_EuclDist(t_els.x(this_el),t_els.y(this_el),t_cont.x,t_cont.y));
   ors = [ors t_cont.lt(idx)];
end

el_params = struct;
img_params.global_rendering = true;
img_params.blend_mode = 'MaxDiff';

if oriented == false
    IMG = GERT_RenderDisplay(@GERT_DrawElement_RadialGabor,t_els,el_params,img_params);
else
    el_params.or = rand(1,t_els.n)*2*pi;
    el_params.or(1:stim.ctag) = ors;
    IMG = GERT_RenderDisplay(@GERT_DrawElement_Gabor,t_els,el_params,img_params);
end

end