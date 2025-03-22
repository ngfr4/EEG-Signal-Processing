function [resting_state_signal_struct, cognitive_task_state_signal_struct] = load_EEG_data(data_folder_path, sampling_rate, preprocessing_flag)
    % Initialize empty structs for the signals of each subject (resting state +
    % cognitive task)
    resting_state_signal_struct = struct();
    cognitive_task_state_signal_struct = struct();

    % Get a list of all files in the specified folder
    file_list = dir([data_folder_path, 'Subject*.mat']);

    if preprocessing_flag
        % For preprocessing the last two seconds (that not part of the actual EEG)
        num_samples_two_seconds = 2*sampling_rate;
    end

    % Loop through each file
    for idx = 1:length(file_list)   
        file_name = file_list(idx).name;

        % Get the subject name (use as struct variable)
        % Find the position of the first underscore in the string
        underscoreIndex = strfind(file_name, '_');
        % Extract subject name from file name
        subject_name = file_name(1:underscoreIndex(1) - 1);

        % Load the data from the file
        eeg_data_struct = load([data_folder_path, file_name]);

        % -------------- Preprocessing --------------
        if preprocessing_flag
            for channel_name = fieldnames(eeg_data_struct)'
                % Get the EEG signal for the current subject and channel
                channel_eeg_signal = eeg_data_struct.(channel_name{1});
                % Remove last two seconds
                modified_channel_eeg_signal = channel_eeg_signal(1:end-num_samples_two_seconds);
                % Detrend the signal
                modified_channel_eeg_signal = detrend(modified_channel_eeg_signal);
                % Save preprocessed struct
                eeg_data_struct.(channel_name{1}) = modified_channel_eeg_signal;
            end
        end

        % Check if the file ends with '1.mat'
        if endsWith(file_name, '1.mat')
            % Add the signal to the resting state signal struct
            resting_state_signal_struct.(subject_name) = eeg_data_struct;
        elseif endsWith(file_name, '2.mat')
            % Add the signal to the cognitive task signal struct
            cognitive_task_state_signal_struct.(subject_name) = eeg_data_struct;
        end
    end

    % Display the subjects saved in the resting state and cognitive tasks
    % structs
    disp('Having following recordings of subjects for the resting state:');
    disp(fieldnames(resting_state_signal_struct));

    disp('Having following recordings of subjects for the cognitive task:');
    disp(fieldnames(cognitive_task_state_signal_struct));
end