function [] = plot_preprocessing_comparison(subject, channel, sampling_rate, resting_state_signal_struct_orig, cognitive_task_state_signal_struct_orig, resting_state_signal_struct, cognitive_task_state_signal_struct, figures_folder_path)
    % Plot a comparison between the original and preprocessed signal in the
    % time and also in the frequency domain. Should give us an idea which
    % preprocessing steps still needs to be added. In the end it was mainly
    % removing the empty EEG signal (last 2s) of each recording and also
    % added detrending, even if baseline wandering was not to significant.

    % Time domain comparison plot
    figure
    set(gcf, 'Units', 'inches', 'Position', [0, 0, 10, 20]);
    subplot(2, 1, 1);
    
    % Concatenate both signals
    resting_state_signal_orig = resting_state_signal_struct_orig.(subject).(channel);
    cognitive_task_signal_orig = cognitive_task_state_signal_struct_orig.(subject).(channel);
    full_eeg_signal_orig = vertcat(resting_state_signal_orig, cognitive_task_signal_orig);
    t_orig = (0:1/sampling_rate:length(full_eeg_signal_orig)/sampling_rate - 1/sampling_rate);
    
    % Plot the original (only bandpass + notch filter) EEG signal
    plot(t_orig, full_eeg_signal_orig);
    xline(length(resting_state_signal_orig)/sampling_rate, 'LineWidth', 1.2);
    title('Original EEG Signal');
    xlabel('Time (s)');
    ylabel('Amplitude (\muV)');
    
    
    subplot(2, 1, 2);
    
    % Concatenate both signals
    resting_state_signal = resting_state_signal_struct.(subject).(channel);
    cognitive_task_signal = cognitive_task_state_signal_struct.(subject).(channel);
    full_eeg_signal = vertcat(resting_state_signal, cognitive_task_signal);
    t = (0:1/sampling_rate:length(full_eeg_signal)/sampling_rate - 1/sampling_rate);
    
    % Plot the preprocessed (remove last 2s + detrending + artifact removal) EEG signal
    plot(t, full_eeg_signal);
    xline(length(resting_state_signal)/sampling_rate, 'LineWidth', 1.2);
    title('Preprocessed EEG Signal');
    xlabel('Time (s)'); 
    ylabel('Amplitude (\muV)');
    
    % Define the figure title
    sgtitle('Comparison between Original and Preprocessed EEG Signal (Time Domain)');
    
    % Save the figure
    preprocessing_comparison_folder = fullfile(figures_folder_path, 'Preprocessing_Comparison');
    % Create preprocessing comparison folder if it does not exist yet
    if ~exist(preprocessing_comparison_folder, 'dir')
        mkdir(preprocessing_comparison_folder);
    end
    time_preprocessing_comparison_file_path = fullfile(preprocessing_comparison_folder, 'time_preprocessing_comparison.png');
    saveas(gcf, time_preprocessing_comparison_file_path);
    close;

    % ---------
    
    % Frequency domain comparison plot
    figure
    set(gcf, 'Units', 'inches', 'Position', [0, 0, 10, 20]);
    subplot(2, 2, 1);
    
    % Compute PSD of original signal
    window_length = 2 * sampling_rate; 
    overlap_length = window_length * 0.5; 
    [psd_resting_state_signal_orig, f_orig] = pwelch(resting_state_signal_orig, window_length, overlap_length, [], sampling_rate);
    
    % Plot the original (only bandpass + notch filter) EEG signal
    plot(f_orig, psd_resting_state_signal_orig);
    xlim([0, 25]); % since we only focus on frequency spectrum till 25 Hz
    title('PSD Resting State Original EEG Signal');
    xlabel('Frequency (Hz)')
    ylabel('Power/Frequency (\muV^2/Hz)')
    
    
    subplot(2, 2, 2);
    
    % Compute PSD of original signal
    [psd_resting_state_signal, f_orig] = pwelch(resting_state_signal, window_length, overlap_length, [], sampling_rate);
    
    % Plot the original (only bandpass + notch filter) EEG signal
    plot(f_orig, psd_resting_state_signal);
    xlim([0, 25]); % since we only focus on frequency spectrum till 25 Hz
    title('PSD Resting State Preprocessed EEG Signal');
    xlabel('Frequency (Hz)')
    ylabel('Power/Frequency (\muV^2/Hz)')
    
    
    subplot(2, 2, 3);
    
    % Compute PSD of original signal
    [psd_cognitive_task_signal_orig, f_orig] = pwelch(cognitive_task_signal_orig, window_length, overlap_length, [], sampling_rate);
    
    % Plot the original (only bandpass + notch filter) EEG signal
    plot(f_orig, psd_cognitive_task_signal_orig);
    xlim([0, 25]); % since we only focus on frequency spectrum till 25 Hz
    title('PSD Cognitive Task Original EEG Signal');
    xlabel('Frequency (Hz)')
    ylabel('Power/Frequency (\muV^2/Hz)')
    
    
    subplot(2, 2, 4);
    
    % Compute PSD of original signal
    [psd_cognitive_task_signal, f_orig] = pwelch(cognitive_task_signal, window_length, overlap_length, [], sampling_rate);
    
    % Plot the original (only bandpass + notch filter) EEG signal
    plot(f_orig, psd_cognitive_task_signal);
    xlim([0, 25]); % since we only focus on frequency spectrum till 25 Hz
    title('PSD Cognitive Task Preprocessed EEG Signal');
    xlabel('Frequency (Hz)')
    ylabel('Power/Frequency (\muV^2/Hz)')
    
    % Define the figure title
    sgtitle('Comparison between Original and Preprocessed EEG Signal (Frequency Domain)');

    % Save the figure
    frequency_preprocessing_comparison_file_path = fullfile(preprocessing_comparison_folder, 'frequency_preprocessing_comparison.png');
    saveas(gcf, frequency_preprocessing_comparison_file_path);
    close;