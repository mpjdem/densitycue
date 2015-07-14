# Contents  
    /*.mat       MATLAB files, contains minimal stimulus definition
    /stims.zip   Compressed file of the .mat files, uncompress this

# Comments
These are not our original MATLAB files, but are reduced in filesize.
The original files contained the full log of the stimulus construction.
However, the MATLAB files in this archive allow the user to:
(1) Visualize the stimulus, by calling render_stimulus(matfile);
(2) Run the simulations in \simulation\1a\simulate_all.m

As a consequence of the reduced filesize, the simulations will be slower,
because some calculations need to be re-done during the simulations.

Filenames in zip archives consist of the following parts

    d t          		Distractor or target  
    hi lo        		High or low overall density  
    op cl        		Open or closed contour  
    eq ran       		Equidistant or random contour placement  
    1-8          		Contour density level  
    1-50			Number of stimulus set  

Contents of the MATLAB file

    stim.x		  	Vector of elements' x-coordinates
    stim.y		  	Vector of elements' y-coordinates
    stim.ctag	  	Index to last contour element (1:ctag = contour elements; ctag:end = background elements)
    stim.min_dist	  	Minimum distance between background elements
    stim.RFP_params     Structure with parameter values to generate the Radial Frequency Pattern contour.
