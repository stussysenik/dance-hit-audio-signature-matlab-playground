function fig = plotCrissCross(simMatrix, names)
% PLOTCRISSCROSS Display NxN similarity matrix as color-coded table.
%   fig = plotCrissCross(simMatrix, names)
%
%   Design (60/30/10 rule):
%     60% — Off-white figure background, neutral chrome
%     30% — Similarity data cells (custom slate→gold colormap)
%     10% — Diagonal self-match highlight, text annotations

    N = size(simMatrix, 1);
    C = vizColors();

    if nargin < 2
        names = arrayfun(@(i) sprintf('Track %d', i), 1:N, 'UniformOutput', false);
    end

    % Shorten names for display
    shortNames = cellfun(@(n) shortenName(n), names, 'UniformOutput', false);

    fig = figure('Name', 'Song Similarity Matrix', ...
                 'NumberTitle', 'off', ...
                 'Position', [100 100 1000 900], ...
                 'Color', C.figureBg);

    % Use pre-built similarity colormap (slate → teal → gold)
    simCmap = C.simCmap;

    % Main axes — reserve space for legend
    ax = axes('Position', [0.15 0.18 0.62 0.72]);

    imagesc(simMatrix);
    colormap(ax, simCmap);

    % Auto-scale to actual data range for better contrast
    offDiag = simMatrix + eye(N) * NaN;
    minSim = min(offDiag(:), [], 'omitnan');
    caxis([max(0, minSim - 0.05) 1]);

    set(ax, 'YDir', 'normal', 'FontSize', 9);
    ax.Color = C.panelBg;
    ax.XAxis.Color = C.textSecondary;
    ax.YAxis.Color = C.textSecondary;

    % Labels
    xticks(1:N);
    yticks(1:N);
    xticklabels(shortNames);
    yticklabels(shortNames);
    xtickangle(45);

    title('Cross-Song Similarity Matrix', ...
        'FontSize', 14, 'FontWeight', 'bold', 'Color', C.textPrimary);
    subtitle('Which songs share similar audio DNA? Gold = similar · Slate = different', ...
        'FontSize', 9, 'Color', C.textSecondary);

    % Annotate cells with values (10% accent)
    for i = 1:N
        for j = 1:N
            val = simMatrix(i, j);
            if val > 0.6
                textColor = C.textPrimary;
            else
                textColor = [0.85 0.85 0.85];
            end
            fontW = 'normal';
            if i == j
                fontW = 'bold';
            end
            text(j, i, sprintf('%.2f', val), ...
                'HorizontalAlignment', 'center', ...
                'Color', textColor, ...
                'FontSize', 8, ...
                'FontWeight', fontW);
        end
    end

    % ====================================================================
    %  RIGHT: Gradient Legend with labeled ticks
    % ====================================================================
    axLeg = axes('Position', [0.82 0.18 0.04 0.72]);

    % Draw gradient bar
    gradientImg = repmat(linspace(1, 0, 256)', 1, 1);
    imagesc(axLeg, [0 1], [0 1], gradientImg);
    colormap(axLeg, simCmap);
    caxis(axLeg, [0 1]);
    set(axLeg, 'XTick', [], 'YDir', 'normal');

    % Custom Y-ticks with semantic labels
    yticks(axLeg, [0 0.25 0.5 0.75 1.0]);
    yticklabels(axLeg, {'0.0 Distant', '0.25', '0.50 Moderate', '0.75', '1.0 Identical'});
    axLeg.YAxisLocation = 'right';
    axLeg.YAxis.Color = C.textSecondary;
    axLeg.FontSize = 8;

    title(axLeg, 'Similarity', 'FontSize', 9, 'Color', C.textPrimary);

    % ====================================================================
    %  BOTTOM: Interpretation guide
    % ====================================================================
    annotation('textbox', [0.15 0.02 0.7 0.08], ...
        'String', { ...
            'Similarity = cosine distance between mean hot-segment feature vectors.', ...
            'Warm gold = highly similar audio signatures | Slate = dissimilar | Diagonal = self-match (1.00)' ...
        }, ...
        'EdgeColor', 'none', 'Color', C.textSecondary, ...
        'FontSize', 8, 'FontAngle', 'italic', ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle');
end

function s = shortenName(name)
    % Remove extension and common prefixes
    [~, s, ~] = fileparts(name);
    s = strrep(s, 'demo_track_', '');
    s = strrep(s, '_', ' ');
    if length(s) > 18
        s = [s(1:15) '...'];
    end
end
