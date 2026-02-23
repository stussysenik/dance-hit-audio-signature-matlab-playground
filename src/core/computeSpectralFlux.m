function spectralFlux = computeSpectralFlux(segments, fs, config)
% COMPUTESPECTRALFLUX Compute frame-to-frame spectral change (Dimension 5).
%   spectralFlux = computeSpectralFlux(segments, fs, config)
%
%   Measures the magnitude of spectral change between consecutive
%   short-time frames within each segment.

    if nargin < 3
        config = AnalysisConfig();
    end

    numSegments = size(segments, 2);
    winLen = size(segments, 1);
    spectralFlux = zeros(1, numSegments);

    for i = 1:numSegments
        seg = segments(:, i);

        frameLen = min(512, winLen);
        hop = round(frameLen / 2);
        numFrames = floor((winLen - frameLen) / hop) + 1;

        fluxValues = zeros(max(0, numFrames - 1), 1);
        prevSpec = [];

        for f = 1:numFrames
            startIdx = (f-1) * hop + 1;
            endIdx = startIdx + frameLen - 1;
            frame = seg(startIdx:endIdx) .* hann(frameLen);
            spec = abs(fft(frame));
            spec = spec(1:frameLen/2+1);

            % Normalize spectrum
            spec = spec / (norm(spec) + eps);

            if ~isempty(prevSpec)
                % Euclidean distance between consecutive spectra
                fluxValues(f-1) = norm(spec - prevSpec);
            end
            prevSpec = spec;
        end

        % Mean spectral flux across the segment
        if ~isempty(fluxValues)
            spectralFlux(i) = mean(fluxValues);
        end
    end
end
