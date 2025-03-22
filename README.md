# EEG Signal Processing for Feature Extraction in Mental Arithmetic Tasks

## Abstract
This project investigates electroencephalogram (EEG) recordings from six healthy subjects, collected before and during mental arithmetic tasks. The goal is to process the signals and extract features that reflect physiological mechanisms distinguishing the resting and task-performing states. Specifically, the analysis focuses on differences within the θ1, θ2, α, β1, and β2 frequency bands using Power Spectral Density (PSD) to observe signal power distribution across frequencies, and Coherence to assess connectivity between brain regions. Further details on data acquisition can be found in the provided paper (EEGDuringMentalTaskPerformance).

## Requirements
For this project we used directly the EEGLab toolbox. Additionally, the Signal Processing Toolbox.

By executing the BSP_Team13Topic03_Code.m all written code will be executed. The code is divided in multiple subfolders, having one subfolder for the dataloader, one for the features (PSD, Coherence), and one for the subplots. The execution of the code can take a couple of minutes (maybe even >10min), since it computes and plots the features for all combinations of subjects, channels and frequency bands.

## Main File Structure
The first part in the main file is for loading the data. Afterwards there is a small analysis (time-frequency CSA plots) to compare the preprocessed and non-preprocessed data. There we saw which additional preprocessing steps were still necessary. Next, the features are calculated and later on plotted. For each feature we also computed the p-value to rank there significance. The preprocessing comparison plots as well as the feature plots are all saved in the Figure folder. Both for the subjects individually as well as averaged across the subjects to obtain the groupwise analysis performance.
