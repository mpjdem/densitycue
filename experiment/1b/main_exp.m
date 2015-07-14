clear all;

%% Set parameters
SPATIAL_RESOLUTION = [1024 768];
TEMPORAL_RESOLUTION = 85;
TRIALS_N = 8 * 100;
SESSIONS_N = 1;
TRIALS_PER_SESSION = TRIALS_N/SESSIONS_N;
BLOCKS_N = 8;
TRIALS_PER_BLOCK = TRIALS_N/BLOCKS_N;
STIMSETS_N = 50;
MIN_FIX_ED = 0.5;
MAX_FIX_ED = 1;
MASK_ED = (1/85) * 30;
STIM_ED = (1/85) * 21;
MAX_RT = 1;
COND_CONTDENS = 1;
COND_DISPDENS = 1:2;
COND_CLOSED = 0:1;
COND_EQUID = 0:1;

%% Set up data structure
dat.subj = input('Subject ID: ', 's');
dat.fname = ['dat' dat.subj '.mat'];

if exist(dat.fname,'file')
    disp('Loading file...')
    load(dat.fname,'dat');
else
    disp('Creating new file...')
    dat.res_spatial = SPATIAL_RESOLUTION;
    dat.res_temp_intended = TEMPORAL_RESOLUTION;
    dat.res_temp_measured = {};
    [foo random_order] = sort(rand([1 TRIALS_N]));
    dat.next_trial = 1;
    dat.target = custom_randi(2,[1 TRIALS_N]);
    dat.cond_contdens = repmat(COND_CONTDENS,[1 TRIALS_N/length(COND_CONTDENS)]);
    dat.cond_contdens = dat.cond_contdens(random_order);
    dat.cond_dispdens = sort(repmat(COND_DISPDENS,[1 TRIALS_N/length(COND_DISPDENS)]));
    dat.cond_dispdens = dat.cond_dispdens(random_order);
    dat.cond_closed = repmat(sort(repmat(COND_CLOSED,[1 TRIALS_N/(2*length(COND_CLOSED))])),[1 2]);
    dat.cond_closed = dat.cond_closed(random_order);
    dat.cond_equid = repmat(sort(repmat(COND_EQUID,[1 TRIALS_N/(4*length(COND_EQUID))])),[1 4]);
    dat.cond_equid = dat.cond_equid(random_order);
    dat.stimseq = cell(1,TRIALS_N);
    dat.resp = zeros(1,TRIALS_N);
    dat.eval = -ones(1,TRIALS_N);
    dat.rt = zeros(1,TRIALS_N);
    dat.timings = cell(1,TRIALS_N);
    
    save(dat.fname,'dat');
end

%% Set up screen and breakers
Priority(1);
AssertOpenGL;
PTBscreens=Screen('Screens');
PTBscreenN=2;
SetResolution(PTBscreenN,SPATIAL_RESOLUTION(1),SPATIAL_RESOLUTION(2),TEMPORAL_RESOLUTION);
HideCursor;

PTBwhite=WhiteIndex(PTBscreenN);
PTBblack=BlackIndex(PTBscreenN);
PTBgray=apply_lut(floor((PTBwhite+PTBblack)/2), [0 255]); % floor was round (bm)
[PTBwnd,PTBrect]=Screen('OpenWindow', PTBscreenN, PTBgray);

[PTBcx,PTBcy] = RectCenter(PTBrect);
PTBhz=Screen('NominalFrameRate',PTBscreenN);

Screen('TextSize', PTBwnd, 18);
Screen('TextStyle', PTBwnd, 32);

KbCheck; WaitSecs(0.1); GetSecs;
KbName('UnifyKeyNames');

sound_correct = audioplayer(sin(linspace(0,5000,1000)), 6000);
sound_wrong = audioplayer(sin(linspace(0,200,1000)), 6000);
sound_1 = audioplayer(sin(linspace(0,500,50)), 6000);
sound_2 = audioplayer(sin(linspace(0,500,50)), 5000);

nsamp = 50;
[PTBifi nsucc stdsucc] = Screen('GetFlipInterval', PTBwnd, nsamp, 0.005, 5);
disp(['Theoretical framerate: ' num2str(PTBhz)]);
disp(['Average measured framerate: ' num2str(1/PTBifi) '(' num2str(nsucc) '/' num2str(50) ' samples, SD=' num2str(stdsucc) ')']);
dat.res_temp_measured = [dat.res_temp_measured {[dat.next_trial 1/PTBifi]}];

parport = digitalio('parallel','LPT1');
addline(parport,0:1,'in');

%% Start the experiment
% Instructions / progress
if dat.next_trial>1
    PTBtxt = 'Welcome back to the experiment! \n Press a button to continue.';
    DrawFormattedText(PTBwnd, PTBtxt, 'Center', 'Center', PTBblack, 50, [], [], 1.5);
    Screen('Flip',PTBwnd);
    wait_for_breaker(parport,3);
    
else
    PTBtxt = 'Welcome and thank you in advance for participating! \n\n\n During the experiment you will see in each trial two stimuli one after another. \n Your task is to indicate whether the target appeared in the first or second interval. \n Press left if the target appeared in the first interval and right if the target appeared in the second interval. \n\n Press any key to start.';
    DrawFormattedText(PTBwnd, PTBtxt, 'Center', 'Center', PTBblack, 50, [], [], 1.5);
    Screen('Flip',PTBwnd);
    wait_for_breaker(parport,3);
end

%% Show the stimuli 
present_stims;  

%% Close
ShowCursor;
Screen('CloseAll');
Priority(0);

%% All done