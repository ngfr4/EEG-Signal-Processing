function [] = plot_mean_psd(resting_state_psd_features_struct, cognitive_task_state_psd_features_struct, freq_ranges, figures_folder_path)
    % Plot the mean psd values. Currently the values are averaged over the
    % subjects. Plot both as bar charts and as topoplots.

    % Load the channel locs to get the channel positions for the topoplots
    chanlocs = load("chanlocs.mat");
    chanlocs = chanlocs.chanlocs;

    % Get subject names
    subjects = fieldnames(resting_state_psd_features_struct)';
    num_subjects = length(subjects);
    % Get channel names
    channels = fieldnames(resting_state_psd_features_struct.(subjects{1}))';
    % Order channels for the topoplots later
    for idx = 1:size(chanlocs, 2)
        label = upper(chanlocs(idx).labels);
        if ismember(label, channels)
            ordered_channels{idx} = label;
        end
    end
    channels = ordered_channels;
    num_channels = length(channels);
    % Get frequency band names
    freq_bands = fieldnames(resting_state_psd_features_struct.(subjects{1}).(channels{1}))';
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

    % Initialize the mean psd result matrices
    mean_psd_results_rest = zeros(num_subjects, num_channels, num_freq_bands);
    mean_psd_results_calculation = zeros(num_subjects, num_channels, num_freq_bands);
    
    % Iterate over each subject
    for subject_idx = 1:num_subjects    
        subject_name = subjects{subject_idx};
        % Iterate over each channel
        for channel_idx = 1:num_channels
            channel_name = channels{channel_idx};
            for freq_band_idx = 1:num_freq_bands
                freq_band_name = freq_bands{freq_band_idx};
                % Get the mean PSD value for the current subject, channel and
                % frequency band combination
                mean_psd_results_rest(subject_idx, channel_idx, freq_band_idx) = resting_state_psd_features_struct.(subject_name).(channel_name).(freq_band_name);
                mean_psd_results_calculation(subject_idx, channel_idx, freq_band_idx) = cognitive_task_state_psd_features_struct.(subject_name).(channel_name).(freq_band_name);
            end
        end

        % ----------- Individual PSD bar charts ------------

        % Create a bar plot for resting state
        figure;
        bar(squeeze(mean_psd_results_rest(subject_idx, :, :)));
        title('PSD Average - Rest State');
        xlabel('Channels');
        ylabel('PSD');
        legend(bands, 'Location', 'northeastoutside');
        set(gca, 'XTick', 1:num_channels, 'XTickLabel', channels);
        set(gca, 'YScale', 'log');
        
        % Save the plot
        mean_psd_folder_subject = fullfile(figures_folder_path, 'Mean_PSD', subject_name);
        % Create preprocessing comparison folder if it does not exist yet
        if ~exist(mean_psd_folder_subject, 'dir')
            mkdir(mean_psd_folder_subject);
        end
        mean_psd_rest_file_path = fullfile(mean_psd_folder_subject, [subject_name, '_mean_psd_rest.png']);
        saveas(gcf, mean_psd_rest_file_path);
        close;
    
        % Create a bar plot for calculating state
        figure;
        bar(squeeze(mean_psd_results_calculation(subject_idx, :, :)));
        title('PSD Average - Calculation State');
        xlabel('Channels');
        ylabel('PSD');
        legend(bands, 'Location', 'northeastoutside');
        set(gca, 'XTick', 1:num_channels, 'XTickLabel', channels);
        set(gca, 'YScale', 'log');
        
        % Save the plot
        mean_psd_calculation_file_path = fullfile(mean_psd_folder_subject, [subject_name, '_mean_psd_calculation.png']);
        saveas(gcf, mean_psd_calculation_file_path);
        close;
    
        % Calculate the difference percentage
        difference_percentage = squeeze((mean_psd_results_calculation(subject_idx, :, :) - mean_psd_results_rest(subject_idx, :, :)) ./ mean_psd_results_rest(subject_idx, :, :) * 100);
        
        % Plot the difference percentage between the two states
        figure;
        bar(difference_percentage);
        title('PSD Percentage Difference between Calculation and Rest States');
        xlabel('Channels');
        ylabel('Difference (%)');
        legend(bands, 'Location', 'northeastoutside');
        set(gca, 'XTick', 1:num_channels, 'XTickLabel', channels);
        
        % Save the plot
        mean_psd_difference_percentage_file_path = fullfile(mean_psd_folder_subject, [subject_name, '_mean_psd_difference_percentage.png']);
        saveas(gcf, mean_psd_difference_percentage_file_path);
        close;
    
        % ---------- Individual PSD Topoplots -----------
    
        % For resting state
        figure;
        set(gcf, 'Units', 'inches', 'Position', [0, 0, 10, 20]);
        subplot_idx = 1;
        min_value = min(mean_psd_results_rest, [], "all");
        max_value = max(mean_psd_results_rest, [], "all"); 
        for freq_band_idx = [1, 2, 4, 5, 3]
            subplot(3, 2, subplot_idx);
            topoplot(squeeze(mean_psd_results_rest(subject_idx, :, freq_band_idx)), chanlocs, 'maplimits', [min_value, max_value], 'plotrad', 0.7, 'headrad', 0.6, 'conv', 'on', 'whitebk', 'on', 'electrodes', 'labels');
            
            % Set position/size and title of subplot
            pos = get(gca, 'Position');
            set(gca, 'Position', [pos(1), pos(2), pos(3), pos(4) * 1.30]);
            title(['PSD Resting State - ',bands{freq_band_idx}]);
            colorbar

            subplot_idx = subplot_idx + 1;
        end
        
        % Save the plot
        mean_psd_topoplot_rest_file_path = fullfile(mean_psd_folder_subject, [subject_name, '_mean_psd_topoplot_rest.png']);
        saveas(gcf, mean_psd_topoplot_rest_file_path);
        close;
    
    
        % For calculating state
        figure;
        set(gcf, 'Units', 'inches', 'Position', [0, 0, 10, 20]);
        subplot_idx = 1;
        min_value = min(mean_psd_results_calculation, [], "all");
        max_value = max(mean_psd_results_calculation, [], "all"); 
        for freq_band_idx = [1, 2, 4, 5, 3]
            subplot(3, 2, subplot_idx);
            topoplot(squeeze(mean_psd_results_calculation(subject_idx, :, freq_band_idx)), chanlocs, 'maplimits', [min_value, max_value], 'plotrad', 0.7, 'headrad', 0.6, 'conv', 'on', 'whitebk', 'on', 'electrodes', 'labels');
            
            % Set position/size and title of subplot
            pos = get(gca, 'Position');
            set(gca, 'Position', [pos(1), pos(2), pos(3), pos(4) * 1.30]);
            title(['PSD Cognitive Task - ',bands{freq_band_idx}]);
            colorbar

            subplot_idx = subplot_idx + 1;
        end
        
        % Save the plot
        mean_psd_topoplot_calculation_file_path = fullfile(mean_psd_folder_subject, [subject_name, '_mean_psd_topoplot_calculation.png']);
        saveas(gcf, mean_psd_topoplot_calculation_file_path);
        close;
    
    
        % Difference percentage between the two states
        figure;
        % Set the figure size (in inches) - adjust the width and height as needed
        set(gcf, 'Units', 'inches', 'Position', [0, 0, 10, 20]);
        subplot_idx = 1;
        min_value = min(difference_percentage, [], "all");
        max_value = max(difference_percentage, [], "all"); 
        for freq_band_idx = [1, 2, 4, 5, 3]
            subplot(3, 2, subplot_idx);
            topoplot(difference_percentage(:, freq_band_idx), chanlocs, 'maplimits', [min_value, max_value], 'plotrad', 0.7, 'headrad', 0.6, 'conv', 'on', 'whitebk', 'on', 'electrodes', 'labels');
            
            % Set position/size and title of subplot
            pos = get(gca, 'Position');
            set(gca, 'Position', [pos(1), pos(2), pos(3), pos(4) * 1.30]);
            title(['PSD Percentage Difference - ',bands{freq_band_idx}]);
            colorbar

            subplot_idx = subplot_idx + 1;
        end
    
        % Save the plot
        mean_psd_topoplot_difference_percentage_file_path = fullfile(mean_psd_folder_subject, [subject_name, '_mean_psd_topoplot_difference_percentage.png']);
        saveas(gcf, mean_psd_topoplot_difference_percentage_file_path);
        close;

    end
    
    % Initialize the matrices for the averaged results
    psd_average_rest = zeros(num_channels, num_freq_bands);
    psd_average_calculation = zeros(num_channels, num_freq_bands);
    
    % Calculate the averaged value for each channel and frequency band
    % combination over the subjects
    for channel_idx = 1:num_channels
        for freq_band_idx = 1:num_freq_bands
            psd_average_rest(channel_idx, freq_band_idx) = mean(mean_psd_results_rest(:, channel_idx, freq_band_idx));
            psd_average_calculation(channel_idx, freq_band_idx) = mean(mean_psd_results_calculation(:, channel_idx, freq_band_idx));
        end
    end

    % ---------------- Average PSD plots -------------------
    
    % Create a bar plot for resting state
    figure;
    bar(psd_average_rest);
    title('PSD Average - Rest State');
    xlabel('Channels');
    ylabel('PSD');
    legend(bands, 'Location', 'northeastoutside');
    set(gca, 'XTick', 1:num_channels, 'XTickLabel', channels);
    set(gca, 'YScale', 'log');
    
    % Save the plot
    mean_psd_folder_average = fullfile(figures_folder_path, 'Mean_PSD', 'Average');
    % Create preprocessing comparison folder if it does not exist yet
    if ~exist(mean_psd_folder_average, 'dir')
        mkdir(mean_psd_folder_average);
    end
    mean_psd_rest_file_path = fullfile(mean_psd_folder_average, 'all_subjects_mean_psd_rest.png');
    saveas(gcf, mean_psd_rest_file_path);
    close;

    % Create a bar plot for calculating state
    figure;
    bar(psd_average_calculation);
    title('PSD Average - Calculation State');
    xlabel('Channels');
    ylabel('PSD');
    legend(bands, 'Location', 'northeastoutside');
    set(gca, 'XTick', 1:num_channels, 'XTickLabel', channels);
    set(gca, 'YScale', 'log');
    
    % Save the plot
    mean_psd_calculation_file_path = fullfile(mean_psd_folder_average, 'all_subjects_mean_psd_calculation.png');
    saveas(gcf, mean_psd_calculation_file_path);
    close;

    % Calculate the difference percentage
    difference_percentage = (psd_average_calculation - psd_average_rest) ./ psd_average_rest * 100;
    
    % Plot the difference percentage between the two states
    figure;
    bar(difference_percentage);
    title('PSD Percentage Difference between Calculation and Rest States');
    xlabel('Channels');
    ylabel('Difference (%)');
    legend(bands, 'Location', 'northeastoutside');
    set(gca, 'XTick', 1:num_channels, 'XTickLabel', channels);
    
    % Save the plot
    mean_psd_difference_percentage_file_path = fullfile(mean_psd_folder_average, 'all_subjects_mean_psd_difference_percentage.png');
    saveas(gcf, mean_psd_difference_percentage_file_path);
    close;

    % ---------- Average PSD Topoplots -----------

    % For resting state
    figure;
    set(gcf, 'Units', 'inches', 'Position', [0, 0, 10, 20]);
    subplot_idx = 1;
    min_value = min(psd_average_rest, [], "all");
    max_value = max(psd_average_rest, [], "all"); 
    for freq_band_idx = [1, 2, 4, 5, 3]
        subplot(3, 2, subplot_idx);

        topoplot(psd_average_rest(:, freq_band_idx), chanlocs, 'maplimits', [min_value, max_value], 'plotrad', 0.7, 'headrad', 0.6, 'conv', 'on', 'whitebk', 'on', 'electrodes', 'labels');
        
        % Set position/size and title of subplot
        pos = get(gca, 'Position');
        set(gca, 'Position', [pos(1), pos(2), pos(3), pos(4) * 1.30]);
        title(['PSD Resting State - ',bands{freq_band_idx}]);
        colorbar

        subplot_idx = subplot_idx + 1;
    end
    
    % Save the plot
    mean_psd_topoplot_rest_file_path = fullfile(mean_psd_folder_average, 'all_subjects_mean_psd_topoplot_rest.png');
    saveas(gcf, mean_psd_topoplot_rest_file_path);
    close;


    % For calculating state
    figure;
    set(gcf, 'Units', 'inches', 'Position', [0, 0, 10, 20]);
    subplot_idx = 1;
    min_value = min(psd_average_calculation, [], "all");
    max_value = max(psd_average_calculation, [], "all"); 
    for freq_band_idx = [1, 2, 4, 5, 3]
        subplot(3, 2, subplot_idx);
        topoplot(psd_average_calculation(:, freq_band_idx), chanlocs, 'maplimits', [min_value, max_value], 'plotrad', 0.7, 'headrad', 0.6, 'conv', 'on', 'whitebk', 'on', 'electrodes', 'labels');
        
        % Set position/size and title of subplot
        pos = get(gca, 'Position');
        set(gca, 'Position', [pos(1), pos(2), pos(3), pos(4) * 1.30]);
        title(['PSD Cognitive Task - ',bands{freq_band_idx}]);
        colorbar

        subplot_idx = subplot_idx + 1;
    end
    
    % Save the plot
    mean_psd_topoplot_calculation_file_path = fullfile(mean_psd_folder_average, 'all_subjects_mean_psd_topoplot_calculation.png');
    saveas(gcf, mean_psd_topoplot_calculation_file_path);
    close;


    % Difference percentage between the two states
    figure;
    % Set the figure size (in inches) - adjust the width and height as needed
    set(gcf, 'Units', 'inches', 'Position', [0, 0, 10, 20]);
    subplot_idx = 1;
    min_value = min(difference_percentage, [], "all");
    max_value = max(difference_percentage, [], "all"); 
    for freq_band_idx = [1, 2, 4, 5, 3]
        subplot(3, 2, subplot_idx);

        topoplot(difference_percentage(:, freq_band_idx), chanlocs, 'maplimits', [min_value, max_value], 'plotrad', 0.7, 'headrad', 0.6, 'conv', 'on', 'whitebk', 'on', 'electrodes', 'labels');
        
        % Set position/size and title of subplot
        pos = get(gca, 'Position');
        set(gca, 'Position', [pos(1), pos(2), pos(3), pos(4) * 1.30]);
        title(['PSD Percentage Difference - ',bands{freq_band_idx}]);
        colorbar

        subplot_idx = subplot_idx + 1;
    end

    % Save the plot
    mean_psd_topoplot_difference_percentage_file_path = fullfile(mean_psd_folder_average, 'all_subjects_mean_psd_topoplot_difference_percentage.png');
    saveas(gcf, mean_psd_topoplot_difference_percentage_file_path);
    close;
end