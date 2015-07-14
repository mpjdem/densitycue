%% Main experimental loop
just_restarted = true;
while true
    
    WaitSecs(0.2); % was: 0.5 (bm)
    
    tr = dat.next_trial;
    disp(['Trial ' num2str(tr)]);
    
    % If the last trial has been reached
    if tr > TRIALS_N
        PTBtxt = 'Experiment done. Press a button to exit.';
        DrawFormattedText(PTBwnd, PTBtxt, 'Center', 'Center', PTBblack, 50, [], [], 1.5);
        Screen('Flip',PTBwnd);
        wait_for_breaker(parport,3);
        break;
    end
    
    % If the end of the session has been reached
    if ~mod(tr-1,TRIALS_PER_SESSION) && tr>1 && ~just_restarted
        PTBtxt = 'End of session. Press a button to exit.';
        DrawFormattedText(PTBwnd, PTBtxt, 'Center', 'Center', PTBblack, 50, [], [], 1.5);
        Screen('Flip',PTBwnd);
        wait_for_breaker(parport,3);
        break;
    end
    
    % If new block
    if ~mod(tr-1,TRIALS_PER_BLOCK)
        ShowCursor;
        PTBtxt = ['Starting block ' num2str(1+(tr-1)/TRIALS_PER_BLOCK) '. Press a button to continue.'];
        DrawFormattedText(PTBwnd, PTBtxt, 'Center', 'Center', PTBblack, 50, [], [], 1.5);
        Screen('Flip',PTBwnd);
        wait_for_breaker(parport,3);
        HideCursor;
    end
    
    % Load the stimulus images
    if dat.cond_dispdens(tr) == 1
        hilo = 'lo';
    else
        hilo ='hi';
    end
    
    distr_n = custom_randi(STIMSETS_N,[1 1]);
    
    load (['stims\d_' hilo '_' num2str(distr_n) '.mat']);
    distractor_img = IMG;
    
    mask_n = custom_randi(STIMSETS_N,[1 3]);
    load (['stims\m_' hilo '_' num2str(mask_n(1)) '.mat']);
    mask1_img = IMG;
    load (['stims\m_' hilo '_' num2str(mask_n(2)) '.mat']);
    mask2_img = IMG;
    load (['stims\m_' hilo '_' num2str(mask_n(3)) '.mat']);
    mask3_img = IMG;
    
    if dat.cond_closed(tr) == 0
        oc = 'op';
    else
        oc = 'cl';
    end
    
    if dat.cond_equid(tr) == 0
        eq = 'ran';
    else
        eq = 'eq';
    end
    
    target_n = custom_randi(STIMSETS_N,[1 1]);
    load (['stims\t_' hilo '_' oc '_' eq '_' num2str(dat.cond_contdens(tr)) '_' num2str(target_n) '.mat']);
    target_img = IMG;
    clear IMG slog;
    
    % Preload stimuli
    if dat.target(tr) == 1
        S1 = Screen('MakeTexture', PTBwnd, apply_lut(target_img)*255);
        Screen('PreloadTextures', PTBwnd, S1);
        S2 = Screen('MakeTexture', PTBwnd, apply_lut(distractor_img)*255);
        Screen('PreloadTextures', PTBwnd, S2);
        dat.stimseq{tr} = [mask_n(1) target_n mask_n(2) distr_n mask_n(3)];
    else
        S2 = Screen('MakeTexture', PTBwnd, apply_lut(target_img)*255);
        Screen('PreloadTextures', PTBwnd, S2);
        S1 = Screen('MakeTexture', PTBwnd, apply_lut(distractor_img)*255);
        Screen('PreloadTextures', PTBwnd, S1);
        dat.stimseq{tr} = [mask_n(1) distr_n mask_n(2) target_n mask_n(3)];
    end
    
    M1 = Screen('MakeTexture', PTBwnd, apply_lut(mask1_img)*255);
    Screen('PreloadTextures', PTBwnd, M1);
    M2 = Screen('MakeTexture', PTBwnd, apply_lut(mask2_img)*255);
    Screen('PreloadTextures', PTBwnd, M2);
    M3 = Screen('MakeTexture', PTBwnd, apply_lut(mask3_img)*255);
    Screen('PreloadTextures', PTBwnd, M3);
    
    fix_ed = MIN_FIX_ED + rand*(MAX_FIX_ED-MIN_FIX_ED);
    
    % Draw fixation dot
    Screen('FillOval', PTBwnd, PTBwhite, [PTBcx-2; PTBcy-2; PTBcx+2; PTBcy+2]);
    Screen('Flip', PTBwnd);
    Screen('FillOval', PTBwnd, PTBwhite, [PTBcx-2; PTBcy-2; PTBcx+2; PTBcy+2]);
    
    % Cycle through the images
    [start_time1 stim_time1 flip_end1]=Screen('Flip', PTBwnd);                       % Fixation
    Screen('DrawTexture', PTBwnd, M1);
    [start_time2 stim_time2 flip_end2]=Screen('Flip',PTBwnd,start_time1+fix_ed);     % Mask 1
    Screen('DrawTexture', PTBwnd, S1);
    [start_time3 stim_time3 flip_end3]=Screen('Flip',PTBwnd,start_time2+MASK_ED);    % Stim 1
    Screen('DrawTexture', PTBwnd, M2);
    play(sound_1);
    [start_time4 stim_time4 flip_end4]=Screen('Flip',PTBwnd,start_time3+STIM_ED);    % Mask 2
    Screen('DrawTexture', PTBwnd, S2);
    [start_time5 stim_time5 flip_end5]=Screen('Flip',PTBwnd,start_time4+MASK_ED);    % Stim 2
    Screen('DrawTexture', PTBwnd, M3);
    play(sound_2);
    [start_time6 stim_time6 flip_end6]=Screen('Flip',PTBwnd,start_time5+STIM_ED);    % Mask 3
    [start_time7 stim_time7 flip_end7]=Screen('Flip',PTBwnd,start_time6+MASK_ED);    % Blank
    
    timing_estimates = ...
        [(stim_time2-stim_time1-fix_ed);
        (stim_time3-stim_time2-MASK_ED);
        (stim_time4-stim_time3-STIM_ED);
        (stim_time5-stim_time4-MASK_ED);
        (stim_time6-stim_time5-STIM_ED);
        (stim_time7-stim_time6-MASK_ED)];
    
    dat.timings(tr) = {timing_estimates};
    
    % Wait for response
    [resp, sec] = wait_for_breaker(parport,2,MAX_RT);
    
    % Evaluate response
    dat.eval(tr) = 0;
    if ~any(resp)
        ShowCursor;
        PTBtxt = 'Respond faster! Press a button to continue';
        disp(PTBtxt);
        DrawFormattedText(PTBwnd, PTBtxt, 'Center', 'Center', PTBblack, 50, [], [], 1.5);
        play(sound_wrong);
        Screen('Flip',PTBwnd);
        wait_for_breaker(parport,3);
        HideCursor;
        
    elseif sum(resp) > 1
        PTBtxt = 'Multiple keys pressed';
        disp(PTBtxt);
        %DrawFormattedText(PTBwnd, PTBtxt, 'Center', 'Center', PTBblack, 50, [], [], 1.5);
        play(sound_wrong);
        Screen('Flip',PTBwnd);
    elseif (resp(1) == 1 && dat.target(tr) == 1) || (resp(2) == 1 && dat.target(tr) == 2)
        PTBtxt = 'Correct!';
        disp(PTBtxt);
        %DrawFormattedText(PTBwnd, PTBtxt, 'Center', 'Center', PTBblack, 50, [], [], 1.5);
        play(sound_correct);
        Screen('Flip',PTBwnd);
        dat.eval(tr) = 1;
        dat.resp(tr) = find(resp);
        dat.rt(tr) = sec;
    elseif (resp(1) == 1 && dat.target(tr) == 2) || (resp(2) == 1 && dat.target(tr) == 1)
        PTBtxt = 'Wrong!';
        disp(PTBtxt);
        %DrawFormattedText(PTBwnd, PTBtxt, 'Center', 'Center', PTBblack, 50, [], [], 1.5);
        play(sound_wrong);
        Screen('Flip',PTBwnd);
        dat.resp(tr) = find(resp);
        dat.rt(tr) = sec;
    else
        PTBtxt = 'Invalid response!';
        disp(PTBtxt);
        %DrawFormattedText(PTBwnd, PTBtxt, 'Center', 'Center', PTBblack, 50, [], [], 1.5);
        play(sound_wrong);
        Screen('Flip',PTBwnd);
    end
    
    % On to the next trial...
    dat.next_trial = dat.next_trial+1;
    
    save(dat.fname,'dat');
    
    just_restarted = false;
    
end