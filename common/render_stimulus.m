function render_stimulus(matfile)
    % Plots and renders stimuli used in local density experiment
    % Input = string: (path+)filename to stimulus
    % Rendering requires the free GERT toolbox (www.gestaltrevision.be/GERT);
    % 2014.11.27 - Bart Machilsen & Maarten Demeyer

    load(matfile);
    
    % Do the plotting:
    figure; hold on;
    plot(stim.x,stim.y,'ko');
    plot(stim.x(1:stim.ctag),stim.y(1:stim.ctag),'ko','MarkerFaceColor',[0.8 0.2 0.2]);
    axis square; axis equal; axis off;
    
    % Do the rendering: (requires GERT toolbox)
    Ea = GElements;
    Ea.x = double(stim.x);
    Ea.y = double(stim.y);
    Ea.dims = [1 512 1 512];
    Ea = settag(Ea,'b',1:Ea.n);
    if stim.ctag>0
        Ea = settag(Ea,'c',1:stim.ctag);
    end
    img_params.global_rendering = true;
    img_params.blend_mode = 'MaxDiff';
    IMG = GERT_RenderDisplay(@GERT_DrawElement_RadialGabor,Ea,struct,img_params);
    figure;
    imshow(IMG);
    
    
