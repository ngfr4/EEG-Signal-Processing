close all; % Close all open figures
clc;       % Clear the MATLAB command window
clear;     % Clear the MATLAB workspace

% Add subfolders to path
abs_repo_folder_path = fileparts(fileparts(mfilename('fullpath')));
code_folder_path = [abs_repo_folder_path, '/Code/'];
% Get a list of the subfolders
subfiles_struct = dir(code_folder_path);
% Loop through the subfolders and add them to the path
for file_idx = 1:length(subfiles_struct)
    subfile_name = subfiles_struct(file_idx).name;
    sub_file_path = fullfile(code_folder_path, subfile_name);
    if isfolder(sub_file_path)
        addpath(sub_file_path);
    end
end

% Set the default behavior for saving figures without displaying them
set(0, 'DefaultFigureVisible', 'off');

%% Define constants

% Define sampling frequency
sampling_rate = 500; % in Hz

% Define frequency ranges (in Hz) for the bands as a struct
freq_ranges = struct('theta1', [4.1, 5.8], ...
                    'theta2', [5.9, 7.4], ...
                    'alpha', [7.5, 12.9], ...
                    'beta1', [13, 19.9], ...
                    'beta2', [20, 25]);

%% Load the data
% Define the data folder for the training data
data_folder_path = [abs_repo_folder_path, '/Data/'];

% Load and preprocess the data -> save into the resting state and cognitive task signal struct
preprocessing_flag = true;
[resting_state_signal_struct, cognitive_task_state_signal_struct] = load_EEG_data(data_folder_path, sampling_rate, preprocessing_flag);

preprocessing_flag = false;
% Load the original data (for comparison)
[resting_state_signal_struct_orig, cognitive_task_state_signal_struct_orig] = load_EEG_data(data_folder_path, sampling_rate, preprocessing_flag);

%% Signal analysis (compare original to preprocessed signal)

% Define the figures folder for saving all plots
figures_folder_path = [abs_repo_folder_path, '/Figures/'];

subject = "Subject01";
channel = "FP1"; % Channel common for eye-artifacts (to analyze if we need further artifact removal)

% Compare the original signal to the preprocessed signal (main purpose:
% check for things that should be preprocessed from the original signal)
plot_preprocessing_comparison(subject, channel, sampling_rate, resting_state_signal_struct_orig, cognitive_task_state_signal_struct_orig, resting_state_signal_struct, cognitive_task_state_signal_struct, figures_folder_path);


% Analyze time-frequency behaviour by CSA plots
db_scale_flag = false;
plot_CSA(resting_state_signal_struct, cognitive_task_state_signal_struct, sampling_rate, freq_ranges, db_scale_flag, figures_folder_path);


%% Feature extraction

% Get for each EEG method (PSD, coherence), each subband, each
% subject and each channel signal (combination) one feature

% Compute the mean psd as feature
resting_state_psd_features_struct = get_mean_psd_features(resting_state_signal_struct, sampling_rate, freq_ranges);
cognitive_task_state_psd_features_struct = get_mean_psd_features(cognitive_task_state_signal_struct, sampling_rate, freq_ranges);

% Compute coherence as feature
resting_state_coherence_features_struct = get_coherence_features(resting_state_signal_struct, sampling_rate, freq_ranges);
cognitive_task_state_coherence_features_struct = get_coherence_features(cognitive_task_state_signal_struct, sampling_rate, freq_ranges);

%% Evaluating features -> Comparing both conditions

% Plot the mean PSD averaged over all subjects
plot_mean_psd(resting_state_psd_features_struct, cognitive_task_state_psd_features_struct, freq_ranges, figures_folder_path);

% Coherence plots
channels = fieldnames(resting_state_psd_features_struct.(subject))';
num_channels = length(channels);
channel_mapping = struct();
% Populate the channel mapping struct
for channel_idx = 1:num_channels
    channel_name = channels{channel_idx};
    channel_mapping.(channel_name) = channel_idx;
end
plot_coherence(resting_state_coherence_features_struct, cognitive_task_state_coherence_features_struct, channel_mapping, freq_ranges, figures_folder_path);

%% Feature selection (p < 0.05) [Additional - just for us]

% Compute for each feature (both the psd and coherence features) the p-value between the two periods (resting state +
% cognitive tasks state)
% Print all features with p-value < 0.05
p_threshold = 0.05;
disp('Analyzing p-values for PSD features:');
psd_features_p_values_struct = get_features_p_values(resting_state_psd_features_struct, cognitive_task_state_psd_features_struct, p_threshold);
disp([newline, 'Analyzing p-values for Coherence features:']);
coherence_features_p_values_struct = get_features_p_values(resting_state_coherence_features_struct, cognitive_task_state_coherence_features_struct, p_threshold);

%% Reset default plotting

% Set the default behavior for displaying figures
set(0, 'DefaultFigureVisible', 'on');