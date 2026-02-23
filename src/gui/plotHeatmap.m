function fig = plotHeatmap(features, timeAxis, hotness, hotIdx, trackName, config)
% PLOTHEATMAP Render time x dimension heatmap with hot segment overlay.
%   fig = plotHeatmap(features, timeAxis, hotness, hotIdx, trackName, config)
%
%   Two-layer layout with category grouping (elite minimalism):
%     LAYER 1: FINGERPRINT — 8 dimensions grouped into rhythm/tonal/texture
%     LAYER 2: HOTNESS — combined danceability score over time
%
%   60/30/10: neutral canvas (60%), heatmap+bars (30%), hot accents (10%)

    if nargin < 6; config = AnalysisConfig(); end
    if nargin < 5; trackName = 'Track'; end

    C = vizColors();
    displayName = strrep(trackName, '_', ' ');

    % Reorder dimensions by category: RHYTHM → TONAL → TEXTURE
    dispOrder = C.dimDisplayOrder;
    dispFeatures = features(dispOrder, :);
    dispMean = mean(features, 2);
    dispMean = dispMean(dispOrder);
    dispNames = config.dimensionNames(dispOrder);
    dispColorRGB = C.dim(dispOrder, :);
    dispHex = C.dimHex(dispOrder);

    fig = figure('Name', displayName, ...
                 'NumberTitle', 'off', ...
                 'Position', [100 100 1500 900], ...
                 'Color', C.figureBg);

    % ── TITLE ────────────────────────────────────────────────────
    annotation('textbox', [0.05 0.955 0.90 0.04], ...
        'String', displayName, ...
        'FontSize', 18, 'FontWeight', 'bold', ...
        'EdgeColor', 'none', 'Color', C.textPrimary, ...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'middle', ...
        'FitBoxToText', 'off');

    % ── LAYER 1 HEADING ──────────────────────────────────────────
    annotation('textbox', [0.04 0.915 0.92 0.03], ...
        'String', 'FINGERPRINT   8 dimensions · rhythm · tonal · texture   |   brighter = higher intensity', ...
        'EdgeColor', 'none', 'Color', C.textSecondary, ...
        'FontSize', 9, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle', ...
        'FitBoxToText', 'off');

    % Build color-coded Y-tick labels
    dimLabels = cell(1, 8);
    for d = 1:8
        hx = dispHex{d};
        rgb = [hex2dec(hx(2:3)), hex2dec(hx(4:5)), hex2dec(hx(6:7))] / 255;
        dimLabels{d} = sprintf('\\color[rgb]{%g,%g,%g}%s', rgb(1), rgb(2), rgb(3), dispNames{d});
    end

    % ── HEATMAP ──────────────────────────────────────────────────
    ax1 = axes('Position', [0.10 0.38 0.52 0.52]);
    imagesc(timeAxis, 1:8, dispFeatures);
    colormap(ax1, C.heatmapCmap);
    set(ax1, 'YDir', 'normal', 'FontSize', 9);
    ax1.Color = C.panelBg;
    ax1.YAxis.Color = C.textSecondary;
    ax1.XAxis.Color = C.textSecondary;
    xlabel('Time (seconds)', 'Color', C.textPrimary, 'FontSize', 9);
    yticks(1:8);
    ax1.TickLabelInterpreter = 'tex';
    yticklabels(dimLabels);

    % Category separators + labels
    hold on;
    plot([timeAxis(1) timeAxis(end)], [3.5 3.5], '-', 'Color', [1 1 1 0.6], 'LineWidth', 1.5);
    plot([timeAxis(1) timeAxis(end)], [6.5 6.5], '-', 'Color', [1 1 1 0.6], 'LineWidth', 1.5);

    xOff = timeAxis(1) + (timeAxis(end)-timeAxis(1))*0.005;
    text(xOff, 2, '  RHYTHM', 'Color', [1 1 1 0.5], 'FontSize', 7, ...
        'FontWeight', 'bold', 'VerticalAlignment', 'middle');
    text(xOff, 5, '  TONAL', 'Color', [1 1 1 0.5], 'FontSize', 7, ...
        'FontWeight', 'bold', 'VerticalAlignment', 'middle');
    text(xOff, 7.5, '  TEXTURE', 'Color', [1 1 1 0.5], 'FontSize', 7, ...
        'FontWeight', 'bold', 'VerticalAlignment', 'middle');

    % Hot segment markers
    for i = 1:length(hotIdx)
        idx = hotIdx(i);
        if idx <= length(timeAxis)
            xline(timeAxis(idx), 'Color', [C.hotOverlay(1:3) 0.2], 'LineWidth', 2);
        end
    end
    hold off;

    % Colorbar
    cb = colorbar(ax1, 'eastoutside');
    cb.Label.String = 'Intensity';
    cb.Label.Color = C.textSecondary;
    cb.Label.FontSize = 8;
    cb.FontSize = 7;
    cb.Ticks = [0 0.5 1.0];
    cb.TickLabels = {'Low', 'Mid', 'Peak'};
    cb.Color = C.textSecondary;

    % ── PROFILE BARS ─────────────────────────────────────────────
    ax3 = axes('Position', [0.70 0.38 0.26 0.52]);
    barh(ax3, 1:8, dispMean, 'FaceColor', 'flat', ...
        'CData', dispColorRGB, 'EdgeColor', 'none');
    yticks(ax3, 1:8);
    set(ax3, 'YDir', 'normal', 'FontSize', 9);
    ax3.Color = C.panelBg;
    ax3.XAxis.Color = C.textSecondary;
    ax3.YAxis.Color = C.textSecondary;
    ax3.TickLabelInterpreter = 'tex';
    yticklabels(ax3, dimLabels);
    xlabel(ax3, 'Mean', 'Color', C.textPrimary, 'FontSize', 9);
    title(ax3, 'Average Profile', 'FontSize', 10, 'Color', C.textPrimary);
    xlim(ax3, [0 1]);
    grid(ax3, 'on');
    ax3.GridColor = C.gridColor;
    ax3.GridAlpha = 0.4;

    % Category separators + value annotations
    hold(ax3, 'on');
    yline(ax3, 3.5, '-', 'Color', C.gridColor, 'LineWidth', 1);
    yline(ax3, 6.5, '-', 'Color', C.gridColor, 'LineWidth', 1);
    for d = 1:8
        text(ax3, dispMean(d) + 0.02, d, sprintf('%.2f', dispMean(d)), ...
            'FontSize', 7, 'Color', C.textSecondary, 'VerticalAlignment', 'middle');
    end
    hold(ax3, 'off');

    % ── LAYER 2 HEADING ──────────────────────────────────────────
    annotation('textbox', [0.04 0.33 0.92 0.03], ...
        'String', 'HOTNESS   all dimensions → single score   |   above threshold = hot segment', ...
        'EdgeColor', 'none', 'Color', C.textSecondary, ...
        'FontSize', 9, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'left', 'VerticalAlignment', 'middle', ...
        'FitBoxToText', 'off');

    % ── HOTNESS CURVE ────────────────────────────────────────────
    ax2 = axes('Position', [0.10 0.06 0.52 0.25]);
    ax2.Color = C.panelBg;

    fill(ax2, [timeAxis(1) timeAxis(end) timeAxis(end) timeAxis(1)], ...
         [min(hotness)*0.9 min(hotness)*0.9 max(hotness)*1.1 max(hotness)*1.1], ...
         C.coolZone(1:3), 'FaceAlpha', C.coolZone(4), 'EdgeColor', 'none');
    hold on;

    plot(timeAxis, hotness, 'Color', C.hotnessLine, 'LineWidth', 1.5);

    threshold = mean(hotness) + config.hotThresholdSigma * std(hotness);
    yline(threshold, '--', 'Color', C.threshold, 'LineWidth', 1.2);

    if ~isempty(hotIdx)
        validIdx = hotIdx(hotIdx <= length(timeAxis));
        scatter(timeAxis(validIdx), hotness(validIdx), 40, ...
            C.hotDot(1:3), 'filled', 'MarkerEdgeColor', 'w', 'LineWidth', 0.5);
        hotMask = hotness >= threshold;
        fillX = timeAxis(hotMask);
        fillY = hotness(hotMask);
        if length(fillX) > 1
            fill([fillX fliplr(fillX)], [fillY ones(size(fillY))*threshold], ...
                C.hotFill(1:3), 'FaceAlpha', C.hotFill(4), 'EdgeColor', 'none');
        end
    end
    hold off;

    xlabel('Time (seconds)', 'Color', C.textPrimary, 'FontSize', 9);
    ylabel('Score', 'Color', C.textPrimary, 'FontSize', 9);
    grid on;
    ax2.GridColor = C.gridColor;
    ax2.GridAlpha = 0.4;
    ax2.XAxis.Color = C.textSecondary;
    ax2.YAxis.Color = C.textSecondary;
    xlim([timeAxis(1) timeAxis(end)]);
    set(ax2, 'FontSize', 9);

    linkaxes([ax1, ax2], 'x');

    % ── READING GUIDE ────────────────────────────────────────────
    ax4 = axes('Position', [0.70 0.06 0.26 0.25]);
    set(ax4, 'XTick', [], 'YTick', [], 'XColor', 'none', 'YColor', 'none');
    xlim(ax4, [0 1]); ylim(ax4, [0 1]);
    ax4.Color = C.panelBg;
    hold(ax4, 'on');

    text(ax4, 0.05, 0.95, 'GUIDE', 'FontSize', 9, 'FontWeight', 'bold', ...
        'Color', C.textPrimary, 'VerticalAlignment', 'top');

    yPos = 0.76;
    sp = 0.16;

    % Score line
    plot(ax4, [0.05 0.22], [yPos yPos], '-', 'Color', C.hotnessLine, 'LineWidth', 1.5);
    text(ax4, 0.27, yPos, 'Hotness score', 'FontSize', 8, 'Color', C.textSecondary, ...
        'VerticalAlignment', 'middle');
    yPos = yPos - sp;

    % Threshold
    plot(ax4, [0.05 0.22], [yPos yPos], '--', 'Color', C.threshold, 'LineWidth', 1);
    text(ax4, 0.27, yPos, 'Hot threshold', 'FontSize', 8, 'Color', C.textSecondary, ...
        'VerticalAlignment', 'middle');
    yPos = yPos - sp;

    % Hot dot
    scatter(ax4, 0.135, yPos, 40, C.hotDot(1:3), 'filled', ...
        'MarkerEdgeColor', 'w', 'LineWidth', 0.5);
    text(ax4, 0.27, yPos, 'Hot segment', 'FontSize', 8, 'Color', C.textSecondary, ...
        'VerticalAlignment', 'middle');
    yPos = yPos - sp;

    % Green overlay
    patch(ax4, [0.05 0.22 0.22 0.05], ...
        [yPos-0.04 yPos-0.04 yPos+0.04 yPos+0.04], ...
        C.hotOverlay(1:3), 'FaceAlpha', 0.25, 'EdgeColor', 'none');
    text(ax4, 0.27, yPos, 'Hot zone overlay', 'FontSize', 8, 'Color', C.textSecondary, ...
        'VerticalAlignment', 'middle');

    hold(ax4, 'off');

    % Stats
    text(ax4, 0.05, 0.08, ...
        sprintf('%d segments  ·  %d hot (%.0f%%)  ·  %.1fs', ...
            size(features, 2), length(hotIdx), ...
            100*length(hotIdx)/max(1,size(features,2)), timeAxis(end)), ...
        'FontSize', 8, 'Color', C.textSecondary, 'VerticalAlignment', 'bottom');
end
