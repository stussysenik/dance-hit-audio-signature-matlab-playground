function vocalPresence = computeVocalPresence(segments, fs, config)
% COMPUTEVOCALPRESENCE Estimate vocal presence in 300-3400 Hz band (Dimension 3).
%   vocalPresence = computeVocalPresence(segments, fs, config)
%
%   Combines spectral centroid position relative to vocal range with
%   harmonic-to-noise ratio to estimate vocal content.

    if nargin < 3
        config = AnalysisConfig();
    end

    numSegments = size(segments, 2);
    winLen = size(segments, 1);
    vocalPresence = zeros(1, numSegments);

    freqs = (0:winLen/2) * fs / winLen;

    for i = 1:numSegments
        seg = segments(:, i) .* hann(winLen);
        spec = abs(fft(seg));
        spec = spec(1:winLen/2+1);

        % Vocal band energy (300-3400 Hz)
        vocalMask = freqs >= config.vocalRange(1) & freqs <= config.vocalRange(2);
        vocalEnergy = sum(spec(vocalMask).^2);
        totalEnergy = sum(spec.^2) + eps;
        bandRatio = vocalEnergy / totalEnergy;

        % Spectral centroid in vocal band
        if vocalEnergy > 0
            vocalFreqs = freqs(vocalMask);
            vocalSpec = spec(vocalMask);
            centroid = sum(vocalFreqs .* vocalSpec') / (sum(vocalSpec) + eps);
            % Normalize centroid to [0,1] within vocal range
            centroidNorm = (centroid - config.vocalRange(1)) / (config.vocalRange(2) - config.vocalRange(1));
            centroidNorm = max(0, min(1, centroidNorm));
        else
            centroidNorm = 0;
        end

        % Harmonic-to-noise ratio estimate
        hnr = estimateHNR(seg, fs);

        % Combine: band ratio (40%), centroid position (30%), HNR (30%)
        vocalPresence(i) = 0.4 * bandRatio + 0.3 * centroidNorm + 0.3 * hnr;
    end
end

function hnr = estimateHNR(segment, fs)
% ESTIMATEHNR Simple harmonic-to-noise ratio estimate via autocorrelation.
    acf = xcorr(segment, 'coeff');
    mid = ceil(length(acf) / 2);

    % Search for first peak after the origin (pitch period)
    minLag = round(fs / 3400);  % Highest vocal pitch
    maxLag = round(fs / 80);    % Lowest vocal pitch

    if mid + maxLag > length(acf)
        maxLag = length(acf) - mid;
    end

    if maxLag <= minLag
        hnr = 0;
        return;
    end

    searchRange = acf(mid + minLag : mid + maxLag);
    peakVal = max(searchRange);

    % HNR = peak / (1 - peak), normalized to [0,1]
    if peakVal > 0
        hnr = max(0, min(1, peakVal));
    else
        hnr = 0;
    end
end
