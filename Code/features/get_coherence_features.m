function [coherence_features_struct] = get_coherence_features(eeg_signals_struct, sampling_rate, freq_ranges)
    % Compute for each subject and channel combination of eeg_signals_struct the coherence value and return as features.

    % Add flag to load channels names only once
    channel_names_loaded_flag = false;

    % Define window length and overlap for PSD computation
    window_length = 10 * sampling_rate; % very slow when choosing 2s windows
    overlap_length = window_length * 0.5; 

    % Iterate over each subject
    for subject_name = fieldnames(eeg_signals_struct)'
        
        % Store channel names
        if ~channel_names_loaded_flag
            channels = fieldnames(eeg_signals_struct.(subject_name{1}))';
            channel_names_loaded_flag = true;
        end

        % Compute coherence between each pair of channels for each frequency band
        for channel_idx_1 = 1:length(channels)
            channel_name_1 = channels(channel_idx_1);
            channel_1_eeg_signal = eeg_signals_struct.(subject_name{1}).(channel_name_1{1});
            for channel_idx_2 = (channel_idx_1+1):length(channels) % To avoid redundancy and self-coherence
                channel_name_2 = channels(channel_idx_2);
                channel_2_eeg_signal = eeg_signals_struct.(subject_name{1}).(channel_name_2{1});
    
                % Compute coherence estimates for each frequency between the eeg signals of the pair of channels
                % TODO: Add other again
                [Cxy, freq] = mscohere(channel_1_eeg_signal, channel_2_eeg_signal, hann(window_length), overlap_length, [], sampling_rate);
                
                for freq_band_name = fieldnames(freq_ranges)'
                    freq_range = freq_ranges.(freq_band_name{1});
                    % Find the frequency indices 
                    freq_indices = freq >= freq_range(1) & freq <= freq_range(2);
                    coherence_value = mean(Cxy(freq_indices));
                    channel_comb_name = strcat(channel_name_1{1}, "_", channel_name_2{1});
                    coherence_features_struct.(subject_name{1}).(channel_comb_name).(freq_band_name{1}) = coherence_value;
                end
            end
        end
    end
end
