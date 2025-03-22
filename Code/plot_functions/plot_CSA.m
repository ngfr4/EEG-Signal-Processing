function [] = plot_CSA(resting_state_signal_struct, cognitive_task_state_signal_struct, sampling_rate, freq_ranges, db_scale_flag, figures_folder_path)
    % Compute the compressed spectral array to compare the signals in the
    % time-frequency domain (based on Lab4 code).

    % Choose f_max as the maximum frequency of our chosen frequency bands
    f_max = -inf; 
    for freq_band = fieldnames(freq_ranges)'
        upper_frequency = freq_ranges.(freq_band{1})(2);
        if upper_frequency > f_max
            f_max = upper_frequency;
        end
    end

    % Create preprocessing comparison folder if it does not exist yet (for
    % saving the plots later)
    time_preprocessing_comparison_folder = fullfile(figures_folder_path, 'Time_Frequency_Comparison');
    if ~exist(time_preprocessing_comparison_folder, 'dir')
        mkdir(time_preprocessing_comparison_folder);
    end

    % Get subject names
    subjects = fieldnames(resting_state_signal_struct)';
    num_subjects = length(subjects);
    % Get channel names
    channels = fieldnames(resting_state_signal_struct.(subjects{1}))';
    num_channels = length(channels);

    % Iterate over each subject
    for subject_idx = 1:num_subjects    
        subject_name = subjects{subject_idx};
        % Iterate over each channel
        for channel_idx = 1:num_channels
            channel_name = channels{channel_idx};

            % Concatenate both resting state and cognitive task
            resting_state_signal = resting_state_signal_struct.(subject_name).(channel_name);
            cognitive_task_signal = cognitive_task_state_signal_struct.(subject_name).(channel_name);
            full_eeg_signal = vertcat(resting_state_signal, cognitive_task_signal);
            t = (0:1/sampling_rate:length(full_eeg_signal)/sampling_rate - 1/sampling_rate);
        
            window_length = sampling_rate*1; % one second time window
            shift = window_length*0.5; % 50% overlap
            order = 15; % model order
            nfft = 2048; % num samples/frequencies for psd
            
            N = length(full_eeg_signal);
            
            i = 1;  %starting index
            counter = 1;
            
            while i+window_length < N %cycle up to the end of the signal
                
                %select the EEG segment
                eeg_segment = detrend(full_eeg_signal(i:i+window_length));
            
                %estimate the PSD
                [psd, f] = pyulear(eeg_segment, order, nfft, sampling_rate);
                
            
                %select only up to f_max
                psd = psd(f<f_max);
            
                CSA(counter,:) = psd; %each row of CSA is a PSD
            
                %define the time (pick the center of the window)
                time(counter) = t(i+window_length/2)/60; %in minutes
            
                %move the index for the next iteration
                i = i + shift;
            
                counter = counter+1;
            end
        
            %plot as a CSA
            freq = f(f<f_max);
            [Time,Frequency] = meshgrid(time,freq);
            
            figure
            waterfall(Time',Frequency',CSA);
            if db_scale_flag
                set(gca, 'ZScale', 'log');
            end
            
            
            xlabel('Time [m]');
            ylabel('Frequency [Hz]');
            zlabel('Power/Frequency (dB/Hz)');
            ylim([0 f_max]);
            xticks(1:N/sampling_rate);
            xticklabels(1:N/sampling_rate);
            title(['Time-Frequency Representation - ', channel_name]);
           
            % Save the figure
            subject_time_preprocessing_comparison_folder = fullfile(time_preprocessing_comparison_folder, subject_name);
            % Create preprocessing comparison folder if it does not exist yet
            if ~exist(subject_time_preprocessing_comparison_folder, 'dir')
                mkdir(subject_time_preprocessing_comparison_folder);
            end
            time_preprocessing_comparison_file_path = fullfile(subject_time_preprocessing_comparison_folder, ['time_frequency_comparison_', channel_name, '.png']);
            saveas(gcf, time_preprocessing_comparison_file_path);
            close;

            % Add the CSA together (for each subject)
            if subject_idx == 1
                average_CSA(channel_idx, :, :) = CSA;
            else
                average_CSA(channel_idx, :, :) = squeeze(average_CSA(channel_idx, :, :)) + CSA;
            end

        end
    end

    % Plot the average CSA plots
    for channel_idx = 1:num_channels
        channel_name = channels{channel_idx};

        % Calculate the average CSA by dividing by the number of subjects
        channel_average_CSA = squeeze(average_CSA(channel_idx, :, :) / num_subjects);
        
        % Plot the average CSA
        figure
        waterfall(Time', Frequency', channel_average_CSA);
        if db_scale_flag
            set(gca, 'ZScale', 'log');
        end
        
        xlabel('Time [s]');
        ylabel('Frequency [Hz]');
        zlabel('Average Power/Frequency (dB/Hz)');
        ylim([0 f_max]);
        xticks(1:N/sampling_rate);
        xticklabels(1:N/sampling_rate);
        title(['Mean Time-Frequency Representation - ', channel_name]);
        
        % Save the average CSA figure
        average_time_preprocessing_comparison_folder = fullfile(time_preprocessing_comparison_folder, 'Average');
        if ~exist(average_time_preprocessing_comparison_folder, 'dir')
            mkdir(average_time_preprocessing_comparison_folder);
        end
        average_time_preprocessing_comparison_file_path = fullfile(average_time_preprocessing_comparison_folder, ['average_time_frequency_comparison_', channel_name, '.png']);
        saveas(gcf, average_time_preprocessing_comparison_file_path);
        close;
    end
end