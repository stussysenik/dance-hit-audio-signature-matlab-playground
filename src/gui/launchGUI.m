function fig = launchGUI(allResults, config)
% LAUNCHGUI Launch the interactive Dance Hit Analyzer GUI.
%   fig = launchGUI() launches with demo data.
%   fig = launchGUI(allResults, config) launches with pre-analyzed results.
%
%   Tabs:
%     1. Single Track Analysis - heatmap + weight sliders
%     2. Multi-Song Comparison - criss-cross similarity table
%     3. DJ Blend Recommendations - ranked blend pairings
%     4. Metadata Explorer - cultural/artist context

    if nargin < 2
        config = AnalysisConfig();
    end

    % If no results provided, run analysis on demo data
    if nargin < 1 || isempty(allResults)
        allResults = analyzeAllDemoTracks(config);
    end

    % Create main figure
    fig = figure('Name', 'Dance Hit Audio Signature Analyzer', ...
                 'NumberTitle', 'off', ...
                 'Position', [50 50 1400 850], ...
                 'Color', [0.15 0.15 0.18], ...
                 'MenuBar', 'none', ...
                 'ToolBar', 'figure');

    % Create tab group
    tabGroup = uitabgroup(fig, 'Position', [0 0 1 1]);

    % --- Tab 1: Single Track Analysis ---
    tab1 = uitab(tabGroup, 'Title', ' Single Track ', 'BackgroundColor', [0.15 0.15 0.18]);
    buildSingleTrackTab(tab1, allResults, config);

    % --- Tab 2: Multi-Song Comparison ---
    tab2 = uitab(tabGroup, 'Title', ' Comparison ', 'BackgroundColor', [0.15 0.15 0.18]);
    buildComparisonTab(tab2, allResults, config);

    % --- Tab 3: DJ Blend ---
    tab3 = uitab(tabGroup, 'Title', ' DJ Blend ', 'BackgroundColor', [0.15 0.15 0.18]);
    buildBlendTab(tab3, allResults, config);

    % --- Tab 4: Metadata ---
    tab4 = uitab(tabGroup, 'Title', ' Metadata ', 'BackgroundColor', [0.15 0.15 0.18]);
    buildMetadataTab(tab4, config);
end

function buildSingleTrackTab(tab, allResults, config)
    N = length(allResults);
    trackNames = {allResults.name};

    % Track selector dropdown
    uicontrol(tab, 'Style', 'text', 'String', 'Select Track:', ...
        'Position', [20 790 100 25], 'BackgroundColor', [0.15 0.15 0.18], ...
        'ForegroundColor', 'w', 'FontSize', 11);

    trackSelector = uicontrol(tab, 'Style', 'popupmenu', ...
        'String', trackNames, 'Position', [130 790 300 25], ...
        'FontSize', 10);

    % Weight sliders
    sliders = gobjects(8, 1);
    sliderLabels = gobjects(8, 1);
    weightValues = gobjects(8, 1);

    for d = 1:8
        yPos = 780 - d * 32;
        sliderLabels(d) = uicontrol(tab, 'Style', 'text', ...
            'String', config.dimensionNames{d}, ...
            'Position', [20 yPos 130 22], ...
            'BackgroundColor', [0.15 0.15 0.18], ...
            'ForegroundColor', 'w', 'FontSize', 9, ...
            'HorizontalAlignment', 'right');

        sliders(d) = uicontrol(tab, 'Style', 'slider', ...
            'Min', 0, 'Max', 1, 'Value', config.weights(d), ...
            'Position', [160 yPos 200 22], ...
            'SliderStep', [0.05 0.1]);

        weightValues(d) = uicontrol(tab, 'Style', 'text', ...
            'String', sprintf('%.2f', config.weights(d)), ...
            'Position', [370 yPos 40 22], ...
            'BackgroundColor', [0.15 0.15 0.18], ...
            'ForegroundColor', [0.3 1 0.3], 'FontSize', 9);
    end

    % Axes for heatmap
    ax1 = axes(tab, 'Position', [0.35 0.35 0.6 0.55]);
    ax2 = axes(tab, 'Position', [0.35 0.08 0.6 0.22]);

    % Text summary panel
    summaryText = uicontrol(tab, 'Style', 'text', ...
        'String', '', 'Position', [20 50 380 180], ...
        'BackgroundColor', [0.2 0.2 0.25], ...
        'ForegroundColor', [0.8 0.9 1], 'FontSize', 9, ...
        'HorizontalAlignment', 'left', 'Max', 2);

    % Update button
    uicontrol(tab, 'Style', 'pushbutton', ...
        'String', 'Analyze', 'Position', [20 500 120 35], ...
        'FontSize', 11, 'FontWeight', 'bold', ...
        'BackgroundColor', [0.2 0.6 1], 'ForegroundColor', 'w', ...
        'Callback', @(~,~) updateSingleTrack());

    % Initial display
    updateSingleTrack();

    function updateSingleTrack()
        idx = get(trackSelector, 'Value');
        r = allResults(idx);

        % Get current weights from sliders
        w = zeros(1, 8);
        for dd = 1:8
            w(dd) = get(sliders(dd), 'Value');
            set(weightValues(dd), 'String', sprintf('%.2f', w(dd)));
        end

        cfg = config;
        cfg.weights = w;

        % Recompute hotness with new weights
        [hotness, hotIdx] = computeHotness(r.features, cfg);

        % Draw heatmap
        cla(ax1);
        axes(ax1);
        imagesc(r.timeAxis, 1:8, r.features);
        colormap(ax1, 'hot');
        colorbar(ax1);
        ylabel(ax1, 'Dimension');
        yticks(ax1, 1:8);
        yticklabels(ax1, config.dimensionNames);
        title(ax1, sprintf('Audio Signature: %s', strrep(r.name, '_', ' ')), 'Color', 'w');
        set(ax1, 'YDir', 'normal', 'Color', [0.1 0.1 0.13]);

        % Draw hotness curve
        cla(ax2);
        axes(ax2);
        plot(ax2, r.timeAxis, hotness, 'c-', 'LineWidth', 1.5);
        hold(ax2, 'on');
        thresh = mean(hotness) + cfg.hotThresholdSigma * std(hotness);
        yline(ax2, thresh, 'r--', 'LineWidth', 1);
        if ~isempty(hotIdx)
            vi = hotIdx(hotIdx <= length(r.timeAxis));
            scatter(ax2, r.timeAxis(vi), hotness(vi), 20, 'r', 'filled');
        end
        hold(ax2, 'off');
        xlabel(ax2, 'Time (s)');
        ylabel(ax2, 'Hotness');
        title(ax2, 'Hotness Score', 'Color', 'w');
        set(ax2, 'Color', [0.1 0.1 0.13], 'XColor', 'w', 'YColor', 'w');
        set(ax1, 'XColor', 'w', 'YColor', 'w');

        % Update summary
        summaryStr = sprintf(['Track: %s\n' ...
            'Segments: %d | Hot: %d (%.0f%%)\n' ...
            'Duration: %.1f sec\n\n' ...
            'Dominant Dimensions:\n'], ...
            strrep(r.name, '_', ' '), ...
            size(r.features, 2), length(hotIdx), ...
            100 * length(hotIdx) / size(r.features, 2), ...
            r.timeAxis(end));

        meanFeat = mean(r.features, 2);
        [~, sortDims] = sort(meanFeat, 'descend');
        for dd = 1:3
            summaryStr = sprintf('%s  %d. %s (%.2f)\n', ...
                summaryStr, dd, config.dimensionNames{sortDims(dd)}, meanFeat(sortDims(dd)));
        end
        set(summaryText, 'String', summaryStr);
    end
end

function buildComparisonTab(tab, allResults, ~)
    N = length(allResults);
    featureCell = {allResults.features};
    hotIdxCell = {allResults.hotIdx};
    names = {allResults.name};

    simMatrix = buildSimilarityMatrix(featureCell, hotIdxCell);

    ax = axes(tab, 'Position', [0.1 0.1 0.8 0.8]);
    imagesc(ax, simMatrix);
    colormap(ax, 'parula');
    colorbar(ax);
    caxis(ax, [0 1]);

    shortNames = cellfun(@(n) strrep(strrep(n, 'demo_track_', ''), '_', ' '), ...
        names, 'UniformOutput', false);
    xticks(ax, 1:N);
    yticks(ax, 1:N);
    xticklabels(ax, shortNames);
    yticklabels(ax, shortNames);
    xtickangle(ax, 45);
    title(ax, 'Cross-Song Similarity Matrix', 'Color', 'w', 'FontSize', 14);
    set(ax, 'YDir', 'normal', 'Color', [0.1 0.1 0.13], 'XColor', 'w', 'YColor', 'w');

    % Annotate cells
    for i = 1:N
        for j = 1:N
            val = simMatrix(i, j);
            tc = 'k';
            if val < 0.5; tc = 'w'; end
            text(ax, j, i, sprintf('%.2f', val), ...
                'HorizontalAlignment', 'center', ...
                'Color', tc, 'FontSize', 7, 'FontWeight', 'bold');
        end
    end
end

function buildBlendTab(tab, allResults, config)
    blends = rankBlends(allResults, config);

    % Create table data
    numShow = min(20, length(blends));
    tableData = cell(numShow, 6);
    for i = 1:numShow
        b = blends(i);
        tableData{i, 1} = i;
        tableData{i, 2} = strrep(b.trackA, '_', ' ');
        tableData{i, 3} = strrep(b.trackB, '_', ' ');
        tableData{i, 4} = sprintf('%.3f', b.score);
        tableData{i, 5} = sprintf('%d:%05.2f', floor(b.timeA/60), mod(b.timeA, 60));
        tableData{i, 6} = sprintf('%d:%05.2f', floor(b.timeB/60), mod(b.timeB, 60));
    end

    uitable(tab, 'Data', tableData, ...
        'ColumnName', {'Rank', 'Track A', 'Track B', 'Score', 'Time A', 'Time B'}, ...
        'Position', [30 30 1340 750], ...
        'FontSize', 10, ...
        'ColumnWidth', {50, 350, 350, 80, 100, 100}, ...
        'RowName', []);

    uicontrol(tab, 'Style', 'text', ...
        'String', sprintf('DJ Blend Recommendations (%d pairs analyzed)', length(blends)), ...
        'Position', [30 790 600 30], ...
        'BackgroundColor', [0.15 0.15 0.18], ...
        'ForegroundColor', [0.3 1 0.3], ...
        'FontSize', 13, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'left');
end

function buildMetadataTab(tab, config)
    metaPath = fullfile(config.metadataDir, 'demo_tracks.json');
    if ~isfile(metaPath)
        uicontrol(tab, 'Style', 'text', ...
            'String', 'No metadata file found. Run generateDemoDataset first.', ...
            'Position', [50 400 400 30], ...
            'BackgroundColor', [0.15 0.15 0.18], ...
            'ForegroundColor', 'w', 'FontSize', 12);
        return;
    end

    metadata = loadMetadata(metaPath);

    numTracks = length(metadata);
    tableData = cell(numTracks, 7);
    for i = 1:numTracks
        m = metadata(i);
        tableData{i, 1} = m.title;
        tableData{i, 2} = m.artist;
        tableData{i, 3} = m.genre;
        tableData{i, 4} = m.origin;
        tableData{i, 5} = num2str(m.bpm);
        tableData{i, 6} = m.key;
        if iscell(m.songwriters)
            tableData{i, 7} = strjoin(m.songwriters, ', ');
        else
            tableData{i, 7} = m.songwriters;
        end
    end

    uitable(tab, 'Data', tableData, ...
        'ColumnName', {'Title', 'Artist', 'Genre', 'Origin', 'BPM', 'Key', 'Songwriters'}, ...
        'Position', [30 30 1340 750], ...
        'FontSize', 10, ...
        'ColumnWidth', {250, 150, 150, 120, 60, 60, 250}, ...
        'RowName', []);

    uicontrol(tab, 'Style', 'text', ...
        'String', 'Track Metadata & Cultural Context', ...
        'Position', [30 790 400 30], ...
        'BackgroundColor', [0.15 0.15 0.18], ...
        'ForegroundColor', [0.3 1 0.3], ...
        'FontSize', 13, 'FontWeight', 'bold', ...
        'HorizontalAlignment', 'left');
end

function allResults = analyzeAllDemoTracks(config)
    demoDir = config.demoDir;
    if ~isfolder(demoDir) || isempty(dir(fullfile(demoDir, '*.wav')))
        generateDemoDataset(config);
    end

    demoFiles = dir(fullfile(demoDir, '*.wav'));
    numTracks = length(demoFiles);
    allResults = struct();

    for i = 1:numTracks
        filePath = fullfile(demoFiles(i).folder, demoFiles(i).name);
        [signal, fs] = audioLoad(filePath, config);
        [segments, timeAxis] = windowSegment(signal, fs, config);
        features = extractFeatures(segments, fs, config);
        [hotness, hotIdx] = computeHotness(features, config);

        allResults(i).name = demoFiles(i).name;
        allResults(i).filePath = filePath;
        allResults(i).features = features;
        allResults(i).timeAxis = timeAxis;
        allResults(i).hotness = hotness;
        allResults(i).hotIdx = hotIdx;
        allResults(i).signal = signal;
        allResults(i).fs = fs;
    end
end
