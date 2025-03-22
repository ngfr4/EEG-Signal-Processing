function [psd_features_struct] = get_mean_psd_features(eeg_signals_struct, sampling_rate, freq_ranges)
    % Compute for each subject and channel of eeg_signals_struct the mean psd value and return as features.
    
    % Init the psd feature struct
    psd_features_struct = struct();

    % Define window length and overlap for PSD computation
    window_length = 2 * sampling_rate; 
    overlap_length = window_length * 0.5; 

    % Iterate over each subject
    for subject_name = fieldnames(eeg_signals_struct)'
        % Iterate over each channel
        for channel_name = fieldnames(eeg_signals_struct.(subject_name{1}))'
            % Get the EEG signal for the current subject and channel
            channel_eeg_signal = eeg_signals_struct.(subject_name{1}).(channel_name{1});
        
            % Calculate the PSD with pwelch
            [psd, freq] = pwelch(channel_eeg_signal, hann(window_length), overlap_length, [], sampling_rate); 
        
            % Compute the mean psd for each frequency band
            for freq_band_name = fieldnames(freq_ranges)'
                freq_range = freq_ranges.(freq_band_name{1});
                % Find the frequency indices 
                freq_indices = freq >= freq_range(1) & freq <= freq_range(2);
                mean_psd = mean(psd(freq_indices));
                psd_features_struct.(subject_name{1}).(channel_name{1}).(freq_band_name{1}) = mean_psd;
            end
        end
    end      
end

