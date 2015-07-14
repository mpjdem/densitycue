# Contents
    /stims                       The stimuli used in the experiment (minimal version)
    /generate_stimuli.m          Stimulus generation script
    /vm_phase_scrambling.m       von Mises phase scrambling script for images
    /make_lut_sa.m               Gamma correction measurement script
    /lut.mat                     Data file containing the power coefficient for gamma correction
    /apply_lut.m                 On-the-fly gamma correction script for images
    /practice.m                  Experimental script for the practice session
    /main_exp.m                  Experimental script for the main experiment
    /present_stims.m             Sub-script for the trial events
    /wait_for_breaker.m          Sub-script to wait for a breaker press 
    /custom_randi.m              Custom random integer generator script

# Comments
Stimuli were generated with the `generate_stimuli.m` script, then saved to disc, and loaded as needed by the experimental script.
Included here in the /stims directory are not those mat-files, but a minimal version of them which can be used for simulation and analysis. Use the /common/render_stimulus.m script to render them for illustration purposes.
