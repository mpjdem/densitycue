# Contents
    /all.mat            Combined file of the individual subject data
    /dat*.mat           Original MATLAB data files of main experiment
    /dat_practice*.mat  Data of the practice trials

# Comments
Structure of the `dat` variable:  

    subj                Subject number
    fname               Own filename during the experiment 
    res_spatial         Spatial resolution of monitor 
    res_temp_int...     Intended refresh rate of monitor 
    res_temp_mea...     Refresh rates measured 
    next_trial          Next trial number to begin 
    target              Interval of target (1 or 2)
    cond_contdens       Level of contour density (1-8) 
    cond_dispdens       Display density (1 or 2)
    cond_closed         Contour open (0) or closed (1) 
    cond_equid          Contour random (0) or equidistant (1) 
    stimseq             Stimulus set numbers used in all 5 intervals 
    resp                Response - invalid/incomplete (0), left (1) or right (2) 
    eval                Evaluation of response - wrong(0), right (1), or invalid/incomplete(-1) 
    rt                  Reaction time in seconds, or 0 if invalid/incomplete 
    timings             Timing deviations per interval per trial 

No practice files were collected for authors BM (subject 20) and MD (subject 21), since they were already sufficiently trained.
