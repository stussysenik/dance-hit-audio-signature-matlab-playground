function [segments, timeAxis] = windowSegment(signal, fs, config)
% WINDOWSEGMENT Segment audio signal into overlapping windows.
%   [segments, timeAxis] = windowSegment(signal, fs) segments the mono
%   signal into windows of 500ms with 50% overlap (default).
%
%   [segments, timeAxis] = windowSegment(signal, fs, config) uses custom config.
%
%   Returns:
%     segments - matrix of size [windowSamples x numSegments]
%     timeAxis - center time of each segment in seconds

    if nargin < 3
        config = AnalysisConfig();
    end

    winLen = config.windowSamples;
    hopLen = config.hopSamples;
    sigLen = length(signal);

    % Calculate number of complete segments
    numSegments = floor((sigLen - winLen) / hopLen) + 1;

    if numSegments < 1
        error('windowSegment:TooShort', ...
            'Signal too short (%d samples) for window size (%d samples).', ...
            sigLen, winLen);
    end

    % Pre-allocate
    segments = zeros(winLen, numSegments);
    timeAxis = zeros(1, numSegments);

    for i = 1:numSegments
        startIdx = (i - 1) * hopLen + 1;
        endIdx = startIdx + winLen - 1;
        segments(:, i) = signal(startIdx:endIdx);
        timeAxis(i) = (startIdx + endIdx) / 2 / fs;  % Center time
    end
end
