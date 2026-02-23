function asciiStr = asciiHeatmap(features, timeAxis, hotIdx, config)
% ASCIIHEATMAP Display text-based heatmap in command window.
%   asciiStr = asciiHeatmap(features, timeAxis, hotIdx, config)
%
%   Uses Unicode block characters to render a compact heatmap.
%   Follows 60/30/10 rule in text:
%     60% — Whitespace, structure, labels
%     30% — Data intensity blocks (░▒▓█)
%     10% — HOT markers (*), dimension highlights

    if nargin < 4
        config = AnalysisConfig();
    end

    blocks = {' ', char(9617), char(9618), char(9619), char(9608)};  % ░▒▓█
    hotMarker = '*';

    numDims = size(features, 1);
    numSegs = size(features, 2);

    % Downsample if too many segments for terminal width
    maxCols = 60;
    if numSegs > maxCols
        step = ceil(numSegs / maxCols);
        colIdx = 1:step:numSegs;
    else
        colIdx = 1:numSegs;
    end
    displaySegs = length(colIdx);

    % Dimension labels and their psychology tags
    dimLabels = config.dimensionNames;
    psych = {'trust','power','warmth','impact','change','depth','organic','drama'};
    maxLabelLen = max(cellfun(@length, dimLabels));

    % ---- Header ----
    fprintf('\n');
    fprintf('  %s  AUDIO SIGNATURE HEATMAP\n', repmat('=', 1, 36));
    fprintf('  %d dimensions x %d segments (%.1fs duration)\n\n', ...
        numDims, numSegs, timeAxis(end));

    % Time axis markers
    fprintf('%s  ', pad('', maxLabelLen));
    for c = 1:displaySegs
        t = timeAxis(colIdx(c));
        if mod(c, 10) == 1
            tStr = sprintf('%.0f', t);
            fprintf('%s', tStr(1));
        else
            fprintf(' ');
        end
    end
    fprintf('  Time(s)\n');

    % Hot segment indicator row (10% accent)
    fprintf('%s  ', pad('HOT', maxLabelLen));
    hotSet = ismember(colIdx, hotIdx);
    for c = 1:displaySegs
        if hotSet(c)
            fprintf('%s', hotMarker);
        else
            fprintf(' ');
        end
    end
    fprintf('\n');

    fprintf('%s\n', repmat('-', 1, maxLabelLen + 2 + displaySegs));

    % Dimension rows (30% data)
    for d = 1:numDims
        label = pad(dimLabels{d}, maxLabelLen);
        fprintf('%s |', label);

        for c = 1:displaySegs
            val = features(d, colIdx(c));
            blockIdx = min(5, max(1, ceil(val * 5)));
            if val < 0.01
                blockIdx = 1;
            end
            fprintf('%s', blocks{blockIdx});
        end
        fprintf('| %s\n', psych{d});
    end

    fprintf('%s\n', repmat('-', 1, maxLabelLen + 2 + displaySegs));

    % ---- Legend (60% — clear communication) ----
    fprintf('\n');
    fprintf('  INTENSITY SCALE:\n');
    fprintf('    '' '' = 0.00-0.20 (silent)     %s = 0.20-0.40 (low)\n', blocks{2});
    fprintf('    %s = 0.40-0.60 (moderate)   %s = 0.60-0.80 (high)\n', blocks{3}, blocks{4});
    fprintf('    %s = 0.80-1.00 (peak)       *  = HOT segment\n', blocks{5});
    fprintf('\n');

    % Dimension color key (maps to color psychology in GUI)
    fprintf('  DIMENSION KEY (color psychology in GUI):\n');
    fprintf('    1. BPM Stability   [Steel Blue]    Trust, reliability\n');
    fprintf('    2. Bass Energy     [Deep Crimson]   Power, primal force\n');
    fprintf('    3. Vocal Presence  [Warm Amber]     Human warmth, emotion\n');
    fprintf('    4. Beat Strength   [Burnt Orange]   Impact, urgency\n');
    fprintf('    5. Spectral Flux   [Electric Cyan]  Change, movement\n');
    fprintf('    6. Rhythm Complex  [Deep Purple]    Sophistication, depth\n');
    fprintf('    7. Harmonic Rich   [Emerald Green]  Organic fullness\n');
    fprintf('    8. Dynamic Range   [Hot Magenta]    Contrast, drama\n');
    fprintf('\n');

    if nargout > 0
        asciiStr = 'Printed to console';
    end
end
