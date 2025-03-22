function [] = plot_coherence(resting_state_coherence_features_struct, cognitive_task_state_coherence_features_struct, channel_mapping, freq_ranges, figures_folder_path)
    % Plot the mean psd values. Currently the values are averaged over the
    % subjects. Plot both as bar charts and as topoplots.
    
    % Get subject names
    subjects = fieldnames(resting_state_coherence_features_struct)';
    num_subjects = length(subjects);
    % Get channel names and channel combinations
    channel_combinations = fieldnames(resting_state_coherence_features_struct.(subjects{1}))';
    num_channel_combinations = length(channel_combinations);
    channels = fieldnames(channel_mapping)';
    num_channels = length(channels);
    % Get frequency band names
    freq_bands = fieldnames(resting_state_coherence_features_struct.(subjects{1}).(channel_combinations{1}))';
    num_freq_bands = length(freq_bands);

    % Initialize an empty cell array for bands
    bands = cell(1, numel(fieldnames(freq_ranges)));
    
    % Extract band information and populate the cell array
    band_names = fieldnames(freq_ranges);
    for i = 1:numel(band_names)
        range = freq_ranges.(band_names{i});
        band_name = band_names{i};
        band_name(1) = upper(band_name(1)); 
        bands{i} = sprintf('%s (%g-%g Hz)', band_name, range(1), range(2));
    end

    % Initialize the coherence result matrices
    coherence_results_rest = zeros(num_subjects, num_channels, num_channels, num_freq_bands);
    coherence_results_calculation = zeros(num_subjects, num_channels, num_channels, num_freq_bands);

    % Iterate over each frequency band
    for freq_band_idx = 1:num_freq_bands
        freq_band_name = freq_bands{freq_band_idx};
        % Iterate over each subject
        for subject_idx = 1:num_subjects    
            subject_name = subjects{subject_idx};
            % Iterate over each channel
            for channel_comb_idx = 1:num_channel_combinations
                channel_comb_name = channel_combinations{channel_comb_idx};
                % Extract the single channel indices from the channel
                % combination (for indexing the coherence matrix)
                channel_names = strsplit(channel_comb_name, '_');
                channel_name_1 = channel_names{1};
                channel_name_2 = channel_names{2};
                channel_idx_1 = channel_mapping.(channel_name_1);
                channel_idx_2 = channel_mapping.(channel_name_2);

                % Get the coherence value for the current subject, channel combination and
                % frequency band combination
                coherence_results_rest(subject_idx, channel_idx_1, channel_idx_2, freq_band_idx) = resting_state_coherence_features_struct.(subject_name).(channel_comb_name).(freq_band_name);
                coherence_results_calculation(subject_idx, channel_idx_1, channel_idx_2, freq_band_idx) = cognitive_task_state_coherence_features_struct.(subject_name).(channel_comb_name).(freq_band_name);
            end
        end
    end

    % Initialize the matrices for the averaged results
    coherence_average_rest = zeros(num_channels, num_channels, num_freq_bands);
    coherence_average_calculation = zeros(num_channels, num_channels, num_freq_bands);
    
    % Calculate the averaged value for each channel combination and
    % frequency band
    for channel_idx_1 = 1:num_channels
        for channel_idx_2 = (channel_idx_1+1):num_channels
            for freq_band_idx = 1:num_freq_bands
                coherence_average_rest(channel_idx_1, channel_idx_2, freq_band_idx) = mean(coherence_results_rest(:, channel_idx_1, channel_idx_2, freq_band_idx));
                coherence_average_calculation(channel_idx_1, channel_idx_2, freq_band_idx) = mean(coherence_results_calculation(:, channel_idx_1, channel_idx_2, freq_band_idx));
            end
        end
    end

    % ----------------- Individual Coherence plots -------------------

    for subject_idx = 1:num_subjects
        subject_name = subjects{subject_idx};
    
        % Resting state plots of the coherence matrices
        figure;
        set(gcf, 'Units', 'inches', 'Position', [0, 0, 10, 20]);
        for freq_band_idx = 1:num_freq_bands
            subplot(3, 2, freq_band_idx);
            pos = get(gca, 'Position');
            set(gca, 'Position', [pos(1), pos(2), pos(3), pos(4) * 1.30]);
            imagesc(squeeze(coherence_results_rest(subject_idx, :, :, freq_band_idx)));
            title(['Coherence Resting State - ', bands{freq_band_idx}]);
            xlabel('channel');
            ylabel('channel');
            colorbar;
            axis square;
            set(gca, 'XTick', 1:num_channels, 'XTickLabel', channels, 'YTick', 1:num_channels, 'YTickLabel', channels);
            xtickangle(45);
        end
    
        % Save the plot
        coherence_folder_subject = fullfile(figures_folder_path, 'Coherence', subject_name);
        % Create preprocessing comparison folder if it does not exist yet
        if ~exist(coherence_folder_subject, 'dir')
            mkdir(coherence_folder_subject);
        end
        coherence_matrices_rest_file_path = fullfile(coherence_folder_subject, [subject_name, '_coherence_matrices_rest.png']);
        saveas(gcf, coherence_matrices_rest_file_path);
        close;
    
    
        % Calculation state plots of the coherence matrices
        figure;
        set(gcf, 'Units', 'inches', 'Position', [0, 0, 10, 20]);
        for freq_band_idx = 1:num_freq_bands
            subplot(3, 2, freq_band_idx);
            pos = get(gca, 'Position');
            set(gca, 'Position', [pos(1), pos(2), pos(3), pos(4) * 1.30]);
            imagesc(squeeze(coherence_results_calculation(subject_idx, :, :, freq_band_idx)));
            title(['Coherence Cognitive Task - ', bands{freq_band_idx}]);
            xlabel('channel');
            ylabel('channel');
            colorbar;
            axis square;
            set(gca, 'XTick', 1:num_channels, 'XTickLabel', channels, 'YTick', 1:num_channels, 'YTickLabel', channels);
            xtickangle(45);
        end
    
        % Save the plot
        coherence_matrices_calculation_file_path = fullfile(coherence_folder_subject, [subject_name, '_coherence_matrices_calculation.png']);
        saveas(gcf, coherence_matrices_calculation_file_path);
        close;
        
    
        % ------------------- Coherence Graph Plots ----------------------
    
        % Load the channel locs to get the channel positions for the graph
        % plots
        chanlocs = load("chanlocs.mat");
        chanlocs = chanlocs.chanlocs;
    
        % Resting state plots of coherence
        figure;
        set(gcf, 'Units', 'inches', 'Position', [0, 0, 10, 20]);
        subplot_idx = 1;
        for freq_band_idx = [1, 2, 4, 5, 3]
            subplot(3, 2, subplot_idx);

            coherence_plot(squeeze(coherence_results_rest(subject_idx, :, :, freq_band_idx)), chanlocs, "absolute");
            title(['Coherence Resting State - ', bands{freq_band_idx}]);

            subplot_idx = subplot_idx + 1;
        end
    
        % Save the plot
        coherence_graph_rest_file_path = fullfile(coherence_folder_subject, [subject_name, '_coherence_graph_rest.png']);
        saveas(gcf, coherence_graph_rest_file_path);
        close;
    
    
        % Cognitive task plots of coherence 
        figure;
        set(gcf, 'Units', 'inches', 'Position', [0, 0, 10, 20]);
        subplot_idx = 1;
        for freq_band_idx = [1, 2, 4, 5, 3]
            subplot(3, 2, subplot_idx);

            coherence_plot(squeeze(coherence_results_calculation(subject_idx, :, :, freq_band_idx)), chanlocs, "absolute");
            title(['Coherence Cognitive Task - ', bands{freq_band_idx}]);

            subplot_idx = subplot_idx + 1;
        end
    
        % Save the plot
        coherence_graph_calculation_file_path = fullfile(coherence_folder_subject, [subject_name, '_coherence_graph_calculation.png']);
        saveas(gcf, coherence_graph_calculation_file_path);
        close;
    
    
        % Absolute coherence difference plots
        figure;
        set(gcf, 'Units', 'inches', 'Position', [0, 0, 10, 20]);
        coherence_difference = squeeze(coherence_results_calculation(subject_idx, :, :, :)) - squeeze(coherence_results_rest(subject_idx, :, :, :));
        coherence_difference_threshold = 0.2;
        subplot_idx = 1;
        for freq_band_idx = [1, 2, 4, 5, 3]
            subplot(3, 2, subplot_idx);

            coherence_plot(coherence_difference(:, :, freq_band_idx), chanlocs, "difference", coherence_difference_threshold);
            title(['Coherence Difference (> ', sprintf('%.2f', coherence_difference_threshold), ') - ', bands{freq_band_idx}]);

            subplot_idx = subplot_idx + 1;
        end
    
        % Save the plot
        coherence_difference_graph_file_path = fullfile(coherence_folder_subject,[subject_name, '_coherence_difference_graph.png']);
        saveas(gcf, coherence_difference_graph_file_path);
        close;
    end

    % ------------------ Average Coherence plots -------------------

    % Resting state plots of the coherence matrices
    figure;
    set(gcf, 'Units', 'inches', 'Position', [0, 0, 10, 20]);
    for freq_band_idx = 1:num_freq_bands
        subplot(3, 2, freq_band_idx);
        pos = get(gca, 'Position');
        set(gca, 'Position', [pos(1), pos(2), pos(3), pos(4) * 1.30]);
        imagesc(coherence_average_rest(:, :, freq_band_idx));
        title(['Coherence Resting State - ', bands{freq_band_idx}]);
        xlabel('channel');
        ylabel('channel');
        colorbar;
        axis square;
        set(gca, 'XTick', 1:num_channels, 'XTickLabel', channels, 'YTick', 1:num_channels, 'YTickLabel', channels);
        xtickangle(45);
    end

    % Save the plot
    coherence_folder_average = fullfile(figures_folder_path, 'Coherence', 'Average');
    % Create preprocessing comparison folder if it does not exist yet
    if ~exist(coherence_folder_average, 'dir')
        mkdir(coherence_folder_average);
    end
    coherence_matrices_rest_file_path = fullfile(coherence_folder_average, 'all_subjects_coherence_matrices_rest.png');
    saveas(gcf, coherence_matrices_rest_file_path);
    close;


    % Calculation state plots of the coherence matrices
    figure;
    set(gcf, 'Units', 'inches', 'Position', [0, 0, 10, 20]);
    for freq_band_idx = 1:num_freq_bands
        subplot(3, 2, freq_band_idx);
        pos = get(gca, 'Position');
        set(gca, 'Position', [pos(1), pos(2), pos(3), pos(4) * 1.30]);
        imagesc(coherence_average_calculation(:, :, freq_band_idx));
        title(['Coherence Cognitive Task - ', bands{freq_band_idx}]);
        xlabel('channel');
        ylabel('channel');
        colorbar;
        axis square;
        set(gca, 'XTick', 1:num_channels, 'XTickLabel', channels, 'YTick', 1:num_channels, 'YTickLabel', channels);
        xtickangle(45);
    end

    % Save the plot
    coherence_matrices_calculation_file_path = fullfile(coherence_folder_average, 'all_subjects_coherence_matrices_calculation.png');
    saveas(gcf, coherence_matrices_calculation_file_path);
    close;
    

    % ------------------- Coherence Graph Plots ----------------------

    % Load the channel locs to get the channel positions for the graph
    % plots
    chanlocs = load("chanlocs.mat");
    chanlocs = chanlocs.chanlocs;

    % Resting state plots of coherence
    figure;
    set(gcf, 'Units', 'inches', 'Position', [0, 0, 10, 20]);
    subplot_idx = 1;
    for freq_band_idx = [1, 2, 4, 5, 3]
        subplot(3, 2, subplot_idx);
        coherence_plot(coherence_average_rest(:, :, freq_band_idx), chanlocs, "absolute");
        title(['Coherence Resting State - ', bands{freq_band_idx}]);

        subplot_idx = subplot_idx + 1;
    end

    % Save the plot
    coherence_graph_rest_file_path = fullfile(coherence_folder_average, 'all_subjects_coherence_graph_rest.png');
    saveas(gcf, coherence_graph_rest_file_path);
    close;
    

    % Cognitive task plots of coherence 
    figure;
    set(gcf, 'Units', 'inches', 'Position', [0, 0, 10, 20]);
    subplot_idx = 1;
    for freq_band_idx = [1, 2, 4, 5, 3]
        subplot(3, 2, subplot_idx);
        coherence_plot(coherence_average_calculation(:, :, freq_band_idx), chanlocs, "absolute");
        title(['Coherence Cognitive Task - ', bands{freq_band_idx}]);

        subplot_idx = subplot_idx + 1;
    end

    % Save the plot
    coherence_graph_calculation_file_path = fullfile(coherence_folder_average, 'all_subjects_coherence_graph_calculation.png');
    saveas(gcf, coherence_graph_calculation_file_path);
    close;


    % Absolute coherence difference plots
    figure;
    set(gcf, 'Units', 'inches', 'Position', [0, 0, 10, 20]);
    coherence_difference = coherence_average_calculation - coherence_average_rest;
    coherence_difference_threshold = 0.1;
    subplot_idx = 1;
    for freq_band_idx = [1, 2, 4, 5, 3]
        subplot(3, 2, subplot_idx);

        coherence_plot(coherence_difference(:, :, freq_band_idx), chanlocs, "difference", coherence_difference_threshold);
               
        pos = get(gca, 'Position');
        set(gca, 'Position', [pos(1), pos(2), pos(3), pos(4) * 1.30]);
    
        subplot_title = title(['Coherence Difference (> ', sprintf('%.2f', coherence_difference_threshold), ') - ', bands{freq_band_idx}]);
        % Adjust the position of the title for the second subplot
        title_position = get(subplot_title, 'Position');
        title_position(2) = title_position(2) - 40;  % Adjust the vertical position
        set(subplot_title, 'Position', title_position);

        subplot_idx = subplot_idx + 1;
    end

    % Save the plot
    coherence_difference_graph_file_path = fullfile(coherence_folder_average, 'all_subjects_coherence_difference_graph.png');
    saveas(gcf, coherence_difference_graph_file_path);
    close;
end