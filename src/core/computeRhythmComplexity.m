function rhythmComplexity = computeRhythmComplexity(segments, fs, config)
% COMPUTERHYTHMCOMPLEXITY Compute rhythm complexity (Dimension 6).
%   rhythmComplexity = computeRhythmComplexity(segments, fs, config)
%
%   Combines onset density (onsets per second) with a syncopation index
%   derived from onset timing relative to the beat grid.

    if nargin < 3
        config = AnalysisConfig();
    end

    numSegments = size(segments, 2);
    winLen = size(segments, 1);
    rhythmComplexity = zeros(1, numSegments);
    segDuration = winLen / fs;

    for i = 1:numSegments
        seg = segments(:, i);

        % Detect onsets via amplitude envelope derivative
        env = abs(seg);
        % Smooth envelope
        smoothLen = round(fs * 0.01);  % 10ms smoothing
        if smoothLen > 1
            kernel = ones(smoothLen, 1) / smoothLen;
            env = conv(env, kernel, 'same');
        end

        % Onset = positive derivative peaks
        envDiff = diff(env);
        envDiff(envDiff < 0) = 0;

        % Adaptive threshold
        threshold = mean(envDiff) + 0.5 * std(envDiff);
        onsetMask = envDiff > threshold;

        % Find onset positions
        onsetPositions = find(diff([0; onsetMask]) == 1);

        % Onset density (onsets per second)
        onsetDensity = length(onsetPositions) / segDuration;
        % Normalize: typical range 0-20 onsets/sec
        densityNorm = min(1, onsetDensity / 20);

        % Syncopation index: variance of inter-onset intervals
        if length(onsetPositions) > 2
            ioi = diff(onsetPositions) / fs;  % Inter-onset intervals in seconds
            ioiCV = std(ioi) / (mean(ioi) + eps);  % Coefficient of variation
            syncopation = min(1, ioiCV);  % High CV = complex rhythm
        else
            syncopation = 0;
        end

        % Combine: 50% density + 50% syncopation
        rhythmComplexity(i) = 0.5 * densityNorm + 0.5 * syncopation;
    end
end
