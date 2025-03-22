function [] = coherence_plot(coherence_matrix, chanlocs, type, coherence_difference_threshold)
    % Create a coherence plot having connections between channels with high
    % coherence (as well as coherence increase/decrease

    num_channels = size(coherence_matrix, 1);

    hold on;

    % Create the rough outline (channel positions with dot and name)
    % Example data for X and Y channel coordinates (need to switch X and Y & sign switch to obtain correct electrode placement) 
    % such that 
    X = -[chanlocs.Y];
    Y = [chanlocs.X];

    % To prevent to close electrode shift certain electrodes to the outside
    shift_value = 15;
    channel_to_shift_left = {'F7', 'T3', 'T5'};
    channel_to_shift_right = {'F8', 'T4', 'T6'};

    % Shift the X-coordinates of electrodes to the left
    for i = 1:numel(channel_to_shift_left)
        electrode_label = channel_to_shift_left{i};
        % Find the index of the electrode in chanlocs
        electrode_index = find(strcmp({chanlocs.labels}, electrode_label));
        % Shift the X-coordinate to the left by shift_value
        X(electrode_index) = X(electrode_index) - shift_value;
    end
    
    % Shift the X-coordinates of electrodes to the right
    for i = 1:numel(channel_to_shift_right)
        electrode_label = channel_to_shift_right{i};
        % Find the index of the electrode in chanlocs
        electrode_index = find(strcmp({chanlocs.labels}, electrode_label));
        % Shift the X-coordinate to the right by shift_value
        X(electrode_index) = X(electrode_index) + shift_value;
    end
    

    channel_names = {chanlocs.labels};
    channel_names = channel_names(1:num_channels);
    
    % Create a custom plot
    axis off;  % Turn off axes
    box off;   % Turn off bounding box
    
    % Create dots for channel coordinates
    scatter(X, Y, 50, 'filled');
    
    % Display the channel names next to the dots
    text(X, Y, channel_names, 'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle', 'FontWeight', 'bold');
    
    % Optionally, rotate the channel names if they overlap
    xtickangle(45);

    if type == "absolute"
        for channel_idx_1 = 1:num_channels
            for channel_idx_2 = (channel_idx_1+1):num_channels
                % Plot a red line between the channels with high coherence
                if coherence_matrix(channel_idx_1, channel_idx_2) >= 0.7
                    plot([X(channel_idx_1), X(channel_idx_2)], [Y(channel_idx_1), Y(channel_idx_2)], 'r-', 'LineWidth', coherence_matrix(channel_idx_1, channel_idx_2));
                end
            end
        end
    elseif type == "difference"
        for channel_idx_1 = 1:num_channels
            for channel_idx_2 = (channel_idx_1+1):num_channels
                % Plot a red line between the channels with significant coherence increase
                if coherence_matrix(channel_idx_1, channel_idx_2) >= coherence_difference_threshold
                    plot([X(channel_idx_1), X(channel_idx_2)], [Y(channel_idx_1), Y(channel_idx_2)], 'r-', 'LineWidth', 2*coherence_matrix(channel_idx_1, channel_idx_2));
                % Plot a blue line between the channels with significant coherence decrease
                elseif coherence_matrix(channel_idx_1, channel_idx_2) <= -coherence_difference_threshold
                    plot([X(channel_idx_1), X(channel_idx_2)], [Y(channel_idx_1), Y(channel_idx_2)], 'b-', 'LineWidth', 2*abs(coherence_matrix(channel_idx_1, channel_idx_2)));
                end
            end
        end
    end


    % Add head (+ears and nose)
    center_electrode = 'Cz';

    % Loop through the chanlocs to find the matching label
    for i = 1:numel(chanlocs)
        if strcmp(chanlocs(i).labels, center_electrode)
            head_center_position_X = - chanlocs(i).Y;
            head_center_position_Y = chanlocs(i).X-5;
            break; % Exit the loop once a match is found
        end
    end
    
    % Draw the head circle with center at (X_cz, Y_cz)
    head_radius = 118; 
    rectangle('Position', [head_center_position_X-head_radius, head_center_position_Y-head_radius, 2*head_radius, 2*head_radius], 'Curvature', [1, 1], 'EdgeColor', 'black');
    axis equal;
    
    % Draw the nose at the top of the head circle
    nose_height = head_radius / 10;
    nose_width = head_radius / 10;
    x_nose = [head_center_position_X-nose_width/2, head_center_position_X+nose_width/2, head_center_position_X];
    y_nose = [head_center_position_Y+head_radius, head_center_position_Y+head_radius, head_center_position_Y+head_radius + nose_height];
    fill(x_nose, y_nose, 'w', 'FaceAlpha', 0);
    
    % Draw the ears as ellipses
    ear_y_radius = head_radius / 5;
    ear_x_radius = head_radius / 10;
    rectangle('Position', [head_center_position_X-head_radius-11.1, head_center_position_Y-2, ear_x_radius, ear_y_radius], 'Curvature', [1, 1], 'EdgeColor', 'black');
    rectangle('Position', [head_center_position_X+head_radius-0.7, head_center_position_Y-2, ear_x_radius, ear_y_radius], 'Curvature', [1, 1], 'EdgeColor', 'black');

    hold off;
end
