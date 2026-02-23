function beatStrength = computeBeatStrength(segments, fs, config)
% COMPUTEBEATSTRENGTH Measure beat strength via onset envelope peaks (Dimension 4).
%   beatStrength = computeBeatStrength(segments, fs, config)
%
%   Computes onset detection function and measures peak amplitude
%   of the onset envelope per segment.

    if nargin < 3
        config = AnalysisConfig();
    end

    numSegments = size(segments, 2);
    winLen = size(segments, 1);
    beatStrength = zeros(1, numSegments);

    for i = 1:numSegments
        seg = segments(:, i);

        % Compute spectral flux onset function
        frameLen = min(512, winLen);
        hop = round(frameLen / 2);
        numFrames = floor((winLen - frameLen) / hop) + 1;

        onsetFunc = zeros(numFrames, 1);
        prevSpec = zeros(frameLen/2 + 1, 1);

        for f = 1:numFrames
            startIdx = (f-1) * hop + 1;
            endIdx = startIdx + frameLen - 1;
            frame = seg(startIdx:endIdx) .* hann(frameLen);
            spec = abs(fft(frame));
            spec = spec(1:frameLen/2+1);

            % Half-wave rectified spectral flux
            onsetFunc(f) = sum(max(0, spec - prevSpec));
            prevSpec = spec;
        end

        % Beat strength = peak amplitude of onset function
        if ~isempty(onsetFunc)
            beatStrength(i) = max(onsetFunc);
        end
    end
end
