% QUICKSTART  Zero-experience-friendly launcher for Dance Hit Audio Signature.
%   Generates demo data if needed, analyzes all tracks, and displays results.
%
%   PIPELINE ORDER (verifiable at each step):
%     1. Load data
%     2. Extract features → 8D fingerprint per segment
%     3. Compute hotness → identify HOT timestamps per song
%     4. Display individual song heatmaps (FINGERPRINT + HOTNESS per song)
%     5. Build segment index → O(1) cross-song queries with timestamps
%     6. Cross-song similarity → compare only AFTER segments identified
%     7. DJ blend recommendations → using verified hot timestamps

rootDir = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(rootDir, 'src')));

config = AnalysisConfig();

fprintf('=============================================================\n');
fprintf('  Dance Hit Audio Signature Analyzer - Quickstart\n');
fprintf('=============================================================\n\n');

%% Step 1: Check for demo data
demoDir = config.demoDir;
if ~isfolder(demoDir) || isempty(dir(fullfile(demoDir, '*.wav')))
    fprintf('[1/8] Demo tracks not found. Generating synthetic demo dataset...\n');
    generateDemoDataset(config);
    fprintf('      Done! Created %d demo tracks.\n\n', config.numDemoTracks);
else
    fprintf('[1/8] Demo tracks found in %s\n\n', demoDir);
end

%% Step 2: Load and analyze all demo tracks
fprintf('[2/8] Analyzing demo tracks (feature extraction + hotness)...\n');
demoFiles = dir(fullfile(demoDir, '*.wav'));
numTracks = length(demoFiles);
allResults = struct();

for i = 1:numTracks
    filePath = fullfile(demoFiles(i).folder, demoFiles(i).name);
    fprintf('      [%d/%d] %s ... ', i, numTracks, demoFiles(i).name);

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

    fprintf('OK (%d segments, %d hot)\n', size(features, 2), length(hotIdx));
end
fprintf('\n');

%% Step 3: Show hot segment timestamps for each song (VERIFIABLE OUTPUT)
fprintf('[3/8] Hot segment timestamps per song:\n');
fprintf('      (These timestamps are verifiable against the audio files)\n\n');
for i = 1:numTracks
    displayName = strrep(allResults(i).name, '_', ' ');
    hotIdx = allResults(i).hotIdx;
    timeAxis = allResults(i).timeAxis;
    fprintf('  %s\n', displayName);
    fprintf('  Duration: %.1fs | Segments: %d | Hot: %d (%.0f%%)\n', ...
        timeAxis(end), size(allResults(i).features, 2), length(hotIdx), ...
        100 * length(hotIdx) / size(allResults(i).features, 2));
    if ~isempty(hotIdx)
        validIdx = hotIdx(hotIdx <= length(timeAxis));
        timestamps = arrayfun(@(j) formatTime(timeAxis(j)), validIdx, 'UniformOutput', false);
        fprintf('  Hot timestamps: %s\n', strjoin(timestamps, '  '));
    else
        fprintf('  Hot timestamps: (none)\n');
    end
    fprintf('\n');
end

%% Step 4: Individual song heatmaps (FINGERPRINT + HOTNESS per song)
fprintf('[4/8] Generating individual song heatmaps...\n');
fprintf('      Each figure shows: FINGERPRINT (8D grouped) + HOTNESS (combined score)\n');
for i = 1:numTracks
    plotHeatmap(allResults(i).features, allResults(i).timeAxis, ...
                allResults(i).hotness, allResults(i).hotIdx, ...
                allResults(i).name, config);
end
fprintf('      %d individual heatmaps displayed.\n\n', numTracks);

%% Step 5: ASCII heatmaps for all tracks
fprintf('[5/8] ASCII Heatmaps:\n');
for i = 1:numTracks
    fprintf('\n  === %s ===\n', strrep(allResults(i).name, '_', ' '));
    asciiHeatmap(allResults(i).features, allResults(i).timeAxis, ...
                 allResults(i).hotIdx, config);
end
fprintf('\n');

%% Step 6: Build O(1) Segment Index (with verifiable timestamps)
fprintf('[6/8] Building O(1) segment index for cross-song queries...\n');
segIndex = SegmentIndex(allResults, config);
segIndex.printStats();

% Top-10 hottest segments globally — WITH TIMESTAMPS
fprintf('  ┌─────────────────────────────────────────────────────────────┐\n');
fprintf('  │  TOP 10 HOTTEST SEGMENTS (across all songs)                │\n');
fprintf('  │  Verify: each timestamp maps to a hot peak in the heatmap  │\n');
fprintf('  ├─────────────────────────────────────────────────────────────┤\n');
fprintf('  %-4s  %-30s  %-10s  %-8s\n', 'Rank', 'Song', 'Time', 'Hotness');
fprintf('  %s\n', repmat('-', 1, 56));
hotResults = segIndex.queryHot(10);
for i = 1:length(hotResults)
    r = hotResults(i);
    fprintf('  %-4d  %-30s  %-10s  %.4f\n', ...
        i, strrep(r.songName, '_', ' '), formatTime(r.time), r.hotness);
end
fprintf('  └─────────────────────────────────────────────────────────────┘\n\n');

% Segments similar to song 1, segment 10
querySeg = min(10, size(allResults(1).features, 2));
fprintf('  Segments similar to %s @ %s:\n', ...
    strrep(allResults(1).name, '_', ' '), formatTime(allResults(1).timeAxis(querySeg)));
simResults = segIndex.querySimilarToSegment(1, querySeg, 5);
fprintf('  %-4s  %-30s  %-10s  %-8s\n', 'Rank', 'Song', 'Time', 'Hotness');
fprintf('  %s\n', repmat('-', 1, 56));
for i = 1:length(simResults)
    r = simResults(i);
    fprintf('  %-4d  %-30s  %-10s  %.4f\n', ...
        i, strrep(r.songName, '_', ' '), formatTime(r.time), r.hotness);
end
fprintf('\n');

%% Step 7: Cross-song similarity (AFTER segments identified)
fprintf('[7/8] Building similarity matrix across %d tracks...\n', numTracks);
fprintf('      (Comparing hot-segment feature vectors — segments found in steps 3-6)\n');
featureCell = {allResults.features};
hotIdxCell = {allResults.hotIdx};
names = {allResults.name};
simMatrix = buildSimilarityMatrix(featureCell, hotIdxCell);
plotCrissCross(simMatrix, names);
fprintf('      Similarity matrix displayed.\n\n');

%% Step 8: DJ Blend recommendations (using verified timestamps)
fprintf('[8/8] Computing DJ blend recommendations...\n');
fprintf('      (Each blend pair references specific timestamps you can verify)\n');
blends = rankBlends(allResults, config);
fprintf('\n  Top 10 Blend Recommendations:\n');
fprintf('  %-4s  %-25s  %-25s  %-8s  %-10s  %-10s\n', ...
    'Rank', 'Track A', 'Track B', 'Score', 'Time A', 'Time B');
fprintf('  %s\n', repmat('-', 1, 88));
for i = 1:min(10, length(blends))
    b = blends(i);
    fprintf('  %-4d  %-25s  %-25s  %-8.3f  %-10s  %-10s\n', ...
        i, b.trackA, b.trackB, b.score, ...
        formatTime(b.timeA), formatTime(b.timeB));
end
fprintf('\n');

fprintf('=============================================================\n');
fprintf('  Quickstart complete! You can now:\n');
fprintf('  - Run launchGUI() for the interactive GUI\n');
fprintf('  - Run generateHTMLReport(allResults, config) for D3.js report\n');
fprintf('  - Run startServer(config) for the web API\n');
fprintf('  - Use segIndex.query(featureVec, K) for O(1) segment lookup\n');
fprintf('  - Use segIndex.queryHot(K) for top-K hottest globally\n');
fprintf('  - Use segIndex.querySimilarToSegment(songIdx, segIdx, K)\n');
fprintf('=============================================================\n');

function tStr = formatTime(seconds)
    m = floor(seconds / 60);
    s = mod(seconds, 60);
    tStr = sprintf('%d:%05.2f', m, s);
end
