function harmonicRichness = computeHarmonicRichness(segments, fs, config)
% COMPUTEHARMONICRICHNESS Compute harmonic richness (Dimension 7).
%   harmonicRichness = computeHarmonicRichness(segments, fs, config)
%
%   Combines the count of significant harmonic peaks with spectral
%   flatness (low flatness = more tonal/harmonic content).

    if nargin < 3
        config = AnalysisConfig();
    end

    numSegments = size(segments, 2);
    winLen = size(segments, 1);
    harmonicRichness = zeros(1, numSegments);

    for i = 1:numSegments
        seg = segments(:, i) .* hann(winLen);
        spec = abs(fft(seg));
        spec = spec(1:winLen/2+1);
        freqs = (0:winLen/2) * fs / winLen;

        % Focus on musical range (50-8000 Hz)
        musicalMask = freqs >= 50 & freqs <= 8000;
        musSpec = spec(musicalMask);

        if isempty(musSpec) || max(musSpec) < eps
            harmonicRichness(i) = 0;
            continue;
        end

        % Count significant peaks
        threshold = 0.1 * max(musSpec);
        [~, locs] = findpeaks(musSpec, 'MinPeakHeight', threshold, ...
                              'MinPeakDistance', round(length(musSpec)/50));
        numPeaks = length(locs);
        % Normalize: typical range 0-30 peaks
        peakScore = min(1, numPeaks / 20);

        % Spectral flatness: geometric mean / arithmetic mean
        musSpecPos = musSpec(musSpec > 0);
        if ~isempty(musSpecPos)
            geoMean = exp(mean(log(musSpecPos + eps)));
            ariMean = mean(musSpecPos);
            flatness = geoMean / (ariMean + eps);
            % Invert: low flatness = high harmonic content
            tonality = 1 - min(1, flatness);
        else
            tonality = 0;
        end

        % Combine: 50% peak count + 50% tonality
        harmonicRichness(i) = 0.5 * peakScore + 0.5 * tonality;
    end
end
