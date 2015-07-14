# Empirical data
The folder data contains an overall data file all.mat for every experiment, in addition to the raw individual files created by the experimental script. In the accompanying CONTENTS.md, a brief explanation of the fields of the data matrix can be found. For more detailed information, have a look at the experimental scripts that generated them in the folder experiment (main_exp and present_stims).

The all.mat file can be opened using MATLAB, or alternatively using scipy.io.loadmat in Python.

# GERT
The GERT version used for the experiments (1.11) can be found in the archives at www.gestaltrevision.be/GERT. The as of now unreleased GERT version used for the simulations is included here as /gert_120ctd, and should also yield identical results for stimulus generation as version 1.11. Please refer to the GERT manual for further instructions on how to use the toolbox.

# Stimuli
To facilitate the distribution of this file, the full stimulus images and the full log of stimulus creation were not included. However, we have included stripped-down mat-files containing the most important stimulus information in the experiment directory. The render_stimulus() script in the /common subdirectory takes such a mat-file, and re-renders the stimulus using GERT.

# Simulations
The simulation results of the manuscript are included, in the /simulation directory. However, the simulate_all.m scripts in the subdirectories of the experiments can be used to run the simulations yourself, or run additional simulations using different metrics or different metric parameters. This will necessitate the unpacking of the reduced stimulus zip-files into a subdirectory /stims of experiment/1a and experiment/1b. Note that the Voronoi_AvgDist1 results were generated separately, after simulating both metrics individually. The script simulate_all_voronoi_avgdist1.m can be used to repeat this procedure. 

# Analysis
The detailed results of the analyses are also included in this file, in the analysis/1x/res subdirectories. They were generated using the ana_all.m script, which can be re-run. This generates the .mat files which contain the data that is processed into plots by the Python script ana_plots.py, using Matplotlib. At the bottom of this script, additional plots can be easily generated, for instance the full psychometric curve fits for AvgDist-3.
