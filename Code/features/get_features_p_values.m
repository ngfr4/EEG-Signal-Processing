function [features_p_values_struct] = get_features_p_values(resting_state_features_struct, cognitive_task_state_features_struct, p_threshold)
    % Compute the p-value between each feature of given data between the resting and cognitive task state using Wilcoxon based on the small sample size.
    % Initialize the p_values feature struct
    features_p_values_struct = struct();

    % Get subject names
    subject_names = fieldnames(resting_state_features_struct)';
    % Get channel names
    channel_names = fieldnames(resting_state_features_struct.(subject_names{1}))';
    % Get frequency band names
    freq_band_names = fieldnames(resting_state_features_struct.(subject_names{1}).(channel_names{1}))';
    
    % Iterate over each channel
    for channel_name = channel_names
        for freq_band_name = freq_band_names
            resting_state_subjects_feature_values = zeros(length(subject_names), 1);
            cognitive_task_state_subjects_feature_values = zeros(length(subject_names), 1);
            
            % Iterate over each subject
            for subject_idx = 1:length(subject_names)
                subject_name = subject_names(subject_idx);
                % Load the resting state and cognitive task feature values for
                % the specific subject, channel, and frequency band and
                % add to separate lists
                resting_state_subjects_feature_values(subject_idx) = resting_state_features_struct.(subject_name{1}).(channel_name{1}).(freq_band_name{1});
                cognitive_task_state_subjects_feature_values(subject_idx) = cognitive_task_state_features_struct.(subject_name{1}).(channel_name{1}).(freq_band_name{1});
            end

            % Perform Wilcoxon test if not normal distributed
            p = ranksum(resting_state_subjects_feature_values, cognitive_task_state_subjects_feature_values);
            if p < p_threshold
                fprintf('Channel %s (%s) has a p-value %.3f < %.2f\n', channel_name{1}, freq_band_name{1}, p, p_threshold);
            end

            % Storing the p-value in the p_values struct
            features_p_values_struct.(channel_name{1}).(freq_band_name{1}) = p;
        end
    end
end
