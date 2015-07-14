%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% !! The GERT manual will be a HUGE help in understanding this file !! %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Clear & Initialize
ccc;                                                                        % Clear all variables, close all figures, clear the command window
GERT_Init;                                                                  % Initialize GERT

%% Settings
% General
SZ = 512;                                                                   % Display size. Power of 2, since that is necessary for phase scrambling
N_STIMS = 1; %50;                                                           % Number of stimuli per condition to generate. Temporarily set to 1 for testing/piloting.

% Contours
RFP_N = 4;                                                                  % Number of RFP components
RFP_AMP = linspace(0.75,1.25,25)*10;                                        % RFP amplitudes to draw from randomly
RFP_FREQ = [2 3 4 5 6];                                                     % RFP frequencies to draw from randomly
RFP_PH = linspace(0,2*pi,25);                                               % RFP phases to draw from randomly

% Foreground elements
FG_DENS_N = 12;                                                             % Number of density levels
FG_MAT_RD = [linspace(11.5,21.5,FG_DENS_N); linspace(16.5,30.5,FG_DENS_N)];         % Foreground density range for random placement
FG_MAT_EQ = [linspace(13.5,23.5,FG_DENS_N); linspace(18.5,32.5,FG_DENS_N)];         % Foreground density range for equidistant placement
OPEN_PROPORTION = 0.4;                                                      % Proportional range of THETA values to use for open RFP contours

% Background elements
LO_DENS = 23.5;                                                               % Low density background spacing
HI_DENS = 16.5;                                                               % High density background spacing

%% Set constant parameters
rfp_params.baser = 100;                                                     % Base radius of RFP contours                                                                                                             

peb_params.resolution = 1000;                                               % Background element placement resolution
peb_params.dims = [1 SZ 1 SZ];                                              % Dimensions of the display

img_params.global_rendering = true;                                         % Use global rendeirng to place identical elements
img_params.blend_mode = 'MaxDiff';                                          % Use the MaxDiff mode to prevent image patches from cutting into eachother

el_params = struct;                                                         % Use the default values for radial Gabor elements

%% Conditions
hilo = [HI_DENS LO_DENS];                                                   % Density conditions
hilo_fn = [{'hi'} {'lo'}];                                                  % How to denote them in the filenames
pecmeths = [{'Random'} {'ParallelEquidistant'}];                            % Placement method conditions
pecmeths_fn = [{'ran'} {'eq'}];                                             
openclosed = [0 2*pi; 0 2*pi*OPEN_PROPORTION];                              % Open/closed conditions
openclosed_fn = [{'cl'} {'op'}];                                           

%% Generate stimuli
for s = 1:N_STIMS                                                           % Iterate over all sets to be generated
    
    s                                                                       % Display the current set number in the command window
    
    % High versus low density
    for h = 1:length(hilo)                                                  % Iterate over the density conditions
        
        peb_params.min_dist = hilo(h);                                      % Adjust the background density accordingly
        
        % % Distractor % %
        fname = ['d_' hilo_fn{h} '_' num2str(s)];                           % Define filename    (num2str: convert number to string)
        GERT_log = start(GERT_log);                                         % Start logging
        GERT_log = add(GERT_log,'msg',fname);                               % Record the filename in the log
        Ea = GERT_PlaceElements_Background([],[],peb_params);               % Fill the empty display with random elements
        IMG = GERT_RenderDisplay(@GERT_DrawElement_RadialGabor,Ea,el_params,img_params); % Render the display using radial Gabors
        slog = fetch(GERT_log);                                             % Retrieve the log
        save([fname '.mat'],'IMG','slog');                                  % Save both the image and the log
        imwrite(IMG, [fname '.png'], 'png');                                % Also write a png image
        GERT_log = stop(GERT_log);                                          % Clear the log
    
        % % Mask % %
        fname = ['m_' hilo_fn{h} '_' num2str(s)];
        IMG = vm_phase_scrambling(IMG);                                     % Phase scramble the generated image
        save([ fname '.mat'],'IMG');
        imwrite(IMG, [fname '.png'], 'png');
        
        % % Targets % %
        % Open versus closed
        for oc = 1:2                                                        % Iterate over the open/closed conditions
            rfp_params.th_range = openclosed(oc,:);                         % Adjust the contour generation accordingly
            
            % Random versus equidistant
            for pcm = 1:length(pecmeths)                                    % Iterate over the placement method conditions
                pec_params.method = 'ParallelEquidistant' %pecmeths{pcm};                          % Adjust the placement method accordingly
                
                % Element density on contour
                for fgd = 1:FG_DENS_N                                       % Iterate over the background density conditions
                    
                    fname = ['t_' hilo_fn{h} '_' openclosed_fn{oc} '_' pecmeths_fn{pcm} '_' num2str(fgd) '_' num2str(s)];
                    GERT_log = start(GERT_log);
                    GERT_log = add(GERT_log,'msg',fname);
                    
                    rfp_params.amp = RFP_AMP(custom_randi(length(RFP_AMP),[1 RFP_N]));     % Randomly generate amplitude, frequency, phase, rotation for RFPs
                    rfp_params.freq = RFP_FREQ(custom_randi(length(RFP_FREQ),[1 RFP_N]));
                    rfp_params.ph = RFP_PH(custom_randi(length(RFP_PH),[1 RFP_N]));
                    rfp_params.rot = rand*2*pi;
                    
                   % if strcmp(pecmeths{pcm},'Random')                       % If Random method
                        %if isfield(pec_params,'cont_avgdist')               % And if the cont_avgdist field is present in the struct
                           % pec_params = rmfield(pec_params,'cont_avgdist'); % Remove it
                       % end
                        %pec_params.eucl_mindist = FG_MAT_RD(h,fgd);         % Then set the eucl_mindist field
                    %else
                        if isfield(pec_params,'eucl_mindist')
                            pec_params = rmfield(pec_params,'eucl_mindist');
                        end
                        pec_params.cont_avgdist = FG_MAT_EQ(h,4)%fgd);         % And vice versa
                   % end
                    
                    C = GERT_GenerateContour_RFP(rfp_params);               % Generate the RFP contour
                    C = GERT_Transform_Shift(C,[SZ/2 SZ/2]);                % Shift it to the middle of the display
                    E = GERT_PlaceElements_Contour(C,pec_params);            % Place the contour elements
                    E.dims = [1 512 1 512];
                    Ea = GERT_PlaceElements_Background(E,[],peb_params);    % Surround them with background elements
                    IMG1 = GERT_RenderDisplay(@GERT_DrawElement_RadialGabor,E,el_params,img_params); % Etc, see above
                    IMG2 = GERT_RenderDisplay(@GERT_DrawElement_RadialGabor,Ea,el_params,img_params);
                    slog = fetch(GERT_log);   
                    save([ fname '.mat'],'IMG1','slog');
                    save([ fname '.mat'],'IMG2','slog');
                    imwrite(IMG1, [fname '.png'], 'png');
                    imwrite(IMG2, [fname '.png'], 'png');
                    GERT_log = stop(GERT_log);
                    
                end % End element density loop
                
            end % End random vs equidistant loop
            
        end % End open versus closed loop
        
    end % End high versus low density loop
    
end % End stimulus sets loop

%% All done