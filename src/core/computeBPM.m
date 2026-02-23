function [bpmStability, globalBPM] = computeBPM(segments, fs, config)
% COMPUTEBPM Detect BPM and compute per-segment tempo stability (Dimension 1).
%   [bpmStability, globalBPM] = computeBPM(segments, fs, config)
%
%   Uses autocorrelation-based tempo estimation on the onset envelope.
%   Returns per-segment BPM stability scores in [0, 1] and the global BPM.

    if nargin < 3
        config = AnalysisConfig();
    end

    numSegments = size(segments, 2);
    bpmStability = zeros(1, numSegments);

    % Compute global BPM from the full signal (reconstructed from segments)
    % Use onset envelope for tempo detection
    fullSignal = segments(:);
    onsetEnv = computeOnsetEnvelope(fullSignal, fs, config);

    % Autocorrelation for tempo detection
    minLag = round(fs * 60 / config.bpmRange(2));  % Highest BPM
    maxLag = round(fs * 60 / config.bpmRange(1));  % Lowest BPM

    % Downsample onset envelope for efficiency
    hopSize = round(fs * 0.01);  % 10ms hop
    envDownsampled = onsetEnv(1:hopSize:end);
    minLagD = max(1, round(minLag / hopSize));
    maxLagD = min(length(envDownsampled) - 1, round(maxLag / hopSize));

    acf = xcorr(envDownsampled, maxLagD, 'coeff');
    acf = acf(maxLagD+1:end);  % Keep positive lags only

    % Find tempo peak
    if maxLagD > minLagD && minLagD < length(acf)
        searchRange = acf(minLagD:min(maxLagD, length(acf)));
        [~, peakIdx] = max(searchRange);
        bestLag = (peakIdx + minLagD - 1) * hopSize;
        globalBPM = 60 * fs / bestLag;
    else
        globalBPM = 120;  % Default fallback
    end

    % Per-segment stability: how consistent is the local tempo estimate
    winSamples = size(segments, 1);
    for i = 1:numSegments
        seg = segments(:, i);
        segEnv = abs(seg);  % Simple envelope

        % Short-time autocorrelation
        segMinLag = max(1, round(winSamples * 60 / (config.bpmRange(2) * (winSamples/fs))));
        segMaxLag = min(round(winSamples * 0.8), round(winSamples * 60 / (config.bpmRange(1) * (winSamples/fs))));

        if segMaxLag > segMinLag && segMaxLag < length(segEnv)
            segAcf = xcorr(segEnv, segMaxLag, 'coeff');
            segAcf = segAcf(segMaxLag+1:end);
            range = segAcf(segMinLag:min(segMaxLag, length(segAcf)));
            if ~isempty(range)
                % Stability = peak prominence of autocorrelation
                [peakVal, ~] = max(range);
                bpmStability(i) = max(0, peakVal);
            end
        else
            bpmStability(i) = 0.5;  % Neutral for too-short segments
        end
    end
end

function env = computeOnsetEnvelope(signal, fs, config)
% Compute onset strength envelope via spectral flux
    frameLen = config.fftSize;
    hop = round(frameLen / 4);
    numFrames = floor((length(signal) - frameLen) / hop) + 1;

    env = zeros(length(signal), 1);
    prevSpec = zeros(frameLen/2 + 1, 1);

    for f = 1:numFrames
        startIdx = (f-1) * hop + 1;
        endIdx = startIdx + frameLen - 1;
        if endIdx > length(signal); break; end

        frame = signal(startIdx:endIdx) .* hann(frameLen);
        spec = abs(fft(frame));
        spec = spec(1:frameLen/2+1);

        % Half-wave rectified spectral flux
        flux = sum(max(0, spec - prevSpec));
        env(startIdx:min(endIdx, length(env))) = flux;
        prevSpec = spec;
    end
end
